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
-- rediscli:lockProcess(GAMENAME..":halllock",function ()
-- end)

    local room = {}
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("myclub")
    local col_person = db:get_col("personlist")
    local cursor=col1:find({op=1,clubkey=clubkey,isin=1},nil,1000000)

    local result = {}
    result.data={}
    for i,v in cursor:pairs() do
        local cursor1=col_person:find_one({_id=v.uid})

        -- local key = keysutils.get_user_main_key(v.uid)
        -- local info = rediscli:hgetall(key)

        local u = userlogic.loaduser(rediscli ,v.uid)
        local info = u:toparam()

        local curtmp=col1:find_one({uid=v.uid,op=1,clubkey=clubkey,isin=1})
        if info then
            -- info = util.redis_pack(info)
            info.uid1 = info.uid
            info.uid = v.uid
            info.role = v.role
            if cursor1==nil then
                info.exp = 0
                info.total = 0
            else
                info.exp = cursor1.exp
                info.total = cursor1.duijucount  --总对局  
            end
            info.starttime = v.date   -- 开始时间
            info.clubkey = v.clubkey
            info.clubfangka = curtmp.clubfangka
            info.bean = rediscli:hget(keysutils.get_user_main_key(v.uid)..':'..clubkey,"bean") or 0
            table.insert(result.data,info)
        end
    end
    ngx.say(cjson.encode(result))

