local cjson 		= require "cjson"
local string 		= require "string"
local string 		= require "string"
local table 		= require "table"
local table 		= require "table"
local mongo 		= require "resty.mongol"
local redis 		= require "redis"
local wrapper       = require "wrapper"
local keysutils 	= require "keysutils"
local config 		= require "config"
local utils			= require "utils"
local userlogic     = require "userlogic"
local usermodel     = require "usermodel"
local genid         = require "genid"

 require "functions"


local _M = {}
local CMD = {}

local function recharge_info(red,uid)
    local result = {}
    local data = {}
    local db,conn = wrapper.conn_mongl()
    if not db then
        result.code= ERR_BASE_CODE+60
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end
    local col = db:get_col("users")
    local fuser =  col:find_one({uid=uid})
    if not fuser then
        result.code= ERR_BASE_CODE+7
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local col1 = db:get_col("chongzhi")

    local cursor = col1:find({uid=uid})
    local ret = cursor:sort({time=-1})
    wrapper.close_mongl(conn)

    for k, val in pairs(ret) do
        if val['uid'] then
            local u = userlogic.loaduser(red,val['uid'])
            if u then
                local rechargeinfo = {}
                rechargeinfo.id = val['_id']
                rechargeinfo.uid = val['uid']
                rechargeinfo.name = u['name']
                rechargeinfo.count = val['count']
                rechargeinfo.rmb = val['rmb']
                rechargeinfo.zuanshi = val['zuanshi']
                rechargeinfo.status = val['status'] or 1 
                rechargeinfo.time = val['timestamp'] or val['time']

                table.dumpdebug(rechargeinfo,"======rechargeinfo ==>>>>")
                table.insert(data,rechargeinfo)
            end
        end
    end

    local count = 0
    for k,v in pairs(data) do
        count = count + 1
    end
    table.dumpdebug(count,"=====count =====>>>")
    if count > 1 then
        table.sort(data, function(a,b) return a.time > b.time end)
    end

    result.data = data
    result.code = nil
    return result
end

local function exchangefangka(red, uid, coin, bilv)
    local result = {}
    local data = {}

    local u = userlogic.loaduser(red,uid)
    local user = u:toparam()
    if user.coin < coin then
        result.code = ERR_BASE_CODE + 78
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local cnt = coin / bilv
    u:xiafen(coin)
    u:shangfen(cnt)

    local db,conn = wrapper.conn_mongl()
    if not db then
        result.code= ERR_BASE_CODE+60
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local col1 = db:get_col("exchange")

    local doc = {}
    doc._id = ''..genid.gen()
    doc.uid = uid
    doc.coin = coin
    doc.bilv = bilv
    doc.fangka = cnt
    doc.t = 1
    doc.timestamp = os.time()

    local ok,err = col1:insert({doc})
    if not ok then
        result.code= ERR_BASE_CODE+1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    wrapper.close_mongl(conn)

    result.code = nil
    result.data = '兑换成功'
    return result
end

local function exchangecoin(red, uid, fangka, bilv)
    local result = {}
    local data = {}

    local u = userlogic.loaduser(red,uid)
    local user = u:toparam()
    if user.fangka < fangka then
        result.code = ERR_BASE_CODE + 84
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local cnt = fangka * bilv
    u:xiafen(fangka)
    u:shangfen(cnt)

    local db,conn = wrapper.conn_mongl()
    if not db then
        result.code= ERR_BASE_CODE+60
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local col1 = db:get_col("exchange")

    local doc = {}
    doc._id = ''..genid.gen()
    doc.uid = uid
    doc.fangka = fangka
    doc.bilv = bilv
    doc.coin = cnt
    doc.t = 2
    doc.timestamp = os.time()

    local ok,err = col1:insert({doc})
    if not ok then
        result.code= ERR_BASE_CODE+1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    wrapper.close_mongl(conn)

    result.code = nil
    result.data = '兑换成功'
    return result
end

