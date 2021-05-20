local cjson          = require "cjson"
local string         = require "string"
local table_new      = require "table.new"
local table          = require "table"
local jwt            = require "resty.jwt"
local mongo          = require "resty.mongol"
local redis          = require "redis"
local keysutils      = require "keysutils"
local uuid           = require "resty.uuid"
local config         = require "config"
local utils          = require "utils"
local redislock      = require "lock"
local str           = require "resty.string"
local http          = require "resty.http"
local sha1          = require "resty.sha1"
local userlogic     = require "userlogic"
local usermodel     = require "usermodel"
local userexmodel   = require "userexmodel"
local genid         = require "genid"
local wrapper       = require "wrapper"
require "functions"


local _M = {}
local CMD = {}

-- 存代理记录到mongo
local function savedaili2mongo(dailiuid,flag)
    local ok,uid = utils.safe2number(dailiuid)
    if not ok then
        table.dumpdebug("safe2number failed") 
        return 
    end 
    
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)

    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("daili")
    local res = col1:find_one({uid=uid})
    if not res then
        local doc = {}
        doc._id=genid.gen()
        doc.uid=uid
        doc.daili = flag
        doc.timestamp = os.time()
        local ok,err = col1:insert({doc})
        if not ok then
            table.dumpdebug(err, "err info:")
            return
        end
    else
        local ok ,err = col1:update({uid=uid},{['$set']={daili=flag,lastop=os.time()}})
        if not ok then
            table.dumpdebug(err, "err 2 msg:")
            return
        end
    end
end

-- 存封号记录到mongo
local function savefenghao2mongo(fenghaouid,flag)
    local ok,uid = utils.safe2number(fenghaouid)
    if not ok then
        table.dumpdebug("safe2number failed") 
        return 
    end 
    
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)

    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("fenghao")
    local res = col1:find_one({uid=uid})
    if not res then
        local doc = {}
        doc._id=genid.gen()
        doc.uid=uid
        doc.fenghao = flag
        doc.timestamp = os.time()
        local ok,err = col1:insert({doc})
        if not ok then
            table.dumpdebug(err, "err info:")
            return
        end
    else
        local ok ,err = col1:update({uid=uid},{['$set']={fenghao=flag,lastop=os.time()}})
        if not ok then
            table.dumpdebug(err, "err 2 msg:")
            return
        end
    end
end


-- 有效人数
local function getyouxiaoplayercnt()
    local youxiaocnt = 0
    local rows = sqlquery.queryyouxiaocntlog()
    if rows then
        for i, row in ipairs(rows) do 
            if row['youxiao'] then
                youxiaocnt = row['youxiao']
            end
        end
    end
    return youxiaocnt
end

local function getplayerinfo(uid,red)
    local u     = userlogic.loaduser(red,uid)
    -- local uex   = userlogic.loaduserex(red,uid)

    local user   = u:toparam()
    -- local userex = uex:toparam()
    -- user['wallet'] = userex['wallet']
    -- user['usdt'] = userex['usdt']
    -- user['buy'] = userex['buy']
    -- user['sale'] = userex['sale']
    -- user['totalreqtbk'] = userex['totalreqtbk']
    -- user['zhifubao'] = userex['zhifubao']
    -- user['realname'] = userex['realname']
    -- user['tel'] = userex['tel']
    -- user['weixin'] = userex['weixin']
    -- user['shenfenzheng'] = userex['shenfenzheng']
    -- user['yinhangka'] = userex['yinhangka']
    -- user['wxmoneyimg'] = userex['wxmoneyimg']
    -- user['zfbmoneyimg'] = userex['zfbmoneyimg']
    -- user['ethwallet'] = userex['ethwallet']
    -- user['alreadyrecharge'] = userex['alreadyrecharge']

    return user
end

