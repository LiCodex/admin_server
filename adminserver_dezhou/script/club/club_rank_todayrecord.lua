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


-- 获取俱乐部今日战绩排行
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

local result = {} 
if not arg.uid or not arg.clubkey then
    result.code = 10001
    result.data = '参数错误'
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

--rediscli:lockProcess(GAMENAME..":halllock",function ()
    local function onedaybegin( t )
        local temp1 = os.date('*t',t)
        return os.time({year=temp1.year, month=temp1.month, day=temp1.day, hour=0,min=0,sec=0})
    end 

    local today = onedaybegin(os.time())
    local yesterday = today-24*3600
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("myclub")
    local rule = col1:find_one({uid=uid,op=1,role="admin",clubkey=clubkey})

    if rule then
        local col2 = db:get_col("ranktodayrecord")    
        ret = ret or {}

        local cursor=col2:find({time=today},nil,1000000)

        local sortret = cursor:sort({todaywin=-1})

        local result = {}
        result.data={}
        for index, item in pairs(sortret) do
            -- local name = rediscli:hget(keysutils.get_model_key("user",item.uid),"name")
            -- local uid1  = rediscli:hget(keysutils.get_model_key("user",item.uid),"uid")
            -- item.avatar = rediscli:hget(keysutils.get_model_key("user",item.uid),"avatar")
            local u = userlogic.loaduser(rediscli,item.uid)
            local s = u:toparam()
            item.avatar = s.avatar
            item.name = s.name
            --item.uid1 = tonumber(uid1)+10000
            item.uid = s.uid
            table.insert(result.data,item)
        end

        ngx.say(cjson.encode(result))
    end
--end)
