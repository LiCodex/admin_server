local cjson = require "cjson"
local string = require "string"
local str = require "resty.string"
local table_new = require "table.new"
local table = require "table"
local redis = require "redis"
local http = require "resty.http"
local sha1 = require "resty.sha1"
require "functions"
local jwt = require "resty.jwt"
local keysutils = require "keysutils"
local mongo = require "resty.mongol"

ngx.req.read_body()

local method = ngx.req.get_method()
if string.upper(method) == 'OPTIONS' then
    ngx.say('ok')
    return 
end


local result = {}

local arg=ngx.req.get_uri_args()
local uid = arg.uid

table.dumpdebug(arg, '=查询抽水记录,参数=====>>> arg ====>>>> ')

if not uid then
	result.code=10001
	result.data = '请求参数错误 10001'
	ngx.say(cjson.encode(result))
	return
end

local start = arg.start
if start == 'null' or start == 'NaN' or not start then
	start = 0
end
start = tonumber(start) or 0
local end1 = arg.end1
table.dump(end1)
local big = os.time()
if end1 == 'null' or end1 == 'NaN' or not end1 then
	big = os.time()
else
	end1 = tonumber(end1)
	if end1 == 0 then
		end1 = os.time()
	end
	big = end1
end


local conn = mongo:new()
conn:set_timeout(1000)
local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
local db=conn:new_db_handle(GAMENAME)
local col1 = db:get_col("choushuirecord")

local cursor = col1:find({})
local ret = cursor:sort({time=-1})
local totalchoushui = 0
for index, item in pairs(ret) do
  local ok ,val = pcall(tonumber,item['choushui'])
  if ok then
  	totalchoushui = totalchoushui + val
  end
end


local data = {}
local cursor = col1:find({uid=uid,time={['$gte']=start,['$lte']=big}})
local ret = cursor:sort({time=-1})
for index, item in pairs(ret) do
  table.insert(data,item)
end
conn:close()


result.code=20000
result.data = data
result.totalchoushui = totalchoushui
ngx.say(cjson.encode(result))



