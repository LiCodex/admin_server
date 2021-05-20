local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local keysutils = require "keysutils"
local userlogic     = require "userlogic"
local usermodel     = require "usermodel"
local userexmodel     = require "userexmodel"

ngx.header.content_type = "application/json; charset=utf-8"
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
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
local result = {}
local adminuid = arg.uid
table.dumpdebug(arg,"=====>>>>>>>>>>>>>all args ====>>>")

local conn = mongo:new()
local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
local db=conn:new_db_handle(GAMENAME)
local col1 = db:get_col("rechargetbk")

local cursor
if arg.finduid and arg.finduid ~='' then
	local ok,uid = ptonumber(arg.finduid)
	if not ok then
		result.code=10001
	    result.data = '数据错误10001'
	    ngx.say(cjson.encode(result))
	    conn:close()
	    return 
	end

	if not uid then
	    result.code=10002
	    result.data = '该玩家不存在10002'
	    ngx.say(cjson.encode(result))
	    conn:close()
	    return 
	end

	table.dumpdebug(uid,'_________________uid__________')
	local userkey = keysutils.get_model_key('user',uid)
	table.dump(userkey, 'userkey')

	cursor = col1:find({uid=uid})
	-- cursor = col1:find({name=uid})
else
	cursor = col1:find({})
end

local data = {}
local ret,err = cursor:sort({timestamp=-1})

-- 计算该玩家总充值额
local totalmoney = 0
if not err then
	for index, item in pairs(ret) do
		if item['uid'] then
			local ok,uid = ptonumber(item['uid'])
			if not ok then
				result.code=10003
			    result.data = '数据错误10003'
			    ngx.say(cjson.encode(result))
			end
			local user     = userlogic.loaduser(rediscli,uid)
			local userex = userlogic.loaduserex(rediscli,uid)
			item['name'] = user['name'] or ''
			item['wallet'] = userex['wallet'] or ''
			item['ethwallet'] = userex['ethwallet'] or ''
			-- local userkey = keysutils.get_model_key('user',uid)
			-- item['name'] = rediscli:hget(userkey,"name")
		end
	    local ok ,v = ptonumber(item.tbk)
	    if ok then
	    	totalmoney = totalmoney + v
	    	table.insert(data,item)
	    end
	end
end

-- 计算所有玩家总充值额
local totalchongzhi = 0
cursor = col1:find({})
local ret,err = cursor:sort({time=-1})
if not err then
	for index, item in pairs(ret) do
	    local ok ,v = ptonumber(item.tbk)
	    if ok then
	    	totalchongzhi = totalchongzhi + v
	    end
	end
end


local result = {}
result.code=20000
result.data = data
result.money = totalmoney
result.totalchongzhi = totalchongzhi

table.dumpdebug(result,'result:')
ngx.say(cjson.encode(result))
conn:close()




