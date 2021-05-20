local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"


local arg=ngx.req.get_uri_args()
table.dumpdebug(arg,'________传入参数_______:')

ngx.header.content_type = "application/json; charset=utf-8"

local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
local choushui_lunpan = rediscli:get(GAMENAME.."-choushui_lunpan")
local choushui_nn = rediscli:get(GAMENAME.."-choushui_nn")
local choushui_28 = rediscli:get(GAMENAME.."-choushui_28")

local result = {}
result.ok=true
result.choushui_lunpan = choushui_lunpan or 1
result.choushui_nn = choushui_nn or 1
result.choushui_28 = choushui_28 or 1
result.code = 20000

table.dumpdebug(result,"result: ")
ngx.say(cjson.encode(result))