-- 获取指定玩家团队的有效玩家数
local function getteamyouxiaocnt(red,uid)
    if not uid then
        return 0
    end
    local ok,puid = pcall(tonumber,uid)
    local conn = mongo:new()
    conn:set_timeout(10000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)

    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("tuijianren")

    local teamyouxiao = 0
    local res = col1:find({['$or']={[0]={uid1=puid},[1]={uid2=puid},[2]={uid3=puid}} })
    if not res then
        return teamyouxiao
    end

    for i,row in res:pairs()  do
        if row['uid'] then
            local cnt = sqlquery.querychongzhicount(row['uid'])
            local ok,count = pcall(tonumber,cnt)
            if count > 0 then
                teamyouxiao = teamyouxiao + 1
            end
        end
    end

    local user = getplayerinfo(uid,red)
    if user.teshu == 1 then
        local res = col1:find({uid4=puid})
        if not res then
            return teamyouxiao
        end

        for i,row in res:pairs()  do
            if row['uid'] then
                local cnt = sqlquery.querychongzhicount(row['uid'])
                local ok,count = pcall(tonumber,cnt)
                if count > 0 then
                    teamyouxiao = teamyouxiao + 1
                end
            end
        end
    end

    return teamyouxiao
end

-- 转赠
function CMD.zhuanzheng(red)
    local arg=ngx.req.get_uri_args()

    local result = {}
    local data = {}

    if not arg.uid or arg.uid == '' or not arg.fuid or arg.fuid == '' or not arg.count or arg.count == '' then
        result.code=10001
        result.data = '参数或者密码错误10001'
        return result
    end

    if arg.uid == arg.fuid  then
        result.code=10002
        result.data = '不能转给自己'
        return result
    end

    local ok,uid = utils.safe2number(arg.uid)
    if not ok then
        result.code = 10009
        result.data = '参数或者密码错误10002'
        return result
    end
    local ok1,fuid = utils.safe2number(arg.fuid)
    if not ok1 then
        result.code = 10003
        result.data = '参数或者密码错误10003'
        return result
    end
    local ok2,count = utils.safe2number(arg.count)
    if not ok2 then
         result.code = 10004
        result.data = '参数或者密码错误10004'
        return result
    end

    local user = userlogic.loaduser(red,uid)
    if not user then
        result.code = 10005
        result.data = '该玩家不存在10005'
        return result
    end

    local u = user:toparam()
    if u.fangka < count then
        result.code = 10007
        result.data = '数量不足 10007'
        return result
    end

    table.dumpdebug(fuid ,"__________arg_______fuid::")

    local fu = userlogic.loaduser(red,fuid)
    if not fu then
        result.code = 10008
        result.data = '玩家不存在 10008'
        return result
    end

    local fuser = fu:toparam()
    local curcount = user:xiafen(count)
    local cnt = fu:shangfen(count)

    result.code = 20000
    result.data = '转赠成功'
    result.fangka=curcount['coin']
    return result
end

function CMD.allowtixian(red)
    local arg=ngx.req.get_uri_args()
    local orderid = arg.orderid
    local opadmin = arg.op
    if not orderid or not opadmin then
        result.code=10001
        result.data = '请正确输入信息10001'
        return result
    end

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)

    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("tibi")

    local result = {}
    local data = {}

    table.dumpdebug(arg,'__________arg_______')
    local res = col1:find_one({_id=orderid})
    if not res then
        result.code=10002
        result.data = '请正确输入信息10002'
        return result
    end

    local ok , status = pcall(tonumber,res['status'])
    if not ok then
        result.code=10003
        result.data = '请正确输入信息10003'
        return result
    end
    if status ~= 1 then
        result.code=20000
        result.data = '该订单已经处理过'
        return result
    end

    local ret, err = col1:update({_id=orderid},{['$set']={status=0,optime=os.time(),opadmin=opadmin}})
    if err then
        result.code=10004
        result.data = '请正确输入信息10004'
        return result
    end

    result.code=20000
    result.data = '您已允许该笔提现请求'
    return result
end

