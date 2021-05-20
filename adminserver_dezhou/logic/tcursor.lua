local cursor_methods = { }
local cursor_mt = { __index = cursor_methods }
if not device then
    require "functions"
end
local nolog=true
local function mydump(value, desciption, nesting)
    if nolog then
        return true
    end
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

local function new_cursor(tbl, query,num_each_query)
    return setmetatable ( {
            tbl = tbl ;
            query = query ;
            limit_n=0;
            results = { } ;
            done = false ;
            i = 0;
            id = false ;
            num_each = num_each_query;
        } , cursor_mt )
end

local function isbasic(t)
    if t=="number" then
        return true
    elseif t=="string" then
        return true
    elseif t=="boolean" then
        return true
    end
end

local function istbl(t)
    if t=="table" then
        return true
    end
end

local function isunknow(t)
    if t=="function" then
        return true
    elseif t=="userdata" then
        return true
    end
end


local function iscmd(t)
    if type(t)=='string' and string.sub(t,1,1)=="$" then
        return true
    end
end

local function getcmdname(t)
    local subStr =string.sub(t, 2, -1)
    return subStr
end

local function deepget(parent,k,column)
    local function get(d,k)
        return d[k]
    end

    local cur=column

    for i, v in ipairs( parent ) do
        local ok,cur1=pcall(get,cur,v)
        cur=cur1
        if not ok then
            return false
        end
    end

    local ok,val=pcall(get,cur,k)
    return ok,val
end

local function deepget1(parent,column)
    local function get(d,k)
        return d[k]
    end

    local cur=column

    for i, v in ipairs( parent ) do
        local ok,cur1=pcall(get,cur,v)
        cur=cur1
        if not ok then
            return false
        end
    end
    return true,cur
end

local cmd={}
local col={}


function cmd.cmd_eq(parent,k,v,data)
    local ok,val=deepget(parent,k,data)
    if not ok then
        return false
    end

    return val==v
end

function cmd.cmd_or( parent,k,v,data )
    for k1, v1 in pairs( v ) do
        local curparent=clone(parent)
        local ok=col.simplequery(curparent,k1,v1,data)
        if ok  then
            return true
        end
    end

    return false
end

function cmd.cmd_gte(parent,cmd,v,data)
    local ok,val=deepget1(parent,data)
    if not ok then
        return false
    end

    return val>=v
end


function cmd.cmd_lte(parent,cmd,v,data)
    local ok,val=deepget1(parent,data)
    if not ok then
        return false
    end

    return val<=v
end

function cmd.cmd_gt(parent,k,v,data)
    local ok,val=deepget1(parent,data)
    if not ok then
        return false
    end

    return val>v
end


function cmd.cmd_lt(parent,k,v,data)
    local ok,val=deepget1(parent,data)
    if not ok then
        return false
    end

    return val<v
end

function cmd.cmd_ne(parent,k,v,data)
    local ok,val=deepget1(parent,data)
    if not ok then
        return false
    end

    return val~=v
end

function cmd.cmd_in(parent,cmd,v,data)

    local ok,val=deepget1(parent,data)
    if not ok then
        return false
    end

    for _, v1 in ipairs( v ) do

        if v1==val then
            return true
        end
    end


    return false
end

function cmd.cmd_nil(parent,k,v,data)
    local ok,val=deepget(parent,k,data)
    return not ok
end

function cmd.cmd_nin(parent,k,v,data)
    local ok,val=deepget1(parent,data)
    if not ok then
        return false
    end

    for _, v1 in ipairs( v ) do

        if v1==val then
            return false
        end
    end


    return true
end

function cmd.cmd_include(parent,k,v,data)
    -- print("v=",v)
    local ok,val=deepget1(parent,data)
    if not ok then
        return false
    end

    for _, v1 in ipairs( val ) do

        if v1==v then
            return true
        end
    end


    return false
end

function cmd.cmd_ninclude(parent,k,v,data)
    local ok,val=deepget1(parent,data)
    if not ok then
        return false
    end

    for _, v1 in ipairs( val ) do

        if v1==v then
            return false
        end
    end


    return true
end


