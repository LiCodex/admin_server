math.randomseed(os.time())
--房间已经满了

local genid = {}
local inc = 0
local prev = nil
local workerId = ngx.worker.id()

function genid.gen()
    if prev and prev~=os.time() then
        inc = 0
    end
    inc = inc + 1
    local d = os.date("*t")
    local s = string.format("%04d%02d%02d%02d%02d%02d%03d%04d",d.year,d.month,d.day,d.hour,d.min,d.sec,workerId,inc)
    prev =os.time()
    return s
end

function genid.genuid(red,f)
    while true do
        local r = math.random(100001,999999)
        local k = f(r)
        if red:exists(k)==0 then
            return r
        end
    end
end

function genid.genclubuid(red,f)
    while true do
        local r = math.random(100001,999999)
        local k = f(r)
        if red:exists(k)==0 then
            return r
        end
    end
end

function genid.gentoken()
    if TEST then
        return "1"
    end
    return genid.gen()
end

return genid
