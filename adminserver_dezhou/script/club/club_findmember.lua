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


--查找会员信息 
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
local findid = arg.findid


local ret = {}
if not findid or not clubkey then
    ret.code = 10001
    ret.data = '参数错误10002'
    ngx.say(cjson.encode(ret))
    return
end

local ok,findid = pcall(tonumber,arg.findid)
local ok1,clubkey = pcall(tonumber,arg.clubkey)
if not ok or not ok1 then
    ret.code = 10003
    ret.data = '参数错误10003'
    ngx.say(cjson.encode(ret))
    return
end


local result = {}
result.data = {}

-- local red = redis:new({timeout=1000})

ngx.header.content_type = "application/json; charset=utf-8"
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})

-- rediscli:lockProcess(GAMENAME..":halllock",function ()
    local room = {}
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("myclub")
    local col_person = db:get_col("personlist")
    local rule = col1:find_one({uid=uid,op=1,role="admin",clubkey=clubkey})

    --local rule = col1:find_one({uid=uid,op=1,{['$or']={role="admin",role="manager"}},clubkey=clubkey})
    if rule then
        table.dumpdebug(rule,"=====rule====::")

        local cursor=col1:find_one({uid=findid,op=1,clubkey=clubkey,isin=1})
        local cursor1=col_person:find_one({_id=findid})

        -- local name = rediscli:hget(keysutils.get_model_key("user",findid),"name")
        -- local uid1  = rediscli:hget(keysutils.get_model_key("user",findid),"uid")
        -- local avatar  = rediscli:hget(keysutils.get_model_key("user",findid),"avatar")
        local u = userlogic.loaduser(rediscli, findid)
        if not u then
            result.code = 10004
            result.data = '玩家不存在'
            ngx.say(cjson.encode(result))
            return
        end
        local user = u:toparam()
        local name = user.name
        local uid = user.uid
        local avatar = user.avatar

        result.data.nickname = name
        result.data.clubkey = cursor.clubkey
        result.data.clubfangka = cursor.clubfangka    -- 俱乐部房卡
        result.data.starttime = cursor.date   -- 开始时间
        result.data.uid = uid
        -- result.data.avatar = 'http://'..DOMAIN..":"..PORT..'/download/'..findid..'.png'
        result.data.avatar = avatar
        result.data.role = cursor.role  --权限

        if cursor1==nil then
            result.data.exp = 0         -- 经验值
            result.data.total = 0       --总对局
        else
            result.data.exp = cursor1.exp               -- 经验值
            result.data.total = cursor1.duijucount      --总对局
        end
        ngx.say(cjson.encode(result))
    end
-- end)
