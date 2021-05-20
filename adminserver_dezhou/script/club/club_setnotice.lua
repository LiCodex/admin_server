local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local util= require "utils"
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


local arg=ngx.req.get_uri_args()
local uid = arg.uid
local clubkey = arg.clubkey
local hallintroduce = arg.notice


local result = {} 
if not arg.uid or not arg.clubkey or not arg.notice then
    result.code = 10001
    result.data = '参数错误'
    ngx.say(cjson.encode(result))
    return
end

local ok,uid = pcall(tonumber, arg.uid)
local ok1,clubkey = pcall(tonumber, arg.clubkey)
if not ok or not ok1 then
    result.code = 10001
    result.data = "参数错误 10001"
    ngx.say(cjson.encode(result))
    return
end


--创建大厅
--需要输入大厅的ID
ngx.header.content_type = "application/json; charset=utf-8"
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
--馆主的UID的判断
-- rediscli:lockProcess(GAMENAME..":halllock",function ()
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col2 = db:get_col("hall")

	local result = {}   
    result.data={}

	col2:update({_id=clubkey,uid=uid},{["$set"]={hallintroduce=hallintroduce}},false,false)	
    result.data.msg = '设置成功'
    ngx.say(cjson.encode(result))
-- end)
