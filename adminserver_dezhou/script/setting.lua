local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local keysutils = require "keysutils"
local genid = require "genid"

local _M = {}
local CMD = {}


function CMD.setzixun(red)
	local result = {}
    -- 设置咨询
    -- local arg=ngx.req.get_uri_args()
    local arg = ngx.req.get_post_args()
	table.dumpdebug(arg,'set ___ args::::')
    local zixuntext = arg.count
    local title = arg.title

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if not ok then
	    result.code = 10001
	    result.data = '数据库错误'
	    return result
	    -- ngx.exit(401)
	end
    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("zixun")
    local res = col1:find_one({_id='zixun'})
    col1:update({_id='zixun'},{['$set']={_id='zixun',title=title, content=zixuntext,timestamp=os.time()}},1,0)
    conn:close()

    result.code = 20000
    result.data = '设置成功'
    return result
end


function CMD.getzixun(red)
	-- local arg=ngx.req.get_uri_args()
	local args = ngx.req.get_post_args()
	table.dumpdebug(args,'args::::')

	local result = {}
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if not ok then
	    result.code = 10001
	    result.data = '数据库错误'
	    return result
	    -- ngx.exit(401)
	end

    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("zixun")
    local res = col1:find_one({_id='zixun'})
    conn:close()
    if not res then
	    result.code = 20000
	    result.data = {}
	    result.data.title = ''
	    result.data.count = ''
	    result.data.timestamp = os.time()
	    return result
    end

	result.data = {}
	result.data.count = res.content
	result.data.title = res.title
	result.data.timestamp = res.timestamp
	result.code = 20000
	return result
end

function CMD.setaboutme(red)
    local result = {}
    -- 设置咨询
    -- local arg=ngx.req.get_uri_args()
    local arg = ngx.req.get_post_args()
    table.dumpdebug(arg,'_________setaboutme ___ args::::')
    local context = arg.count
    local title = arg.title

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if not ok then
        result.code = 10001
        result.data = '数据库错误'
        return result
        -- ngx.exit(401)
    end
    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("aboutme")
    local res = col1:find_one({_id='aboutme'})
    col1:update({_id='aboutme'},{['$set']={_id='aboutme',title=title, content=context,timestamp=os.time()}},1,0)
    conn:close()

    result.code = 20000
    result.data = '设置成功'
    return result
end


function CMD.getaboutme(red)
    -- local arg=ngx.req.get_uri_args()
    local args = ngx.req.get_post_args()
    table.dumpdebug(args,'_________setaboutme args::::')

    local result = {}
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if not ok then
        result.code = 10001
        result.data = '数据库错误'
        return result
        -- ngx.exit(401)
    end

    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("aboutme")
    local res = col1:find_one({_id='aboutme'})
    conn:close()
    if not res then
        result.code = 20000
        result.data = {}
        result.data.title = ''
        result.data.count = ''
        result.data.timestamp = os.time()
        return result
    end

    result.data = {}
    result.data.count = res.content
    result.data.title = res.title
    result.data.timestamp = res.timestamp
    result.code = 20000
    return result
end


function CMD.sethelp(red)
    local result = {}
    -- 设置咨询
    -- local arg=ngx.req.get_uri_args()
    local arg = ngx.req.get_post_args()
    table.dumpdebug(arg,'set ___ args::::')
    local rumen = arg.rumen
    local changjian = arg.changjian
    local service = arg.service

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if not ok then
        result.code = 10001
        result.data = '数据库错误'
        return result
        -- ngx.exit(401)
    end
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("helper")
    local res = col1:find_one({_id='helper'})
    col1:update({_id='helper'},{['$set']={_id='helper',rumen=rumen, changjian=changjian,service=service,timestamp=os.time()}},1,0)
    conn:close()

    result.code = 20000
    result.data = '设置成功'
    return result
end


