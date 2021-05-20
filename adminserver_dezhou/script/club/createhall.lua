local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local jwt       = require "resty.jwt"
local keysutils = require "keysutils"
local userlogic = require "userlogic"
local usermodel = require "usermodel"
local genid = require "genid"

local log = table.dumpdebug
local desclog = ">>>>>>>>>>>>>>> log dump info >>>>>>>>>>>>>>"


require "functions"
local method = ngx.req.get_method()
if string.upper(method) == 'OPTIONS' then
    ngx.say('ok')
    return 
end

local function ptonumber(val)
    if val==nil then
        return false
    end

    local ok,v = pcall(tonumber,val)
    return ok,v
end


local arg=ngx.req.get_uri_args()
ngx.header.content_type = "application/json; charset=utf-8"

-- local token = arg.token
-- local jwtobj =  jwt:verify('lua-resty-jwt',token)
-- if not jwtobj then
--     return
-- end
-- local payload = jwtobj.payload or {}
-- local uid = payload.uid



local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
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

if not arg.guid or not arg.t or not arg.hallintroduce or not arg.hallname then
    result.code = 10001
    result.data = '参数不正确10001'
    ngx.say(cjson.encode(result))
end


-- 新改
-- local uid = arg.uid
if not arg.guid then
    result.code = 10003
    result.data = '参数不正确'
    ngx.say(cjson.encode(result))
end


local ok,val = pcall(tonumber,arg.guid)
if not ok or not val then
    result.code=10004
    result.data = '参数不正确 10004'
    ngx.say(cjson.encode(result))
    return 
end

local uid=val

-- local biao = keysutils.get_user_map(uid1-10000)
-- if not biao then
--     result.code=10005
--     result.data = '数据错误'
--     ngx.say(cjson.encode(result))
--     return 
-- end

--local uid = rediscli:get(biao)
if not uid then
    result.code=10006
    result.data = '该馆主不存在'
    ngx.say(cjson.encode(result))
    return 
end

--创建大厅
--需要输入大厅的ID
-- local hallkey = arg.hallkey
-- local t = arg.t
-- if not hallkey then
--     err1(1,'参数错误:请输入茶馆ID')
-- end

-- 生成hallkey
local hallkey = genid.genclubuid(rediscli, keysutils.get_club_main_key)
rediscli:set(keysutils.get_user_main_club(uid), hallkey)

log(hallkey,desclog)

if string.len(hallkey)~=6 then
    err1(1,'参数错误:茶馆ID格式错误')
end

local ok , hallkey = pcall(tonumber, hallkey)
if not ok then
    result.code = 10002
    result.data = '参数不正确10002'
    ngx.say(cjson.encode(result))
end

-- rediscli:lockProcess(GAMENAME..":halllock",function ()
    --向mongodb插入数据
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("hall")

    local col2 = db:get_col("myclub")
    local cnt = col2:count({uid=uid})
    if cnt > 0 then
        ngx.say(cjson.encode({code=3,data='该ID已经创建过俱乐部'}))
        return
    end

    local mhall = {}
    mhall._id = hallkey
    mhall.time = os.time()
    mhall.hallintroduce = arg.hallintroduce
    mhall.hallname = arg.hallname
    mhall.uid = uid
    mhall.t = arg.t
    local n,err=col1:insert({mhall,},nil,true)
    if  err then
        ngx.say(cjson.encode({code=2,data='创建茶馆错误'}))
    else
        local mclub={}
        mclub._id = hallkey..uid
        mclub.op=1
        mclub.clubkey = hallkey
        mclub.date = os.time()
        mclub.uid = uid
        mclub.role = 'admin'
        mclub.clubfangka = tonumber(rediscli:get(GAMENAME..'-orifangka')) or 3
        mclub.isfirstjoin = 0    --是否首次加入
        mclub.isin = 1          --是否还在俱乐部
        local ok , err  = col2:insert({mclub,},nil,true)
        if not ok then
            ngx.say(cjson.encode({code=10003,data='创建茶馆错误'}))
            return
        end
        -- ngx.say(cjson.encode({code=20000,data='success'}))

        result.code = 20000
        result.data = {msg='创建成功',hallkey=hallkey}
        ngx.say(cjson.encode(result))
    end
-- end)






