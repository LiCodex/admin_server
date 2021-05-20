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
local userexmodel     = require "userexmodel"
local loginput      = require "loginput"
local sqlquery      = require "sqlquery"
local genid         = require "genid"
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

function CMD.uploaderweima(red)
    local arg=ngx.req.get_uri_args()
    local fuid = arg.fuid
    local wximgurl = arg.weixinurl
    local zhifubaourl = arg.zhifubaourl

    table.dumpdebug(arg, ">>>>>>>>>>>>>>>>>_________uploaderweima_____arg:")

    local result = {}
    if not wximgurl and not zhifubaourl then
        result.code=10008
        result.data = '请正确输入信息10008'
        return result
    end

    if not fuid then
        result.code=10001
        result.data = '请正确输入信息10001'
        return result
    end

    -- local u     = userlogic.loaduser(red,fuid)
    local uex   = userlogic.loaduserex(red,fuid)
    table.dumpdebug(uex ,"__________uex:")


    if uex and wximgurl then
        uex.wxmoneyimg = wximgurl
        table.dumpdebug(uex.wxmoneyimg,"__________>>>>>>>>>>weixinurl:::::")
    end

    if uex and zhifubaourl then
        uex.zfbmoneyimg = zhifubaourl
        table.dumpdebug(uex.wxmoneyimg,"__________>>>>>>>>>>zhifubaourl:::::")
    end
    uex:save()

    result.code = 20000
    result.data = '二维码保存成功'
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
    if not fuid then
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


