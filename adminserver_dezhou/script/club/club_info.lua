local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local keysutils = require "keysutils"
local util = require "utils"
local userlogic = require "userlogic"
local usermodel = require "usermodel"


require "functions"
local log = table.dumpdebug
local desclog = ">>>>>>>>>>>>>>> log dump info >>>>>>>>>>>>>>"

local result = {}

local arg=ngx.req.get_uri_args()
local clubkey = arg.clubkey
local uid = arg.uid
ngx.header.content_type = "application/json; charset=utf-8"
local ok,clubkey = util.safe2number(clubkey)
if not ok then
	result.code = 10001
	result.data = "参数错误"
	ngx.say(cjson.encode(result))
	return
end

local conn = mongo:new()
conn:set_timeout(1000)
local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
local db=conn:new_db_handle(GAMENAME)
local col1 = db:get_col("hall")
local r=col1:find_one({_id=clubkey})

result.data = r

if not r then
    result.msg='俱乐部不存在'
else
    local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
    local u = userlogic.loaduser(rediscli,r.uid)
    if not u then
		result.code = SUCCEED_CODE
		result.data = "没找到俱乐部管理员"
		ngx.say(cjson.encode(result))
		return
    end
    local user = u:toparam()
    result.data.guanzhu=user
    result.code = SUCCEED_CODE
    -- local k = keysutils.get_model_key('user',r.uid)
    -- local s = rediscli:hgetall(k)
    -- if s then
	   --  s=util.redis_pack(s)
	   --  result.data.guanzhu = s
	-- end
end

ngx.say(cjson.encode(result))

