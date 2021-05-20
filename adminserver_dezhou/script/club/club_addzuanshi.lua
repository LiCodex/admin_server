local cjson = require "cjson"
local string = require "string"
local table_new = require "table.new"
local table = require "table"
local redis = require "redis"
local utils=require "utils"
local mongo = require "resty.mongol"
local keysutils = require "keysutils"
local center = require "center"
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


local uid = arg.uid
local num = arg.num
local t = arg.t
log("房卡类型:",zuanshi)

if not arg.uid or not arg.num or not t then
    result.code=10001
    result.data = '参数错误 10001'
    ngx.say(cjson.encode(result))
    return
end
if t ~= 'coin' and t~='zuanshi' and t~= 'fangka' then
    result.code=10002
    result.data = '参数错误 10002'
    ngx.say(cjson.encode(result))
    return

end


local result = {}
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})

local ok,uid = pcall(tonumber,arg.uid)
if not ok or not uid then
    result.code=10002
    result.data = '玩家id格式不正确'
    ngx.say(cjson.encode(result))
    return 
end

local ok1,num = pcall(tonumber,arg.num)
if not ok1 or not num then
    result.code=10004
    result.data = '钻石必须为数值类型'
    ngx.say(cjson.encode(result))
    return 
end

-- local key = keysutils.get_model_key("user",uid)
-- rediscli:hincrby(key,zuanshi,num)
local u = userlogic.loaduser(rediscli,uid)

if not u then
    result.code=10005
    result.data = '玩家不存在'
    ngx.say(cjson.encode(result))
    return 
end

local user = u:toparam()
u:shangfen(num, t)


result.code=20000
result.data = '充值成功'
ngx.say(cjson.encode(result))

-- local oldsessionId = ngx.shared.sessionuid:get(uid)
-- if oldsessionId then
--     local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
--     local zuanshi = rediscli:hget(keysutils.get_model_key("user",uid),"zuanshi")
--     local response ={}
--     local data = {
--         zuanshi = zuanshi,
--     }
--     response.m = "updatezuanshi"
--     response.c = "room"
--     response.data = data
--     response.src = 'server'
--     center.send2client(oldsessionId,response)
-- end

