local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
require "functions"
local method = ngx.req.get_method()
if string.upper(method) == 'OPTIONS' then
    ngx.say('ok')
    return 
end

local arg=ngx.req.get_uri_args()
ngx.header.content_type = "application/json; charset=utf-8"

local shenglvsys = arg['shenglvsys']
local shenglvply = arg['shenglvply']

local result = {}
if shenglvsys == 'null' or not shenglvsys or not shenglvply or shenglvply == 'null' then
    result.code=10001
    result.data = '请输入胜率值'
    ngx.say(cjson.encode(result))
    return 
end

local ok1, slsys = pcall(tonumber,shenglvsys)
local ok2, slply = pcall(tonumber,shenglvply)
if not ok1 or not ok2 or slsys < 0 or slply < 0 then
    result.code=10001
    result.data = '请输入胜率值'
    ngx.say(cjson.encode(result))
    return 
end

local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})

local result = {}
local ok1 = rediscli:set(GAMENAME..'-system_shenglv',slsys)
local ok2 = rediscli:set(GAMENAME..'-player_shenglv',slply)
if ok1 and ok2 then
    result.code=20000
    result.data = '设置成功'
    ngx.say(cjson.encode(result))
    return 
end



