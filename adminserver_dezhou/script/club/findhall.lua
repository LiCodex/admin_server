-- 根据ID查找俱乐部
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

    local ok,v = pcall(tonumber,val)
    return ok,v
end

local arg=ngx.req.get_uri_args()
ngx.header.content_type = "application/json; charset=utf-8"
local hallkey = arg.hallkey
local jwt = arg.jwt

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

local conn = mongo:new()
conn:set_timeout(1000)
local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
local db=conn:new_db_handle(GAMENAME)
local col1 = db:get_col("hall")
local ret=col1:find_one({_id=hallkey})
err2(20000,ret)