function col.simplequery( parent,k,v,column )
    local t=type(v)
    if iscmd(k) then
        local cmdname=getcmdname(k)

        local f=cmd['cmd_'..cmdname]

        if f(parent,k,v,column)  then
            return true
        end
    elseif isbasic(t) then

        local f=cmd['cmd_eq']
        if f(parent,k,v,column)  then
            return true
        end

        -- error("asdfsd")
    else
        
        -- mydump(k)
        for k1, v1 in pairs( v ) do
            local curparent=clone(parent)
            table.insert(curparent,k)
 
            if not col.simplequery(curparent,k1,v1,column) then
                -- error("asdfsd")
                return false
            end
        end
        return true
    end
end


function col.query(tbl,query,i,size)
    local t={}
    t.CursorNotFound=1
    local cid,result=0,{}
    local counter=0

    for index, column in ipairs( tbl ) do
        if index==i then
            t.CursorNotFound=nil
        end

        local pass=true
        for k, v in pairs( query ) do
            local parent={}
            pass=col.simplequery(parent,k,v,column)
            if not pass then
                break
            end
        end
        -- print("query pass=",pass,i)
        if pass then
            counter=counter+1
            if counter>i then
                table.insert(result,clone(column))

                if #result>size then
                    break
                end
            end
        end
    end
    return cid,result,t
end

function col.getmore(tbl,query,id,size,i)
    local t={}
    t.CursorNotFound=1
    local cid,result=0,{}
    local counter=0

    for index, column in ipairs( tbl ) do
        if index==i then
            t.CursorNotFound=nil
        end

        local pass=true
        for k, v in pairs( query ) do
            local parent={}
            pass=col.simplequery(parent,k,v,column)
            if not pass then
                break
            end
        end
        -- print("query pass=",pass,i)
        if pass then
            counter=counter+1
            if counter>i then
                table.insert(result,clone(column))

                if #result>size then
                    break
                end
            end
        end
    end
    return cid,result,t
end



function cursor_methods:limit(n)
    assert(n)
    self.limit_n = n
end

function cursor_methods:sort(field, size)
    size = size or 10000
    if size < 2 then return nil, "number of object must > 1" end
    if not field then return nil, "field should not be nil" end

    local key, asc, t
    for k,v in pairs(field) do
        key = k
        asc = v
        break
    end

    if asc ~= 1 and asc ~= -1 then return nil, "order must be 1 or -1" end

    local sort_f = 
    function(a, b) 
        if not a and not b then return false end
        if not a then return true end
        if not b then return false end
        if not a[key] and not b[key] then return false end
        if not a[key] then return true end
        if not b[key] then return false end
        if asc == 1 then
            return a[key] < b[key]
        else
            return a[key] > b[key]
        end
    end

    if #self.results > self.i then
           table.sort(self.results, sort_f)
    elseif #self.results == 0 and self.i == 0 then
       if self.num_each == 0 and self.limit_n ~= 0 then
           size = self.limit_n
       elseif self.num_each ~= 0 and self.limit_n == 0 then
           size = self.num_each
       else
           size = (self.num_each < self.limit_n 
                       and self.num_each) or self.limit_n
       end

       self.id, self.results, t = col.query(self.tbl,self.query,self.i, size)
       table.sort(self.results, sort_f)
    else
       return nil, "sort must be an array"
    end
    return self.results
end

function cursor_methods:next()
    if self.limit_n > 0 and self.i >= self.limit_n then return nil end

     local v = self.results [ self.i + 1 ]
     if v ~= nil then
         self.i = self.i + 1
         self.results [ self.i ] = nil
         return self.i , v
     end

     if self.done then return nil end

     local t
     if not self.id then
         self.id, self.results, t = col.query(self.tbl,self.query, self.i, self.num_each)
         if self.id == 0 then
             self.done = true
         end
     else
        self.id, self.results, t = col.getmore(self.tbl,self.query,self.id,self.num_each, self.i)
        if self.id == 0 then
         self.done = true
        elseif t.CursorNotFound then
         self.id = false
        end
     end
     return self:next ( )
end

function cursor_methods:pairs( )
    return self.next, self
end

return new_cursor