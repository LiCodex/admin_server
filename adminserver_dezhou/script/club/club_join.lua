local cjson = require "cjson"
local string = require "string"
local string = require "string"
local table = require "table"
local table = require "table"
local mongo = require "resty.mongol"
local redis = require "redis"
local jwt       = require "resty.jwt"
local keysutils = require "keysutils"
local rnd = require "rnd"
local userlogic = require "userlogic"
local usermodel = require "usermodel"


require "functions"
local log = table.dumpdebug
local desclog = ">>>>>>>>>>>>>>> log dump info >>>>>>>>>>>>>>"

local result = {}
local arg=ngx.req.get_uri_args()
-- local uid =arg.uid
local clubkey=arg.clubkey
ngx.header.content_type = "application/json; charset=utf-8"
local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})

if not arg.clubkey or not arg.uid then
    result.code = 10000
    result.data = "参数错误 10000"
    ngx.say(cjson.encode(result))
    return
end
--馆主的UID的判断
-- rediscli:lockProcess(GAMENAME..":halllock",function ()
-- end)


local ok,uid = pcall(tonumber, arg.uid)
local ok1,clubkey = pcall(tonumber, arg.clubkey)
if not ok or not ok1 then
    result.code = 10001
    result.data = "参数错误 10001"
    ngx.say(cjson.encode(result))
    return
end

    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    local db=conn:new_db_handle(GAMENAME)
    local col1 = db:get_col("hall")
    local col2 = db:get_col("myclub")

    local r = col1:find_one({_id=clubkey})
    if not r then
        ngx.say(cjson.encode({data='俱乐部不存在'}))
    else
        local r =  col2:find_one({uid=uid,clubkey=clubkey})
        if not r then
            local info = {}
            info._id = clubkey..uid
            info.op=0
            info.clubkey = clubkey
            info.date = os.time()
            info.uid = uid
            info.clubfangka = tonumber(rediscli:get(GAMENAME..'-orifangka')) or 3
            info.isfirstjoin = 1    --是否首次加入
            info.isin = 0   --是否还在俱乐部
            col2:insert({info},nil,true)
            ngx.say(cjson.encode({data='申请加入俱乐部成功'}))

            local wId = rnd.getWorkerId(tonumber(clubkey))
            -- local center = require "center"
            -- center.send2center({
            --     src='admin',
            --     m='apply',
            --     c='club',
            --     data={clubkey=clubkey,state=state},
            -- },wId)
            ngx.log(ngx.INFO,'____fffdddd_操作成功')
        else
            -- 之前已经加入过此俱乐部 再次申请
            if tonumber(r.isin) == 0 then

                if r.op==0 then
                    ngx.say(cjson.encode({data='已经申请加入了俱乐部'}))
                    return
                else                
                    col2:update({uid=uid,clubkey=clubkey},{["$set"]={op=0,isin=0}},0,0)
                    ngx.say(cjson.encode({data='申请加入俱乐部成功'}))

                    local wId = rnd.getWorkerId(tonumber(clubkey))
                    -- local center = require "center"
                    -- center.send2center({
                    --     src='admin',
                    --     m='apply',
                    --     c='club',
                    --     data={clubkey=clubkey,state=state},
                    -- },wId)
                    ngx.log(ngx.INFO,'____fffdddd_操作成功')
                end
            end

            if r.uid==uid then
                ngx.say(cjson.encode({data='不能加入自己的俱乐部'}))
                return 
            end
        end
    end




