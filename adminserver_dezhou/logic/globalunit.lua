local globalunit = {}
local redis = require "redis"
local keysutils = require "keysutils"

local function safe2number(val)
    if not val then return 0 end
    local ok,v = pcall(tonumber,val)
    if ok then
        return v
    end
    return 0
end

local function getfangka(uid)
   local rediscli = redis:new({timeout=1000}) 
   local fangka   = rediscli:hget(keysutils.get_user_main_key(uid),"fangka")
   return safe2number(fangka)
end

local function getzuanshi(uid)
   local rediscli = redis:new({timeout=1000}) 
   local zuanshi   = rediscli:hget(keysutils.get_user_main_key(uid),"zuanshi")
   return safe2number(zuanshi)
end

globalunit.getfangka = getfangka
globalunit.getzuanshi = getzuanshi
globalunit.safe2number = safe2number
--计算房卡数
function globalunit.calroomneedfangka(roomconfig)
	return tonumber(roomconfig.costfangka) * -1
end

function globalunit.incrbyfangka(uid,fangka)
  local rediscli = redis:new({timeout=1000}) 
  local fangka   = rediscli:hincrby(keysutils.get_user_main_key(uid),"fangka",fangka)
end
function globalunit.incrbyzuanshi(uid,zuanshi)
  local rediscli = redis:new({timeout=1000}) 
  local zuanshi   = rediscli:hincrbyfloat(keysutils.get_user_main_key(uid),"zuanshi",zuanshi)
end

function globalunit.incrbyyongjin(uid,yongjin)
  local rediscli = redis:new({timeout=1000}) 
  local yongjin   = rediscli:hincrbyfloat(keysutils.get_user_main_key(uid),"yongjin",yongjin)
end

return globalunit