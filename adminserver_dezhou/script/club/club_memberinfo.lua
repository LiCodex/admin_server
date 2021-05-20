local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local keysutils = require "keysutils"
local util= require "utils"
local userlogic = require "userlogic"
local usermodel = require "usermodel"
local clubmodel = require "clubmodel"

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
local clubkey = arg.clubkey

if not arg.clubkey or not arg.uid then
    result.code = 10000
    result.data = "参数错误 10000"
    ngx.say(cjson.encode(result))
    return
end

local ok,uid = pcall(tonumber, arg.uid)
local ok1,clubkey = pcall(tonumber, arg.clubkey)
if not ok or not ok1 then
    result.code = 10001
    result.data = "参数错误 10001"
    ngx.say(cjson.encode(result))
    return
end


--创建大厅
--需要输入大厅的ID
ngx.header.content_type = "application/json; charset=utf-8"
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})

-- result.bean = rediscli:hget(keysutils.get_model_key("user",uid),"bean") or 0
local clubusrkey = keysutils.get_club_key(clubkey, uid)
local u = clubmodel.new(clubusrkey, rediscli)
u:read()
local info = u:toparam()
result.dou = info.dou or 0 -- 欢乐豆

ngx.say(cjson.encode(result))

