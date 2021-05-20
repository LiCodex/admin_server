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
local genid         = require "genid"


require "functions"

local _M = {}

local CMD = {}
-- 查询记录


local function getplayerinfo(uid,red)
    table.dumpdebug(uid,"______getplayerinfo:")
    table.dumpdebug(red,"______getplayerinfo red:")
    local u     = userlogic.loaduser(red,uid)
    -- local uex   = userlogic.loaduserex(red,uid)
    return u:toparam()
end

function CMD.tixianlist(red)
    local arg=ngx.req.get_uri_args()
    local orderid = arg.orderid

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)

    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("tixian")

    local result = {}
    local data = {}

    table.dumpdebug(arg,'__________arg:')

    -- 查询全部订单
    local cursor = col1:find({})
    local ret = cursor:sort({_id=-1})
    for index, tixian in pairs(ret) do
        table.dumpdebug(tixian,"__________tixian item:")
        local uid = tixian['uid']
        local user = getplayerinfo(uid,red)

        user['_id'] = tixian['_id']
        user['count'] = tixian['count']
        user['status'] = tixian['status']
        user['optime'] = tixian['optime']
        user['opadmin'] = tixian['opadmin']
        user['type'] = tixian['type']
        user['timestamp'] = tixian['timestamp']

        user['phone'] = tixian['phone']
        user['zhifubao'] = tixian['zhifubao']
        user['zfbname'] = tixian['zfbname']

        table.insert(data,user)
    end

    conn:close()
    result.code = 20000
    result.data = data
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
    local col1 = db:get_col("yongjintixian")

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
    local col1 = db:get_col("yongjintixian")

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
    local ok1,count = pcall(tonumber,res['count'])
    if not ok1 then
        result.code=10005
        result.data = '请正确输入信息10005'
        return result
    end

    local u   = userlogic.loaduser(red,uid)
    u:shangyongjin(count)
    
    -- uex:save()


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

-- 德州 这里的一些字段名需要修改.
function CMD.shenqingtixian(red)
    local arg=ngx.req.get_uri_args()
    local result = {}

    -- if not arg.uid or not arg.count or not arg.phone or not arg.zhifubao or not arg.zfbname or string.len(arg.zfbname) == 0 then
    if not arg.uid or not arg.count then
        result.errcode = 10001
        result.errmsg = '参数错误'
        return result
    end

    local ok, uid = pcall(tonumber, arg.uid)
    local ok2, count = pcall(tonumber, arg.count)
    if not ok or not ok2 then
        result.errcode = 10002
        result.errmsg = '参数错误'
        return result
    end

    local u = userlogic.loaduser(red,uid)
    if not u then
        result.errcode = 10003
        result.errmsg = '用户不存在 10003'
        return result
    end
    
    if u.yhk == '' or u.yhkname =='' or u.yhkadr == '' then
        result.errcode = 10004
        result.errmsg = '该玩家未绑定银行卡 10004'
        return result
    end

    local user = u:toparam()
    if user.yongjin < count then
        result.errcode = 10009
        result.errmsg = '可提现余额不足 10009'
        return result
    end    

    local beforyongjin = user.yongjin
    local yongjincnt = u:xiayongjin(count)
    u  = userlogic.loaduser(red,uid)
    user = u:toparam()



    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if err then
        result.errcode = 10004
        result.errmsg = '参数或者密码错误10004'
        return result
    end

    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("yongjintixian")
    local doc = {}
    doc._id = genid.gen()
    doc.uid = uid
    doc.count = count
    doc.status = 1
    doc.bankcard = u.yhk
    doc.beforyongjin = beforyongjin
    doc.bankname  = u.yhkname
    doc.bankaddr = u.yhkadr
    -- doc.zfbname = zfbname
    doc.timestamp = os.time()
    local ok ,err = col1:insert({doc},1,1)
    if not ok then
        result.errcode = 10005
        result.errmsg = '数据插入失败10005'
        return result
    end

    result.errcode = 0
    result.errmsg = '申请提现成功'
    result.data = {}
    result.data.yongjin = user.yongjin
    return result
