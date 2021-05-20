local sql = {}

function sql.call(data)
	local func = 'query'..'_'..data.c..'_'..data.m
	local f = sql[func]
	if f then
		return f(data.data)
	else
		return {ok='ng',msg='参数错误'}
	end
end


function sql.query_insert_table(data)
	local sql = "insert into mr_person (uid,phone,nickname,avatar,sex,time) values('%s','%d','%s','%s','%s','%d')"
    local sql = string.format(sql,tostring(data.uid),tonumber(data.phone),tostring(data.nickname),tostring(data.avatar),tostring(data.sex),tonumber(os.time()))
    return sql
end

return sql