function CMD.gethelp(red)
    -- local arg=ngx.req.get_uri_args()
    local args = ngx.req.get_post_args()

    local result = {}
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if not ok then
        result.code = 10001
        result.data = '数据库错误'
        return result
        -- ngx.exit(401)
    end

    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("helper")
    local res = col1:find_one({_id='helper'})
    conn:close()
    if not res then
        result.code = 20000
        result.data = {}
        result.data.rumen = ''
        result.data.changjian = ''
        result.data.service = ''
        result.data.timestamp = os.time()
        return result
    end
    result.data = {}
    result.data.rumen = res.rumen
    result.data.changjian = res.changjian
    result.data.service = res.service
    result.data.timestamp = res.timestamp
    result.code = 20000
    return result
end


function CMD.setrumen(red)
    local result = {}
    -- 设置咨询
    -- local arg=ngx.req.get_uri_args()
    local arg = ngx.req.get_post_args()
    table.dumpdebug(arg,'set ___ setrumensetrumensetrumensetrumensetrumen::::')
    local zixuntext = arg.count
    local title = arg.title

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if not ok then
        result.code = 10001
        result.data = '数据库错误'
        return result
        -- ngx.exit(401)
    end
    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("rumen")
    local res = col1:find_one({_id='rumen'})
    col1:update({_id='rumen'},{['$set']={_id='rumen',title=title, content=zixuntext,timestamp=os.time()}},1,0)
    conn:close()

    result.code = 20000
    result.data = '设置成功'
    return result
end


function CMD.getrumen(red)
    -- local arg=ngx.req.get_uri_args()
    local args = ngx.req.get_post_args()
    table.dumpdebug(args,'args::::')

    local result = {}
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if not ok then
        result.code = 10001
        result.data = '数据库错误'
        return result
        -- ngx.exit(401)
    end

    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("rumen")
    local res = col1:find_one({_id='rumen'})
    conn:close()
    if not res then
        result.code = 20000
        result.data = {}
        result.data.title = ''
        result.data.count = ''
        result.data.timestamp = os.time()
        return result
    end
    result.data = {}
    result.data.count = res.content
    result.data.title = res.title
    result.data.timestamp = res.timestamp
    result.code = 20000
    return result
end

-- add
function CMD.addchangjian(red)
    local result = {}
    -- 设置咨询
    -- local arg=ngx.req.get_uri_args()
    local arg = ngx.req.get_post_args()
    table.dumpdebug(arg,'add changjian ___ args::::')
    local zixuntext = arg.count
    local title = arg.title

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if not ok then
        result.code = 10001
        result.data = '数据库错误'
        return result
        -- ngx.exit(401)
    end
    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("changjian")
    col1:insert({{_id=genid.gen(),title=title,content=zixuntext,time=os.time()}})
    conn:close()

    result.code = 20000
    result.data = '添加成功'
    return result
end

function CMD.delchangjian(red)
    local result = {}
    -- 设置咨询
    local arg=ngx.req.get_uri_args()
    -- local arg = ngx.req.get_post_args()
    table.dumpdebug(arg,'set ___ args::::')
    
    if not arg.id or arg.id == '' then
        result.code = 10000
        result.data = '参数错误10000'
        return result
    end

    local ok,id = pcall(tonumber,arg.id)
    if not ok then 
        result.code = 10003
        result.data = '参数错误10003'
        return result
    end


    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if not ok then
        result.code = 10001
        result.data = '数据库错误'
        return result
        -- ngx.exit(401)
    end
    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("changjian")

    local ok,err = col1:delete({_id=id},0,0)
    if err then
        table.dumpdebug(err,"_________mongo del____")
        result.code = 10002
        result.data = '删除失败10002'
        return result
    end
    conn:close()

    result.code = 20000
    result.data = '设置成功'
    return result
end

function CMD.getchangjian(red)
    -- local arg=ngx.req.get_uri_args()
    local args = ngx.req.get_post_args()
    table.dumpdebug(args,'args::::')

    local result = {}
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if not ok then
        result.code = 10001
        result.data = '数据库错误'
        return result
        -- ngx.exit(401)
    end

    local data = {}
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("changjian")
    local cursor = col1:find({})
    local ret = cursor:sort({time=-1})

    for index, item in pairs(ret) do
      table.insert(data,item)
    end

    conn:close()

    result.data = data
    result.code = 20000
    return result
end

