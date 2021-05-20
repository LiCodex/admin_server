--缓存数据
local cjson = require "cjson"
local redis = require "redis"
local utils = require "utils"
local mp    = require 'MessagePack'
local sql   = require 'sql'
local logfilter     = require "logfilter"


local logqueueutil={}

function logqueueutil.send(c,m,data)
    if m == 'operation' then
        local result = logfilter.operationfilter(data.description)
        if result == false then
            return
        end
    end

    local d = {}
    d.m=m
    d.c=c
    d.data = data
    table.dumpdebug(d,"==== logqueueutil == data =========")
    local msg = mp.pack(d)
    local red= redis:new({host=REDIS_QUEUE_CONFIG.ip,port=REDIS_QUEUE_CONFIG.port,timeout=5000})
    local res,err = red:lpush('logqueue',msg)
end

function logqueueutil.sendrecharge(c,m,data)
	local d = {}
    d.m=m
    d.c=c
    d.data = data
    local msg = mp.pack(d)
    local red= redis:new({host=REDIS_QUEUE_CONFIG.ip,port=REDIS_QUEUE_CONFIG.port,timeout=5000})
    local res,err = red:lpush('rechargequeue',msg)
end

return logqueueutil
