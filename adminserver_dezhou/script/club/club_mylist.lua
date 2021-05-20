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
local clubmodel = require "clubmodel"

require "functions"
local log = table.dumpdebug
local desclog = ">>>>>>>>>>>>>>> log dump info >>>>>>>>>>>>>>"

local method = ngx.req.get_method()
if string.upper(method) == 'OPTIONS' then
    ngx.say('ok')
    return 
end

local result = {}
local arg=ngx.req.get_uri_args()
local uid = arg.uid
if not arg.uid then
    result.code = 10001
    result.data = '参数错误 10001'
    ngx.say(cjson.encode(result))
    return
end

local ok,uid  = pcall(tonumber,arg.uid)
if not ok then
    result.code = 10002
    result.data = '参数错误 10002'
    ngx.say(cjson.encode(result))
    return
end

ngx.log(ngx.INFO,'_____我曹')
--创建大厅
--需要输入大厅的ID
ngx.header.content_type = "application/json; charset=utf-8"
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
--馆主的UID的判断
-- rediscli:lockProcess(GAMENAME..":halllock",function ()
    local room = {}
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("myclub")
    local col2 = db:get_col("hall")
    local col3 = db:get_col("clubroom")
    local cursor=col1:find({uid=uid,op=1,isin=1},nil,1000000)
    local cnt =col1:count({uid=uid,op=1,isin=1})
    log(cnt,desclog)

    local tmp = {}
    for index, item in cursor:pairs() do
        table.insert(tmp,item.clubkey)
    end
    log(tmp,"===item.clubkey=====")
    
    result.data={}
    -- result.bean = rediscli:hget(keysutils.get_model_key("user",uid),"bean") or 0

    for i,v in ipairs(tmp) do
        local role=col1:find_one({uid=uid,op=1,clubkey=v})
        local r = col2:find_one({_id=v})

        table.dumpdebug(role, "====::clubkey::====="..uid.."===>>")
        -- 
        -- local k = keysutils.get_model_key('user',r.uid)
        -- local s = rediscli:hgetall(k)
        local u = userlogic.loaduser(rediscli,r.uid)
        local s = u:toparam()

        if s then
            -- s=util.redis_pack(s)
            s.uid = r.uid
            r.guanzhu = s

            local rooms = col3:find({clubkey=v},nil,1000000)
            local count3 = 0
            for index, item in rooms:pairs() do
                count3 = count3 + 1
            end
            table.dump(count3,'____________________count')
            r.roomcount = count3

            local clubps = col1:find({op=1,clubkey=v},nil,1000000)
            local count1 = 0
            for index, item in clubps:pairs() do
                count1 = count1 + 1
            end
            table.dump(count1,'____________________count')
            r.membercount = count1
            r.role = role.role
            r.clubkey = role.clubkey
            table.dumpdebug(clubkey, "=========clubkey=========")

            local clubusrkey = keysutils.get_club_key(r.clubkey, r.uid)
            local u = clubmodel.new(clubusrkey, rediscli)
            u:read()
            local info = u:toparam()
            r.dou = info.dou -- 欢乐豆

            table.insert(result.data,r)
        end
    end
    ngx.say(cjson.encode(result))

-- end)
