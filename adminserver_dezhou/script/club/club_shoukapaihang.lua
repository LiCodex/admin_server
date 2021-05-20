local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
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
ngx.header.content_type = "application/json; charset=utf-8"

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


--创建大厅
--需要输入大厅的ID
local room = {}
local conn = mongo:new()
conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
local db=conn:new_db_handle(GAMENAME)
local col1 = db:get_col("chongzhihuizong")

cursor = col1:find({},{n=0},1000000)

local ret,err3 = cursor:sort({fangka=-1})
if not err3 then
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
    for index, item in pairs(ret) do
        local u = userlogic.loaduser(rediscli, item.uid)
        if u then
            local user = u:toparam()
            item.name = user.name
            item.avatar = user.avatar
            item['index'] = index
            table.insert(room,item)
        end
    end
end

err2(20000,room)


