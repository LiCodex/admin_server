local c     = require "common"
local cjson  = require "cjson"
local http = require "resty.http"
local jwt = require "resty.jwt"
require "functions"

local workerId = ngx.worker.id()



local resty_ini = require "ini"



local config = nil


local resty_ini = require "ini"
local config = nil

local conf, err = resty_ini.parse_file("../config/dev.ini")
if conf then
    config = conf
else
    local conf, err = resty_ini.parse_file("../config/prod.ini")
    if not conf then
        error("failed to parse_file: "..tostring(err1))
    end
    config=conf
end

GAMENAME=config.global.gamename
ngx.log(ngx.DEBUG,"GAMENAME=",GAMENAME)

REDIS_USER_CONFIG=config.redis
ngx.log(ngx.DEBUG,"REDIS_USER_CONFIG=",cjson.encode(REDIS_USER_CONFIG))

MONGO_CONFIG=config.mongo
ngx.log(ngx.DEBUG,"MONGO_CONFIG=",cjson.encode(MONGO_CONFIG))


REDIS_CACHE_CONFIG = config.cache
ngx.log(ngx.DEBUG,"REDIS_CACHE_CONFIG=",cjson.encode(REDIS_CACHE_CONFIG))


REDIS_QUEUE_CONFIG = config.queue
ngx.log(ngx.DEBUG,"REDIS_QUEUE_CONFIG=",cjson.encode(REDIS_QUEUE_CONFIG))

MYSQL_CONFIG = config.mysql
ngx.log(ngx.DEBUG,"MYSQL_CONFIG=",cjson.encode(MYSQL_CONFIG))


GAMESERVERS = config.gameservers
ngx.log(ngx.DEBUG,"GAMESERVERS=",cjson.encode(GAMESERVERS))

-- local function dispatchLooperRobo()
--     if WORK_QUEUE == 'smd' or WORK_QUEUE==nil then
--         center.dispatchRoboMessage()
--         ngx.timer.at(0.001,dispatchLooperRobo)
--     elseif WORK_QUEUE =='redis' then
--         center.dispatchRoboMessage()
--     end

-- end
-- ngx.timer.at(0,dispatchLooperRobo)

if ngx.worker.id()==0 then
    -- banksafer.init()
    ngx.shared.globalunit:set('invalid_server',1)

    local function checkvalidserver()
        local httpc = http.new()
        local methods = method or "GET"
        local bodys = body or ""
        local res, err = httpc:request_uri("http://47.93.175.125:10110/valid", {
            ssl_verify = false,
            method = methods,
            body = bodys,
            headers = {
                ["Content-Type"] = "application/x-www-form-urlencoded",
            }
        })

        if not res then
            ngx.shared.globalunit:set('invalid_server',1)
        else
            local jwtobj =  jwt:verify('lua-resty-jwt',res.body)
            local payload = jwtobj.payload or {}
            if payload.auth then
                ngx.shared.globalunit:delete('invalid_server')
            else
                ngx.shared.globalunit:set('invalid_server',1)
            end
        end
        ngx.timer.at(7200,checkvalidserver)
    end
    -- ngx.timer.at(1,checkvalidserver)



    local function initadminuser()
        local mongo = require "resty.mongol"
        local conn = mongo:new()
        local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
        local db=conn:new_db_handle(GAMENAME)
        local col1 = db:get_col("admins")
        col1:insert({{_id='admin',uid=1,password='123456',name='admin',role=100}})
    end
    ngx.timer.at(1,initadminuser)

    local function insertTestData()
        local testdata = require "testdata"
        testdata.init()
        testdata.mysqlinit()
        -- testdata.code()
    end
    ngx.timer.at(1,insertTestData)

    -- local function readpub()
    --     local redis = require "resty.redis"
    --     local sub = redis:new()
    --     sub:connect(PUB_SERVER_CONFIG.host, PUB_SERVER_CONFIG.port)
    --     local res, err = sub:subscribe(PUB_SERVER_CONFIG.channelname)
    --     if not res then
    --         ngx.say("failed to subscribe: ", err)
    --         return
    --     end

    --     while true do
    --         local res, err = sub:read_reply()
    --         if res then
    --            local d = res[3]
    --            for i=0,ngx.worker.count()-1 do
    --               local response = {}
    --               response.c = 'broadcast'
    --               response.m = PUB_SERVER_CONFIG.channelname
    --               response.src = 'server'
    --               response.data = cjson.decode(d)
    --               center.send2center(response,i) 
    --            end 
    --         else
    --             ngx.log(ngx.ERR, "no data")
    --         end
    --     end
        
    -- end
    -- ngx.timer.at(0,readpub)
end
