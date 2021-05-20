--  客户端处理
--  jack
local cjson  = require "cjson"
local center = require "center"
local common = require "common"
local server = require "resty.websocket.server"
local rnd    = require "rnd"
local chunk = 16384  
local table_insert = table.insert  
local table_concat = table.concat 
local mp = require 'MessagePack'
local zlib = require('ffi-zlib')  

ngx.shared.globalunit:incr("online",1,0)

local d = center.getClientDispatcher()
local wb, err = server:new{
    timeout = 300000,
    max_payload_len = 65535
}

local function islocal(str)
    local o1,o2,o3,o4 = str:match("(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)" )
    o1=tonumber(o1)
    o2=tonumber(o2)
    o3=tonumber(o3)
    o4=tonumber(o4)
    ngx.log(ngx.INFO,"o1="..o1)
    if o1==127 or o1==10 or o1==172 or o1==192 then
        return true
    end
    return false
end


if not wb then
    ngx.log(ngx.ERR, "failed to new websocket: ", err)
    return ngx.exit(444)
end



local function getip( )
    local myIP = ngx.req.get_headers()["X-Real-IP"]
    if myIP == nil then
        myIP = ngx.req.get_headers()["x_forwarded_for"]
    end
    if myIP == nil then
        myIP = ngx.var.remote_addr
    end
    return myIP
end


local myIP = getip()
local invalid = ngx.shared.globalunit:get('invalid_server')
if invalid and not islocal(myIP) then
    return ngx.exit(444)
end
ngx.log(ngx.INFO,"IP地址是:",myIP..'___'..tostring(invalid),"--",islocal(myIP))
--玩家的uid
local closeFlag = false
local sessionId = d:getSessionId()

local clientSessionId = common.server_id..common.DEC_HEX(sessionId)
local sema = d:getSemaphore(sessionId)

local clienthandler = require "clienthandler"
local ctx={
    closeFlag=false,
    sessionId=sessionId,
    sema = sema,
    wb = wb,
    ip=myIP,
}
clienthandler = clienthandler.new(ctx)
clienthandler.IP = myIP

local function push_thread_function()
    while ctx.closeFlag == false do
        local ok,err = sema:wait(300)
        if ok then
            local messages = d:getMessage(sessionId) or {}
        if #messages > 0 then

               -- local timerhelper = require "time_helper"
                --local mili = timerhelper.current_time_millis()

                for i,message in ipairs(messages) do
                    -- ngx.log(ngx.INFO,"----------->从服务端接收的数据:",cjson.encode(message))
                    local cmdname = string.format("CMD")
                    local f = clienthandler[cmdname]
                    if f then
                        f(clienthandler,message)
                    end
                end
            end
        else
            -- ngx.log(ngx.ERR,'timeout')
        end
        ngx.log(ngx.DEBUG,'push_thread_function close',cjson.encode(ctx.closeFlag))

        if ( ctx.closeFlag ) then
            d:destory(sessionId);
            wb:send_close()
            break
        end
    end
end

local s = os.time()
local push_thread = ngx.thread.spawn(push_thread_function)

while true do
    local data, typ, err = wb:recv_frame()
    ngx.log(ngx.ERR,err,'========',wb.fatal)
    if wb.fatal then
        ctx.closeFlag = true;
        sema:post(1);
        break
    end

    if not data then
        local bytes, err = wb:send_ping()
        ngx.log(ngx.DEBUG, 'send ping: ', err)
        if not bytes then
            ngx.log(ngx.ERR, 'failed to send ping: ', err)
            ctx.closeFlag = true;
            sema:post(1);
            break
        end
    elseif typ == 'close' then
        ctx.closeFlag = true;
        ngx.log(ngx.DEBUG,'closing WS,sessionId:'..clientSessionId)
        sema:post(1);
        break
    elseif typ == 'ping' then
        local bytes, err = wb:send_pong()
        if not bytes then
            ngx.log(ngx.ERR, 'failed to send pong: ', err)
            ctx.closeFlag = true;
            sema:post(1);
            break
        end
    elseif typ == 'pong' then
        ngx.log(ngx.DEBUG, 'client ponged')
        
    elseif typ == 'text' then
        ISTEXT=true
        local ok,message=pcall(cjson.decode,data)
        if ok then
            if message.m~='heartbeat' then
                ngx.log(ngx.INFO,"----------->text 从客户端接收的数据:",cjson.encode(message))
            end
            local cmdname = string.format("CMD")
            message.src = 'client'
            local f = clienthandler[cmdname]
            if f then
                f(clienthandler,message)
            else
                ngx.log(ngx.INFO,data)
            end
        end

    elseif typ == 'binary' then
        ISBINARY=true

        local compressed = data 
        local output_table = {}  
        local output = function(data1)  
            table_insert(output_table, data1)  
        end  

        local count = 0  
        local input = function(bufsize)  
            local start = count > 0 and bufsize*count or 1  
            local data1 = compressed:sub(start, (bufsize*(count+1)-1) )  
            count = count + 1  
            return data1 
        end  
 
        local ok, err = zlib.inflateGzip(input, output, chunk)  
        if not ok then  
            for i=1,string.len(compressed) do
                ngx.log(ngx.INFO,string.byte(compressed,i,i))
            end
            ngx.log(ngx.INFO,"err",err,"_",compressed)
        end  
        
        -- local ok,message=pcall(cjson.decode,data)
        if ok then
            local output_data = table_concat(output_table,'')  
            local ok1,message=pcall(cjson.decode,output_data)
            if ok1 then
                if message.m~='heartbeat' then
                    ngx.log(ngx.INFO,"-----------> binary 从客户端接收的数据:",cjson.encode(message))
                end
                local cmdname = string.format("CMD")
                message.src = 'client'
                local f = clienthandler[cmdname]
                if f then
                    f(clienthandler,message)
                else
                    ngx.log(ngx.INFO,data)
                end
            end
        end

    elseif typ == 'continuation' then
        -- ignore
        ngx.log(ngx.DEBUG, 'continuation')
    end
end

ngx.thread.wait(push_thread)
ngx.log(ngx.DEBUG, 'websocket-close')
ngx.shared.globalunit:incr("online",-1)

clienthandler:offline()
wb:send_close()

