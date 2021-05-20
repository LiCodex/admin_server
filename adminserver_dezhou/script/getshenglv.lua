local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"


local arg=ngx.req.get_uri_args()
ngx.header.content_type = "application/json; charset=utf-8"

local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
local shenglv_sys = rediscli:get(GAMENAME.."-system_shenglv")
local shenglv_ply = rediscli:get(GAMENAME.."-player_shenglv")

local result = {}
result.ok=true
result.shenglvsys = shenglv_sys or 1
result.shenglvply = shenglv_ply or 1
result.code = 20000
ngx.say(cjson.encode(result))



