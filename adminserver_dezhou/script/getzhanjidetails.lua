local cjson = require "cjson"
local string = require "string"
local table_new = require "table.new"
local table = require "table"
local redis = require "redis"
local utils=require "utils"
local mongo = require "resty.mongol"

local arg=ngx.req.get_uri_args()
local uniquekey = arg.uniquekey or ""
-- roomkey = tonumber(roomkey)
-- table.dump("房间号",roomkey)
ngx.header.content_type = "application/json; charset=utf-8"

local conn = mongo:new()
conn:set_timeout(1000)
local ok,err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
if not ok then
    ngx.exit(401)
end

local db=conn:new_db_handle(GAMENAME)
local col1 = db:get_col("zhanjidetail")
local cursor = col1:find({uniquekey = ''..uniquekey})
local ret = cursor:sort({time=1})

local zhanjidetails = {}
for index, item in pairs(ret) do
	table.dump("数据",item)
	table.insert(zhanjidetails,item)
end
conn:close()
ngx.say(cjson.encode(zhanjidetails))