function CMD.decltixian(red)
    local arg=ngx.req.get_uri_args()
    local orderid = arg.orderid
    local opadmin = arg.op
    table.dumpdebug(arg,"__________arg_______:::")

    if not orderid or not opadmin then
        result.code=10001
        result.data = '请正确输入信息10001'
        return result
    end

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)

    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("tibi")

    local result = {}
    local data = {}

    table.dumpdebug(arg,'__________arg_______')
    local res = col1:find_one({_id=orderid})
    if not res then
        result.code=10002
        result.data = '请正确输入信息10002'
        return result
    end

    local ok , status = pcall(tonumber,res['status'])
    if not ok then
        result.code=10003
        result.data = '请正确输入信息10003'
        return result
    end
    if status ~= 1 then
        result.code=20000
        result.data = '该订单已经处理过'
        return result
    end

    local ok,uid  = pcall(tonumber,res['uid'])
    if not ok then
        result.code=10004
        result.data = '请正确输入信息10004'
        return result
    end
    local ok1,count = pcall(tonumber,res['coin'])
    if not ok1 then
        result.code=10005
        result.data = '请正确输入信息10005'
        return result
    end

    local uex   = userlogic.loaduserex(red,uid)

    if count and type(count) == 'number' then
        uex:shangusdt(count)
        loginput.logusdt(uid,loginput.admin_tixian_jujue, count)
    end
    uex:save()


    local ret, err = col1:update({_id=orderid},{['$set']={status=2,optime=os.time(),opadmin=opadmin}})
    if err then
        result.code=10004
        result.data = '请正确输入信息10004'
        return result
    end

    result.code=20000
    result.data = '您已拒绝该笔提现请求'
    return result
end

function CMD.tixianlist(red)
    local arg=ngx.req.get_uri_args()
    local orderid = arg.orderid

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)

    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("tibi")

    local result = {}
    local data = {}

    table.dumpdebug(arg,'__________arg:')

    -- 带订单号查询
    if orderid and string.len(orderid) > 0 and orderid ~= 'undefine' then
        local cursor = col1:find({_id=orderid})
        local ret = cursor:sort({time=-1})
        for index, tixian in pairs(ret) do
            local uid = tixian['uid']
            local user = getplayerinfo(uid,red)

            user['_id'] = tixian['_id']
            user['count'] = tixian['coin']
            user['status'] = tixian['status']
            user['time'] = tixian['time']
            user['optime'] = tixian['optime']
            user['opadmin'] = tixian['opadmin']
            user['type'] = tixian['type']
            if tixian['type'] and tixian['type'] == 'ethwallet' then
                user['tixianwallet'] = user['ethwallet']
            else
                user['tixianwallet'] = user['wallet']
            end
            table.insert(data,user)
        end
        table.dumpdebug(orderid ,'__________orderid:')
        conn:close()
        result.code = 20000
        result.data = data
        return result
    end

    -- 根据人查找
    if arg.fuid and arg.fuid ~= '' then
        local ok , fuid = pcall(tonumber, arg.fuid)
        if not ok then
            table.dumpdebug(arg.fuid ,'__________arg.fuid____:')
            conn:close()
            result.code = 10005
            result.data = '参数或者密码错误10005'
            return result
        end

        local cursor = col1:find({uid=fuid})
        local ret = cursor:sort({time=-1})
        -- local ret,tixian=cursor:next()
        -- while tixian do
        for _,tixian in pairs(ret) do
            table.dumpdebug(tixian,"------result")
            local uid = tixian['uid']
            local user = getplayerinfo(uid,red)
            user['_id'] = tixian['_id']
            user['count'] = tixian['coin']
            user['status'] = tixian['status']
            user['optime'] = tixian['optime']
            user['opadmin'] = tixian['opadmin']
            user['time'] = tixian['time']

            user['type'] = tixian['type']
            if tixian['type'] and tixian['type'] == 'ethwallet' then
                user['tixianwallet'] = user['ethwallet']
            else
                user['tixianwallet'] = user['wallet']
            end
            table.insert(data,user)
            -- ret,tixian=cursor:next()
        end

        table.dumpdebug(fuid ,'__________fuid:')
        conn:close()
        result.code = 20000
        result.data = data
        return result
        -- local ret = cursor:sort({time=-1})
        -- for index, tixian in pairs(ret) do

        -- end
    end

    -- 查询全部订单
    local cursor = col1:find({})
    local ret = cursor:sort({_id=-1})
    for index, tixian in pairs(ret) do
        table.dumpdebug(tixian,"__________tixian item:")
        local uid = tixian['uid']
        local user = getplayerinfo(uid,red)

        user['_id'] = tixian['_id']
        user['count'] = tixian['coin']
        user['status'] = tixian['status']
        user['optime'] = tixian['optime']
        user['opadmin'] = tixian['opadmin']
        user['type'] = tixian['type']
        user['time'] = tixian['time']
        if tixian['type'] and tixian['type'] == 'ethwallet' then
            user['tixianwallet'] = user['ethwallet']
        else
            user['tixianwallet'] = user['wallet']
        end
        table.insert(data,user)
    end

    -- table.dumpdebug(data ,'__________data:')

    conn:close()
    result.code = 20000
    result.data = data
    return result
