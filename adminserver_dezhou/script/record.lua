local cjson          = require "cjson"
local string         = require "string"
local table_new      = require "table.new"
local table          = require "table"
local jwt            = require "resty.jwt"
local mongo          = require "resty.mongol"
local redis          = require "redis"
local keysutils      = require "keysutils"
local uuid           = require "resty.uuid"
local config         = require "config"
local utils          = require "utils"
local redislock      = require "lock"
local str           = require "resty.string"
local http          = require "resty.http"
local sha1          = require "resty.sha1"
local userlogic     = require "userlogic"
local usermodel     = require "usermodel"
local sqlquery      = require 'sqlquery'
local genid         = require 'genid'

require "functions"

local _M = {}
local CMD = {}
-- 查询记录

local function getplayerinfo(uid,red)
    local u     = userlogic.loaduser(red,uid)
    return u:toparam()
end

function CMD.jiluchongzhi(red)
    local arg=ngx.req.get_uri_args()
    local uid = arg.uid
    local count = arg.count
    local chongzhiuid = arg.chongzhiuid

    local result = {}
    local data = {}

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if err then
        result.code = 10002
        result.data = '参数或者密码错误10002'
        return result
    end

        -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("chongzhi")


    local id_key = string.format("%s-%s",chongzhiuid,genid.gen())
    local ok2,ret = col1:insert({{_id=id_key,uid=chongzhiuid,count=count,typ='coin',game='dezhou',timestamp=os.time()}})
    if not ok2 then
        result.code = 10006
        result.data = '充值失败10006'
        ngx.say(cjson.encode(result))
        return
    end

    result.code=20000
    result.data = '充值成功' 
    return result  
    -- ngx.say(cjson.encode(result))
end

-- 充值记录
function CMD.getchongzhirecord(red)
    local arg=ngx.req.get_uri_args()
    local name = arg.name
    local uid = arg.uid

    local result = {}

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if err then
        result.code = 10002
        result.data = '参数或者密码错误10002'
        return result
    end

    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("chongzhi")

    local data = {}
    -- local cursor = col1:find({uid={['$gt']=1}})
    local cursor = col1:find({game='dezhou'})
    local ret,err = cursor:sort({timestamp=-1})
    if not err then
        for index, item in pairs(ret) do
            if item['uid'] then
                info = getplayerinfo(item['uid'],red)
                item['name'] = info['name']
                table.insert(data, item)
            end
        end
    end

    result.code = 20000
    result.data = data
    return result
end




function CMD.getlunpanrecord(red)
    local arg=ngx.req.get_uri_args()    
    local result = {}
    local data = {}
    

    table.dumpdebug(arg, '_____________>>>>>> lunpan paramsa::::::::')
    
    if arg.st and arg.et and arg.st ~= '' and arg.et ~= '' and arg.st ~= '0' and arg.et ~= '0' then
        local ok1,st = pcall(tonumber,arg.st)
        local ok2,et = pcall(tonumber,arg.et)
        if not ok1 or not ok2 then
            result.code=10001
            result.data = '参数错误10001'
            return result
        end

        -- 有时间参数
        if arg.fuid and arg.fuid ~= '' then
            local ok, fuid = pcall(tonumber, arg.fuid)
            if not ok then
                result.code=10002
                result.data = '参数错误10002'
                return result
            end
            -- uid+time
            table.dumpdebug("uid+ time")
            data = timeforuidlunpanrecord(red,st,et,fuid)
        else
            -- time
            table.dumpdebug(" ___time")
            data = timeforlunpanrecord(red,st,et)
        end
    elseif arg.fuid then
        -- 只有UID 参数
        local ok, fuid = pcall(tonumber, arg.fuid)
        if not ok then
            result.code=10003
            result.data = '参数错误10003'
            return result
        end
        -- uid
        table.dumpdebug("uid+ ")
        data = uidlunpanrecord(red,fuid)
    else
        -- 没参,全所有 all
        table.dumpdebug("alll____")
        data = getalllunpanrecord(red)
    end
    -- 统计数据 
    result.tongji = getlunpantongji(red)
    result.code = 20000
    result.data = data
    return result
end

function _M.invoke(name)
    local method = ngx.req.get_method()
    if string.upper(method) == 'OPTIONS' then
        table.dumpdebug(name ,"OPTIONS OPTIONS OPTIONS OPTIONS:::: ")
        ngx.say('ok')
        return
    end
    local arg=ngx.req.get_uri_args()
    ngx.log(ngx.DEBUG,'=================================> function:',name,',data:',cjson.encode(arg))

    local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
    ngx.header['Content-Type'] = 'application/json; charset=utf-8'

    if arg.uid then
        local mainkey = keysutils.get_user_main_key(arg.uid)
        local f = CMD[name]
        if not TEST then
            local l = redislock.new(rediscli,"lock:"..mainkey,10)
            if l:lock() then
                local result = f(rediscli)
                if result.code and result.code~=0 then
                    -- result.errmsg=config.get('errmsg','e'..result.code)
                end
                ngx.say(cjson.encode(result))
                l:unlock()
            end
        else
            local result = f(rediscli)
            if result.code and result.code~=0 then
                -- result.errmsg=config.get('errmsg','e'..result.code)
            end
            ngx.log(ngx.DEBUG,'<================================= function:',name,",data:",cjson.encode(result))
            ngx.say(cjson.encode(result))
        end
    else
        local f = CMD[name]
        if not TEST then
            local l=redislock.new(rediscli,"lock:".."adminserver",10)
            if l:lock() then
                local result = f(rediscli)
                if result.code and result.code~=0 then
                    -- result.errmsg=config.get('errmsg','e'..result.code)
                end
                ngx.say(cjson.encode(result))
                l:unlock()
            end
        else
            local result = f(rediscli)
            if result.code and result.code~=0 then
                -- result.errmsg=config.get('errmsg','e'..result.code)
            end
            ngx.log(ngx.DEBUG,'<================================= function:',name,",data:",cjson.encode(result))
            ngx.say(cjson.encode(result))
        end
    end

    -- ngx.say("hello")
end


return _M
