local cjson = require "cjson"
local string = require "string"
local table_new = require "table.new"
local table = require "table"
local redis = require "redis"
local utils=require "utils"
local mongo = require "resty.mongol"
local keysutils = require "keysutils"

require "functions"

local _M = {}
local CMD = {}

function CMD.changepwd(red)
    local result = {}
    local arg=ngx.req.get_uri_args()
    local oldpwd = arg.oldpwd
    local newpwd = arg.newpwd
    local pwd = arg.pwd

    table.dumpdebug(arg,"______>>>>>>>> changepwd:::")

    if not oldpwd or oldpwd == '' then
        result.code=10001
        result.data = '请输入旧密码'
        return result
    end

    if not newpwd or newpwd == '' or not pwd or pwd == '' then
        result.code=10002
        result.data = '请输入新密码'
        return result
    end


    if  newpwd ~=  pwd  then
        result.code=10003
        result.data = '两次密码必须一致'
        return result
    end
    if string.len(newpwd) <= 4 then
        result.code=10004
        result.data = '密码长度必须大于4'
        return result
    end


    local ok,uid = pcall(tonumber,arg.uid)
    if not ok then
        result.code=10005
        result.data = '参数或者密码错误10005'
        return result
    end

    table.dumpdebug(uid, '-----------changepwd uid = ')

    -- local red = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
    -- local uid = keysutils.get_user_map(useruid)

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("admins")

    local row = col1:find_one({uid=uid})
    table.dumpdebug( row , '______ mongo query result:: =====')

    if not row or not row['password']then
        result.code=10006
        result.data = '用户不存在10006'
        conn:close()
        return result
    end

    if row['password'] ~= oldpwd then
        result.code=10007
        result.data = '原密码不正确: 10007'
        conn:close()
        return result
    end
    -- col1:update({_id='admin-'..finduid},{['$set']={_id='admin-'..finduid,uid=finduid, name=name,password='123456',role=tequan,timestamp=os.time()}},1,0)
    col1:update({uid=uid},{['$set']={password=newpwd}},1,0)
    conn:close()
    -- if not uid then
    --     result.code=10005
    --     result.data = '参数或者密码错误10005'
    --     return result
    -- end

    -- local k = red:get(uid)
    -- if not k then
    --     result.code=10006
    --     result.data = '参数或者密码错误10006'
    --     return result
    -- end

    -- local password = red:hget(keysutils.get_user_main_key(k),'pwd')
    -- if oldpwd~=password then
    --     result.code=10007
    --     result.data = '密码错误7'
    --     return result
    -- end

    -- local num = string.len(pwd)
    -- if num<4 then
    --     result.code=10008
    --     result.data = '密码长度必须大于4'
    --     return result
    -- end

    -- local ok = red:hset(keysutils.get_user_main_key(k),'pwd',pwd)
    -- if ok then
    --     result.code=20000
    --     result.data = '设置成功'
    --     return result
    -- end
    result.code=20000
    result.data = '设置成功'
    return result
end

function CMD.changebankpwd(red)
    local result = {}
    local arg=ngx.req.get_uri_args()

    local oldpwd = arg.oldpwd
    local newpwd = arg.newpwd
    local pwd = arg.pwd

    if not oldpwd or oldpwd == '' then
        result.code=10001
        result.data = '请输入旧密码'
        return result
    end

    if not newpwd or newpwd == '' or not pwd or pwd == '' then
        result.code=10002
        result.data = '请输入新密码'
        return result
    end

    if  newpwd ~=  pwd  then
        result.code=10003
        result.data = '两次密码必须一致'
        return result
    end

    local uid1 = arg.uid
    local ok,val = pcall(tonumber,uid1)
    if not ok or not val then
        result.code=10004
        result.data = '参数或者密码错误10004'
        return result
    end

    uid1=val
    local red = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
    local uid = keysutils.get_user_map(uid1-10000)
    if not uid then
        result.code=10005
        result.data = '参数或者密码错误10005'
        return result
    end

    local k = red:get(uid)
    if not k then
        result.code=10006
        result.data = '参数或者密码错误10006'
        return result
    end

    local password = red:hget(keysutils.get_user_main_key(k),'bankpwd')
    if not password or oldpwd~=password then
        result.code=10006
        result.data = '旧密码错误'
        return result
    end

    local num = string.len(pwd)
    if num<4 then
        result.code=10006
        result.data = '密码长度必须大于4'
        return result
    end

    local ok = red:hset(keysutils.get_user_main_key(k),'bankpwd',pwd)
    if ok then
        result.code=20000
        result.data = '银行密码设置成功'
        return result
    end
end

function _M.invoke(name)
    local method = ngx.req.get_method()
    if string.upper(method) == 'OPTIONS' then
        ngx.say('ok')
        return
    end
    local arg=ngx.req.get_uri_args()
    ngx.log(ngx.DEBUG,'=================================> function:',name,',data:',cjson.encode(arg))

    local rediscli = redis:new({host=REDIS_USER_CONFIG.ip,port=REDIS_USER_CONFIG.port})
    ngx.header['Content-Type'] = 'application/json; charset=utf-8'

    if arg.uid then
        local mainkey = keysutils.get_user_main_key(arg.uid)
        local f = CMD[name]
        if not TEST then
            local l = redislock.new(rediscli,"lock:"..mainkey,10)
            if l:lock() then
                local result = f(rediscli)
                if result.errcode and result.errcode~=0 then
                    result.errmsg=config.get('errmsg','e'..result.errcode)
                end
                ngx.say(cjson.encode(result))
                l:unlock()
            end
        else
            local result = f(rediscli)
            if result.errcode and result.errcode~=0 then
                result.errmsg=config.get('errmsg','e'..result.errcode)
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
                if result.errcode and result.errcode~=0 then
                    result.errmsg=config.get('errmsg','e'..result.errcode)
                end
                ngx.say(cjson.encode(result))
                l:unlock()
            end
        else
            local result = f(rediscli)
            if result.errcode and result.errcode~=0 then
                result.errmsg=config.get('errmsg','e'..result.errcode)
            end
            ngx.log(ngx.DEBUG,'<================================= function:',name,",data:",cjson.encode(result))
            ngx.say(cjson.encode(result))
        end
    end

    -- ngx.say("hello")
end

return _M