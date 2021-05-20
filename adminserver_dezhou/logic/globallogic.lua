-- 市场
local cjson       = require "cjson"
local redcache    = require "redcache"
local idgen       = require "idgen"
local keysutils   = require "keysutils"
local redis       = require "redis"
local utils       = require "utils"
local genid       = require "genid"
local mongo       = require "resty.mongol"
local redcache    = require "redcache"
local utilsdate   = require "utilsdate"
local config      = require "config"
local utilsdate   = require "utilsdate"
local globalmodel = require "globalmodel"
local systbkmodel = require "systbkmodel"

math.randomseed(tostring(ngx.time()):reverse():sub(1, 6));

local globallogic = {}

function globallogic.loadglobal(red,uid)
    local key = keysutils.get_model_key('global','config')
    local g = globalmodel.new(key,red)
    g:read()
    return g
end

function globallogic.loadsystbk(red,uid)
    local today = utilsdate.daybegin(os.time())
    local key = keysutils.get_model_key('globaltbk',today)
    local g = systbkmodel.new(key,red)
    g:read()
    return g
end

return globallogic