-- 获取商城信息
function CMD.get_shop_config(red)
	local result = {}
	local data = {}
	local arg=ngx.req.get_uri_args()
	ngx.header.content_type = "application/json; charset=utf-8"

    if not arg.uid or arg.uid == '' then
        result.code = ERR_BASE_CODE + 1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local ok,uid = utils.safe2number(arg.uid)
    if not ok or ok  == false then
        result.code = ERR_BASE_CODE + 1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    -- 该玩家充值信息
    local res = recharge_info(red,uid)
    if res.code then
        result.code = res.code
        return result
    end

    data.zuanshi ={}
    data.coin = {}
	local conf = config.get('chongzhi','zuanshi')
	for k,v in pairs(conf) do
		table.insert(data.zuanshi,v)
	end
    table.sort(data.zuanshi,function(a,b) return a.zuanshi < b.zuanshi end)

    local coinconf = config.get('chongzhi','coin')
    for k,v in pairs(coinconf) do
        table.insert(data.coin,v)
    end
    table.sort(data.coin,function(a,b) return a.coin < b.coin end)


	result.data = data
    result.chongzhilist = res.data
	result.code = SUCCEED_CODE
	return result
end

--获取当前玩家充值信息
function CMD.get_recharge_info(red)
    local arg=ngx.req.get_uri_args()

    local result = {}
    local data = {}

    if not arg.uid or arg.uid ~= '' then
    	result.code = ERR_BASE_CODE + 1
    	result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local ok,uid = utils.safe2number(arg.uid)
    if not ok or ok  == false then
    	result.code = ERR_BASE_CODE + 1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local db,conn = wrapper.conn_mongl()
    if not db then
        result.code= ERR_BASE_CODE+60
    	result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end
    local col = db:get_col("users")
    local fuser =  col:find_one({uid=uid})
    if not fuser then
		result.code= ERR_BASE_CODE+7
    	result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local res = recharge_info(red,uid)
    if res.code then
        result.code = res.code
        return result
    end

    result.code = SUCCEED_CODE
    result.data = res.data
    return result
end

--金币兑换房卡
function CMD.coin2fangka(red)
    local arg=ngx.req.get_uri_args()

    local result = {}
    local data = {}

    if not arg.uid or arg.uid == '' or not arg.coin  then
        result.code = ERR_BASE_CODE + 1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local ok,uid = utils.safe2number(arg.uid)
    if not ok or ok  == false then
        result.code = ERR_BASE_CODE + 1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local ok,coin = utils.safe2number(arg.coin)
    if not ok or ok  == false then
        result.code = ERR_BASE_CODE + 1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local bilv = config.get('exchange',"bilv")
    if not bilv then
        result.code = ERR_BASE_CODE + 1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local ret = exchangefangka(red,uid,coin,bilv)
    if ret.code then
        result.code = ret.code
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local u = userlogic.loaduser(red,uid)
    local user = u:toparam()

    result.code = SUCCEED_CODE
    result.data = ret.data
    result.user = user
    return result
end

--房卡兑换金币 
function CMD.fangka2coin(red)
    local arg=ngx.req.get_uri_args()

    local result = {}
    local data = {}

    if not arg.uid or arg.uid == '' or not arg.fangka  then
        result.code = ERR_BASE_CODE + 1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local ok,uid = utils.safe2number(arg.uid)
    if not ok or ok  == false then
        result.code = ERR_BASE_CODE + 1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local ok,fangka = utils.safe2number(arg.fangka)
    if not ok or ok  == false then
        result.code = ERR_BASE_CODE + 1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local bilv = config.get('exchange',"bilv")
    if not bilv then
        result.code = ERR_BASE_CODE + 1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local ret = exchangecoin(red,uid,fangka,bilv)
    if ret.code then
        result.code = ret.code
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local u = userlogic.loaduser(red,uid)
    local user = u:toparam()

    result.code = SUCCEED_CODE
    result.data = ret.data
    result.user = user
    return result
end
-- function CMD.( ... )
--     -- body
-- end

function _M.invoke(name)
    local method = ngx.req.get_method()
    if string.upper(method) == 'OPTIONS' then
        table.dumpdebug(name ,"OPTIONS OPTIONS OPTIONS OPTIONS:::: ")
        ngx.say('ok')
        return
    end
    local arg=ngx.req.get_uri_args()
    ngx.log(ngx.DEBUG,'=================================> function:',name,',data:',cjson.encode(arg))

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

