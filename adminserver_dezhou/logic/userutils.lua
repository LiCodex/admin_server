local cjson        = require "cjson"
local string       = require "string"
local table_new    = require "table.new"
local table        = require "table"
local jwt          = require "resty.jwt"
local mongo        = require "resty.mongol"
local redis        = require "redis"
local keysutils    = require "keysutils"
local redislock    = require "lock"
local wrapper 		= require "wrapper" 
local utils 		= require "utils"
require 'functions'
local config 		= require "config"

local userutils = {}


-- 消息类型
local msgtype = {}
msgtype.type = 101	-- 申请加入俱乐部分



function userutils.getnumberparam(param)
	if type(param) ~= "number" and param ~= nil then
		local ok , num = utils.safe2number(v)
		if not ok or ok == false then
			return isexist
		end
		return num
	else
		retun param
	end
end


function userutils.getuserinfo(red,uid)
	assert(uid~=nil,"uid == nil")

	-- assert(type(uid) == 'number', 'uid is not number type~')
	if type(uid) ~= "number" then
		local ok , nuid = utils.safe2number(uid)
		if not ok or ok == false then
			return nil
		end
		uid = nuid
	end

 	local u     = userlogic.loaduser(red,uid)
 	if u then
		return u:toparam()
	end
	return nil
end


function userutils.isuserexist(uid)
	local isexist = nil
	assert(uid~=nil,"uid == nil")
	-- assert(type(uid) == 'number', 'uid is not number type~')
	uid = userutils.getnumberparam(uid)
	if not uid then
		return isexist
	end

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return isexist
	end

	local col = db:get_col("users")
	local res = col:find_one({{uid=uid}})
	if not res then
		return nil
	end
	wrapper.close_mongl(conn)
	return true
end


-- 俱乐部相关

