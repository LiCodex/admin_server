local cjson     = require "cjson"
local string    = require "string"
local str       = require "resty.string"
local table_new = require "table.new"
local table     = require "table"
local redis     = require "redis"
local http      = require "resty.http"
local sha1      = require "resty.sha1"
local jwt       = require "resty.jwt"
local keysutils = require "keysutils"
local utils     = require "utils"
local mongo = require "resty.mongol"

require "functions"
local method = ngx.req.get_method()
if string.upper(method) == 'OPTIONS' then
	ngx.say('ok')
	return 
end
local result = {}

ngx.req.read_body()

local args=ngx.req.get_uri_args()
local uid=args.uid
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
--验证用户是否存在
local ok = rediscli:exists(keysutils.get_user_main_key(uid))
if ok==0 then
	result.code=10005
    result.data = '玩家不存在'
    ngx.say(cjson.encode(result))
    return 
end

local teshu = rediscli:hget(keysutils.get_user_main_key(uid),'teshu')
if teshu then
	if teshu == 'true' then
		rediscli:hset(keysutils.get_user_main_key(uid),'teshu','false')
	elseif hei == 'teshu' then
		rediscli:hset(keysutils.get_user_main_key(uid),'teshu','true')
	end
else
	rediscli:hset(keysutils.get_user_main_key(uid),'teshu','true')
end
result.code=20000
result.data = '操作成功'
ngx.say(cjson.encode(result))