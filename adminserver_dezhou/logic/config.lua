local mongo       = require "resty.mongol"
local config = {}

local DEFAULT={
    game_cdx = {
        misc={
            inittbk = 20,--初始赠送玩家的tbk的个数
            extra_cal = 5,--当前游戏超过10把的附加的千分比
            c2cmoney = 5, --挂售的手续费
            tbk2udt = 15, --TBK兑换USDT收取15%手续费
            tixian=15, --提现手续费
        },
        cal={--算力等级
            lvl1={
                s=350,
                e=5000,
                percent=5,
            },
            lvl2={
                s=1001,
                e=15000,
                percent=10,
            },
            lvl3={
                s=15001,
                e=9999999999999999,
                percent=15,
            },
        },
        recharge_percent={ --充值返现
            lvl1=10,
            lvl2=5,
            lvl3=5,
            lvl4=5,
        },
        tixian={
            shouxufei=15,
        },
        huizhang={
            lvl1={
                zhitui=10,
                tuandui = 50,
            },
            lvl2={
                zhitui=30,
                tuandui = 300,
            },
            lvl3={
                zhitui=50,
                tuandui = 1000,
            },
        },
        huizhangpercent={
            lvl1={
                lvl1=2,
                lvl2=1,
                lvl3=1,
            },
            lvl2={
                lvl1=3,
                lvl2=3,
                lvl3=3,
            },
            lvl3={
                lvl1=4,
                lvl2=3,
                lvl3=3,
            },
        },
    },
    game_ddz = {
        misc={
            inittbk = 20,--初始赠送玩家的tbk的个数
            extra_cal = 5,--当前游戏超过10把的附加的千分比
        },
        cal={--算力等级
            lvl1={
                s=350,
                e=5000,
                percent=5,
            },
            lvl2={
                s=1001,
                e=15000,
                percent=10,
            },
            lvl3={
                s=15001,
                e=9999999999999999,
                percent=15,
            },
        },
        recharge_percent={ --充值返现
            lvl1=10,
            lvl2=5,
            lvl3=5,
            lvl4=5,
        },
        tixian={
            shouxufei=15,
        },
        huizhang={
            lvl1={
                zhitui=10,
                tuandui = 50,
            },
            lvl2={
                zhitui=30,
                tuandui = 300,
            },
            lvl3={
                zhitui=50,
                tuandui = 1000,
            },
        },
        huizhangpercent={
            lvl1={
                lvl1=2,
                lvl2=1,
                lvl3=1,
            },
            lvl2={
                lvl1=3,
                lvl2=3,
                lvl3=3,
            },
            lvl3={
                lvl1=4,
                lvl2=3,
                lvl3=3,
            },
        },
    },
    game_nn = {
        misc={
            inittbk = 20,--初始赠送玩家的tbk的个数
            extra_cal = 5,--当前游戏超过10把的附加的千分比
        },
        cal={--算力等级
            lvl1={
                s=350,
                e=5000,
                percent=5,
            },
            lvl2={
                s=1001,
                e=15000,
                percent=10,
            },
            lvl3={
                s=15001,
                e=9999999999999999,
                percent=15,
            },
        },
        recharge_percent={ --充值返现
            lvl1=10,
            lvl2=5,
            lvl3=5,
            lvl4=5,
        },
        tixian={
            shouxufei=15,
        },
        huizhang={
            lvl1={
                zhitui=10,
                tuandui = 50,
            },
            lvl2={
                zhitui=30,
                tuandui = 300,
            },
            lvl3={
                zhitui=50,
                tuandui = 1000,
            },
        },
        huizhangpercent={
            lvl1={
                lvl1=2,
                lvl2=1,
                lvl3=1,
            },
            lvl2={
                lvl1=3,
                lvl2=3,
                lvl3=3,
            },
            lvl3={
                lvl1=4,
                lvl2=3,
                lvl3=3,
            },
        },
    },
    game_sh = {
        misc={
            inittbk = 20,--初始赠送玩家的tbk的个数
            extra_cal = 5,--当前游戏超过10把的附加的千分比
        },
        cal={--算力等级
            lvl1={
                s=350,
                e=5000,
                percent=5,
            },
            lvl2={
                s=1001,
                e=15000,
                percent=10,
            },
            lvl3={
                s=15001,
                e=9999999999999999,
                percent=15,
            },
        },
        recharge_percent={ --充值返现
            lvl1=10,
            lvl2=5,
            lvl3=5,
            lvl4=5,
        },
        tixian={
            shouxufei=15,
        },
        huizhang={
            lvl1={
                zhitui=10,
                tuandui = 50,
            },
            lvl2={
                zhitui=30,
                tuandui = 300,
            },
            lvl3={
                zhitui=50,
                tuandui = 1000,
            },
        },
        huizhangpercent={
            lvl1={
                lvl1=2,
                lvl2=1,
                lvl3=1,
            },
            lvl2={
                lvl1=3,
                lvl2=3,
                lvl3=3,
            },
            lvl3={
                lvl1=4,
                lvl2=3,
                lvl3=3,
            },
        },
    },
    game_tpj = {
        misc={
            inittbk = 20,--初始赠送玩家的tbk的个数
            extra_cal = 5,--当前游戏超过10把的附加的千分比
        },
        cal={--算力等级
            lvl1={
                s=350,
                e=5000,
                percent=5,
            },
            lvl2={
                s=1001,
                e=15000,
                percent=10,
            },
            lvl3={
                s=15001,
                e=9999999999999999,
                percent=15,
            },
        },
        recharge_percent={ --充值返现
            lvl1=10,
            lvl2=5,
            lvl3=5,
            lvl4=5,
        },
        tixian={
            shouxufei=15,
        },
        huizhang={
            lvl1={
                zhitui=10,
                tuandui = 50,
            },
            lvl2={
                zhitui=30,
                tuandui = 300,
            },
            lvl3={
                zhitui=50,
                tuandui = 1000,
            },
        },
        huizhangpercent={
            lvl1={
                lvl1=2,
                lvl2=1,
                lvl3=1,
            },
            lvl2={
                lvl1=3,
                lvl2=3,
                lvl3=3,
            },
            lvl3={
                lvl1=4,
                lvl2=3,
                lvl3=3,
            },
        },
    },
    game_ttz = {
        misc={
            inittbk = 20,--初始赠送玩家的tbk的个数
            extra_cal = 5,--当前游戏超过10把的附加的千分比
        },
        cal={--算力等级
            lvl1={
                s=350,
                e=5000,
                percent=5,
            },
            lvl2={
                s=1001,
                e=15000,
                percent=10,
            },
            lvl3={
                s=15001,
                e=9999999999999999,
                percent=15,
            },
        },
        recharge_percent={ --充值返现
            lvl1=10,
            lvl2=5,
            lvl3=5,
            lvl4=5,
        },
        tixian={
            shouxufei=15,
        },
        huizhang={
            lvl1={
                zhitui=10,
                tuandui = 50,
            },
            lvl2={
                zhitui=30,
                tuandui = 300,
            },
            lvl3={
                zhitui=50,
                tuandui = 1000,
            },
        },
        huizhangpercent={
            lvl1={
                lvl1=2,
                lvl2=1,
                lvl3=1,
            },
            lvl2={
                lvl1=3,
                lvl2=3,
                lvl3=3,
            },
            lvl3={
                lvl1=4,
                lvl2=3,
                lvl3=3,
            },
        },
    },
    game_xyzp = {
        misc={
            inittbk = 20,--初始赠送玩家的tbk的个数
            extra_cal = 5,--当前游戏超过10把的附加的千分比
        },
        cal={--算力等级
            lvl1={
                s=350,
                e=5000,
                percent=5,
            },
            lvl2={
                s=1001,
                e=15000,
                percent=10,
            },
            lvl3={
                s=15001,
                e=9999999999999999,
                percent=15,
            },
        },
        recharge_percent={ --充值返现
            lvl1=10,
            lvl2=5,
            lvl3=5,
            lvl4=5,
        },
        tixian={
            shouxufei=15,
        },
        huizhang={
            lvl1={
                zhitui=10,
                tuandui = 50,
            },
            lvl2={
                zhitui=30,
                tuandui = 300,
            },
            lvl3={
                zhitui=50,
                tuandui = 1000,
            },
        },
        huizhangpercent={
            lvl1={
                lvl1=2,
                lvl2=1,
                lvl3=1,
            },
            lvl2={
                lvl1=3,
                lvl2=3,
                lvl3=3,
            },
            lvl3={
                lvl1=4,
                lvl2=3,
                lvl3=3,
            },
        },
    },
    game_zjh = {
        misc={
            inittbk = 20,--初始赠送玩家的tbk的个数
            extra_cal = 5,--当前游戏超过10把的附加的千分比
        },
        cal={--算力等级
            lvl1={
                s=350,
                e=5000,
                percent=5,
            },
            lvl2={
                s=1001,
                e=15000,
                percent=10,
            },
            lvl3={
                s=15001,
                e=9999999999999999,
                percent=15,
            },
        },
        recharge_percent={ --充值返现
            lvl1=10,
            lvl2=5,
            lvl3=5,
            lvl4=5,
        },
        tixian={
            shouxufei=15,
        },
        huizhang={
            lvl1={
                zhitui=10,
                tuandui = 50,
            },
            lvl2={
                zhitui=30,
                tuandui = 300,
            },
            lvl3={
                zhitui=50,
                tuandui = 1000,
            },
        },
        huizhangpercent={
            lvl1={
                lvl1=2,
                lvl2=1,
                lvl3=1,
            },
            lvl2={
                lvl1=3,
                lvl2=3,
                lvl3=3,
            },
            lvl3={
                lvl1=4,
                lvl2=3,
                lvl3=3,
            },
        },
    },
    --价格
    price={
        usdt=1,
        eth =230,
        btc=6732.25,
        tbk=0.028,
    },
    pricechange={
        usdt=0,
        eth =0,
        btc=0,
    },
    errmsg={
        e10001='注册参数错误',
        e10002='注册验证码过期',
        e10003='手机号已经注册过',
        e10004='推荐人不存在',
        e10005='系统验证码错误',
        e10006='登录参数错误',
        e10007='用户不存在或者密码错误',
        e10008='修改密码参数错误',
        e10009='参数错误',
        e10010='金币不足',
        e10011='购买矿场重复',
        e10012='购买矿工重复',
        e10013='矿工不存在',
        e10014='矿场不存在',
        e10015='装备不存在',
        e10016='装不能重复绑定',
        e10017='好友不允许偷取，或者已经被好友加入黑名单',
        e10018='矿工已经到达最大等级',
        e10019='矿工已经派遣到矿场，不能重复派遣',
        e10020='昵称已经存在',
        e10021='原始密码错误',
        e10022='奖励数据过期',
        e10023='不能重复偷取',
        e10024='移动到达最大投群次数的上限',
        e10025='任务已经领取',
        e10026='任务编号错误',
        e10027='已经开启了自动收取功能',
        e10027='任务尚未完成',
        e10028='矿工不在挖矿中不能召回',
        e10029='饮料个数不足',
        e10030='装备没有绑定到矿工身上',
        e10031='超出矿工的体力上限',
        e10032='钱包已经设置，如果需要修改请联系客服',
        e10033='矿币不足,不能提现',
        e10034='没有设置钱包不能提现',
        e10035='交易密码有误',
        e10036='超过提现次数上限',
        e10037='保留矿场不能购买',
        e10038='矿工品质不能低于装备品质',
        e10039='该矿工已经装备同类型装备',
        e10040='验证码无效',
        e10041='手机号与登陆用户不相符',
        e10042='该钱包地址已有用户设置',
        e10043='该帐号已被封号',
        e10044='订单已匹配，请联系客服',
        e10045='上传失败，请稍后重试',
        e10046='操作失败，请联系客服',
    },
}

