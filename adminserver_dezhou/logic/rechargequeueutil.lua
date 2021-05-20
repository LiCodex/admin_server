--缓存数据
local cjson       = require "cjson"
local redis       = require "redis"
local utils       = require "utils"
local mp          = require 'MessagePack'
local sql         = require 'sql'
local minelogic   = require "minelogic"
local workerlogic = require "workerlogic"
local proplogic   = require "proplogic"
local uuid        = require "resty.uuid"
local keysutils   = require "keysutils"
local config      = require "config"
require "functions"

local rechargequeueutil={}

function rechargequeueutil.updatetask(red,uid)
    local task = {}
    local ok,errmsg,allmine=minelogic.loadallmine(red,uid)
    local ok1,errmsg,allworker = workerlogic.loadallworker(red,uid)
    local ok2,errmsg,allprop = proplogic.loadallprop(red,uid)

    --签到天数决定的
    local checkinkey = keysutils.get_model_key('checkin',uid)
    local a=red:get(checkinkey) or 0
    a=tonumber(a)

    local task_day_cal =  config.get("task_day_cal",'cal')
    a=a*task_day_cal

    if ok and ok1 and ok2  then
        local minemap = {}
        for _,mine in ipairs(allmine) do
            minemap[mine.id]=mine
        end

        local hastask=false
        local taskmine = {}
        local taskworker = {}
        local taskprop = {}
        for _,worker in ipairs(allworker) do
            if worker.mine~=0 then
                hastask=true
                taskmine[worker.mine] = worker
            end
        end

        for _,prop in ipairs(allprop) do
            if  prop.wid~=0 then
                taskprop[prop.uuid] = prop
            end
        end

        task.mine={}
        --计算每一个矿的数据
        for k,_ in pairs(taskmine) do
            local m =clone(minemap[k])
            m.index= k
            m.worker={}

            for _,worker in ipairs(allworker) do
                if worker.mine==k then
                    local w = clone(worker)
                    w.prop = {}
                    for _,prop in ipairs(allprop) do
                        if prop.wid==worker.id then
                            local p = clone(prop)
                            table.insert(w.prop,p)
                        end
                    end
                    table.insert(m.worker,w)
                end
            end
            table.insert(task.mine,m)
        end

        if hastask then
            task.uid=uid
            rechargequeueutil.send(uid,task)
        else
            rechargequeueutil.del(uid)
        end
    end
end

function rechargequeueutil.del(uid)
    local taskid = keysutils.get_simple_id('task',uid)
    local red= redis:new({host=REDIS_QUEUE_CONFIG.ip,port=REDIS_QUEUE_CONFIG.port,timeout=5000})
    red:del(taskid)
    red:zrem('calqueue',uid)
end

function rechargequeueutil.send(uid,task)
    local taskid = keysutils.get_simple_id('task',uid)
    local msg = mp.pack(task)
    local red= redis:new({host=REDIS_QUEUE_CONFIG.ip,port=REDIS_QUEUE_CONFIG.port,timeout=5000})
    red:set(taskid,msg)
    red:expire(taskid,48*3600)
    red:zadd('calqueue',os.time(),uid)
end

return rechargequeueutil
