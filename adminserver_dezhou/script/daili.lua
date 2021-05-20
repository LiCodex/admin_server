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
local genid = require "genid"
local fanli = require "fanli"

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

function CMD.fanlitest(red)
    local arg=ngx.req.get_uri_args()
    
    local result = {}
    local ok,count = pcall(tonumber, arg.count)
    local ok,chongzhiuid = pcall(tonumber, arg.chongzhiuid)

    local ret = fanli.fanli(red, count, chongzhiuid)

    table.dumpdebug(ret,"fanli test:::")
    return ret
    -- result.code = 2000
    -- result.data = 'test succeed'
    -- return result
end

function CMD.getadminfanli(red)
    local arg=ngx.req.get_uri_args()
    
    local result = {}
    local data  = {}
    data.fanli = 0

    local basefanli = red:get(keysutils.get_base_fanli_key())
    table.dumpdebug(basefanli,"======basefanli111111=====")
    if not basefanli then
        basefanli = 1
        data.fanli = basefanli
    else
        local ok,fanli = pcall(tonumber, basefanli)
        table.dumpdebug(fanli,"======fanli 2222222222=====")

        if ok and fanli then
            data.fanli= fanli
            table.dumpdebug(ok,"======fanli 333333=====")
        end
    end

    result.code = 20000
    result.data = data
    return result
end

function CMD.setadminfanli(red)
    local arg=ngx.req.get_uri_args()
    
    local result = {}
    local data  = {}

    if not arg.uid or arg.uid == '' or not arg.fanli then
        result.code=10001
        result.data = '参数或者密码错误10001'
        return result
    end
    local ok,uid =  pcall(tonumber, arg.uid)
    local ok1,fanli =  pcall(tonumber, arg.fanli)
    if not ok or not ok1 or uid == nil or fanli == nil then
        result.code=10002
        result.data = '参数或者密码错误10002'
        return result
    end

    red:set(keysutils.get_base_fanli_key(), fanli)

    result.code = 20000
    result.data = data
    return result
end


function CMD.setfanli(red)
    local arg=ngx.req.get_uri_args()
    local result = {}
    result.code = 10001

    if not arg.uid or arg.uid == '' or not arg.fanli then
        result.code=10001
        result.data = '参数或者密码错误10001'
        return result
    end

    local ok , uid = pcall(tonumber, arg.uid)
    local ok1, fanli = pcall(tonumber, arg.fanli)
    if not ok or not ok1 or not fanli then
        result.code=10003
        result.data='参数或者密码错误10003'
        return result
    end

    local u = userlogic.loaduser(red,uid)
    if u.daili == 1 then
        fanli = math.ceil(fanli);
        u.fanli = fanli
        u:save()

        result.code = 20000
    end
    result.data = '设置返利成功'
    return result
end

function CMD.setsjfanli(red)
    local arg=ngx.req.get_uri_args()
    local result = {}
    result.code = 10001

    if not arg.fuid or arg.fuid == '' or not arg.sjfanli then
        result.code=10001
        result.data = '参数或者密码错误10001'
        return result
    end

    local ok , fuid = pcall(tonumber, arg.fuid)
    local ok1, sjfanli = pcall(tonumber, arg.sjfanli)
    if not ok or not ok1 or not sjfanli then
        result.code=10003
        result.data='参数或者密码错误10003'
        return result
    end

    sjfanli = math.ceil(sjfanli);
    if sjfanli < 0 then
        result.code=10008
        result.data='不能设置小于0的返利'
        return result
    end

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if err then
        result.code = 10002
        result.data = '参数或者密码错误 10002'
        return result
    end
    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("daili")
    local col2 = db:get_col("tuijianren")

    local res = col2:find_one({uid=fuid})
    if res and res['uid1'] then
        local dailiuser = userlogic.loaduser(red,res['uid1'])
        local u = userlogic.loaduser(red,fuid)
        if u.daili == 1 then
            if dailiuser.sjfanli < sjfanli then
                result.code=10005
                result.data='您设置的返利不应大于上级设置的返利最大限额 10005'
                return result
            else
                u.sjfanli = sjfanli
                u:save()
                result.code = 20000
            end
        end
    else
        result.code=10004
        result.data='该用户没有上级代理 10004'
        return result
    end

    result.data = '设置返利成功'
    return result
end


