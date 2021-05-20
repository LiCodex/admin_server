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
-- local loginput      = require "loginput"


require "functions"
local method = ngx.req.get_method()
if string.upper(method) == 'OPTIONS' then
    ngx.say('ok')
    return 
end

local game = 'dezhou'
local result = {}
local arg=ngx.req.get_uri_args()
table.dumpdebug(arg,'================>>>>>>>>>>>arg:')

local uid = arg.uid

if not arg.chongzhiuid or arg.chongzhiuid == '' or not arg.count or not arg.typ then
    result.code=10001
    result.data = '请正确输入信息10001'
    ngx.say(cjson.encode(result))
    return 
end

local ok, chongzhiuid = pcall(tonumber,arg.chongzhiuid)
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

local res = col1:find_one({uid=chongzhiuid})
if not res then
    result.code = 10002
    result.data = '玩家不存在10002'
    ngx.say(cjson.encode(result))
    return
end

local ok1,typ = pcall(tonumber,arg.typ)
if not ok1 then
    result.code = 10005
    result.data = '请正确输入信息10005'
    return result
end

local ok,count = pcall(tonumber,arg.count)
if not ok then
    result.code=10004
    result.data = '请正确输入信息10004'
    ngx.say(cjson.encode(result))
    return 
end


local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
local user     = userlogic.loaduser(rediscli,chongzhiuid)
-- local userex = userlogic.loaduserex(rediscli,uid)


-- redis 操作
-- local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
-- 上usdt
-- local user = userlogic.loaduser(rediscli,uid)



local strtyp = 'fangka'
if typ == 1 then
    strtyp = 'coin'
else
    strtyp = 'fangka'
end

-- 添加充值记录
local col2 = db:get_col("chongzhi")
-- mongo充值记录
-- local id_key = string.format("%s-%d",uid,os.time())
local id_key = string.format("%s-%s",chongzhiuid,genid.gen())
local ok2,ret = col2:insert({{_id=id_key,uid=chongzhiuid,count=count,typ=strtyp,game=game,timestamp=os.time()}})
table.dumpdebug(ok2, "_________ok2")
table.dumpdebug(ret, "_________ret")
if not ok2 then
    result.code = 10006
    result.data = '充值失败10006'
    ngx.say(cjson.encode(result))
    return
end



local zhenzhu = 0
if count >0  then
    zhenzhu = user:shangfen(count)
    -- zhenzhu = user:shangfen(count,strtyp)
else
    local cnt = math.abs(count)
    zhenzhu = user:xiafen(cnt,strtyp)
end

-- loginput.logtbk(uid,loginput.admin_shangfen, count)
-- table.dumpdebug(count,"___________logtbk__logtbk__logtbk__logtbk__::::")
if not zhenzhu then
    result.code = 10007
    result.data = '充值失败10007'
    ngx.say(cjson.encode(result))
    return
end


result.code=20000
result.data = '充值成功'    
ngx.say(cjson.encode(result))























