local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local keysutils = require "keysutils"
local util = require "utils"
local rnd = require "rnd"
local userlogic = require "userlogic"
local usermodel = require "usermodel"


require "functions"
local log = table.dumpdebug
local desclog = ">>>>>>>>>>>>>>> log dump info >>>>>>>>>>>>>>"


-- 权限修改(创始人 变更管理和会员的权限)
require "functions"
local method = ngx.req.get_method()
if string.upper(method) == 'OPTIONS' then
    ngx.say('ok')
    return 
end


local arg=ngx.req.get_uri_args()
local uid = arg.uid
local clubkey = arg.clubkey
local toid = arg.toid
local torole = arg.torole

local result = {}
if not arg.uid or not arg.clubkey or not arg.toid or not arg.torole then
    result.code=10001
    result.data = '参数错误10001'
    ngx.say(cjson.encode(result))
    return 
end


local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
local ok ,toid = pcall(tonumber,arg.toid)
local ok1 ,uid = pcall(tonumber,arg.uid)
local ok2 ,clubkey = util.safe2number(arg.clubkey)
if not ok or not ok1 or not ok2 or not toid or not uid then
    result.code=10002
    result.data = '参数错误10002'
    ngx.say(cjson.encode(result))
    return 
end

ngx.header.content_type = "application/json; charset=utf-8"
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
-- rediscli:lockProcess(GAMENAME..":halllock",function ()
    local room = {}
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("myclub")
    local user = col1:find_one({uid=uid,op=1,clubkey=clubkey})
    local touser = col1:find_one({uid=toid,clubkey=clubkey}) -- op=1
    local col2 = db:get_col("clubmsg")

    local name = rediscli:hget(keysutils.get_model_key("user",uid),"name")
    local toname = rediscli:hget(keysutils.get_model_key("user",toid),"name")
    local msg={}
    local uids = {}
    table.insert(uids,tuid)
    table.insert(uids,uid)
    msg._id = clubkey..uid..os.time()
    msg.clubkey = clubkey
    msg.uids = uids
    msg.time = os.time()

    if user.role == "admin" then
        local result = {}
        if touser then
            -- 解除管理员
            if touser.role == "manager" or torole == "player" then
                result.data = {}
                result.data._id = touser._id
                result.data.op=touser.op
                result.data.clubkey = touser.clubkey
                result.data.date = os.time()
                result.data.uid = touser.uid
                result.data.role = torole
                col1:update({_id = result.data._id},{['$set']={role=torole}},1)

                msg.content = '【'..name..'】解除了【'..toname..'】的管理员权限'
                msg.type = 1
                col2:insert({msg,},nil,true)

                ngx.say(cjson.encode(result))

                local wId = rnd.getWorkerId(tonumber(clubkey))
                -- local center = require "center"
                -- center.send2center({
                --     src='admin',
                --     m='role',
                --     c='club',
                --     data={clubkey=clubkey,state=state},
                -- },wId)

                ngx.log(ngx.INFO,'____club"_changerke.lua')

            -- 添加管理员
            elseif touser.role == "player" or torole == "manager" then
                local ismanager = col1:find_one({role="manager",clubkey=clubkey})
                -- 一个俱乐部只有一个管理员
                if not ismanager then
                    result.data = {}
                    result.data._id = touser._id
                    result.data.op=touser.op
                    result.data.clubkey = touser.clubkey
                    result.data.date = os.time()
                    result.data.uid = touser.uid
                    result.data.role = torole
                    col1:update({_id = result.data._id},{['$set']={role=torole}},1)

                    msg.content = '【'..name..'】 给 【'..toname..'】设为管理员'
                    msg.type = 1
                    col2:insert({msg,},nil,true)

                    ngx.say(cjson.encode(result))

                    local wId = rnd.getWorkerId(tonumber(clubkey))
                    -- local center = require "center"
                    -- center.send2center({
                    --     src='admin',
                    --     m='role',
                    --     c='club',
                    --     data={clubkey=clubkey,state=state},
                    -- },wId)

                    ngx.log(ngx.INFO,'____club"_changerke.lua')
                else
                    result.data='管理员已经存在'
                    ngx.say(cjson.encode(result))
                end

            end
        else
            result.code = 10010
            result.data = '玩家不在该俱乐部中'
            ngx.say(cjson.encode(result))
        end

    end

-- end)