end

function CMD.wallet2uid(red)
    local arg=ngx.req.get_uri_args()
    local wallet = arg.wallet

    local result = {}
    if not wallet or wallet == '' then
        result.code=10001
        result.data = '请正确输入信息10001'
        return result
    end

    -- 查询玩家uid
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)

    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("users")
    local res = col1:find_one({wallet=wallet})
    if not res or not res['wallet'] or not res['uid'] then
        result.code = 10002
        result.data = '钱包地址不存在10002'
        ngx.say(cjson.encode(result))
        return
    end
    -- 得到要查询玩家的UID
    table.dumpdebug(res, '__________查询mongo,users 表的数据 字段::__________')
    result.code = 20000
    result.data = {}
    result.data.uid = res['uid']
    return result
end

function CMD.ethwallet2uid(red)
    local arg=ngx.req.get_uri_args()
    local wallet = arg.wallet

    local result = {}
    if not wallet or wallet == '' then
        result.code=10001
        result.data = '请正确输入信息10001'
        return result
    end

    -- 查询玩家uid
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)

    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("users")
    local res = col1:find_one({ethwallet=wallet})
    if not res or not res['ethwallet'] or not res['uid'] then
        result.code = 10002
        result.data = '钱包地址不存在10002'
        ngx.say(cjson.encode(result))
        return
    end
    -- 得到要查询玩家的UID
    table.dumpdebug(res, '__________查询mongo,users 表的数据 字段::__________')
    result.code = 20000
    result.data = {}
    result.data.uid = res['uid']
    return result
end

function CMD.fenghao(red)
    local arg=ngx.req.get_uri_args()
    local uid = arg.uid
    local fuid = arg.fuid

    local result = {}
    if not uid or not fuid then
        result.code = 10001
        result.data = '输入的参数信息不正确10001'
        return result
    end

    local u     = userlogic.loaduser(red,fuid)
    if u['fenghao'] then
        local ok, fh = pcall(tonumber,u['fenghao'])
        if not ok then
            fh = 0
        end
        
        if fh == 0 then
            fh = 1
        else
            fh = 0
        end
        u['fenghao'] = fh
    else
        u['fenghao'] = 1
    end

    u:save()

    local fenghaoflag = u['fenghao']
    savefenghao2mongo(fuid,fenghaoflag)

    result.code = 20000
    result.data = '设置成功'
    return result
end


function CMD.setdaili(red)
    local arg=ngx.req.get_uri_args()
    local uid = arg.uid
    local fuid = arg.fuid

    local result = {}
    if not uid or not fuid then
        result.code = 10001
        result.data = '输入的参数信息不正确10001'
        return result
    end

    local u     = userlogic.loaduser(red,fuid)
    if u['daili'] then
        local ok, dl = pcall(tonumber,u['daili'])
        if not ok then
            dl = 0
        end
        
        if dl == 0 then
            dl = 1
        else
            dl = 0
        end
        u['daili'] = dl
    else
        u['daili'] = 1
    end

    u:save()
    local dailiflag = u['daili']
    savedaili2mongo(fuid,dailiflag)

    result.code = 20000
    result.data = '设置成功'
    return result
end


