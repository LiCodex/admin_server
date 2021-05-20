local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local keysutils = require "keysutils"
local redis = require "redis"
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

local arg=ngx.req.get_uri_args()
local uid=arg.uid
local start=arg.start
local jieshu=arg.jieshu

local result = {}
if not arg.uid or not arg.start or not arg.jieshu then
    result.code = 10001
    result.data = '参数错误10001'
    ngx.say(cjson.encode(result))
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


local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})

-- local role = red:hget(keysutils.get_model_key("user",uid),"role") or 'players'
local role = red:hget(keysutils.get_model_key("user",uid),"daili") or 0
table.dumpdebug("权限",role)

local conn = mongo:new()
conn:set_timeout(1000)
local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
if not ok then
    result.code=10001
    result.data = '参数错误10003'
    ngx.say(cjson.encode(result))
    return
end

local db=conn:new_db_handle(GAMENAME)
local col1 = db:get_col("dailifanli")
local ok2,kaishi = ptonumber(start)
local ok1,jieshu1 = ptonumber(jieshu)
local cursor 
if role == 'admin' then
	if ok2 and ok2~=0 then
	    cursor = col1:find({time={['$gte']=kaishi}},{n=0},100000)
	else
	    cursor = col1:find({},{n=0},100000)
	end
else
	if ok2 and ok2~=0 then
	    cursor = col1:find({guid=uid,time={['$gte']=kaishi}},{n=0},100000)
	else
	    cursor = col1:find({guid=uid},{n=0},100000)
	end
end

local zhuang = {}
local ret,err3 = cursor:sort({time=-1})
if not err3 then
    for index, item in pairs(ret) do
        local name = red:hget(keysutils.get_model_key("user",item.uid),"name")
        local uid1 = red:hget(keysutils.get_model_key("user",item.uid),"uid")
        local name1 = red:hget(keysutils.get_model_key("user",item.guid),"name")
        item.name = name
        item.uid1 = uid1
        item.guanname = name1
        if ok2 and ok2~=0 then
            if item.time <= jieshu1 then
                table.insert(zhuang,item)
            end
        else
            table.insert(zhuang,item)
        end 
    end
end

result.code=20000
result.data = zhuang
ngx.say(cjson.encode(result))























