-- 市场
local cjson     = require "cjson"
local redcache  = require "redcache"
local idgen     = require "idgen"
local keysutils = require "keysutils"
local redis     = require "redis"
local utils     = require "utils"
local genid     = require "genid"
local mongo     = require "resty.mongol"
local redcache  = require "redcache"
local utilsdate = require "utilsdate"
local config    = require "config"
local utilsdate = require "utilsdate"

math.randomseed(tostring(ngx.time()):reverse():sub(1, 6));

local sharelogic = {}

function sharelogic.share(red,uid)
    local key = keysutils.get_model_key('share',uid)
    key = key .. utilsdate.onedaybegin(os.time())

    local a = red:setnx(key,1)
    red:expire(key,24*3600+10)

    return a
end

return sharelogic
