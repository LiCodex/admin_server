local cjson     = require "cjson"
local string    = require "string"
local table_new = require "table.new"
local table     = require "table"
local jwt       = require "resty.jwt"
local mongo     = require "resty.mongol"
local redis     = require "redis"
local keysutils = require "keysutils"

require "functions"

local _M={}

function _M.access(checklogin)
    local arg=ngx.req.get_uri_args()
    local jwtval = arg.jwt or arg.token

    local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
    
    if not jwtval  then
        table.dumpdebug(jwtobj,'jwtobj')
        ngx.exit(401)
        return
    end
    local jwtobj = jwt:verify('lua-resty-jwt',jwtval)


    if not jwtobj or not jwtobj.payload or not jwtobj.payload.uid  or not jwtobj.payload then
        ngx.exit(401)
        return
    end

    -- local key = GAMENAME..":token:"..jwtobj.payload.uid
    -- local usermodelkey = keysutils.get_model_key('user',jwtobj.payload.uid)

    -- if rediscli:exists(usermodelkey)==0 and checklogin then
    --     ngx.say(cjson.encode({errcode=20002,errmsg='没有登录游戏服务器',oldtoken=oldtoken,curtoken=jwtobj.payload.token}))
    --     ngx.exit(401)
    --     return
    -- end

    -- local oldtoken = rediscli:get(key)
    -- if oldtoken~=jwtobj.payload.token then
    --     ngx.say(cjson.encode({errcode=20001,errmsg='当前用户在其他终端上登录',oldtoken=oldtoken,curtoken=jwtobj.payload.token}))
    --     ngx.exit(401)
    --     return
    -- end

    -- --被封号
    -- local status = tonumber(rediscli:hget(usermodelkey,'status') or 1)
    -- if status == 1 then
    --     ngx.say(cjson.encode({errcode=20003,errmsg='此账号已被禁用, 无法使用!'}))
    -- end

    local args = ngx.req.get_uri_args()
    args.uid = jwtobj.payload.uid
    ngx.req.set_uri_args(args)
end


return _M