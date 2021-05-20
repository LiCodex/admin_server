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
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})


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
local col1 = db:get_col("tixianlist")

local role = redis:hget(keysutils.get_model_key(uid),"role")
local cursor = nil
if role == 'admin' then
    cursor = col1:find({},{n=0},1000000)
else
    cursor = col1:find({uid=uid},{n=0},1000000)
end

local ret,err3 = cursor:sort({time=-1})

if not err3 then
    for index, item in pairs(ret) do
        local name = redis:hget(keysutils.get_model_key(item.uid),"name")
        local uid1 = redis:hget(keysutils.get_model_key(item.uid),"uid")
        item.name = name
        item.uid1 = uid1
        table.insert(room,item)
    end
end
err2(20000,room)












