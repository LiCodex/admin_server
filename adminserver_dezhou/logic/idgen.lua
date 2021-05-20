--id生成器
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"

local idgen = {}
function idgen.gen(red,k)
    local id = red:incr(k)
    return id
end

function idgen.genadminuid(col)
    while true do
        -- local r = math.random(2,99999)
        local r = math.random(100001,999999)
        local row = col:find_one({uid=r})
        if not row then
            return r
        end
    end
end

return idgen
