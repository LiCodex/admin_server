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
local clubmodel = require "clubmodel"

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
    local yesterday = today-24*3600
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)

    local col1 = db:get_col("myclub")
    local col2 = db:get_col("hall")
    local col3 = db:get_col("clubroom")
    local col4 = db:get_col("personlist")
    local col5 = db:get_col("todaylist")

    local ret = col4:find_one({_id=uid})
    local ret1 = col1:find_one({uid=uid,op=1,clubkey=clubkey})
    local ret2 = col5:find_one({_id=uid..today..clubkey})
    local ret3 = col5:find_one({_id=uid..yesterday..clubkey})

    ret = ret or {}
    ret.date = ret1 and ret1.date or os.time()
    ret.role = ret1 and ret1.role or 'player'
    ret.clubfangka = ret1 and ret1.clubfangka or 0
    ret.todaycount = ret2 and ret2.todaycount or 0
    ret.todayscore = ret2 and ret2.todayscore or 0
    ret.todayping = ret2 and ret2.todayping or 0
    ret.todayexp = ret2 and ret2.todayexp or 0
    ret.todaywin = ret2 and ret2.todaywin or 0
    ret.todaylose = ret2 and ret2.todaylose or 0
    ret.yesterdayscore = ret3 and ret3.todayscore or 0

    -- ret.bean = rediscli:hget(keysutils.get_user_main_key(uid)..':'..clubkey,"bean") or 0
    local clubusrkey = keysutils.get_club_key(clubkey, uid)
    local u = clubmodel.new(clubusrkey, rediscli)
    u:read()
    local info = u:toparam()
    ret.dou = info.dou -- 欢乐豆

    local result = {}
    result.data = ret

    ngx.say(cjson.encode(result))
-- end)
