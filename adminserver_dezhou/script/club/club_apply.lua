local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local keysutils = require "keysutils"
local util = require "utils"
local userlogic = require "userlogic"
local usermodel = require "usermodel"

require "functions"
local log = table.dumpdebug
local desclog = ">>>>>>>>>>>>>>> log dump info >>>>>>>>>>>>>>"

local arg=ngx.req.get_uri_args()
local uid = arg.uid
local clubkey = arg.clubkey

if not arg.uid or not arg.clubkey then
    result.code=10001
    result.data = '参数错误 10001'
    ngx.say(cjson.encode(result))
    return
end
local ok,uid = util.safe2number(arg.uid)
local ok1,clubkey = util.safe2number(arg.clubkey)
if not ok or not ok1 then
    result.code=10002
    result.data = '参数错误 10002'
    ngx.say(cjson.encode(result))
    return
end

ngx.header.content_type = "application/json; charset=utf-8"
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})


--馆主的UID的判断
-- rediscli:lockProcess(GAMENAME..":halllock",function ()
-- end)

local room = {}
local conn = mongo:new()
conn:set_timeout(1000)
local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
local db=conn:new_db_handle(GAMENAME)
local col1 = db:get_col("myclub")
local cursor=col1:find({op=0,clubkey=clubkey},nil,1000000)

local tmp = {}
for index, item in cursor:pairs() do
    table.insert(tmp,item.uid)
end

local result = {}
result.data={}
for i,v in ipairs(tmp) do
    local u = userlogic.loaduser(rediscli, v)
    if u then
        local user = u:toparam()
        if not user['uid'] or user['uid'] == 0 then
            user['uid'] = v
            table.dumpdebug(v ,"===============发现toparam玩家没有uid====================:")
        end
        table.insert(result.data,user)
    end
    -- local key = keysutils.get_user_main_key(v)
    -- local info = rediscli:hgetall(key)
    -- if info then
    --     info = util.redis_pack(info)
    --     -- info.uid1 = info.uid
    --     info.uid = v
    --     table.insert(result.data,info)
    -- end
end

ngx.say(cjson.encode(result))
