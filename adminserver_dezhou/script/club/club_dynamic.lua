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


local method = ngx.req.get_method()
if string.upper(method) == 'OPTIONS' then
    ngx.say('ok')
    return 
end

local arg=ngx.req.get_uri_args()
local uid = arg.uid
local clubkey = arg.clubkey
local state=arg.state

local result = {} 
if not arg.uid or not arg.clubkey or not arg.state then
    result.code = 10001
    result.data = '参数错误'
    ngx.say(cjson.encode(result))
    return
end

local ok,uid = pcall(tonumber, arg.uid)
local ok1,state = pcall(tonumber, arg.state)
local ok2,clubkey = pcall(tonumber, arg.clubkey)
if not ok or not uid or not ok1 or not state or not ok2 or not clubkey then
    result.code = 10002
    result.data = '参数错误'
    ngx.say(cjson.encode(result))
    return
end


ngx.header.content_type = "application/json; charset=utf-8"
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
--馆主的UID的判断
-- rediscli:lockProcess(GAMENAME..":halllock",function ()
    local room = {}
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("clubmsg")

    local result = {}   
    local cursor=col1:find({clubkey = clubkey},nil,1000000)

    local tmp = {}
    for index, item in cursor:pairs() do
        table.insert(tmp,item)
    end
    result.data=tmp
    ngx.say(cjson.encode(result))

    -- return
-- end)
