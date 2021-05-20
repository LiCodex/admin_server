math.randomseed(os.time())
--房间已经满了
local mongo = require "resty.mongol"
local redis = require "redis"
local keysutils = require "keysutils"
local utils = require "utils"

local banksafer = {}

function banksafer.init()
    if ngx.worker.id()==0 then
        local conn = mongo:new()
        conn:set_timeout(1000)
        local ok, err = conn:connect("127.0.0.1",27017)
        local db=conn:new_db_handle(GAMENAME)
        local col1 = db:get_col("banksafer")
        col1:drop()
    end
end

function banksafer.addbill(batchid,uid,k,count)
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect("127.0.0.1",27017)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("banksafer")
    col1:insert({{_id=batchid..'-'..uid,k=count,batchid=batchid,date=os.time()}})
end

function banksafer.incrby(batchid,uid,k,c)
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect("127.0.0.1",27017)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("banksafer")
    col1:update({_id=batchid..'-'..uid,},{['$inc']={k=c}})
end

function banksafer.getkeycount(uid,k)
    local rediscli = redis:new({timeout=1000})
    local ret = rediscli:hgetall(keysutils.get_user_main_key(uid))
    ret=utils.redis_pack(ret)
    local c= ret[k] or 0
    local ok,c=pcall(tonumber,c)
    if not ok then
        c=0
    end
    c=c or 0

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect("127.0.0.1",27017)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("banksafer")
    local r = col1:find({uid=uid})
    for i,v in r:pairs()  do
        if v[k] then
            c=c-v[k]
        end
    end
    return c
end

function banksafer.removeone(batchid,uid)
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect("127.0.0.1",27017)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("banksafer")
    col1:remove({batchid=batchid,uid=uid})
end

function banksafer.removebill(batchid)
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect("127.0.0.1",27017)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("banksafer")
    col1:remove({batchid=batchid})
end

return banksafer
