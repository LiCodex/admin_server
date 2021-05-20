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

local arg=ngx.req.get_uri_args()
local result = {}
ngx.header.content_type = "application/json; charset=utf-8"

local uid=arg.uid
if not uid or uid == false then
	result.code=10001
    result.data = '参数错误10001'
    ngx.say(cjson.encode(result))
    return 
end

local ok,uid = pcall(tonumber, uid)
if not ok then
    result.code=10002
    result.data = '参数错误10002'
    ngx.say(cjson.encode(result))
    return 
end

local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})


local chongzhi = arg.chongzhi
local shouka = arg.shouka

if chongzhi == 'true' and shouka == 'true' then
	red:hset(keysutils.get_model_key(uid), 'role','super_editor')
elseif  chongzhi == 'true' and shouka == 'false' then
	red:hset(keysutils.get_model_key(uid), 'role','chongzhi')
elseif  chongzhi == 'false' and shouka == 'true' then
	red:hset(keysutils.get_model_key(uid), 'role','shouka')
elseif  chongzhi == 'false' and shouka == 'false' then
	red:hset(keysutils.get_model_key(uid), 'role','players')
end

result.code=20000
result.data = '设置成功'
ngx.say(cjson.encode(result))








