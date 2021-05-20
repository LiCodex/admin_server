local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local rnd = require "rnd"
local keysutils = require "keysutils"
local userlogic = require "userlogic"
local usermodel = require "usermodel"


require "functions"
local log = table.dumpdebug
local desclog = ">>>>>>>>>>>>>>> log dump info >>>>>>>>>>>>>>"


local arg=ngx.req.get_uri_args()
local uid = arg.uid
local tuid = arg.tuid
local clubkey = arg.clubkey
local state=arg.state

local result = {} 
if not arg.uid or not arg.tuid or not arg.clubkey or not arg.state then
    result.code = 10001
    result.data = '参数错误'
    ngx.say(cjson.encode(result))
    return
end

local ok,uid = pcall(tonumber, arg.uid)
-- local ok1,state = pcall(tonumber, arg.state)
local ok2,clubkey = pcall(tonumber,arg.clubkey)
local ok3,tuid = pcall(tonumber,arg.tuid)

if not ok or not uid or not ok2 or not clubkey or not ok3 or not tuid then
    result.code = 10002
    result.data = '参数错误'
    ngx.say(cjson.encode(result))
    return
end

log(tuid,"======tuid========")

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
    local col2 = db:get_col("clubmsg")
    local r=col1:find_one({op=0,clubkey=clubkey,uid=tuid})

    local result = {}   
    result.data={}

    if not r then
        result.data.msg = '申请不存在'
        ngx.say(cjson.encode(result))
        return
    end

    local tt = ''
    if state=="tongyi" then -- 同意加入
        tt = '申请加入俱乐部【'..clubkey..'】成功'
        col1:update({op=0,clubkey=clubkey,uid=tuid},{["$set"]={op=1,role='player',isin=1}},false,false)
        col1:update({op=1,clubkey=clubkey,uid=tuid,isfirstjoin = 1},{["$set"]={isfirstjoin=0}},false,false)

        -- local wId = rnd.getWorkerId(tonumber(clubkey))
        -- local center = require "center"
        -- center.send2center({
        --     src='admin',
        --     m='pass',
        --     c='club',
        --     data={clubkey=clubkey,state=state},
        -- },wId)

        ngx.log(ngx.INFO,'____send2center admin pass club')
    else
        tt = '申请加入俱乐部【'..clubkey..'】失败'
        col1:delete({op=0,clubkey=clubkey,uid=tuid})
    end

    -- 消息列表插入
    local name = rediscli:hget(keysutils.get_model_key("user",tuid),"name")
    local msg={}
    local uids = {}
    table.insert(uids,tuid)
    table.insert(uids,uid)
    msg._id = clubkey..uid..os.time()
    msg.clubkey = clubkey
    msg.uids = uids
    msg.time = os.time()
    msg.content = name..tt
    msg.type = 1
    col2:insert({msg,},nil,true)

    result.data.msg = '操作成功'
    ngx.say(cjson.encode(result))
