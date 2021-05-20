local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local keysutils = require "keysutils"
local rnd = require "rnd"
local userlogic = require "userlogic"
local usermodel = require "usermodel"


require "functions"
local log = table.dumpdebug
local desclog = ">>>>>>>>>>>>>>> log dump info >>>>>>>>>>>>>>"



local arg=ngx.req.get_uri_args()
local uid = arg.uid
local clubkey = arg.clubkey
local convertfangka=arg.convertfangka

if not arg.uid or not arg.clubkey or not arg.convertfangka then
    result.code=10001
    result.data = '参数错误10001'
    ngx.say(cjson.encode(result))
    return 
end


local ok ,convertfangka = pcall(tonumber,arg.convertfangka)
local ok1 ,uid = pcall(tonumber,arg.uid)
local ok2 ,clubkey = util.safe2number(arg.clubkey)
if not ok or not ok1 or not ok2 or not toid or not uid then
    result.code=10002
    result.data = '参数错误10002'
    ngx.say(cjson.encode(result))
    return 
end


ngx.header.content_type = "application/json; charset=utf-8"
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})

local conn = mongo:new()
conn:set_timeout(1000)
local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
local db=conn:new_db_handle(GAMENAME)

-- 房卡和fangka转换
local clubcol = db:get_col("myclub")
local ret=clubcol:find_one({uid=uid,clubkey = clubkey})
local clubfangka = tonumber(ret.clubfangka)
convertfangka = tonumber(convertfangka)

if convertfangka>clubfangka then
	local result = {}
    result.data='俱乐部房卡不足'
    ngx.say(cjson.encode(result))
	return
end

if true then
	local result = {}
	-- 
	-- local key = keysutils.get_model_key(uid)
	-- rediscli:hincrby(key,"fangka",convertfangka)
	local u = userlogic.loaduser(rediscli, uid)
	if u then
		local user = u:toparam()
		u:shangfen(convertfangka)
	end

	clubcol:update({uid=uid,clubkey = clubkey},{["$inc"]={clubfangka=-convertfangka,}},1)

	local result = {}
	local ret=clubcol:find_one({uid=uid,clubkey = clubkey})
    result.data='转换成功'
    
    -- result.fangka = rediscli:hget(keysutils.get_model_key("user",uid),"fangka")
    u = userlogic.loaduser(rediscli, uid)
    local user = u:toparam()
    result.fangka = user.fangka

    result.clubfangka = ''..ret.clubfangka
    ngx.say(cjson.encode(result))
end


