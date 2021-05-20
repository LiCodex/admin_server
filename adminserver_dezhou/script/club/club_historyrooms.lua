-- 获得历史牌局
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


local method = ngx.req.get_method()
if string.upper(method) == 'OPTIONS' then
    ngx.say('ok')
    return 
end

local arg=ngx.req.get_uri_args()
local uid = arg.uid
local ok,uid = util.safe2number(uid)
local clubkey = arg.clubkey
local ok,clubkey = util.safe2number(clubkey)

ngx.header.content_type = "application/json; charset=utf-8"
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
--馆主的UID的判断
-- rediscli:lockProcess(GAMENAME..":halllock",function ()          
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("clubroomhis")

    local cursor=col1:find({uid=uid,clubkey=clubkey},nil,1000000)
    local ret = cursor:sort({date=-1})  
    local result = {}
    result.data={}

    local tmp = {}
    for index, item in pairs(ret) do
        local iswinloase = false
        for k,v in pairs(item.data.players) do
            if v.score~=0 then
                iswinloase = true
            end
        end
        if iswinloase==true then
            table.insert(result.data,item)
        end
        if #result.data >=30 then
            break
        end
    end


    -- for index, item in pairs(tmp) do
    --     if index<=30 then
    --         table.insert(result.data,item)
    --     end
    -- end

    ngx.say(cjson.encode(result))
-- end)
