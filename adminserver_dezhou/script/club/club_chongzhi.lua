local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local keysutils = require "keysutils"
local rnd = require "rnd"
local utils = require "utils"
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

local result = {}

local arg=ngx.req.get_uri_args()
local uid = arg.uid
local fangka = arg.fangka
local clubkey = arg.clubkey
local money=arg.zuanshi
local guid = arg.guid

local ok,clubkey 	= utils.safe2number(clubkey)
local ok1,guid 		= utils.safe2number(guid)
local ok2,money 	= utils.safe2number(money)
local ok3,fangka 	= utils.safe2number(fangka)

if not ok or not ok1 or not ok2 or not ok3 then
	result.code=10001
    result.data = '参数错误10001'
    ngx.say(cjson.encode(result))
    return
end


ngx.header.content_type = "application/json; charset=utf-8"
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})

local room = {}
local conn = mongo:new()
conn:set_timeout(1000)
local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
local db=conn:new_db_handle(GAMENAME)

-- 房卡和钻石转换
-- local zuanshi = rediscli:hget(keysutils.get_model_key("user",uid),"zuanshi")
-- zuanshi = tonumber(zuanshi)
-- money = tonumber(money)
-- fangka = tonumber(fangka)
local u = userlogic.loaduser(rediscli, uid)
if not u then
	result.code=10002
    result.data = '参数错误10002'
    ngx.say(cjson.encode(result))
    return
end

local user = u:toparam()
local zuanshi = user.zuanshi


if zuanshi<money then
	result.code = 10001
    result.data='充值钻石不足'
    ngx.say(cjson.encode(result))
	return
end

local mapfk = {
	['1'] = 1,
	['5'] = 5,
	['10'] = 13,
	['20'] = 26,
	['50'] = 65,
	['100'] = 140,
}

if true then
	local result = {}
	local data = {}	
	local clubcol = db:get_col("myclub")
	log(mapfk[""..fangka],'______mapfk[""..fangka]'..fangka)
	clubcol:update({uid=uid,clubkey = clubkey},{["$inc"]={clubfangka=mapfk[""..money],}},1)
	
	-- local key = keysutils.get_model_key(uid)
	-- rediscli:hincrby(key,"zuanshi",-money)
	u:xiafen(money,"zuanshi")

	local result = {}
	local ret=clubcol:find_one({uid=uid,clubkey = clubkey})
    result.msg='充值成功'

    -- result.zuanshi = rediscli:hget(keysutils.get_model_key("user",uid),"zuanshi")
    u = userlogic.loaduser(red, uid)
   	user = u:toparam()
   	result.zuanshi = user.zuanshi
   	
    result.clubfangka = ret.clubfangka
    ngx.say(cjson.encode(result))
end

local col1 = db:get_col("clubrecord")
local col2 = db:get_col("chongzhihuizong")
local col3 = db:get_col("dailifanli")
local col4 = db:get_col("dailifanlizong")
  
local msg={}
msg._id = uid..os.time()
msg.time = os.time()
msg.uid = uid
msg.guid = guid
msg.fangka = fangka
msg.money = money
msg.chong = 'chongzhi'
msg.content = '充值房卡'..fangka..'张'
col1:insert({msg,},nil,true)

fangka = tonumber(fangka)
money = tonumber(money)
col2:update({_id=guid},{["$set"]={_id=guid},["$inc"]={fangka=fangka,money=money}},1,0,0)

local fanli = rediscli:get(GAMENAME..'-fanli') or 10
fanli = tonumber(fanli)/100
local yongjin = money * fanli
local msg1 = {}
msg1._id = uid..os.time()..guid
msg1.yongjin = yongjin
msg1.uid = uid
msg1.guid = guid
msg1.time = os.time()
col3:insert({msg1,},nil,true)

col4:update({_id=guid},{["$set"]={_id=guid},["$inc"]={yongjin=yongjin}},1,0,0)

-- 每月房卡销售总量+佣金
local col1 = db:get_col("clubselling")
local now = os.date("*t")
local time = string.format("%d-%d",now.year,now.month)
col1:update({_id=guid..'-'..time..'-'..clubkey},{['$set']={guid=guid,time=time,clubkey=clubkey},['$inc']={sellfangka=mapfk[""..money],yongjin=yongjin}},1)


