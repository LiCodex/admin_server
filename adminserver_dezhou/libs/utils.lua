--工具类
--
local utils={}
require "functions"

--redis的对象解压缩
function utils.redis_pack(...)
    local t = {}
    local s = ...
    for i=1,#s,2 do
        local k = s[i]
        local v = s[i+1]
        t[k] = v
    end

    return t
end

local function table2linekey(parent,tbl,result)
    parent = parent or ""
    for k,v in pairs(tbl) do
        if type(v)=='table' then
            local p = nil
            if parent=='' then
                p = string.format("%s",tostring(k))
            else
                p = string.format("%s.%s",parent,tostring(k))
            end
            table2linekey(p,v,result)
        else
            local p = nil
            if parent=='' then
                p = string.format("%s",tostring(k))
            else
                p = string.format("%s.%s",parent,tostring(k))
            end
            -- local key =string.format("%s.%s",p,tostring(k))
            result[p]=v
        end
    end
end

function utils.table2line(tbl)
    local result = {}
    table2linekey("",tbl,result)
    return result
end


function utils.redis_unpack(values)
    local fields = {}
    for k,v in pairs(values) do
        table.insert(fields,k)
        table.insert(fields,v)
    end
    return fields
end

function utils.safe2number(v)
    local ok,val = pcall(tonumber,v or "y")
    if not val then
        return false
    end
    return ok,val
end

local function convertbonuskey2table(key)
    local arr =  string.split(key,":")
    local arr1 = string.split(arr[1],'-')

    --转换格式
    local reqtime = arr1[1]
    reqtime       = tonumber(reqtime)
    local uid     = arr1[2]
    uid           = tonumber(uid)
    local mine    = arr1[3]
    mine          = tonumber(mine)

    return {
        uid=uid,
        reqtime=reqtime,
        mine=mine,
        bonusid=key,
    }
end

function utils.convertbonuskey2table(key)
    local ok,tbl = pcall(convertbonuskey2table,key)
    return ok,tbl
end

local ok,val=utils.safe2number("1.5344121801785E+15")
print(ok,val)

-- table.dump(utils.table2line({a={b={c=1}},d=2}))

return utils
