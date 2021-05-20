local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local utils = require "utils"
local keysutils = require "keysutils"
local userlogic = require "userlogic"
local usermodel = require "usermodel"


require "functions"

local log = table.dumpdebug
local desclog = ">>>>>>>>>>>>>>> log dump info >>>>>>>>>>>>>>"


local function ptonumber(val)
    if val==nil then
        return false
    end
    local ok,v = pcall(tonumber,val)
    return ok,v
end

local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
ngx.header.content_type = "application/json; charset=utf-8"
local result = {}


local map = red:hgetall(GAMENAME..':'..'duihuanfangka') or {}
local peizhi = utils.redis_pack(map or {})
-- result.peizhi = peizhi


local huodong = {}
for i=1,6 do
    local fangka = 'jushu'..i
    local jinbi = 'jinbi'..i
    if peizhi[fangka] and peizhi[jinbi] then
        table.insert(huodong,{index=i,fangka=tonumber(peizhi[fangka]),zuanshi=tonumber(peizhi[jinbi])})
    end
end
result.code = 20000
result.data=huodong
ngx.say(cjson.encode(result))


