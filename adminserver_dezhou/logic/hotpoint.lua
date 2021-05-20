-- 市场
local cjson     = require "cjson"
local redcache  = require "redcache"
local idgen     = require "idgen"
local keysutils = require "keysutils"
local redis     = require "redis"
local utils     = require "utils"
local genid     = require "genid"
local mongo     = require "resty.mongol"

local hotpoint = {}

--在这里配置子系统名
local CONFIG = {
    ['mail']={

    },
}

--获得红点
function hotpoint.loadhotpoint(red,uid)
    local mainkey = keysutils.get_user_main_key(uid)
    local key = 'hotpont-'..uid
    for k,v in pairs(CONFIG) do
        local tmpkey = key..'-'..k

        local count = red:bitcount(tmpkey)
        if count>0 then
        end
    end

end

function hotpoint.set(red,uid,module,key)
    local mainkey = keysutils.get_user_main_key(uid)
    local hotkey = 'hotpoint-'..mainkey..'-'..module
end

return hotpoint
