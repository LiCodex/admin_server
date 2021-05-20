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

ngx.req.read_body()
local args = ngx.req.get_post_args()


local key = GAMENAME..':'..'duihuanfangka'
ngx.log(ngx.INFO,cjson.encode(args),type(args))

local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
local keycount = table.keys(args or {})
if #keycount<12 then
    local result = {}
    result.code=10001
    result.data = '参数错误'
    result.args = args
    ngx.say(cjson.encode(result))
    return
end

for k,v in pairs(args) do
	local c = tonumber(v)
	if c then
    	red:hset(key,k,v)
    end
end

local result = {}
result.code=20000
result.data = '设置成功'
ngx.say(cjson.encode(result))



