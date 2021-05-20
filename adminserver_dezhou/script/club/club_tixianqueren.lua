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


local arg=ngx.req.get_uri_args()
ngx.header.content_type = "application/json; charset=utf-8"

local id = arg.id

if not id then
	err1(10001,'参数错误')
end
local conn = mongo:new()
conn:set_timeout(1000)
local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
local db=conn:new_db_handle(GAMENAME)
local col1 = db:get_col("tixianshenqing")
local cursor = col1:find_one({_id=id})
if not cursor then
	err1(10002,'已同意该提现申请')
end

local uid = cursor.uid
local money = cursor.money
local fangshi = cursor.type
local time = cursor.time
local text = cursor.text

local col2 = db:get_col("tixianlist")
local msg={}
msg.uid = uid
msg.money = money
msg.type = fangshi
msg.time = time
msg.time1 = os.time()
msg._id = os.time()..id
msg.text = text
col2:insert({msg,},nil,true)

col1:delete({_id=id})
err2(20000,'成功')
















