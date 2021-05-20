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
local userlogic     = require "userlogic"
local usermodel     = require "usermodel"
local userexmodel   = require "userexmodel"

--移除会员 
require "functions"
local log = table.dumpdebug
local desclog = ">>>>>>>>>>>>>>> log dump info >>>>>>>>>>>>>>"


local method = ngx.req.get_method()
if string.upper(method) == 'OPTIONS' then
    ngx.say('ok')
    return 
end


local arg=ngx.req.get_uri_args()
local useruid = arg.uid
local clubkey = arg.clubkey
local toid = arg.toid

local result = {}
if not arg.uid or not arg.clubkey or not arg.toid then
    ret.code = 10001
    ret.data = '参数错误10002'
    ngx.say(cjson.encode(ret))
    return
end

local ok,toid = pcall(tonumber,arg.toid)
local ok1,uid = pcall(tonumber,arg.uid)
local ok2,clubkey = pcall(tonumber,arg.clubkey)
if not ok or not ok1 or not ok2 then
    ret.code = 10002
    ret.data = '参数错误10002'
    ngx.say(cjson.encode(ret))
    return
end

local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})

--local k = keysutils.get_user_map(uid1-10000)
--if not k then
--    result.code=10001
--    result.data = '参数错误10001'
--    ngx.say(cjson.encode(result))
--    return 
--end

--local toid = red:get(k)
-- local toid = uid
if not toid then
    result.code=10003
    result.data = '参数错误10003'
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
    local col2 = db:get_col("clubmsg")
    local user = col1:find_one({uid=uid,op=1,clubkey=clubkey,isin=1})
    local touser = col1:find_one({uid=toid,clubkey=clubkey,isin=1}) -- ,op=1

    if not touser then
        result.code=10004
        result.data = '玩家不存在 10004'
        ngx.say(cjson.encode(result))
        return 
    end

    if touser.role == "player" or touser.role==nil then
        local name = rediscli:hget(keysutils.get_model_key("user",uid),"name")
        local toname = rediscli:hget(keysutils.get_model_key("user",toid),"name")
        local msg={}
        local uids = {}
        table.insert(uids,toid)
        table.insert(uids,uid)
        msg._id = clubkey..uid..os.time()
        msg.clubkey = clubkey
        msg.uids = uids
        msg.time = os.time()

        if user.role=="admin" or user.role=="manager" then
            local tmpuser={}
            tmpuser._id = touser._id
            tmpuser.op=touser.op
            tmpuser.clubkey = touser.clubkey
            tmpuser.date = os.time()
            tmpuser.uid = touser.uid
            tmpuser.role = touser.role
            col1:update({_id=touser._id},{["$set"]={isin=0}},false,false)

            --退出动态
            msg.content = '【'..name..'】移除了会员【'..toname..'】'
            msg.type = 1
            col2:insert({msg,},nil,true)

            -- 移除会员 房卡转为好友房卡
            local ret=col1:find_one({uid=toid,clubkey = clubkey})
            local clubfangka = tonumber(ret.clubfangka)
            -- local key = keysutils.get_user_main_key(toid)
            -- rediscli:hincrby(key,"fangka",clubfangka)
            -- 玩家下会
            local u = userlogic.loaduser(rediscli, toid)
            if u then
                u:shangfen(clubfangka,'fangka')
            end

            col1:update({uid=toid,clubkey = clubkey},{["$inc"]={clubfangka=-clubfangka,}},1)

            ngx.say(cjson.encode(tmpuser))

            local wId = rnd.getWorkerId(tonumber(clubkey))
            -- local center = require "center"
            -- center.send2center({
            --     src='admin',
            --     m='kick',
            --     c='club',
            --     data={clubkey=clubkey,state=state},
            -- },wId)

            ngx.log(ngx.INFO,'____club_removemember.lua')
        elseif user.role=="player" then
            local tmpuser={}
            tmpuser._id = touser._id
            tmpuser.op=touser.op
            tmpuser.clubkey = touser.clubkey
            tmpuser.date = os.time()
            tmpuser.uid = touser.uid
            tmpuser.role = touser.role
            col1:update({_id=touser._id},{["$set"]={isin=0}},false,false)

            --退出动态
            msg.content = '会员【'..toname..'】 退出了俱乐部'
            msg.type = 1
            col2:insert({msg,},nil,true)

            -- 移除会员 房卡转为好友房卡
            local ret=col1:find_one({uid=toid,clubkey = clubkey})
            local clubfangka = tonumber(ret.clubfangka)

            -- local key = keysutils.get_user_main_key(toid)
            -- rediscli:hincrby(key,"fangka",clubfangka)
            local u = userlogic.loaduser(rediscli, toid)
            if u then
                u:shangfen(clubfangka,'fangka')
            end
            col1:update({uid=toid,clubkey = clubkey},{["$inc"]={clubfangka=-clubfangka,}},1)

            ngx.say(cjson.encode(tmpuser))

            local wId = rnd.getWorkerId(tonumber(clubkey))
            -- local center = require "center"
            -- center.send2center({
            --     src='admin',
            --     m='kick',
            --     c='club',
            --     data={clubkey=clubkey,state=state},
            -- },wId)

            ngx.log(ngx.INFO,'____club_removemember.lua')
        end
    end

-- end)