-- 玩家已在该俱乐部
function userutils.isclubincludeuid(clubuid,uid)
	local isexist = nil
	assert(uid~=nil,"uid == nil")
	assert(clubuid ~= nil, 'clubuid == nil')

	uid = userutils.getnumberparam(uid)
	clubuid = userutils.getnumberparam(clubuid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return isexist
	end

	local col = db:get_col("club_members")
	
	local res = col:find_one({uid=uid})
	if not res then
		return nil
	end

	wrapper.close_mongl(conn)
	return true
end

-- 俱乐部基本信息
function userutils.getclubinfo(clubuid)
	local isexist = nil
	assert(clubuid ~= nil, 'clubuid == nil')
	clubuid = userutils.getnumberparam(clubuid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return isexist
	end

	local col = db:get_col("club")
	local res = col:find_one({clubuid=clubuid,jiesan=0})
	if not res then
		return nil
	end
	wrapper.close_mongl(conn)
	return res
end

-- 俱乐部详情
function userutils.getclubdetails(clubuid)
	local isexist = nil
	assert(clubuid ~= nil, 'clubuid == nil')
	clubuid = userutils.getnumberparam(clubuid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return isexist
	end

	-- 俱乐部不存在
	if not userutils.getclubinfo(clubuid) then
		return nil
	end

	local col = db:get_col("club_details")
	local res = col:find_one({clubuid=clubuid})
	if not res then
		return nil
	end
	wrapper.close_mongl(conn)
	return res
end

-- 俱乐部会员列表
function userutils.getclubmembers(clubuid)
	local data = {}
	assert(clubuid ~= nil, 'clubuid == nil')
	clubuid = userutils.getnumberparam(clubuid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return nil
	end

	local col = db:get_col("club_members")
	local cursor = col:find({clubuid=clubuid})
	local ret = cursor:sort({timestamp=1})
	for k,v in pairs(ret) do
		local user = userutils.getuserinfo(red, uid)
		table.insert(data,user)
	end
	wrapper.close_mongl(conn)
	return data
end

-- 俱乐部管理员(创建者)
function userutils.getclubadmin(clubuid)
	local adminuid = nil
	assert(clubuid ~= nil, 'clubuid == nil')
	clubuid = userutils.getnumberparam(clubuid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return nil
	end

	local col = db:get_col("club")
	local res = col:find_one({clubuid=clubuid,jiesan=0})
	if not res then
		return nil
	end
	wrapper.close_mongl(conn)

	adminuid = res['uid']
	return adminuid
end

-- 俱乐部消息
function userutils.getclubmessage(clubuid)
	local data = {}
	assert(clubuid ~= nil, 'clubuid == nil')
	clubuid = userutils.getnumberparam(clubuid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return data
	end
	
	-- 俱乐部不存在
	if not userutils.getclubinfo(clubuid) then
		return data
	end

	local col = db:get_col("club_message")
	local cursor = col:find({clubuid=clubuid})
	local ret = cursor:sort({timestamp=1})
	for k,v in pairs(ret) do
		table.insert(data,v)
	end
	wrapper.close_mongl(conn)
	
	return data
end

-- 俱乐部消息
function userutils.pushclubmessage(clubuid,doc)
	local ret = 1
	assert(clubuid ~= nil, 'clubuid == nil')
	clubuid = userutils.getnumberparam(clubuid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return data
	end

	-- 俱乐部不存在
	if not userutils.getclubinfo(clubuid) then
		return data
	end

	local col = db:get_col("club_message")
	local ok ,err = col:insert({doc})
	if ok ~= -1 then
		table.dumpdebug(err,"push message err:")
		return nil,err
	end 
	wrapper.close_mongl(conn)
	
	return ret
end

-- 个人消息
function userutils.pushusermessage(uid,doc)
	local ret = 1
	assert(uid ~= nil, 'uid == nil')
	uid = userutils.getnumberparam(uid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return data
	end

	local col = db:get_col("user_message")
	local ok ,err = col:insert({doc})
	if ok ~= -1 then
		table.dumpdebug(err,"push message err:")
		return nil,err
	end 
	wrapper.close_mongl(conn)
	
	return ret
end

-- 玩家加入的俱乐部分列表
function userutils.getplayerjoinclublist(uid)
	local data = {}
	assert(uid ~= nil, 'uid == nil')
	uid = userutils.getnumberparam(uid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return nil
	end

	local col = db:get_col("club_members")
	local cursor = col:find({uid=uid})
	local ret = cursor:sort({timestamp=1})
	for k,v in pairs(ret) do
		if userutils.getclubinfo(v['clubuid']) then
			local clubinf = userutils.getclubinfo(v['clubuid'])
			local cnt = col:count({clubuid=v['clubuid']})
			clubinf['memcnt'] = cnt
			table.insert(data,clubinf)
		end
	end
	wrapper.close_mongl(conn)
	return data
end

-- 玩家退出俱乐部
function userutils.quitclub(clubuid,uid)
	local code = SUCCEED_CODE

	assert(uid ~= nil, 'uid == nil')
	uid = userutils.getnumberparam(uid)
	clubuid = userutils.getnumberparam(clubuid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return nil
	end

	local col = db:get_col("club_members")
	local res = col:find_one({clubuid=clubuid,uid=uid})
	wrapper.close_mongl(conn)
	if not res then
		code = ERR_BASE_CODE + 74
		return code
	end
	return code
end

function userutils.iscanchongzhi(clubuid,uid)
	local code = SUCCEED_CODE

	assert(uid ~= nil, 'uid == nil')
	uid = userutils.getnumberparam(uid)
	clubuid = userutils.getnumberparam(clubuid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return nil
	end

	local col = db:get_col("club_members")
	local res = col:find_one({clubuid=clubuid,uid=uid})
	wrapper.close_mongl(conn)
	if not res then
		code = ERR_BASE_CODE + 74
		return code
	end
	return code
end

-- 俱乐部充值
function userutils.clubchongzhi(clubuid,uid,count)
	local code = SUCCEED_CODE

	assert(uid ~= nil, 'uid == nil')
	uid = userutils.getnumberparam(uid)
	clubuid = userutils.getnumberparam(clubuid)
	count = userutils.getnumberparam(count)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return nil
	end


	local col = db:get_col("club_details")
	local res = col:update({clubuid=clubuid},{['$inc']={coin=count}})
	if not res then
		code = ERR_BASE_CODE + 74
		return code
	end
    
    local col1 = db:get_col("club_chongzhi")
    local doc = {}
    doc._id = genid.gen()..clubuid
    doc.uid = uid
    doc.clubuid = clubuid
    doc.count = count
    doc.type = 1
    doc.timestamp = os.time()
	wrapper.close_mongl(conn)
    return code
end

-- 获取俱乐部配置
function userutils.getclubconfig(clubuid,uid)
	local code = SUCCEED_CODE
	local data = {}

	assert(uid ~= nil, 'uid == nil')
	uid = userutils.getnumberparam(uid)
	clubuid = userutils.getnumberparam(clubuid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return nil
	end

	local col = db:get_col("club_details")
	local res = col:find_one({clubuid=clubuid})
	wrapper.close_mongl(conn)
	if not res then
		code= ERR_BASE_CODE+1
		return code,data
	end
    
    data.auth_createroom    = res.auth_createroom
    data.auth_fangfei       = res.auth_fangfei
    data.auth_chongzhi      = res.auth_chongzhi
    data.auth_chongzhilist  = res.auth_chongzhilist
    data.gonggao = res.gonggao
    return code,data
end

-- 获取俱乐部帐单
function userutils.getclubchongzhilist(clubuid,uid)
	local code = SUCCEED_CODE
	local data = {}

	assert(uid ~= nil, 'uid == nil')
	uid = userutils.getnumberparam(uid)
	clubuid = userutils.getnumberparam(clubuid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db) 
		code= ERR_BASE_CODE+1
		return code,data,-1
	end

	local col = db:get_col("club_details")
	local res = col:find_one({clubuid=clubuid})
	if not res then
		code= ERR_BASE_CODE+1
		return code,data,-1
	end
    
	local col = db:get_col("club_chongzhi")
	local cursor = col:find({clubuid=clubuid})
    local ret = cursor:sort({timestamp=-1})

    for k,val in pairs(ret) then
        if val['uid'] then
            local user = loaduser(val['uid'])
            val['name'] = user['name']
            val['unionid'] = user['unionid']
            table.insert(data,val)
        end
    end

    wrapper.close_mongl(conn)

    return code,data,-1
end

--保存快速开局设置 
function userutils.save_fastconfig(clubuid,uid,config)
	local code = SUCCEED_CODE
	local data = {}

	assert(uid ~= nil, 'uid == nil')
	uid = userutils.getnumberparam(uid)
	clubuid = userutils.getnumberparam(clubuid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db) 
		code= ERR_BASE_CODE+1
		return code,data,-1
	end

	local col = db:get_col("club_fastconfig")
	local ret,err = col:update({clubuid=clubuid},{['$set']={_id=clubuid,clubuid=clubuid,uid=uid,config=config,timestamp=os.time()}},1,0)
	wrapper.close_mongl(conn)
	if not ret or ret ~= -1 then
		code= ERR_BASE_CODE+1
		return code,err
	end

    return code,nil
end

--加载快速开局设置 
function userutils.load_fastconfig(clubuid,uid)
	local code = SUCCEED_CODE
	local data = {}

	assert(uid ~= nil, 'uid == nil')
	uid = userutils.getnumberparam(uid)
	clubuid = userutils.getnumberparam(clubuid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db) 
		code= ERR_BASE_CODE+1
		return code,data,-1
	end

	local col = db:get_col("club_fastconfig")
	local res= col:find_one({clubuid=clubuid})
	wrapper.close_mongl(conn)
	if not res then
		code= ERR_BASE_CODE+1
		return code
	end
    return ret
end

function userutils.costfangfei(clubid,uid,count)
	local code = SUCCEED_CODE

	assert(uid ~= nil, 'uid == nil')

	uid = userutils.getnumberparam(uid)
	clubuid = userutils.getnumberparam(clubuid)
	count = userutils.getnumberparam(count)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return nil
	end

	local col = db:get_col("club_details")
	local res = col:update({clubuid=clubuid},{['$inc']={coin=-count}})
	if not res then
		code = ERR_BASE_CODE + 74
		return code
	end
    
    local col1 = db:get_col("club_chongzhi")
    local doc = {}
    doc._id = genid.gen()..clubuid
    doc.uid = uid
    doc.clubuid = clubuid
    doc.count = count
    doc.type = 11
    doc.timestamp = os.time()
	wrapper.close_mongl(conn)
    return code
end

-- newmem uid
function userutils.addnewmember(clubid,memuid)
	local code = SUCCEED_CODE
	assert(uid ~= nil, 'uid == nil')

	memuid = userutils.getnumberparam(memuid)
	clubuid = userutils.getnumberparam(clubuid)

	local db ,conn = wrapper.conn_mongl()
	if not db and conn then
		wrapper.close_mongl(db)
		return nil
	end

	local col = db:get_col("club_members")
	doc._id = ''..clubuid..memuid
    doc.clubuid = clubuid
    doc.uid = memuid
    doc.role = 1
    doc.timestamp = os.time()

	local res = col:insert({doc}})
	if not res then
		code = ERR_BASE_CODE + 74
		return code
	end

	wrapper.close_mongl(conn)
    return code
end

return userutils