function CMD.setlev1dailifanli(red)
    local arg=ngx.req.get_uri_args()
    local result = {}
    result.code = 10001

    if not arg.fuid or arg.fuid == '' or not arg.sjfanli then
        result.code=10001
        result.data = '参数或者密码错误10001'
        return result
    end

    local ok , fuid = pcall(tonumber, arg.fuid)
    local ok1, sjfanli = pcall(tonumber, arg.sjfanli)
    if not ok or not ok1 or not sjfanli then
        result.code=10003
        result.data='参数或者密码错误10003'
        return result
    end

    sjfanli = math.ceil(sjfanli);
    if sjfanli > 100 or sjfanli < 0 then
        result.code=10007
        result.data='不能设置超过100%,或小于0%的返利'
        return result
    end

    local u = userlogic.loaduser(red,fuid)
    if u.daili == 1 then
        u.sjfanli = sjfanli
        u:save()
        
    end
    result.code = 20000
    result.data = '设置返利成功'
    return result
end


function CMD.getfanli(red)
    local arg=ngx.req.get_uri_args()
    
    local result = {}
    local data  = {}
    data.fanli = 0
    data.shangjifanli = -1

    if not arg.uid or arg.uid == '' then
        result.code=10001
        result.data = '参数或者密码错误10001'
        return result
    end

    local ok , uid = pcall(tonumber, arg.uid)
    if not ok then
        result.code=10003
        result.data = '参数或者密码错误10003'
        return result
    end

    local u = userlogic.loaduser(red,uid)
    if u.shangji and u.shangji ~= 0 then
        data.shangjifanli = u.sjfanli
    else
        local basefanli = red:get(keysutils.get_base_fanli_key())
        if not basefanli then
            basefanli = 10
        else
            local ok,fanli = pcall(tonumber, basefanli)
            if ok and fanli then
                basefanli = fanli
            end
        end
        u.sjfanli = basefanli
        u:save()
        data.shangjifanli = basefanli
    end

    result.code = 20000
    result.data =data
    return result
end

--获取团队信息
function CMD.getteaminfo(red)
    local arg=ngx.req.get_uri_args()
    local uid = arg.uid
    table.dumpdebug(arg, '___getteaminfo__args_______')
    
    local result = {}
    if not uid or uid == '' then
        result.code=10001
        result.data = '参数或者密码错误10001'
        return result
    end
    local data = {}
    local item = {}

    table.dumpdebug("_________CCcc1111111111")
    local ok,uid = pcall(tonumber,arg.uid)
    if not ok then
        result.code=10003
        result.data = '参数或者密码错误10003'
        return result
    end

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
    local col1 = db:get_col("daili")
    local col2 = db:get_col("tuijianren")


    -- local cursor = col2:find({},{},999999)
    local cursor = col2:find({uid1=uid},{},999999)
    -- local cursor = col2:find({},{},999999)

    local ret,err = cursor:sort({timestamp=-1})
    if not err then
        for index, item in pairs(ret) do
            if item['uid'] then
                local userinfo = getplayerinfo(item['uid'], red)
                table.insert(data, userinfo)
            end
        end
    end
    
    result.data = data
    result.code =20000
    table.dumpdebug(data,"data:")
    return result
end


-- 代理列表
-- function CMD.daililist(red)
--     local arg=ngx.req.get_uri_args()
--     local name = arg.name
--     local uid = arg.uid

--     local result = {}

--     local conn = mongo:new()
--     conn:set_timeout(1000)
--     local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
--     if err then
--         result.code = 10002
--         result.data = '参数或者密码错误10002'
--         return result
--     end
--     -- 对获取用户权限修改
--     local db=conn:new_db_handle(GAMENAME)
--     local col1 = db:get_col("daili")
--     local col2 = db:get_col("tuijianren")

--     local data = {}
--     -- local cursor = col1:find({uid={['$gt']=1}})
--     local cursor = col1:find({},{},999999)
--     local ret,err = cursor:sort({timestamp=-1})
--     if not err then
--         for index, item in pairs(ret) do
--             if item['uid'] and item['daili'] == 1 then
--                 local cnt = col2:count({uid1=item['uid']})
--                 info = getplayerinfo(item['uid'],red)
--                 item['name'] = info['name']
--                 item['cnt'] = cnt
--                 table.insert(data, item)
--             end
--         end
--     end