-- 修改玩家信息 NN
function CMD.modifyplayerinfo(red)
    local arg=ngx.req.get_uri_args()
    local uid = arg.uid

    local result = {}
    if not uid then
        result.code = ERR_BASE_CODE+1
        return result
    end

    local u     = userlogic.loaduser(red,uid)
    local user  = u:toparam()

    table.dumpdebug(arg, "__________arg::")
    table.dumpdebug(u, "__________:u:")


    if arg.mname and string.len(arg.mname) > 0 then
        u.name = arg.mname
    end

    -- 性别设置
    if arg.sex and string.len(arg.sex) > 0 then
        u.sex = ''..arg.sex
    end

    u:save()

    u = userlogic.loaduser(red,uid)

    result.code = 20000
    result.data = u:toparam()
    return result
end


--获取所有玩家信息
function CMD.getplayers(red)
    local arg=ngx.req.get_uri_args()
    local uid = arg.uid
    local fuid = arg.fuid

    table.dumpdebug("111111111111")
    if fuid and fuid ~= '' then
            table.dumpdebug("2222222222")

        return CMD.getplayer(red)
    end

    local result = {}
    local data = {}
    table.dumpdebug("33333333333333")

    local db,conn = wrapper.conn_mongl()
    if not db then
        result.code= ERR_BASE_CODE+60
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end
    local col1 = db:get_col("users")

    -- 查询玩家总数
    local totalcnt,err = col1:count({})
    if not totalcnt and err then
        totalcnt = 0
    end

    local cursor = col1:find({})
    local ret = cursor:sort({time=-1})
    wrapper.close_mongl(conn)

    for index, player in pairs(ret) do
        local uid = player['uid']
        --读取玩家自己的数据
        local u     = userlogic.loaduser(red,uid)
        local user   = u:toparam()
        user['create'] = player['time']

        table.insert(data,user)
    end
    
    result.code = SUCCEED_CODE
    result.data = data
    return result
end

function CMD.getplayer(red)
    local arg=ngx.req.get_uri_args()
    local uid = arg.uid

    local result = {}
    local data = {}

    if not arg.fuid or arg.fuid == '' then
        result.code=ERR_BASE_CODE+1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local ok,fuid = utils.safe2number(arg.fuid)
    if not ok or ok == false then
        result.code=ERR_BASE_CODE+1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local db,conn = wrapper.conn_mongl()
    if not db then
        result.code= ERR_BASE_CODE+60
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local col1 = db:get_col("users")
    local ret = col1:find_one({uid=fuid})
    if not ret then
        result.code= ERR_BASE_CODE+7
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    --读取玩家自己的数据
    local u     = userlogic.loaduser(red,fuid)
    local user   = u:toparam()
    user['create'] = ret['time']

    table.insert(data,user)
    wrapper.close_mongl(conn)

    result.code = SUCCEED_CODE
    result.data = data
    return result
end

-- 绑定推荐人[客户端大厅 推荐人 按钮]
function CMD.bindtuijianren(red)
    local result = {}
    local data = {}

    local args=ngx.req.get_uri_args()

    if not args or not args.uid or not args.fuid then
        result.code = ERR_BASE_CODE + 1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local ok ,uid = utils.safe2number(args.uid)
    if not ok or ok == false then
        result.code = ERR_BASE_CODE + 1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local ok1, fuid = utils.safe2number(args.fuid)
    if not ok1 or ok1 == false then
        result.code = ERR_BASE_CODE + 1
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    if uid == fuid then
        result.code = ERR_BASE_CODE + 51
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local db,conn = wrapper.conn_mongl()
    if not db then
        result.code= ERR_BASE_CODE+60
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end
    local col2 = db:get_col("users")
    local ret2 = col2:find_one({uid=uid})
    if not ret2 then
        result.code= ERR_BASE_CODE+7
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end
    local ret3 = col2:find_one({uid=fuid})
    if not ret3 then
        result.code= ERR_BASE_CODE+4
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local col1 = db:get_col("tuijianren")
    local ret = col1:find_one({uid=uid})
    if ret then
        result.code= ERR_BASE_CODE+63
        result.debug = debug.getinfo(1).currentline..'/'..debug.getinfo(1).short_src
        return result
    end

    local doc = {}
    doc._id = ''..uid..fuid
    doc.uid = uid
    doc.uid1 = fuid
    doc.timestamp  = os.time()
    local ok , err = col1:insert({doc})

    result.code = SUCCEED_CODE
    result.data = '绑定成功'
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

