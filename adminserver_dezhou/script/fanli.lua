local cjson     = require "cjson"
local string    = require "string"
local str       = require "resty.string"
local table_new = require "table.new"
local table     = require "table"
local redis     = require "redis"
local http      = require "resty.http"
local sha1      = require "resty.sha1"
local jwt       = require "resty.jwt"
local keysutils = require "keysutils"
local utils     = require "utils"
local mongo 	= require "resty.mongol"
local genid 	= require "genid"
local userlogic = require "userlogic"
local usermodel = require "usermodel"


require "functions"


local fanli = {}

local function getbasefanli(red)
    local basefanli = red:get(keysutils.get_base_fanli_key())
    if not basefanli then
    	basefanli =1
        red:set(keysutils.get_base_fanli_key(),basefanli)
    else
    	local ok,fanli = pcall(tonumber,basefanli)
    	if not ok then
    		basefanli = fanli
    	end
    end
    return basefanli
end

local function setfanlifangka(red,col ,dailiuid,uid,flpercent, cnt ,level , chongzhicnt, czkey)
	local cztype = 'coin'
	local flcnt = 0

    flpercent = flpercent or 1
    flpercent =tonumber(flpercent)
    if flpercent <= 0 then
        flpercent = 1
    end

	local u = userlogic.loaduser(red, dailiuid)
	if u and u.daili == 1 then
		flcnt = flpercent * cnt / 100
		u:shangfen(flcnt, cztype)

		local doc = {}
		doc._id = genid.gen()
		doc.dailiuid = dailiuid
		doc.fanlicnt = flcnt
		doc.percent  = flpercent
		doc.level = level
		doc.czuid = uid
		doc.czcount = cnt
        doc.chongzhicnt = chongzhicnt
        doc.czkey = czkey
		doc.timestamp = os.time()
		col:insert({doc})
	end
	return flcnt
end

-- dailiuid     代理uid
-- uid          充值玩家id
-- flpercent    返现百分比例
-- level        等级level
-- chongzhicnt  充值额度
-- czkey        充值订单ID
-- 8个参数
local function setfanlicoin(red,col ,dailiuid,uid,flpercent,sjfanli,xiajifanli , level , chongzhicnt, czkey)
    local cztype = 'coin'
    local flcnt = 0

    flpercent = flpercent or 1
    flpercent =tonumber(flpercent)
    if flpercent <= 0 then
        flpercent = 1
    end

    local u = userlogic.loaduser(red, dailiuid)
    if u and u.daili == 1 then
        flcnt = flpercent * chongzhicnt / 100
        u:shangfen(flcnt, cztype)

        local doc = {}
        doc._id = genid.gen()
        doc.dailiuid = dailiuid
        doc.fanlicnt = flcnt
        doc.percent  = flpercent
        doc.sjfanli = sjfanli
        doc.xiajifanli = xiajifanli
        doc.level = level
        doc.czuid = uid
        doc.czcount = chongzhicnt
        doc.chongzhicnt = chongzhicnt
        doc.czkey = czkey
        doc.timestamp = os.time()
        col:insert({doc})
    end
    return flcnt
end

-- 得到玩家代理 等级 返现金额
function fanli.getyongjinlevel2cnt(level)
    local cnt  = 0
    if level == 1 then
        cnt = 60
    elseif level == 2 then
        cnt = 70
    elseif level == 3 then
        cnt = 80
    elseif level == 4 then
        cnt = 100
    elseif level == 5 then
        cnt = 120
    elseif level == 6 then
        cnt = 140
    elseif level == 7 then
        cnt = 160
    elseif level == 8 then
        cnt = 180
    elseif level == 9 then
        cnt = 200
    elseif level == 10 then
        cnt = 220
    elseif level == 11 then
        cnt = 230
    else
        cnt = 60
    end
    return cnt
end

function fanli.fanyongjin()

end



