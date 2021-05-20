local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local utils = require "utils"
local rnd = require "rnd"
local keysutils = require "keysutils"
local genid = require "genid"
local keysutils = require "keysutils"
local userlogic = require "userlogic"
local usermodel = require "usermodel"

require "functions"
local log = table.dumpdebug
local desclog = ">>>>>>>>>>>>>>> log dump info >>>>>>>>>>>>>>"



local function ptonumber(val)
    if val==nil then
        return false
    end

    local ok,v = pcall(tonumber,val)
    return ok,v
end

local method = ngx.req.get_method()
if string.upper(method) == 'OPTIONS' then
    ngx.say('ok')
    return 
end


local arg=ngx.req.get_uri_args()
--ngx.header.content_type = "application/json; charset=utf-8"
if not arg.hallkey then
    result.code = 10001
    result.data = '参数不正确10001'
    ngx.say(cjson.encode(result))
end

local ok , hallkey = pcall(tonumber, arg.hallkey)
if not ok then
    result.code = 10002
    result.data = '参数不正确10002'
    ngx.say(cjson.encode(result))
end


local result = {}

local function err(err,msg)
    result.code=err
    result.data=msg
end

local function err1(err,msg)
    result.code=err
    result.data=msg
    ngx.say(cjson.encode(result))
    ngx.exit(ngx.OK)
end

-- local ok,hallkey = ptonumber(arg.hallkey)
-- if not ok then
--     err1(1,'参数错误')
-- end

local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
local conn = mongo:new()
conn:set_timeout(1000)

local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
local db=conn:new_db_handle(GAMENAME)
local col1 = db:get_col("hall")
local col2 = db:get_col("myclub")


-- rediscli:lockProcess(GAMENAME..":halllock",function ()
-- end)

    --向mongodb插入数据
    local r = col1:find_one({_id=hallkey})
    if not r then
        err1(2,'大厅不存在'..hallkey)
        return
    end

    col1:delete({_id=hallkey})
    col2:delete({clubkey=hallkey})
    local k = GAMENAME..'hall-'..hallkey
    rediscli:del(k)
    rediscli:del(keysutils.get_user_main_club(r.uid))

    local t = tonumber(hallkey)
    local wId = rnd.getWorkerId(t)
    -- ngx.say(""..hallkey)
    -- ngx.say(""..wId)

    -- 通知俱乐部成员,解散
    -- local center = require "center"
    -- center.send2center({
    --     src='admin',
    --     m='dismiss',
    --     c='hall',
    --     data={hallkey=hallkey,},
    -- },wId)

    -- err(20000,'success')
    result.code = 20000
    result.data = 'success'
    ngx.say(cjson.encode(result))


-- ngx.say(cjson.encode(result))