function CMD.getchangjian_client(red)
    -- local arg=ngx.req.get_uri_args()
    local args = ngx.req.get_post_args()
    table.dumpdebug(args,'args::::')

    local result = {}
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if not ok then
        result.errcode = 10001
        result.errmsg = '数据库错误'
        return result
        -- ngx.exit(401)
    end

    local data = {}
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("changjian")
    local cursor = col1:find({})
    local ret = cursor:sort({time=-1})

    for index, item in pairs(ret) do
        table.insert(data,item)
    end

    conn:close()

    result.data = data
    result.errcode = 0
    return result
end


function CMD.setfuwu(red)
    local result = {}
    -- 设置咨询
    -- local arg=ngx.req.get_uri_args()
    local arg = ngx.req.get_post_args()
    table.dumpdebug(arg,'set ___ args::::')
    local zixuntext = arg.count
    local title = arg.title

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if not ok then
        result.code = 10001
        result.data = '数据库错误'
        return result
        -- ngx.exit(401)
    end
    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("fuwu")
    local res = col1:find_one({_id='fuwu'})
    col1:update({_id='fuwu'},{['$set']={_id='fuwu',title=title, content=zixuntext,timestamp=os.time()}},1,0)
    conn:close()

    result.code = 20000
    result.data = '设置成功'
    return result
end


function CMD.getfuwu(red)
    -- local arg=ngx.req.get_uri_args()
    local args = ngx.req.get_post_args()
    table.dumpdebug(args,'args::::')

    local result = {}
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if not ok then
        result.code = 10001
        result.data = '数据库错误'
        return result
        -- ngx.exit(401)
    end

    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("fuwu")
    local res = col1:find_one({_id='fuwu'})
    conn:close()
    if not res then
        result.code = 20000
        result.data = {}
        result.data.title = ''
        result.data.count = ''
        result.data.timestamp = os.time()
        return result
    end
    result.data = {}
    result.data.count = res.content
    result.data.title = res.title
    result.data.timestamp = res.timestamp
    result.code = 20000
    return result
end





function _M.invoke(name)
    local method = ngx.req.get_method()
    if string.upper(method) == 'OPTIONS' then
        ngx.say('ok')
        return
    end
    local arg=ngx.req.get_uri_args()
    ngx.log(ngx.DEBUG,'=================================> function:',name,',data:',cjson.encode(arg))

    local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
    ngx.header['Content-Type'] = 'application/json; charset=utf-8'

    if arg.uid then
        local mainkey = keysutils.get_user_main_key(arg.uid)
        ngx.log(ngx.DEBUG,'_______main key____ :', mainkey)
        ngx.log(ngx.DEBUG,'_______uid __ :', arg.uid )
        local f = CMD[name]
        if not TEST then
            local l = redislock.new(rediscli,"lock:"..mainkey,10)
            if l:lock() then
                local result = f(rediscli)
                if result.errcode and result.errcode~=0 then
                    result.errmsg=config.get('errmsg','e'..result.errcode)
                end
                ngx.say(cjson.encode(result))
                l:unlock()
            end
        else
            local result = f(rediscli)
            if result.errcode and result.errcode~=0 then
                result.errmsg=config.get('errmsg','e'..result.errcode)
            end
            ngx.log(ngx.DEBUG,'<================================= function:',name,",data:",cjson.encode(result))
            ngx.say(cjson.encode(result))
        end
    else
        local f = CMD[name]
        if not TEST then
            local l=redislock.new(rediscli,"lock:".."adminserver",10)
            if l:lock() then
                local result = f(rediscli)
                if result.errcode and result.errcode~=0 then
                    result.errmsg=config.get('errmsg','e'..result.errcode)
                end
                ngx.say(cjson.encode(result))
                l:unlock()
            end
        else
            local result = f(rediscli)
            if result.errcode and result.errcode~=0 then
                result.errmsg=config.get('errmsg','e'..result.errcode)
            end
            ngx.log(ngx.DEBUG,'<================================= function:',name,",data:",cjson.encode(result))
            ngx.say(cjson.encode(result))
        end
    end

    -- ngx.say("hello")
end


return _M