-- 修改玩家信息
function CMD.modifyplayerinf(red)
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
    local uex   = userlogic.loaduserex(red,fuid)

    table.dumpdebug(arg, "__________arg::")
    table.dumpdebug(fuid, "__________fuid::")
    table.dumpdebug(u, "__________:u:")
    table.dumpdebug(uex, "__________:uex:")

    if arg.fname and string.len(arg.fname) > 0 then
        u.name = arg.fname
    end

    -- 性别设置
    if arg.sex and string.len(arg.sex) > 0 then
        u.sex = ''..arg.sex
    end
    if arg.unionid and string.len(arg.unionid) > 0 then
        u.unionid = arg.unionid
    end
    
    -- 特殊号设置
    if arg.teshu then
        local ok, teshu = utils.safe2number(arg.teshu)
        if ok and ok ~= false then
            u.teshu = teshu

            -- save teshu into mongo
            local ok,nfuid = pcall(tonumber,fuid)
            if ok then
                local conn = mongo:new()
                conn:set_timeout(1000)
                local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)

                local db=conn:new_db_handle(GAMENAME)
                local col1 = db:get_col("teshuusers")

                local ret = col1:update({uid=nfuid},{["$set"]={_id=nfuid,uid=nfuid,teshu=teshu,timestamp=os.time()}},1,0)
                table.dumpdebug(ret,"modify ethwallet::")
                if ret and ret == -1 then
                    table.dumpdebug("update ethwallet succeed")
                end
                conn:close()            
            end


        end
    end
    
    -- 操作管理员
    if arg.opadmin then
        u.opadmin = arg.opadmin
    end
    if arg.shenglv then
        local ok, shenglv = utils.safe2number(arg.shenglv)
        if ok and ok ~= false then
            if shenglv > 100 then
                shenglv = 100
            end
            if shenglv < 0 then
                shenglv = 0
            end
            u.shenglv = shenglv
        end
    end
    -- 封号
    if arg.fenghao then
        local ok, fenghao = utils.safe2number(arg.fenghao)
        if ok and ok ~= false then
            u.fenghao = fenghao
        end
    end

    -- 真名
    if arg.realname and string.len(arg.realname) > 0 then
        uex.realname = arg.realname
    end

    -- 电放
    if arg.tel and string.len(arg.tel) > 0 then
        uex.tel = arg.tel
    end

    -- 微信
    if arg.weixin and string.len(arg.weixin) > 0 then
        uex.weixin = arg.weixin
    end

    -- 支付宝
    if arg.zhifubao and string.len(arg.zhifubao) > 0 then
        uex.zhifubao = arg.zhifubao
    end

    -- 身份证
    if arg.shenfenzheng and string.len(arg.shenfenzheng) > 0 then
        uex.shenfenzheng = arg.shenfenzheng
    end
    -- 银行卡
    if arg.yinhangka and string.len(arg.yinhangka) > 0 then
        uex.yinhangka = arg.yinhangka
    end

    -- 钱包
    if arg.wallet and string.len(arg.wallet) > 0 then
        local ok,nfuid = pcall(tonumber,fuid)
        if ok then
            local walletkey = keysutils.get_wallet_key(arg.wallet)
            table.dumpdebug(walletkey,"___________wallet:9999999999999::::____")
            local userid = red:get(walletkey)
            if userid then
                result.code = 10020
                result.data = '比特链钱包已绑定其它玩家,本次修改失败 10020'
                return result
            end

            -- 如果该玩家已绑定钱包,删除原钱包
            if uex.wallet and uex.wallet ~= '' then
                local uexwalletkey = keysutils.get_wallet_key(uex.wallet)
                red:del(uexwalletkey)
            end
            -- 设置新key[uid -> wallet] 绑定钱包
            red:set(walletkey,nfuid)
            uex.wallet = arg.wallet


            local conn = mongo:new()
            conn:set_timeout(1000)
            local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)

            local db=conn:new_db_handle(GAMENAME)
            local col1 = db:get_col("users")

            table.dumpdebug(nfuid,"____________wallet nfuid::::")
            local res = col1:find_one({uid=nfuid})
            local walres = col1:find_one({wallet=arg.wallet})
            if not res then
                result.code = 10011
                result.data = '玩家不存在10011'
                return result
            end
            if walres then
                result.code = 10014
                result.data = '比特链钱包已绑定其它玩家,本次修改失败 10014'
                return result
            end

            local returncode = col1:update({uid=nfuid},{['$set']={wallet=arg.wallet}})
            if returncode then
                table.dumpdebug(returncode ,"___________wallet setting Return code:")
            end
            conn:close()
        end
    end
    -- yitaifang
    if arg.ethwallet and string.len(arg.ethwallet) > 0 then

        local ok,nfuid = pcall(tonumber,fuid)
        if ok then
            local ethwalletkey = keysutils.get_ethwallet_key(arg.ethwallet)
            table.dumpdebug(ethwalletkey,"___________ethwallet:888888888888::::____")
            local userid = red:get(ethwalletkey)
            if userid then
                result.code = 10021
                result.data = '以太链钱包已绑定其它玩家,本次修改失败 10021'
                return result
            end

            -- 如果该玩家已绑定钱包,删除原钱包
            if uex.ethwallet and uex.ethwallet ~= '' then
                local uexethwalletkey = keysutils.get_ethwallet_key(uex.ethwallet)
                red:del(uexethwalletkey)
            end
            -- 设置新key[uid -> wallet] 绑定钱包
            red:set(ethwalletkey,nfuid)
            uex.ethwallet = arg.ethwallet


            local conn = mongo:new()
            conn:set_timeout(1000)
            local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)

            local db=conn:new_db_handle(GAMENAME)
            local col1 = db:get_col("users")
            local res = col1:find_one({uid=nfuid})
            local walres = col1:find_one({ethwallet=arg.ethwallet})

            if not res then
                result.code = 10011
                result.data = '玩家不存在10012'
                return result
            end

            if walres then
                result.code = 10013
                result.data = '以太链钱包已绑定其它玩家,本次修改失败 10013'
                return result
            end


            if res then
                local ret = col1:update({uid=nfuid},{["$set"]={ethwallet=arg.ethwallet}})
                table.dumpdebug(ret,"modify ethwallet::")
                if ret and ret == -1 then
                    table.dumpdebug("update ethwallet succeed")
                end
            end
            conn:close()
        end


    end

    u:save()
    uex:save()

    result.code = 20000
    result.data = '设置成功'
    return result
end

--获取所有玩家信息
function CMD.getplayers(red)
    local arg=ngx.req.get_uri_args()
    local uid = arg.uid
    local fuid = arg.fuid

    if fuid and fuid ~= '' then
        return CMD.getplayer(red)
    end

    local result = {}
    local data = {}

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local result = {}
    if not ok then
        result.code=10001
        result.data = '参数或者密码错误10001'
        return result
    end

    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("users")

    -- 查询玩家总数
    local totalplayerscnt,err = col1:count({})
    if not totalplayerscnt and err then
        totalplayerscnt = 0
    end
    -- 有效玩家人数(充过值的)
    -- local youxiaoplayerscnt ,err = col1:count({chongusdt=1})
    -- if not youxiaoplayerscnt and err then
    --     youxiaoplayerscnt = 0
    -- end

    local youxiaoplayerscnt = getyouxiaoplayercnt()


    local cursor = col1:find({})
    local ret = cursor:sort({time=-1})
    conn:close()
    for index, player in pairs(ret) do
        local uid = player['uid']
        --读取玩家自己的数据
        local u     = userlogic.loaduser(red,uid)
        local uex   = userlogic.loaduserex(red,uid)

        local user   = u:toparam()
        user['create'] = player['time']
        -- local userex = uex:toparam()
        -- user['wallet'] = userex['wallet']
        -- user['usdt'] = userex['usdt']
        -- user['ethwallet'] = userex['ethwallet']
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
        -- user['alreadyrecharge'] = userex['alreadyrecharge']
        -- user['tuandui'] = getteamyouxiaocnt(red,uid)

        table.dumpdebug(user['fenghao'],"_______fenghao::_________")

        table.insert(data,user)
    end
    
    result.code = 20000
    result.totalpcnt = totalplayerscnt
    result.yxplycnt = youxiaoplayerscnt
    result.data = data
    return result