-- redis,充值数,充值玩家的uid
function fanli.fanli2(red,cnt,czuid,czkey)
    local arg=ngx.req.get_uri_args()
    local cztype = 'fangka'

    local name = arg.name
    local uid = arg.uid

    local result = {}
    local basefanli = getbasefanli(red)

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if err then
        result.code = 10002
        result.data = '参数或者密码错误10002'
        return result
    end


    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("chongzhifanli")
    local col2 = db:get_col("tuijianren")

    local data = {}
    -- local cursor = col1:find({uid={['$gt']=1}})
    local row = col2:find_one({uid=czuid})
    if not row then
        -- 没有上级的1级代理 充值给自己返利
        -- local u = userlogic.loaduser(red, czuid)
        -- if u.daili == 1 and u.sjfanli > 0 then
        --     table.dumpdebug("======ggggggggggg 充值 ==>>>>>>>>>>>>>>")
        --     setfanlicoin(red,col1,czuid,czuid, u.sjfanli , u.sjfanli, 0 , 0, cnt, czkey)
        -- end

        result.code = 10003
        result.data = '该玩家没绑定代理'
        return result
    end

    table.dumpdebug('1111111111111111111111111111111')

    -- 三级代理 uid
    local d1fanli = 0
    local d2fanli = 0
    local d3fanli = 0

    local duid3 = row['uid3']
    local duid2 = row['uid2']
    local duid1 = row['uid1']
    if duid3 then
        local u = userlogic.loaduser(red, row['uid3'])
        if u.daili == 1 and u.shangji == 0 and u.sjfanli == 0 then
            u.sjfanli = basefanli
            u:save()
        end
        d3fanli = u.sjfanli
    end
    if duid2 then
        local u = userlogic.loaduser(red, row['uid2'])
        if u.daili == 1 and u.shangji == 0 and u.sjfanli == 0 then
            u.sjfanli = basefanli
            u:save()
        end
        d2fanli = u.sjfanli
    end
    if duid1 then
        local u = userlogic.loaduser(red, row['uid1'])
        if u.daili == 1 and u.shangji == 0 and u.sjfanli == 0 then
            u.sjfanli = basefanli
            u:save()
        end
        d1fanli = u.sjfanli
    end

    -- 代理自己充值给自己返利
    if true then
        local u = userlogic.loaduser(red, czuid)
        if u.daili == 1 and u.shangji == 0 and u.sjfanli == 0 then
            u.sjfanli = basefanli
            u:save()
        end
    end

    table.dumpdebug('2222222222222222222222222222222')

    -- 计算返利
    
    -- 如果自己是代理, 自己给自己返利
    if true then
        local u = userlogic.loaduser(red, czuid)
        if u.daili == 1 and u.sjfanli > 0 then
            setfanlicoin(red,col1,czuid,czuid, u.sjfanli , u.sjfanli, 0 , 0, cnt, czkey)
        end
    end

    -- 3级代理返利
    if duid1 then
        local u = userlogic.loaduser(red, duid1)
        if u.daili == 1 and u.sjfanli > 0 then
            local u1 = userlogic.loaduser(red,czuid)
            table.dumpdebug(u.daili,"======3级代理返利比例========")

            if u1 and u1.daili == 1 then
                local flcnt = u.sjfanli - u1.sjfanli
                if flcnt > 0 then
                    fanli1 = setfanlicoin(red,col1,duid1,czuid, flcnt , u.sjfanli, u1.sjfanli , 3, cnt, czkey)
                end
            else
                if u.sjfanli > 0 then
                    fanli1 = setfanlicoin(red,col1,duid1,czuid, u.sjfanli , u.sjfanli, 0 , 3, cnt, czkey)
                end
            end
            
        end
    end

    table.dumpdebug('333333333333333333333333333333333')

    -- 2级代理返利
    if duid2 then
        local u = userlogic.loaduser(red, duid2)
        if u.daili == 1 and u.sjfanli > 0 then
            table.dumpdebug(u.daili,"======2级代理返利比例========")
            local flcnt = d2fanli - d1fanli
            if flcnt > 0 then
                fanli2 = setfanlicoin(red,col1,duid2,czuid, flcnt ,u.sjfanli , d1fanli , 2, cnt, czkey)
            end
        end
    end

    table.dumpdebug('44444444444444444444444444444444444')

    -- 1级代理返利
    if duid3 then
        local u = userlogic.loaduser(red, duid3)
        if u.daili == 1 and u.sjfanli > 0 then
            table.dumpdebug(u.daili,"======3级代理返利比例========")
            local flcnt = d3fanli - d2fanli
            if flcnt > 0 then
                fanli3 = setfanlicoin(red,col1,duid3,czuid, flcnt ,u.sjfanli,d2fanli , 1, cnt, czkey)
            end
        end
    end

    -- setfanlicoin(red,col ,dailiuid,uid,flpercent, level , chongzhicnt, czkey)

    result.code = 20000
    result.data = data
    return result
end


return fanli
