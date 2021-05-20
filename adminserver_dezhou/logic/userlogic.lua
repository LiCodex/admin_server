-- 市场
local cjson       = require "cjson"
local redcache    = require "redcache"
local idgen       = require "idgen"
local keysutils   = require "keysutils"
local redis       = require "redis"
local utils       = require "utils"
local genid       = require "genid"
local mongo       = require "resty.mongol"
local usermodel   = require "usermodel"
local userexmodel = require "userexmodel"

local userlogic = {}

--获得红点
function userlogic.loaduser(red, uid)
    local key = keysutils.get_model_key('user', uid)
    local user = usermodel.new(key, red)
    user:read()
    return user
end

function userlogic.loaduserex(red, uid)
    local key = keysutils.get_model_key('userex', uid)
    local user = userexmodel.new(key, red)
    user:read()
    return user
end

return userlogic
