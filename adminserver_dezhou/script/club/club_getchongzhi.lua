local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local utils = require "utils"
local keysutils = require "keysutils"
local userlogic = require "userlogic"
local usermodel = require "usermodel"


require "functions"
local log = table.dumpdebug
local desclog = ">>>>>>>>>>>>>>> log dump info >>>>>>>>>>>>>>"



local method = ngx.req.get_method()
if string.upper(method) == 'OPTIONS' then
    ngx.say('ok')
    return 
end

local function ptonumber(val)
    if val==nil then
        return false
    end
    if val=='null' then
        return 0
    end
    local ok,v = pcall(tonumber,val)
    return ok,v
end


local arg=ngx.req.get_uri_args()
ngx.header.content_type = "application/json; charset=utf-8"
local start=arg.start
local jieshu=arg.jieshu
local result = {}

local function err2(err,msg)
    result.code=err
    result.data=msg
    ngx.say(cjson.encode(result))
end

local function err1(err,msg)
    result.code=err
    result.data=msg
    ngx.say(cjson.encode(result))
    ngx.exit(ngx.OK)
end

local ok2,kaishi = utils.safe2number(start)
local ok1,jieshu1 = utils.safe2number(jieshu)
if not ok1 or not ok2 then
    err2(10001,"参数错误")
    return
end

--创建大厅
--需要输入大厅的ID
local room = {}
local conn = mongo:new()
conn:set_timeout(1000)
local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
local db=conn:new_db_handle(GAMENAME)
local col1 = db:get_col("clubrecord")

if ok2 and ok2~=0 then
    cursor = col1:find({chong="chongzhi",time={['$gte']=kaishi}},{n=0},1000000)
else
    cursor = col1:find({chong="chongzhi"},{n=0},1000000)
end

local ret,err3 = cursor:sort({time=-1})
if not err3 then
    local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
    for index, item in pairs(ret) do
        local name = redis:hget(keysutils.get_model_key("user",item.uid),"name")
        item.name = name
        local guanname = redis:hget(keysutils.get_model_key("user",item.guid),"name")
        item.guanname = guanname
        if ok2 and ok2~=0 then
            if item.time <= jieshu1 then
                table.insert(room,item)
            end
        else
            table.insert(room,item)
        end 
    end
end
err2(20000,room)


