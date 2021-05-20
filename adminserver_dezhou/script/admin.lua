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
local idgen         = require "idgen"
require "functions"

local _M = {}
local CMD = {}

-- 添加管理员
function CMD.addmanager(red)
    local arg=ngx.req.get_uri_args()
    local name = arg.fname
    local pwd = arg.password

    table.dumpdebug(arg,"_____________arg:")
    local result = {}
    if not name or not pwd or string.len(pwd) == 0 or not arg.frole then
        result.code = 10001
        result.data = '参数或者密码错误10001'
        return result
    end

    local ok , role = pcall(tonumber,arg.frole)
    if not ok then
        role = 1
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
    local col1 = db:get_col("admins")

    local uid = idgen.genadminuid(col1)
    table.dumpdebug(uid,"_____________createuid::")
    if not uid then
        result.code = 10003
        result.data = '参数或者密码错误10003'
        return result
    end

    local res = col1:find_one({name=name})
    if res then
        result.code = 10004
        result.data = '管理员已存在10004'
        return result
    end

    local ret , err = col1:insert({{_id=''..uid,uid=uid,name=name,password=pwd,role=role,timestamp=os.time()}})
    if ret ~= -1 and err then
        table.dumpdebug(err, 'err msg: ')
        result.code = 10005
        result.data = '参数或者密码错误10005'
        return result
    end

    result.code = 20000
    result.data = '添加管理员成功'
    return result
end

-- 移除管理员
function CMD.delmanager(red)
    local arg=ngx.req.get_uri_args()
    -- local fuid = arg.fuid

    local result = {}
    if not arg.fuid then
        result.code = 10001
        result.data = '参数或者密码错误10001'
        return result
    end

    local ok , fuid = pcall(tonumber,arg.fuid)
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
    local col1 = db:get_col("admins")

    local res = col1:find_one({uid=fuid})
    if not res then
        result.code = 10004
        result.data = '参数或者密码错误10004'
        return result
    end

    local ret , err = col1:delete({uid=fuid},1)
    if ret ~= -1 and err then
        table.dumpdebug(err, 'err msg: ')
        result.code = 10005
        result.data = '参数或者密码错误10005'
        return result
    end

    result.code = 20000
    result.data = '删除管理员成功'
    return result
end

-- 管理列表
function CMD.managerlist(red)
    local arg=ngx.req.get_uri_args()
    local name = arg.name
    local uid = arg.uid

    local result = {}
    if not name or not uid then
        result.code = 10001
        result.data = '参数或者密码错误10001'
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
    local col1 = db:get_col("admins")

    local data = {}
    local cursor = col1:find({uid={['$gt']=1}})
    local ret,err = cursor:sort({timestamp=-1})
    if not err then
        for index, item in pairs(ret) do
            table.insert(data, item)
        end
    end

    result.code = 20000
    result.data = data
    return result
end

-- 管理员信息
function CMD.admininfo(red)
    -- 获取登陆后台用户信息及权限
    local arg=ngx.req.get_uri_args()
    local name = arg.name

    table.dumpdebug(arg,"===========>>>>>>arg::::")
    table.dumpdebug(MONGO_CONFIG,"===========>>>>>>mongo config::::")

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)

    -- 对获取用户权限修改
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("admins")
    local res = col1:find_one({name=name})

    local result = {}
    result.code = 20000
    result.data = {
        role = {res.role or 'players'},
        name = res.name,
        uid=res.uid,
        payload=payload,
    }
    conn:close()

    return result
end

-- 管理员登陆
function CMD.adminlogin(red)
    local result = {}
    ngx.req.read_body()

    local newarg=nil
    local args = ngx.req.get_post_args()

    for k,v in pairs(args) do
        newarg=k
    end

    ngx.log(ngx.INFO, 'vue login = '..cjson.encode(args))

    if not args then
        result.code=10001
        result.data = '参数或者密码错误10001'
        return result
    end

    if not newarg then
        result.code=10002
        result.data = '参数或者密码错误10002'
        return result
    end


    local ok,tmp = pcall(cjson.decode,newarg)
    if not ok then
        result.code=10003
        result.data = '参数或者密码错误10003'
        return result
    end

    args = tmp

    local name=args.username
    local pwd =args.password


    local role = nil
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)

    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("admins")
    local res = col1:find_one({name=name})

    table.dumpdebug(res,'_______Res______:')
    if not res or  pwd~= res['password'] or not res['role'] then
        result.code=10010
        result.data = '参数或者密码错误10010'
        conn:close()
        return result
    end

    local ok , roleid = pcall(tonumber, res['role'])
    if not ok then
        result.code=10011
        result.data = '参数或者密码错误10011'
        conn:close()
        return result
    end

    table.dumpdebug(roleid,"_______Res______:")
    -- if not roleid then
    --     roleid = 100
    -- end
    
    if roleid <= 0 then
        result.code=10012
        result.data = '非管理员权限10012'
        conn:close()
        return result
    end
    res['role'] = roleid

    conn:close()
    if true then
        local jwt_token = jwt:sign(
        "lua-resty-jwt",
        {
            header={typ="JWT", alg="HS256"},
            payload={
                name=name,
                uid=res.uid,
                role=res.role
            }
        }
        )

        result = {code=20000,data={token=jwt_token}}
        return result
    end
end

function CMD.adminlogout(red)
    local result = {}
    result = {code=20000,data="登出"}
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

