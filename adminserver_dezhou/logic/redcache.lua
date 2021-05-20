--缓存数据
local cjson     = require "cjson"
local string    = require "string"
local table_new = require "table.new"
local table     = require "table"

local redis = require "redis"
local utils = require "utils"
local redcache={}

--获得hash表的数据
--[[
    redcache.sethash('hash',{a=1,b=2,c=3})
    table.dump(redcache.gethash('hash'),'hash')
]]
function redcache.gethash(key)
    key = 'cache:'..key
    local red= redis:new({host=REDIS_CACHE_CONFIG.ip,port = REDIS_CACHE_CONFIG.port,timeout=5000})
    --链接密码
    if REDIS_CACHE_CONFIG.password then
        red:auth(REDIS_CACHE_CONFIG.password)
    end
    local data,err = red:hgetall(key) or {}
    return utils.redis_pack(data)
end

function redcache.sethash(key,values,ttl)
    key = 'cache:'..key
    ttl = ttl or 300
    local red= redis:new({host=REDIS_CACHE_CONFIG.ip,port = REDIS_CACHE_CONFIG.port,timeout=5000})
    --链接密码
    if REDIS_CACHE_CONFIG.password then
        red:auth(REDIS_CACHE_CONFIG.password)
    end

    local fields = {}
    for k,v in pairs(values) do
        table.insert(fields,k)
        table.insert(fields,v)
    end

    local res,err = red:del(key)
    if err then
        return
    end
    local data,err = red:hmset(key,unpack(fields))
    red:expire(key,ttl)
end

function redcache.delhash(key)
    key = 'cache:'..key
    local red= redis:new({host=REDIS_CACHE_CONFIG.ip,port =  REDIS_CACHE_CONFIG.port,timeout=5000})
    --链接密码
    if REDIS_CACHE_CONFIG.password then
        red:auth(REDIS_CACHE_CONFIG.password)
    end
    red:del(key)
end


--获得list的数据
--[[
redcache.setlist('list',{'a','b','c'})
table.dump(redcache.getlist('list'),'list')
]]
function redcache.getlist(key)
    key = 'cache:'..key
    local red= redis:new({host=REDIS_CACHE_CONFIG.ip,port =  REDIS_CACHE_CONFIG.port,timeout=5000})
    return red:lrange(key,0,-1)
end

function redcache.exists(key)
    key = 'cache:'..key
    local red= redis:new({host=REDIS_CACHE_CONFIG.ip,port =  REDIS_CACHE_CONFIG.port,timeout=5000})
    --链接密码
    if REDIS_CACHE_CONFIG.password then
        red:auth(REDIS_CACHE_CONFIG.password)
    end
    return red:exists(key)
end

function redcache.dellist(key)
    key = 'cache:'..key
    local red= redis:new({host=REDIS_CACHE_CONFIG.ip,port =  REDIS_CACHE_CONFIG.port,timeout=5000})
    return red:del(key)
end


function redcache.setlist(key,values,ttl)
    key = 'cache:'..key
    ttl = ttl or 300
    local red= redis:new({host=REDIS_CACHE_CONFIG.ip,port =  REDIS_CACHE_CONFIG.port,timeout=5000})
    red:del(key)
    red:rpush(key,unpack(values))
    red:expire(key,ttl)
end

--获得key值
--[[
redcache.setkey('key','a',10)
table.dump(redcache.getkey('key'),'key')
]]
function redcache.getkey(key)
    key = 'cache:'..key
    local red= redis:new({host=REDIS_CACHE_CONFIG.ip,port = REDIS_CACHE_CONFIG.port,timeout=5000})
    --链接密码
    if REDIS_CACHE_CONFIG.password then
        red:auth(REDIS_CACHE_CONFIG.password)
    end
    return red:get(key)
end


function redcache.delkey(key)
    key = 'cache:'..key
    local red= redis:new({host=REDIS_CACHE_CONFIG.ip,port = REDIS_CACHE_CONFIG.port,timeout=5000})
    --链接密码
    if REDIS_CACHE_CONFIG.password then
        red:auth(REDIS_CACHE_CONFIG.password)
    end
    return red:del(key)
end

function redcache.setkey(key,value,ttl)
    key = 'cache:'..key
    ttl = ttl or 300
    local red= redis:new({host=REDIS_CACHE_CONFIG.ip,port = REDIS_CACHE_CONFIG.port,timeout=5000})
    --链接密码
    if REDIS_CACHE_CONFIG.password then
        red:auth(REDIS_CACHE_CONFIG.password)
    end
    local ret = red:set(key,value)
    red:expire(key,ttl)
end

function redcache.getredis()
    local red= redis:new({host=REDIS_CACHE_CONFIG.ip,port = REDIS_CACHE_CONFIG.port,timeout=5000})
    return red
end

function redcache.setmax(key,val,ttl)
   key = 'cache:'..key
   local red= redis:new({host=REDIS_CACHE_CONFIG.ip,port = REDIS_CACHE_CONFIG.port,timeout=5000})
   local setmaxval=[[
       local key = ARGV[1]
       local val = ARGV[2]
       local b = redis.call("get",key) or -1
       b=tonumber(b)
       local v = tonumber(val)
       redis.call("set",key,math.max(b,v))
       return v
   ]]
   local a=red:eval(setmaxval,2,'k','v',key,val)
   if ttl then
        red:expire(key,ttl)
   end
   return a
end


return redcache
