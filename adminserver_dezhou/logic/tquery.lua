-- lua 数据库，跟Mongodb差不多
local tquery={}
local new_cursor
if not device then
new_cursor=require "tcursor"
else
new_cursor=import(".tcursor") 
end
function tquery:find( tbl,query,num_each_query )
    return new_cursor(tbl,query,num_each_query or 100)
end

return tquery