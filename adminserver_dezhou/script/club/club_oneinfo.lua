local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local util= require "utils"
local keysutils = require "keysutils"
local userlogic = require "userlogic"
local usermodel = require "usermodel"


require "functions"
local log = table.dumpdebug
local desclog = ">>>>>>>>>>>>>>> log dump info >>>>>>>>>>>>>>"


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

ngx.header.content_type = "application/json; charset=utf-8"
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
--馆主的UID的判断
rediscli:lockProcess(GAMENAME..":halllock",function ()
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("myclub")
    local col2 = db:get_col("hall")
    local col3 = db:get_col("clubroom")

    local result = {}
    local r = col2:find_one({_id=clubkey})


    -- local k = keysutils.get_model_key(r.uid)
    -- local s = rediscli:hgetall(k)
    -- s=util.redis_pack(s)
    local u = userlogic.loaduser(rediscli,r.uid)
    local s = u:toparam()
    s.uid = r.uid
    -- s.avatar = "http://"..DOMAIN..":"..PORT.."/download/"..r.uid..".png"
    r.guanzhu = s

    local count,err = col3:count()
    r.roomcount = count

    local count = col1:count({op=1,clubkey=clubkey})
    r.membercount = count
    result.data=r

    ngx.say(cjson.encode(result))
end)
