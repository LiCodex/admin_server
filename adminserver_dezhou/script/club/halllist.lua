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

local function getplayerinfo(uid,red)
    local u     = userlogic.loaduser(red,uid)
    if u then
        return u:toparam()
    end
    return nil
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

--创建大厅
--需要输入大厅的ID
local room = {}
local conn = mongo:new()
conn:set_timeout(1000)
-- local ok, err = conn:connect("127.0.0.1",27017)
local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
local db=conn:new_db_handle(GAMENAME)
local col1 = db:get_col("hall")
local cursor=col1:find({},{n=0},1000000)
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
for index, item in cursor:pairs() do
    local user = getplayerinfo(item.uid, rediscli)
    if user then
        item.name = user.name
        table.insert(room,item)
    end
end

err2(20000,room)








