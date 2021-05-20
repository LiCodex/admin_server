local cjson     = require "cjson"
local string    = require "string"
local str       = require "resty.string"
local table_new = require "table.new"
local table     = require "table"
local redis     = require "redis"
local http      = require "resty.http"
local sha1      = require "resty.sha1"
local jwt       = require "resty.jwt"
local utils     = require "utils"
local mongo     = require "resty.mongol"
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
-- ngx.say(cjson.encode({code=20000,data={token='admin'}}))

local result = {}

ngx.req.read_body()

local args=ngx.req.get_uri_args()


local uid1=args.uid
local daili1 =args.waigua

local ok1,daili = pcall(tonumber,daili1)
if not ok1 or not daili then
    result.code=10004
    result.data = '是否同意设置为代理'
    ngx.say(cjson.encode(result))
    return 
end

local ok,val = pcall(tonumber,uid1)
if not ok or not val then
    result.code=10004
    result.data = '玩家id格式不正确'
    ngx.say(cjson.encode(result))
    return 
end

uid=val

local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})

if daili > 0 then
    red:hset(keysutils.get_model_key("user",uid), 'waigua',0)
    result.code = 20000
    result.data = '删除成功'
else
    red:hset(keysutils.get_model_key("user",uid), 'waigua',1)
   
    result.code = 20000
    result.data = '设置成功'
    
end


ngx.say(cjson.encode(result))
