end

function CMD.getplayer(red)
    local arg=ngx.req.get_uri_args()
    local uid = arg.uid

    local result = {}
    local data = {}

    if not arg.fuid or arg.fuid == '' then
        result.code=10001
        result.data = '参数或者密码错误10001'
        return result
    end

    local ok,fuid = pcall(tonumber,arg.fuid)
    if not ok then
        result.code=10003
        result.data = '参数或者密码错误10003'
        return result
    end

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local result = {}
    if not ok then
        result.code=10002
        result.data = '参数或者密码错误10002'
        return result
    end

    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("users")

    -- 查询玩家总数
    -- local totalplayerscnt,err = col1:count({})
    -- if not totalplayerscnt and err then
    --     totalplayerscnt = 0
    -- end
    -- 有效玩家人数(充过值的)
    -- local youxiaoplayerscnt ,err = col1:count({chongusdt=1})
    -- if not youxiaoplayerscnt and err then
    --     youxiaoplayerscnt = 0
    -- end
    -- local youxiaoplayerscnt = getyouxiaoplayercnt()

    local ret = col1:find_one({uid=fuid})
    if not ret then
        result.code=10003
        result.data = '玩家不存在 10003'
        return result
    end

    --读取玩家自己的数据
    local u     = userlogic.loaduser(red,fuid)
    -- local uex   = userlogic.loaduserex(red,fuid)

    local user   = u:toparam()
    -- local userex = uex:toparam()
    user['create'] = ret['time']

    table.insert(data,user)

    result.code = 20000
    -- result.totalpcnt = totalplayerscnt
    -- result.yxplycnt = youxiaoplayerscnt
    result.data = data
    return result
end

function CMD.modifywalletaddr(red)
    local arg=ngx.req.get_uri_args()
    local uid = arg.uid
    local newwallet = arg.newwallet

    local result = {}
    local data = {}

    table.dumpdebug(arg.puid,"_______fuid_________")
    table.dumpdebug(newwallet,"_______newwallet_________")
    if not arg.puid or arg.puid == '' or not newwallet or newwallet == '' then
        result.code=10001
        result.data = '参数或者密码错误10001'
        return result
    end

    local ok,fuid = pcall(tonumber,arg.puid)
    if not ok then
        result.code=10003
        result.data = '参数或者密码错误10003'
        return result
    end

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local result = {}
    if not ok then
        result.code=10002
        result.data = '参数或者密码错误10002'
        return result
    end

    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("users")
    col1:update({uid=fuid},{['$set']={wallet=newwallet}})
    conn:close()

    local key = keysutils.get_model_key('userex',fuid)
    local user = red:hset(key,'wallet',newwallet)

    result.code = 20000
    result.data = '钱包地址修改成功'
    return result
end


function CMD.setteshu(red)
    local result = {}
    ngx.req.read_body()
    local data = {}

    local args=ngx.req.get_uri_args()
    table.dumpdebug(args, '______ set role ====:: ')

    if not args['setuid'] or not args['teshu'] then
        result.code = 10001
        result.data = '输入的参数信息不正确10001'
        return result
    end

    local ok1, teshu = pcall(tonumber,args['teshu'])
    local ok, fuid = pcall(tonumber,args['setuid'])
    if not ok or not ok1 then
        result.code = 10002
        result.data = '输入的参数信息不正确10002'
        return result
    end

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("admins")

    local name = red:hget(keysutils.get_model_key('user',fuid),'name')
    if not name then
        result.code = 10003
        result.data = '输入的参数信息不正确10003'
        return result
    end


    -- 修改权限
    red:hset(keysutils.get_model_key('userex',fuid),'teshu',teshu)
    red:hset(keysutils.get_model_key('user',fuid),'teshu',teshu)
    col1:update({_id='admin-'..fuid},{['$set']={_id='admin-'..fuid,uid=fuid, name=name,password='123456',role=teshu,timestamp=os.time()}},1,0)
    conn:close()
    
    result.code = 20000
    result.data = '设置成功'
    return result
