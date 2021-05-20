local cjson        = require "cjson"
local string       = require "string"
local table_new    = require "table.new"
local table        = require "table"
local jwt          = require "resty.jwt"
local mongo        = require "resty.mongol"
local redis        = require "redis"
local keysutils    = require "keysutils"
local redislock    = require "lock"
local market_ctrl = require "market_ctrl"
require 'functions'

local _M = {}

local CMD = {}

local TEST = false

function CMD.queryorder(red)

end

function CMD.getorderlist(red)
	local result = {}

    -- local TEST_GWL = false
    if TEST_GWL then
        -- 造假数据 
        local data = {}
        result.code = 20000
        result.data = data
        table.insert(data, {id='213456',create=1539749410})
        table.insert(data, {id='123456',create=1539748110})
        return result
    else
        result = market_ctrl.gettousulist(red)
        if result.code ~= 20000 then
            return result
        end
    end
    result.code = 20000
    result.data = {}
    return result
end

function CMD.terminatorder(red)
	
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
end


return _M

