-- 市场
local cjson              = require "cjson"
local redcache           = require "redcache"
local idgen              = require "idgen"
local keysutils          = require "keysutils"
local redis              = require "redis"
local utils              = require "utils"
local genid              = require "genid"
local mongo              = require "resty.mongol"
local minemodel          = require "minemodel"
local config             = require "config"
local utilsdate          = require "utilsdate"
local taskmodel          = require "taskmodel"

math.randomseed(tostring(ngx.time()):reverse():sub(1, 6));
local tasklogic = {}

function tasklogic.loadtask(red,uid)
    local s = utilsdate.daybegin(os.time())
    local key = keysutils.get_model_key('dailytask',uid)

    key = key..":"..s

    local model = taskmodel.new(key,red)
    if red:exists(key)==0 then
        model:read()
        model:save()
    else
        model:readmerge()
    end
    red:hset(key,'xxxx',1)
    return model
end

--删除每日任务中的一个小任务
function tasklogic.delsubtask(red,uid,subkey)
    local s = utilsdate.daybegin(os.time())
    local key = keysutils.get_model_key('dailytask',uid)

    key = key..":"..s
    red:hdel(key,subkey)
end

return tasklogic