local dbconfig={}

function config.loadconfig()
    local conn = mongo:new()
    conn:set_timeout(5000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col('gameconfig')

    for k,v in pairs(DEFAULT) do
        dbconfig[k] = col1:find_one({_id=k})
        if dbconfig[k] then
            dbconfig[k]['_id'] = nil
        end
    end
end


function config.merge(dest, src)
    local srcs = src or {}
    for k, v in pairs(srcs) do
        if not dest[k] then
            dest[k] =v 
        else
            if type(v)=='table' then
                dest[k] = dest[k] or {}
                config.merge(dest[k], v)
            end
        end
    end
    return dest
end

function config.getallconfig()

    local dest = {a = 1, b = 2}
    local src  = {c = 3, d = 4}
    table.dumpdebug(config.merge(dest, src),"sssssss")

    local conn = mongo:new()
    conn:set_timeout(5000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col('gameconfig')

    local tmp = {}
    for k,v in pairs(DEFAULT) do
        local val = col1:find_one({_id=k})
        if val then
            tmp[k]= config.merge(val, DEFAULT[k])
            tmp[k]._id=nil
        else
            tmp[k] = DEFAULT[k]
        end
    end
    return tmp
end

function config.get(...)
    local d = dbconfig
    for _,v in ipairs({...}) do
        local k = v
        d=d[k]
        if not d then
            break
        end
    end
    if d then
        return d
    end

    local d = DEFAULT
    for _,v in ipairs({...}) do
        local k = v
        d=d[k]
        if not d then
            break
        end
    end
    if d then
        return d
    end
    assert(false,'不能走到这里')
end

return config
