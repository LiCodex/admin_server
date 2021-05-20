local cjson 		= require "cjson"
local string 		= require "string"
local string 		= require "string"
local table 		= require "table"
local table 		= require "table"
local mongo 		= require "resty.mongol"
local redis 		= require "redis"
local wrapper       = require "wrapper"
local keysutils 	= require "keysutils"
local utils 		= require "utils"
require "functions"

-- 调试信息
local err_line       = debug.getinfo(1).currentline

local _M = {}
local CMD = {}


-- local arg=ngx.req.get_uri_args()
-- ngx.header.content_type = "application/json; charset=utf-8"

-- local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
-- local notice = rediscli:get(GAMENAME.."-notice")

-- local result = {}
-- result.ok=true
-- result.notice = notice
-- result.code = 20000
-- ngx.say(cjson.encode(result))


-- 设置滚动公告
function CMD.set_scroll_notice(red)
	local result = {}
	local arg=ngx.req.get_uri_args()
	ngx.header.content_type = "application/json; charset=utf-8"
	local notice = arg.notice

	if not notice or string.len(notice) == 0 then
		result.code = ERR_BASE_CODE +1
    	result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
		return result
	end

	red:set(keysutils.get_notice('scoll'), notice)
	result.code = SUCCEED_CODE
	return result
end

--获取滚动公告
function CMD.get_scroll_notice(red)
	local result = {}
	local arg=ngx.req.get_uri_args()
	ngx.header.content_type = "application/json; charset=utf-8"

	local context = red:get(keysutils.get_notice('scoll'))
	if not context then
		context = ''
	end
	-- result.code = SUCCEED_CODE
	-- result.data = context
	result.errcode = 0
	result.data = context
	return result
end

function CMD.get_scroll_notice_for_ht(red)
	local result = {}
	local arg=ngx.req.get_uri_args()
	ngx.header.content_type = "application/json; charset=utf-8"

	local context = red:get(keysutils.get_notice('scoll'))
	if not context then
		context = ''
	end
	result.code = SUCCEED_CODE
	result.data = context
	return result
end


-- 最新公行
function CMD.set_last_notice(red)
	local result = {}
	local arg=ngx.req.get_uri_args()
	ngx.header.content_type = "application/json; charset=utf-8"
	local notice = arg.notice

	if not notice or string.len(notice) == 0 then
		result.code = ERR_BASE_CODE +1
    	result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
		return result
	end

	red:set(keysutils.get_notice('last'), notice)
	result.code = SUCCEED_CODE
	return result
end

--获取最新公告
function CMD.get_last_notice(red)
	local result = {}
	local arg=ngx.req.get_uri_args()
	ngx.header.content_type = "application/json; charset=utf-8"

	local context = red:get(keysutils.get_notice('last'))
	if not context then
		context = ''
	end
	result.code = SUCCEED_CODE
	result.data = context
	return result
end

-- 健康公告
function CMD.set_health_notice(red)
	local result = {}
	local arg=ngx.req.get_uri_args()
	ngx.header.content_type = "application/json; charset=utf-8"
	local notice = arg.notice

	if not notice or string.len(notice) == 0 then
		result.code = ERR_BASE_CODE +1
    	result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
		return result
	end

	red:set(keysutils.get_notice('health'), notice)
	result.code = SUCCEED_CODE
	return result
end

--获取健康公告
function CMD.get_health_notice(red)
	local result = {}
	local arg=ngx.req.get_uri_args()
	ngx.header.content_type = "application/json; charset=utf-8"

	local context = red:get(keysutils.get_notice('health'))
	if not context then
		context = ''
	end
	result.code = SUCCEED_CODE
	result.data = context
	return result
end

-- 外挂公告
function CMD.set_waigua_notice(red)
	local result = {}
	local arg=ngx.req.get_uri_args()
	ngx.header.content_type = "application/json; charset=utf-8"
	local notice = arg.notice

	if not notice or string.len(notice) == 0 then
		result.code = ERR_BASE_CODE +1
    	result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
		return result
	end

	red:set(keysutils.get_notice('waigua'), notice)
	result.code = SUCCEED_CODE
	return result
end

--获取外挂公告
function CMD.get_waigua_notice(red)
	local result = {}
	local arg=ngx.req.get_uri_args()
	ngx.header.content_type = "application/json; charset=utf-8"

	local context = red:get(keysutils.get_notice('waigua'))
	if not context then
		context = ''
	end
	result.code = SUCCEED_CODE
	result.data = context
	return result
end

--更新公告
function CMD.set_update_notice(red)
	local result = {}
	local arg=ngx.req.get_uri_args()
	ngx.header.content_type = "application/json; charset=utf-8"
	local notice = arg.notice

	if not notice or string.len(notice) == 0 then
		result.code = ERR_BASE_CODE +1
    	result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
		return result
	end

	red:set(keysutils.get_notice('update'), notice)
	result.code = SUCCEED_CODE
	return result