end

function CMD.createadmin(red)
    local result = {}
    ngx.req.read_body()
    local data = {}

    local args=ngx.req.get_uri_args()
    table.dumpdebug(arg, "--->> createadmin___:::")
    table.dumpdebug(MONGO_CONFIG, "----------->> mongo config:::")

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("admins")

    local uid = 1
    local ok = col1:update({_id='admin-'..uid},{['$set']={_id='admin-'..uid,uid=uid, name='admin',password='123456',role='admin',timestamp=os.time()}},1,0)
    table.dumpdebug(ok,"col1:update::return:______>>>>>")
    conn:close()

    data.err = ok
    result.code = 20000
    result.data = data
    return result
end


-- 分类查询管理员,会长,特殊号列表
function CMD.getadmins(red)
    local result = {}
    ngx.req.read_body()
    local data = {}

    local args=ngx.req.get_uri_args()
    if not args['type'] then
        result.code = 10001
        result.data = '输入的参数信息不正确10001'
        return result
    end

    table.dumpdebug(args.type , '_________type : ')
    local ok,querytype = pcall(tonumber,args.type)
    if not ok then
        result.code = 10002
        result.data = '输入的参数信息不正确10002'
        return result
    end

    local red = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("admins")


    local cursor = col1:find({role=querytype})
    local ret,val=cursor:next()
    while val do
        -- val['_id'] = nil
        table.dumpdebug(val , '_________val : ')
        if val['uid'] then
            table.dumpdebug(val['uid'] , '_________user uid: ')
            local userkey = keysutils.get_model_key('user',val['uid'])
            --验证用户是否存在
            val['name'] = red:hget(userkey,'name')
        end
        table.insert(data,val)
        ret,val=cursor:next()
    end
    conn:close()

    result.code = 20000
    result.data = data
    return result
end

-- 分类查询管理员,会长,特殊号列表
function CMD.getteshulist(red)
    local result = {}
    ngx.req.read_body()
    local data = {}

    local args=ngx.req.get_uri_args()


    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("teshuusers")


    local cursor = col1:find({teshu=1})
    local ret,val=cursor:next()
    while val do
        table.dumpdebug(val , '_________val : ')
        if val['uid'] then
            table.dumpdebug(val['uid'] , '_________user uid: ')
            
            local u     = userlogic.loaduser(red,val['uid'])
            val['name'] = u.name

            -- local userkey = keysutils.get_model_key('user',val['uid'])
            -- --验证用户是否存在
            --  = red:hget(userkey,'name')
            table.insert(data,val)
        end
        
        ret,val=cursor:next()
    end
    conn:close()

    result.code = 20000
    result.data = data
    return result
end

-- 绑定推荐人[客户端大厅 推荐人 按钮]
function CMD.bindtuijianren(red)
    local result = {}
    local data = {}

    local args=ngx.req.get_uri_args()
    if not args or not args.fuid then
        result.code = 10001
        result.data = '请正确输入信息10001'
        return result
    end

    local ok ,uid = pcall(tonumber, args.fuid)
    if not ok then
        
    end

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("tuijianren")

    -- col1:find_one({uid=})
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
                -- if result.code and result.code~=0 then
                --     result.errmsg=config.get('errmsg','e'..result.code)
                -- end
                ngx.say(cjson.encode(result))
                l:unlock()
            end
        else
            local result = f(rediscli)
            -- if result.code and result.code~=0 then
            --     result.errmsg=config.get('errmsg','e'..result.code)
            -- end
            ngx.log(ngx.DEBUG,'<================================= function:',name,",data:",cjson.encode(result))
            ngx.say(cjson.encode(result))
        end
    else
        local f = CMD[name]
        if not TEST then
            local l=redislock.new(rediscli,"lock:".."adminserver",10)
            if l:lock() then
                local result = f(rediscli)
                -- if result.code and result.code~=0 then
                --     result.errmsg=config.get('errmsg','e'..result.code)
                -- end
                ngx.say(cjson.encode(result))
                l:unlock()
            end
        else
            local result = f(rediscli)
            -- if result.code and result.code~=0 then
            --     result.errmsg=config.get('errmsg','e'..result.code)
            -- end
            ngx.log(ngx.DEBUG,'<================================= function:',name,",data:",cjson.encode(result))
            ngx.say(cjson.encode(result))
        end
    end

    -- ngx.say("hello")
end


return _M

