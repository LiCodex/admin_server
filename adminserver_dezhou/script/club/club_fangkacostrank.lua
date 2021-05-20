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


require "functions"
local log = table.dumpdebug
local desclog = ">>>>>>>>>>>>>>> log dump info >>>>>>>>>>>>>>"

local result = {}
local arg=ngx.req.get_uri_args()
local uid = arg.uid
local clubkey = arg.clubkey

if not arg.uid or not arg.clubkey then
    result.code = 10001
    result.data = '参数错误'
    ngx.say(cjson.encode(result))
    return
end

local ok,uid = pcall(tonumber, arg.uid)
local ok2,clubkey = pcall(tonumber, arg.clubkey)
-- if not ok or not uid or not ok1 or not state or not ok2 or not clubkey then
if not ok or not uid or not ok2 or not clubkey then
    result.code = 10002
    result.data = '参数错误'
    ngx.say(cjson.encode(result))
    return
end


--创建大厅
--需要输入大厅的ID
ngx.header.content_type = "application/json; charset=utf-8"
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
--馆主的UID的判断
-- rediscli:lockProcess(GAMENAME..":halllock",function ()
    local function onedaybegin( t )
        local temp1 = os.date('*t',t)
        return os.time({year=temp1.year, month=temp1.month, day=temp1.day, hour=0,min=0,sec=0})
    end 

    local today = onedaybegin(os.time())

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col5 = db:get_col("todaylist")

    local cursor = col5:find({today=today,clubkey=clubkey},nil,1000000)
    local ret = cursor:sort({costfangka=-1})  
    local result = {}
    result.data={}
    for index, item in pairs(ret) do
        table.dumpdebug(item,"=======item=======")
        if item['uid'] then
            local u = userlogic.loaduser(rediscli,item.uid)
            local user = u:toparam()
            item.name = user.name
            item.avatar = user.avatar
            -- item.name = rediscli:hget(keysutils.get_model_key("user",item.uid),"name")
            -- item.avatar = rediscli:hget(keysutils.get_model_key("user",item.uid),"avatar")
            table.insert(result.data,item)
        end
    end

    ngx.say(cjson.encode(result))
-- end)
