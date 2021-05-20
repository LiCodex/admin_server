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

local function ptonumber(val)
    if val==nil then
        return false
    end
    if val=='null' then
        return 0
    end
    local ok,v = pcall(tonumber,val)
    return ok,v
end


local arg=ngx.req.get_uri_args()
ngx.header.content_type = "application/json; charset=utf-8"
local start=arg.start

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



local room = {}
local conn = mongo:new()
conn:set_timeout(1000)
local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
local db=conn:new_db_handle(GAMENAME)
local col1 = db:get_col("players")
local col2 = db:get_col("personlist")
local cursor
if start == 'null' then
    cursor = col1:find({},{n=0},1000000)
else
    cursor = col1:find({time=start},{n=0},1000000)
end
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})

for index, item in cursor:pairs() do
    local name = redis:hget(keysutils.get_model_key("user",item._id),"name")
    item.name = name
    local fangka   = redis:hget(keysutils.get_model_key("user",item._id),"fangka")
    local sex      = redis:hget(keysutils.get_model_key("user",item._id),"sex")
    local uid1     = redis:hget(keysutils.get_model_key("user",item._id),"uid")
    local waigua = redis:hget(keysutils.get_model_key("user",item._id),"waigua")
    local waiguaqiangzhuang = redis:hget(keysutils.get_model_key("user",item._id),"waiguaqiangzhuang")
    local waiguashenglv = redis:hget(keysutils.get_model_key("user",item._id),"waiguashenglv")
    item.fangka = fangka
    item.sex = sex
    item.uid1 = uid1
    item.waigua = waigua
    item.waiguaqiangzhuang = waiguaqiangzhuang
    item.waiguashenglv = waiguashenglv
    local person = col2:find_one({_id=item._id})
    if person then
        item.win = person.win
        item.ping = person.ping
        item.lose = person.lose
    end
    table.insert(room,item)
end

err2(20000,room)


