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
local gameconfig     = require "config"

require "functions"

local _M = {}
local CMD = {}

-- 开启关闭交易区
function CMD.enablejiaoyiqu(red)
    local arg=ngx.req.get_uri_args()
    table.dumpdebug(arg, "_____enablejiaoyiqu_____arg:")

    local result = {}
    if not arg.data then
        result.code = 10001
        result.data = '参数有误10001'
        return result
    end

    local configobj = cjson.decode(arg.data)
    if not config or not configobj['enablejiaoyi'] or not configobj['enablejiaoyi']['kaiqi'] then
        result.code = 10002
        result.data = '参数有误10002'
        return result
    end

    local ok, kaiqi = pcall(tonumber,configobj['enablejiaoyi']['kaiqi'])
    if not ok then
        result.code = 10003
        result.data = '参数有误10003'
        return result
    end
    configobj['enablejiaoyi']['kaiqi'] = kaiqi

    local conn = mongo:new()
    conn:set_timeout(5000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col('gameconfig')

    for k,v in pairs(configobj) do
        -- table.dumpdebug(key,"keys = ")
        -- table.dumpdebug(val, 'vals = ')
        -- key = cjson.decode(key)

        if k == nil or v == nil then
            result.code = 10009
            result.data = '参数有误'
            return result
        end

        local tttt = utils.table2line(v)
        col1:update({_id=k},{['$set']=tttt},1) 
        -- end
    end
    result.code = 20000
    result.data = '交易区设置成功'
    return result
end

function CMD.uploadkefumingpian(red)
    local arg=ngx.req.get_uri_args()

    table.dumpdebug(arg, "_____uploadkefuerweima_____arg:")

    local result = {}
    if not arg.data then
        result.code = 10001
        result.data = '参数有误10001'
        return result
    end

    local configobj = cjson.decode(arg.data)

    local conn = mongo:new()
    conn:set_timeout(5000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col('gameconfig')

    -- erweimaurl={ --客服二维码地址
    --     url1 = '',
    --     url2 = ''
    -- },

    -- k = value  v=true
    for k,v in pairs(configobj) do
        -- table.dumpdebug(key,"keys = ")
        -- table.dumpdebug(val, 'vals = ')
        -- key = cjson.decode(key)

        -- for k,v in pairs(val) do
        -- table.dumpdebug(v,k..'================= modifyconfig =========  ssssssss===== ')
        if k == nil or v == nil then
            result.code = 10009
            result.data = '参数有误'
            return result
        end

        local tttt = utils.table2line(v)
        table.dumpdebug(tttt ,'================= modifyconfig2222222222 ========= ===== ')

        if k == 'worker_desc' then
            table.dumpdebug(tttt ,'================= modifyconfig1111111111 ========= ===== ')
        end
        col1:update({_id=k},{['$set']=tttt},1) 
        -- end
    end

    conn:close()
    result.code = 20000
    result.data = '二维码保存成功'
    return result
end

-- 获取游戏所有配置信息
function CMD.getallconfig(red)
    -- 获取游戏所有配置信息
    local result = {}
    result.code = 20000
    result.data = gameconfig.getallconfig()
    table.dumpdebug(result.data,"_____cofig:")

    local conn = mongo:new()
    conn:set_timeout(5000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col('gameconfig')
    local res = col1:find_one({_id='opadmin'})
    if res then
        result.data['opadmin'] = res['opadmin']
    end
    return result
end


-- 设置数值参数
function CMD.setnumberconfig(red)
    ngx.req.read_body()

    local arg = ngx.req.get_post_args()
    table.dumpdebug(arg,"post参数内容:")

    local result = {}
    if arg == nil or arg.data == nil then
        result.code = 10009
        result.data = '参数为空'
        return result
    end

    local configobj = cjson.decode(arg.data)

    local conn = mongo:new()
    conn:set_timeout(5000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col('gameconfig')

    local def = config.getdefault()

    local t1 = utils.table2line(configobj)
    local t2 = utils.table2line(def)

    table.dumpdebug(t1,"t1")
    table.dumpdebug(t2,"t2")

    local newobj = {}

    for k,v1 in pairs(t1) do
        local v2 = t2[k]
        if v2 then
            if type(v2)=='number' then
                local ok,tempval = utils.safe2number(v1)
                if ok and tempval then
                    local ss = string.split(k,".")
                    local dictkey =ss[#ss]
                    ss=table.slice(ss,1,-2)

                    local dict = nil
                    for _,dictkey in ipairs(ss) do
                        if not dict then
                            dict=newobj[dictkey] or {}
                            newobj[dictkey]=dict
                        else
                            local nextdict=dict[dictkey] or {}
                            dict[dictkey]=nextdict
                            dict = nextdict
                        end
                    end

                    dict[dictkey]=tempval
                end
            else
                local ss = string.split(k,".")
                local dictkey =ss[#ss]
                ss=table.slice(ss,1,-2)

                local dict = nil
                for _,dictkey in ipairs(ss) do
                    if not dict then
                       dict=newobj[dictkey] or {}
                       newobj[dictkey]=dict
                    else
                        local nextdict=dict[dictkey] or {}
                        dict[dictkey]=nextdict
                        dict = nextdict
                    end
                end

                dict[dictkey]=v1
            end
        end
    end

    for k,v in pairs(newobj) do
        local tttt = utils.table2line(v)
        col1:update({_id=k},{['$set']=tttt},1) 
    end


    -- k = value  v=true
    -- for k,v in pairs(configobj) do
    --     -- table.dumpdebug(key,"keys = ")
    --     -- table.dumpdebug(val, 'vals = ')
    --     -- key = cjson.decode(key)

    --     -- for k,v in pairs(val) do
    --     -- table.dumpdebug(type(v),'================ setnumebr ======')
    --     -- table.dumpdebug(v,'================= setnumberconfig ======'..k..':t :::')
    --     if k == nil or v == nil then
    --         result.code = 10009
    --         result.data = '参数有误'
    --         return result
    --     end

    --     local tttt = utils.table2line(v)
    --     table.dumpdebug(tttt ,'================= modifyconfig1111111111 ========= ===== ')

    --     if k == 'worker_desc' then
    --         table.dumpdebug(tttt ,'================= modifyconfig1111111111 ========= ===== ')
    --     end
    --     -- col1:update({_id=k},{['$set']=tttt},1) 
    --     -- end
    -- end

    table.dumpdebug(newobj,'newobj')
    if configobj['opadmin'] then
        col1:update({_id='opadmin'},{['$set']={opadmin=configobj['opadmin']}},1,0)
    end

    conn:close()
    result.code = 20000
    result.data = '游戏配置修改成功'
    return result
end


-- 修改游戏配置参数
function CMD.setallconfig(red)
    -- 修改游戏配置参数
    ngx.req.read_body()

    local arg = ngx.req.get_post_args()
    table.dumpdebug(arg,"post参数内容:")

    local result = {}
    if arg == nil or arg.data == nil then
        result.code = 10009
        result.data = '参数为空'
        return result
    end

    local configobj = cjson.decode(arg.data)

    local conn = mongo:new()
    conn:set_timeout(5000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col('gameconfig')

    -- k = value  v=true
    for k,v in pairs(configobj) do
        -- table.dumpdebug(key,"keys = ")
        -- table.dumpdebug(val, 'vals = ')
        -- key = cjson.decode(key)

        -- for k,v in pairs(val) do
        -- table.dumpdebug(v,k..'================= modifyconfig =========  ssssssss===== ')
        if k == nil or v == nil then
            result.code = 10009
            result.data = '参数有误'
            return result
        end

        local tttt = utils.table2line(v)
        if k == 'worker_desc' then
            table.dumpdebug(tttt ,'================= modifyconfig1111111111 ========= ===== ')
        end
        col1:update({_id=k},{['$set']=tttt},1) 
        -- end
    end

    conn:close()
    result.code = 20000
    result.data = '游戏配置修改成功'
    return result
end


-- 修改游戏配置参数
function CMD.setgameconfig(red)
    -- 修改游戏配置参数
    ngx.req.read_body()

    local arg = ngx.req.get_post_args()
    table.dumpdebug(arg,"post参数内容:")

    local result = {}
    if arg == nil or arg.data == nil then
        result.code = 10009
        result.data = '参数为空10009'
        return result
    end

    local configobj = cjson.decode(arg.data)

    local conn = mongo:new()
    conn:set_timeout(5000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col('gameconfig')

    -- k = value  v=true
    for k,v in pairs(configobj) do
        -- table.dumpdebug(key,"keys = ")
        -- table.dumpdebug(val, 'vals = ')
        -- key = cjson.decode(key)

        -- for k,v in pairs(val) do
        -- table.dumpdebug(v,k..'================= modifyconfig =========  ssssssss===== ')
        if k == nil or v == nil then
            result.code = 10009
            result.data = '参数有误'
            return result
        end

        local tttt = utils.table2line(v)
        if k == 'worker_desc' then
            table.dumpdebug(tttt ,'================= modifyconfig1111111111 ========= ===== ')
        end
        col1:update({_id=k},{['$set']=tttt},1) 
        -- end
    end

    conn:close()
    result.code = 20000
    result.data = '游戏配置修改成功'
    return result
end


function _M.invoke(name)
    local method = ngx.req.get_method()
    if string.upper(method) == 'OPTIONS' then
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
                if result.errcode and result.errcode~=0 then
                    result.errmsg=config.get('errmsg','e'..result.errcode)
                end
                ngx.say(cjson.encode(result))
                l:unlock()
            end
        else
            local result = f(rediscli)
            if result.errcode and result.errcode~=0 then
                result.errmsg=config.get('errmsg','e'..result.errcode)
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
                if result.errcode and result.errcode~=0 then
                    result.errmsg=config.get('errmsg','e'..result.errcode)
                end
                ngx.say(cjson.encode(result))
                l:unlock()
            end
        else
            local result = f(rediscli)
            if result.errcode and result.errcode~=0 then
                result.errmsg=config.get('errmsg','e'..result.errcode)
            end
            ngx.log(ngx.DEBUG,'<================================= function:',name,",data:",cjson.encode(result))
            ngx.say(cjson.encode(result))
        end
    end

    -- ngx.say("hello")
end


return _M

