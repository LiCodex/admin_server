local cjson         = require "cjson"
local string        = require "string"
local table_new     = require "table.new"
local table         = require "table"
local redis         = require "redis"
local utils         =require "utils"
local mongo         = require "resty.mongol"
local keysutils     = require "keysutils"
local gameconfig    = require "config"
local genid         = require "genid"
local usermodel     = require "usermodel"
local userexmodel   = require "userexmodel"
local userlogic     = require "userlogic"
local loginput      = require "loginput"


require "functions"
local method = ngx.req.get_method()
if string.upper(method) == 'OPTIONS' then
    ngx.say('ok')
    return 
end

-- 会长等级
local function gethuizhanglvl(red,uid)
    local zhlvl = 0
    local tuijianrenkey = keysutils.get_model_key('user',uid)
    local l = red:hget(tuijianrenkey,'huizhang')
    if not l then
        return zhlvl
    end
    local ok,lvl = pcall(tonumber,l)
    if not ok then
        return zhlvl
    end
    return lvl
end

local function getteshu(red,uid)
    local tuijianrenkey = keysutils.get_model_key('user',uid)
    local t = red:hget(tuijianrenkey,'teshu')
    local ok,teshu = pcall(tonumber,t)
    if not ok then
        return 0
    end
    return teshu
end

-- 反现在千分比
local function getfanxianpersent(lvl)
    local persent = 0
    if not lvl then
        return persent
    end
    local strkey = 'lvl' + lvl
    return gameconfig.get("recharge_percent",strkey)
end

local function fanxian(red,col1,uid,fuid,usdt,lvl)
    table.dumpdebug(uid,"_______uid:")
    table.dumpdebug(fuid,"_______fuid:")
    table.dumpdebug(usdt,"_______usdt:")
    table.dumpdebug(lvl,"_______lvl:")

    local hzlvl = gethuizhanglvl(red,uid)
    if hzlvl or hzlvl == 0 then
        return
    end

    local persent = getfanxianpersent(hzlvl)
    local fanxiancnt = persent * usdt / 1000    -- 千分比
    if fanxiancnt <= 0 then
        return
    end
    -- 返现
    red:hincrby(keysutils.get_model_key('user',uid),'fanxian_tbk', fanxiancnt)
    -- 记录
    local row = {_id=uid..'-'..os.time(),uid=uid, fuid=fuid ,lvl=lvl,fanxiancnt=fanxiancnt,perc=persent/1000,timestamp=os.time()}
    col1:insert({row})
end

local result = {}
local arg=ngx.req.get_uri_args()
table.dumpdebug(arg,'================>>>>>>>>>>>arg:')

local tbk = arg.tbk
local uid = arg.uid
--local wallet = arg.wallet
local enablefanxian = arg.enablefanxian --or false

table.dumpdebug(enablefanxian,'____enable fanxian :')
if enablefanxian and enablefanxian == true then
    table.dumpdebug(enablefanxian,"_________fanxian.true...")
else
    table.dumpdebug(enablefanxian,"_________fanxian.false...")
end

if not arg.rechargeuid or arg.rechargeuid == '' or not tbk then
    result.code=10001
    result.data = '请正确输入信息10001'
    ngx.say(cjson.encode(result))
    return 
end

local ok, uid = pcall(tonumber,arg.rechargeuid)
if not ok then
    result.code = 10002
    result.data = '参数错误10002'
    ngx.say(cjson.encode(result))
    return
end

-- 查询玩家uid
local conn = mongo:new()
conn:set_timeout(1000)
local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
local db=conn:new_db_handle(GAMENAME)
local col1 = db:get_col("users")

local res = col1:find_one({uid=uid})
if not res then
    result.code = 10002
    result.data = '玩家不存在10002'
    ngx.say(cjson.encode(result))
    return
end


-- 得到要查询玩家的UID
-- uid = res['uid']
local ok,count = pcall(tonumber,tbk)
if not ok then
    result.code=10004
    result.data = '请正确输入信息10004'
    ngx.say(cjson.encode(result))
    return 
end

local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
local user     = userlogic.loaduser(rediscli,uid)
local userex = userlogic.loaduserex(rediscli,uid)
-- redis 操作
-- local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
-- 上usdt
-- local user = userlogic.loaduser(rediscli,uid)


-- 添加充值记录
local col2 = db:get_col("rechargetbk")
-- mongo充值记录
-- local id_key = string.format("%s-%d",uid,os.time())
local id_key = string.format("%s-%s",uid,genid.gen())
local ok2,ret = col2:insert({{_id=id_key,uid=uid,status=0,tbk=count,wallet=userex['wallet'] or '',ethwallet=userex['ethwallet'] or '',timestamp=os.time()}})
table.dumpdebug(ok2, "_________ok2")
table.dumpdebug(ret, "_________ret")
if not ok2 then
    result.code = 10006
    result.data = '充值失败10006'
    ngx.say(cjson.encode(result))
    return
end



local totaltbk = 0
if count >0  then
    totaltbk = user:shangfen(count)
else
    local cnt = math.abs(count)
    totaltbk = user:xiafen(cnt)
end



loginput.logtbk(uid,loginput.admin_shangfen, count)
table.dumpdebug(count,"___________logtbk__logtbk__logtbk__logtbk__::::")
if not totaltbk then
    result.code = 10007
    result.data = '充值失败10007'
    ngx.say(cjson.encode(result))
    return
end


result.code=20000
result.data = '设置成功'    
ngx.say(cjson.encode(result))























