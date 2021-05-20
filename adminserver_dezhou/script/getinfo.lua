local cjson = require "cjson"
local string = require "string"
local table_new = require "table.new"
local table = require "table"
local redis = require "redis"
local utils=require "utils"
local keysutils = require "keysutils"

local arg=ngx.req.get_uri_args()
local uid = arg.uid
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
local info     = {}



local matchcoin  = rediscli:hget(keysutils.get_user_main_key(uid),"matchcoin")
local fangka  = rediscli:hget(keysutils.get_user_main_key(uid),"fangka")
local coin  = rediscli:hget(keysutils.get_user_main_key(uid),"coin")
local zuanshi  = rediscli:hget(keysutils.get_user_main_key(uid),"zuanshi")
local name     = rediscli:hget(keysutils.get_user_main_key(uid),"name")
local avatar   = rediscli:hget(keysutils.get_user_main_key(uid),"avatar")
local sex      = rediscli:hget(keysutils.get_user_main_key(uid),"sex")
local uid1     = rediscli:hget(keysutils.get_user_main_key(uid),"uid")
local uid2     = rediscli:hget(keysutils.get_user_main_key(uid),"uid1")


info.matchcoin = matchcoin
info.name   = name
info.avatar = avatar
info.sex    = sex
info.uid1   = uid1
info.uid2   = uid2
info.zuanshi = zuanshi
info.fangka = fangka
info.coin = coin

ngx.say(cjson.encode(info))
