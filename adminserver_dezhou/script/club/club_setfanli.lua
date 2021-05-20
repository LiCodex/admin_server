local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local keysutils = require "keysutils"
local userlogic = require "userlogic"
local usermodel = require "usermodel"


require "functions"
local log = table.dumpdebug
local desclog = ">>>>>>>>>>>>>>> log dump info >>>>>>>>>>>>>>"


local method = ngx.req.get_method()
if string.upper(method) == 'OPTIONS' then
	ngx.say('ok')
	return 
end

local result = {}

local arg=ngx.req.get_uri_args()
ngx.header.content_type = "application/json; charset=utf-8"

local a, fanli = pcall(tonumber,arg.fanli)
if not a then
	result.code=10005
    result.data = '参数错误'
    ngx.say(cjson.encode(result))
    return
end

local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})

if not fanli then
	result.code=10006
    result.data = '参数错误'
    ngx.say(cjson.encode(result))
    return
end


local ok = rediscli:set(GAMENAME..'-fanli',fanli)
if ok then
	result.code=20000
    result.data = fanli
    ngx.say(cjson.encode(result))
    return 
end



