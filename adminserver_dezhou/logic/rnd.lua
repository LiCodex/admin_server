math.randomseed(os.time())
--房间已经满了

local rnd = {}

local function  rndroomid(workerId,workercount,length)
    local max = 10^length - 1
    local min = 10^(length-1)

    max=math.floor(max/workercount)
    min=math.floor(min/workercount)

    local a = math.random(min,max)
    a=a*workercount+workerId

    return a
end

local function getWorkerId(roomId,worker_count)
    local a = roomId - 1
    a = a%worker_count + 1
    return a - 1
end

function rnd.getWorkerId(roomId)
    local worker_count
    if ngx then
        worker_count = ngx.worker.count()
    else
        worker_count = 4
    end

    return getWorkerId(roomId,worker_count)
end

function rnd.rndroomId(length)
    local worker_count
    local workerId
    if ngx then
        worker_count = ngx.worker.count()
        workerId = ngx.worker.id() + 1
    else
        worker_count = 4
        workerId = 2
    end

    return rndroomid(workerId,worker_count,length)
end

--获取房间id的长度
function rnd.roomlen(roomId)
    local s= ""..roomId
    return string.len(roomId)
end

local TEST = true
if TEST then
    if true then
        local a = getWorkerId(1001,4)
        assert(a==0,"错误:"..a)
    end
    if true then
        local a = getWorkerId(9999,4)
        assert(a==2,"错误:"..a)
    end

end

return rnd
