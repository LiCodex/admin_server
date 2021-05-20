local cjson = require "cjson"
local string = require "string"
local table_new = require "table.new"
local table = require "table"
local redis = require "redis"
local utils=require "utils"
local mongo = require "resty.mongol"

require "functions"

local arg=ngx.req.get_uri_args()
local uid=arg.uid
local zhanji = {}
zhanji.data = {}

local ok,fuid = pcall(tonumber,uid)
if not ok then
	ngx.say(cjson.encode(zhanji))
	return
end

local conn = mongo:new()
conn:set_timeout(1000)
local ok,err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
local db = conn:new_db_handle(GAMENAME)
local col1 = db:get_col("zhanji")
local now = os.time()
local cursor = col1:find({uid=fuid})
local ret = cursor:sort({time=-1})
for index, item in pairs(ret) do
	table.insert(zhanji.data,item)
end
conn:close()
ngx.say(cjson.encode(zhanji))
