-- 数组查询器的测试用例
-- Author:jack 
-- Date: 2016-08-19 09:11:15
--
require "functions"
local function mydump(value, desciption, nesting)
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    local traceback = string.split(debug.traceback("", 2), "\n")
    print("dump from: " .. string.trim(traceback[3]))

    local function _dump(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(_v(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
        elseif lookupTable[value] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
        else
            lookupTable[value] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
            else
                result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = _v(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    _dump(value, desciption, "- ", 1)

    for i, line in ipairs(result) do
        print(line)
    end
end


local tquery=require "tquery"
local function test_search()
    local data={
        {a={b=1}},
        -- {a=2},
        -- {a=3},
        -- {a=4},
    }

    local cursor=tquery:find(data,{a={b=1}},100)
    cursor:sort({b=-1})
    local ret,val=cursor:next()
    while val do
        mydump(val,"------result")
        ret,val=cursor:next()
    end

end

local function test_or()
    local data={
        {a=1},
        {a=2},
        {a=3},
        {a=4},
    }

    local cursor=tquery:find(data,{['$or']={{a=1},}},100)
    cursor:sort({b=-1})
    local ret,val=cursor:next()
    while val do
        mydump(val,"result")
        ret,val=cursor:next()
    end

end

local function test_and()
    local data={
        {a=1},
        {a=2},
        {a=3},
        {a=4},
    }

    local cursor=tquery:find(data,{a=1},100)
    cursor:sort({b=-1})
    local ret,val=cursor:next()
    while val do
        mydump(val,"result")
        ret,val=cursor:next()
    end
end

local function test_gte()
    local data={
        {a=10},
        {a=11},
        {a=20},
        {a=30},
        {a=40},
    }

    local cursor=tquery:find(data,{a={["$gt"]=10,["$lt"]=20}},100)
    cursor:sort({b=-1})
    local ret,val=cursor:next()
    while val do
        mydump(val,"----------------->result")
        ret,val=cursor:next()
    end
end

local function test_in()
    local data={
        {a=1},
        {a=2},
        {a=3},
        {a=4},
    }

    local cursor=tquery:find(data,{a={["$nin"]={1,2,3,}}},100)
    cursor:sort({b=-1})
    local ret,val=cursor:next()
    while val do
        -- error("sdfsd")
        mydump(val,"---====-----result")
        mydump(ret,"---====-----result")
        ret,val=cursor:next()
    end

end


local function test_1()
    local data={
        {a=1},
        {a=2},
        {a=10},
        {a=6,b=1},
        {a=6,c={d=1}},
    }

    local cursor=tquery:find(data,{['$or']={c={d=1},a=10,b={["$in"]={1}}}},100)
    cursor:sort({b=-1})

    for index, item in cursor:pairs() do
        mydump(index,"========-----index")
        mydump(item,"========-----item")
    end
    -- local ret,val=cursor:next()
    -- while val do
    --     mydump(val,"========-----val")
    --     mydump(ret,"========-----ret")
    --     ret,val=cursor:next()
    -- end

end

local function test_2()
    local data={
        {week={1,2,3,4},lvl=1},
        {week={1,2,3,4},lvl=2},
        {week={1,2,3,},lvl=2},
    }

    local cursor=tquery:find(data,{
        lvl={['$gte']=2,},
        week={
            ["$include"]=4
        }
    },100)
    -- cursor:sort({b=-1})

    for index, item in cursor:pairs() do
        mydump(index,"========-----result")
        mydump(item,"========-----result")
    end
    -- local ret,val=cursor:next()
    -- while val do
        -- mydump(val,"========-----result")
        -- ret,val=cursor:next()
    -- end

end
print("==============================")
-- test_nil()
-- test_gte()
-- test_search()
-- test_in()
--test_gte()
test_1()

local function test_3()
    local a=10
    if a==1 then
        for i=1,a do
            print(i,v)
        end
    else
        for i=1,a do 
            print(i,v)
        end
    end
end	