--     result.code = 20000
--     result.data = data
--     return result
-- end

-- 绑定代理[天天乐牛牛]
function CMD.bindtuijianren(red)
    local arg=ngx.req.get_uri_args()
    local result = {}
    local zengsong = false
    local song = 0

    if not arg.uid or not arg.dailiuid then
        result.code = 10001
        result.data = '参数错误'
        return result
    end
    local ok, uid = pcall(tonumber, arg.uid)
    local ok1, dailiuid = pcall(tonumber, arg.dailiuid)
    if not ok or not ok1 then
        result.code = 10002
        result.data = '参数错误'
        return result
    end

    local u = userlogic.loaduser(red, dailiuid)
    if not u or u.daili ~= 1 then
        result.code = 10003
        result.data = '玩家不存在,或输入的代理UID不是代理权限'
        return result
    end

    if uid == dailiuid then
        result.code = 10005
        result.data = '代理不能绑定自己'
        return result
    end

    local p = userlogic.loaduser(red, uid)
    if not p then
        result.code = 10004
        result.data = '玩家不存在'
        return result
    end
    
    if p.shangji == 0 or not p.shangji then
        zengsong = true
    end

    p.shangji = dailiuid
    p:save()
    if zengsong == true then
        p:shangfen(8,'fangka')
        song = 8
    end

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
    local col2 = db:get_col("tuijianren")
    local res = col2:find_one({uid=dailiuid})

    local doc = {}
    doc._id = ''..uid..dailiuid
    doc.uid = uid
    doc.uid1 = dailiuid
    doc.timestamp = os.time()
    if res then
        if res['uid1'] then
            doc.uid2 = res['uid1']
        end
        if res['uid2'] then
            doc.uid3 = res['uid2']
        end
    end
    col2:insert({doc},1,1)

    result.code = 20000
    result.song = song     -- 送房卡数
    result.data = '代理绑定成功'
    return result
end


-- 代理列表
function CMD.daililist(red)
    local arg=ngx.req.get_uri_args()
    local name = arg.name
    local uid = arg.uid

    local result = {}

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
    local col1 = db:get_col("daili")
    local col2 = db:get_col("tuijianren")

    local data = {}
    -- local cursor = col1:find({uid={['$gt']=1}})
    local cursor = col1:find({},{},999999)
    local ret,err = cursor:sort({timestamp=-1})
    if not err then
        for index, item in pairs(ret) do
            if item['uid'] and item['daili'] == 1 then
                local cnt = col2:count({uid1=item['uid']})
                -- info = getplayerinfo(item['uid'],red)
                local u = userlogic.loaduser(red,item['uid'])
                local uinfo = u:toparam()
                item['name'] = uinfo['name']
                item['fanli'] = uinfo['fanli']
                item['sjfanli'] = uinfo['sjfanli']
                item['cnt'] = cnt
                table.insert(data, item)
            end
        end
    end

    result.code = 20000
    result.data = data
    return result
end


-- 代理列表
function CMD.getfanlichongzhirecord(red)
    local arg=ngx.req.get_uri_args()
    local name = arg.name
    local fuid = arg.fuid

    table.dumpdebug("=======getfanlichongzhirecord==========")
    local result = {}

    if not arg.fuid then
        result.code = 10001
        result.data = '参数或者密码错误10001'
        return result
    end
    local ok ,fuid = pcall(tonumber, arg.fuid)
    if not ok then
        result.code = 10002
        result.data = '参数或者密码错误10002'
        return result
    end

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
    local col2 = db:get_col("chongzhi")

    table.dumpdebug(fuid,"=======fuid=======")
    local data = {}
    -- local cursor = col1:find({uid={['$gt']=1}})
    local cursor = col1:find({dailiuid=fuid},{},999999)
    local ret,err = cursor:sort({timestamp=-1})
    if not err then
        for index, item in pairs(ret) do
            if item['czuid'] and item['czkey'] then
                table.dumpdebug(item['czuid'],"=======item['czuid']=======")
                local czres = col2:find_one({_id=item["czkey"]})
                if czres then
                    item['czcount'] = czres['count']
                end

                local u = userlogic.loaduser(red,item['czuid'])
                local uinfo = u:toparam()
                item['name'] = uinfo['name']

                table.dumpdebug(item,"=======item=======")
                table.insert(data, item)
            end
        end
    end

    result.code = 20000
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
    