end

--获取更新公告
function CMD.get_update_notice(red)
	local result = {}
	local arg=ngx.req.get_uri_args()
	ngx.header.content_type = "application/json; charset=utf-8"

	local context = red:get(keysutils.get_notice('update'))
	if not context then
		context = ''
	end
	result.code = SUCCEED_CODE
	result.data = context
	return result
end

-- 最新公行
function CMD.set_rule(red)
	local result = {}
	-- ngx.req.read_body()
    -- local arg = ngx.req.get_post_args()
	local arg=ngx.req.get_uri_args()
	ngx.header.content_type = "application/json; charset=utf-8"
	local rule = arg.rule
	table.dumpdebug(arg,'----------rule--------')

	if not rule or string.len(rule) == 0 then
		result.code = ERR_BASE_CODE +1
    	result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
		return result
	end

	red:set(keysutils.get_notice('rule'), rule)
	result.code = SUCCEED_CODE
	return result
end

--获取最新公告
function CMD.get_rule(red)
	local result = {}

	local arg=ngx.req.get_uri_args()

	ngx.header.content_type = "application/json; charset=utf-8"

	local rule = red:get(keysutils.get_notice('rule'))
	if not rule then
		rule = ''
	end
	-- result.code = SUCCEED_CODE
	result.errcode = 0
	result.data = rule
	return result
end


function CMD.set_notice(red)
	local result = {}
	local arg=ngx.req.get_uri_args()
	ngx.header.content_type = "application/json; charset=utf-8"
	local notice = arg.notice

	if not notice or string.len(notice) == 0 then
		result.code = ERR_BASE_CODE +1
    	result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
		return result
	end

	red:set(keysutils.get_notice('scoll'), notice)
	-- red:set(keysutils.get_notice('notice'), notice)
	result.code = SUCCEED_CODE
	return result
end

function CMD.get_notice(red)
	local result = {}
	local data = {}
	local arg=ngx.req.get_uri_args()
	ngx.header.content_type = "application/json; charset=utf-8"

	local txt_notice = red:get(keysutils.get_notice('scoll'))
	if not txt_notice then
		txt_notice = ''
	end

	local txt_rule = red:get(keysutils.get_notice('rule'))
	if not txt_rule then
		txt_rule = ''
	end

	-- local txt_last = red:get(keysutils.get_notice('last'))
	-- if not txt_last then
	-- 	txt_last = ''
	-- end

	-- local txt_health = red:get(keysutils.get_notice('health'))
	-- if not txt_health then
	-- 	   txt_health = ''
	-- end

	-- local txt_waigua  = red:get(keysutils.get_notice('waigua'))
	-- if not txt_waigua then
	-- 	txt_waigua = ''
	-- end

	-- local txt_update = red:get(keysutils.get_notice('update'))
	-- if not txt_update then
	-- 	txt_update = ''
	-- end

    data.notice = txt_notice
    data.rule = txt_rule
    -- data.last = txt_last
    -- data.health = txt_health
    -- data.waigua = txt_waigua
    -- data.update = txt_update

	result.code = SUCCEED_CODE
	result.data = data
	return result
end


function _M.invoke(name)
    local method = ngx.req.get_method()
    if string.upper(method) == 'OPTIONS' then
        table.dumpdebug(name ,"OPTIONS OPTIONS OPTIONS OPTIONS:::: ")
        ngx.say('ok')
        return
    end
    local arg=ngx.req.get_uri_args()
    ngx.log(ngx.DEBUG,'=================================> function:',name,',data:',cjson.encode(arg))

    table.dumpdebug(REDIS_USER_CONFIG,"dddd::")

    local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
    ngx.header['Content-Type'] = 'application/json; charset=utf-8'

    if arg.uid then
        local mainkey = keysutils.get_user_main_key(arg.uid)
        local f = CMD[name]
        if not TEST then
            local l = redislock.new(rediscli,"lock:"..mainkey,10)
            if l:lock() then
                local result = f(rediscli)
                if wrapper.ngx_say(result,name) then
                    ngx.log(ngx.DEBUG,"wrapper return err : has uid - release")
                end
                l:unlock()
            end
        else
            local result = f(rediscli)
            if wrapper.ngx_say(result,name) then
                ngx.log(ngx.DEBUG,"wrapper return err : has uid - TEST")
            end
        end
    else
        local f = CMD[name]
        if not TEST then
            local l=redislock.new(rediscli,"lock:".."adminserver",10)
            if l:lock() then
                local result = f(rediscli)
                if wrapper.ngx_say(result,name) then
                    ngx.log(ngx.DEBUG,"wrapper return err : not uid - release")
                end
                l:unlock()
            end
        else
            local result = f(rediscli)
            if wrapper.ngx_say(result,name) then
                ngx.log(ngx.DEBUG,"wrapper return err : not uid - TEST")
            end
        end
    end

    -- ngx.say("hello")
end


return _M