end

-- 获取玩家的提现记录
function CMD.gettixianrecord(red)
    local arg=ngx.req.get_uri_args()
    local result = {}
    local data = {}

    table.dumpdebug(arg,"=======提现记录=====")
    if not arg.uid then
        result.errcode = 10001
        result.errmsg = '参数错误'
        return result
    end

    local ok, uid = pcall(tonumber, arg.uid)
    if not ok then
        result.errcode = 10002
        result.errmsg = '参数错误'
        return result
    end

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if err then
        result.errcode = 10004
        result.errmsg = '参数或者密码错误10004'
        return result
    end

    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("yongjintixian")
    local cursor = col1:find({uid=uid})
    local ret = cursor:sort({timestamp=-1})
    for index, item in pairs(ret) do
        item['_id'] = nil
        table.insert(data, item)
    end
    result.data = data
    result.errcode = 0
    result.errmsg = "查询成功"
    return result
end

-- 获取代理提现积分数
function CMD.gettixianjifen(red)
    local arg=ngx.req.get_uri_args()
    local result = {}

    if not arg.uid then
        result.code = 10001
        result.data = '参数错误'
        return result
    end
    local ok, uid = pcall(tonumber, arg.uid)
    if not ok then
        result.code = 10002
        result.data = '参数错误'
        return result
    end

    local u = getplayerinfo(uid,red)
    u['jifen'] = u['coin']
    result.code = 20000
    result.data = u

    return result
end

function CMD.getyejirecord(red)
    local arg=ngx.req.get_uri_args()
    local result = {}
    local data = {}

    -- if not arg.uid then
    --     result.code = 10001
    --     result.data = '参数错误'
    --     return result
    -- end
    
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if err then
        result.code = 10004
        result.data = '参数或者密码错误10004'
        return result
    end

    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("useryeji")
    
    if arg.fuid then
        local ok,fuid = pcall(tonumber,arg.fuid)
        if ok then
            local cursor = col1:find({touid=fuid})
            local ret = cursor:sort({_id=-1})
            for index, item in pairs(ret) do
                if item['fromuid'] and item['touid'] then
                    local u1 = userlogic.loaduser(item['fromuid'])
                    local u2 = userlogic.loaduser(item['touid'])
                    item['tname'] = u2.name
                    item['fname'] = u1.name
                    table.insert(data,item)
                end
            end
        end
    else
        local cursor = col1:find({})
        local ret = cursor:sort({_id=-1})
        for index, item in pairs(ret) do
            if item['fromuid'] and item['touid'] then
                local u1 = userlogic.loaduser(item['fromuid'])
                local u2 = userlogic.loaduser(item['touid'])
                item['tname'] = u2.name
                item['fname'] = u1.name
                table.insert(data,item)
            end
        end
    end

    result.data = data
    result.code = 20000
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
                if result.code and result.code~=0 then
                    -- result.errmsg=config.get('errmsg','e'..result.code)
                end
                ngx.say(cjson.encode(result))
                l:unlock()
            end
        else
            local result = f(rediscli)
            if result.code and result.code~=0 then
                -- result.errmsg=config.get('errmsg','e'..result.code)
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
                if result.code and result.code~=0 then
                    -- result.errmsg=config.get('errmsg','e'..result.code)
                end
                ngx.say(cjson.encode(result))
                l:unlock()
            end
        else
            local result = f(rediscli)
            if result.code and result.code~=0 then
                -- result.errmsg=config.get('errmsg','e'..result.code)
            end
            ngx.log(ngx.DEBUG,'<================================= function:',name,",data:",cjson.encode(result))
            ngx.say(cjson.encode(result))
        end
    end

    -- ngx.say("hello")
end


return _M
