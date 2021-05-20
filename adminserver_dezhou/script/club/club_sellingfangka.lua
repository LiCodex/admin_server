local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local keysutils = require "keysutils"
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
local guid = arg.guid

local result = {}
if not arg.uid or not arg.clubkey or not arg.guid then
    result.code = 10001
    result.data = '参数错误'
    ngx.say(cjson.encode(result))
    return
end

local ok,uid = pcall(tonumber, arg.uid)
local ok1,clubkey = pcall(tonumber, arg.clubkey)
local ok2,guid = pcall(tonumber, arg.guid)
if not ok or not ok1 or not ok2 then
    result.code = 10002
    result.data = "参数错误 10002"
    ngx.say(cjson.encode(result))
    return
end


--创建大厅
--需要输入大厅的ID
ngx.header.content_type = "application/json; charset=utf-8"
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
--馆主的UID的判断
-- rediscli:lockProcess(GAMENAME..":halllock",function ()
    -- -- 每月房卡销售总量+佣金
    local now = os.date("*t")
    local lastyear = now.year
    local lastmonth = now.month - 1
    if now.month== 1 then
        lastmonth = 12
        lastyear = lastyear - 1
    end
    local time = string.format("%d-%d",lastyear,lastmonth)
    -- table.dump(time,'______lastyeartime')
    -- local time = string.format("%d-%d",now.year,now.month)
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("clubselling")
    local ret = col1:find_one({_id=guid..'-'..time..'-'..clubkey})
    
    local result = {}
    result.data = ret

    ngx.say(cjson.encode(result))
-- end)
