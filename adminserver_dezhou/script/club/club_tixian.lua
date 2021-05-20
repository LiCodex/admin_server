local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local jwt       = require "resty.jwt"
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
local function ptonumber(val)
    if val==nil then
        return false
    end

    local ok,v = pcall(tonumber,val)
    return ok,v
end


local arg=ngx.req.get_uri_args()
ngx.header.content_type = "application/json; charset=utf-8"

local token = arg.token
local jwtobj =  jwt:verify('lua-resty-jwt',token)
if not jwtobj then
    return
end

local payload = jwtobj.payload or {}
local uid = payload.uid
local result = {}



local function err2(err,msg)
    result.code=err
    result.data=msg
    ngx.say(cjson.encode(result))
end


local function err1(err,msg)
    result.code=err
    result.data=msg
    ngx.say(cjson.encode(result))

    ngx.exit(ngx.OK)
end


local fangshi = arg.type
local money = arg.money
money = tonumber(money)
local text = arg.text

if not fangshi or not money or not text or text == 'null' then
	err1(10001,'参数错误')
end

if money < 100 then
    err1(10001,'提现金额必须大于100')
end

local conn = mongo:new()
conn:set_timeout(1000)
local ok, err = conn:connect("127.0.0.1",27017)
local db=conn:new_db_handle(GAMENAME)
local col1 = db:get_col("dailifanlizong")
local cursor = col1:find_one({_id=uid})
if not cursor then
	err1(10003,'您没有佣金')
end
local yongjin = cursor.yongjin
yongjin = tonumber(yongjin)

if yongjin < money then
	err1(10002,'余额不足')
end

col1:update({_id=uid},{["$inc"]={yongjin=-money}},1,0,0)

local col2 = db:get_col("tixianshenqing")
local msg={}
msg._id = uid..os.time()
msg.time = os.time()
msg.uid = uid
msg.money = money
msg.type = fangshi
msg.text = text
col2:insert({msg,},nil,true)

err2(20000,'提现成功')













