local cjson = require "cjson"
local string = require "string"
local table_new = require "table.new"
local table = require "table"
local redis = require "redis"
local utils=require "utils"
local keysutils = require "keysutils"



local method = ngx.req.get_method()
if string.upper(method) == 'OPTIONS' then
    ngx.say('ok')
    return 
end


local arg=ngx.req.get_uri_args()
local uid1 = arg.uid
local red = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
local result = {}
table.dumpdebug(uid1, 'uid1________:::::')
if uid1 ~= '' then
  -- 查询一个玩家
  local ok,val = pcall(tonumber,uid1)
  if not ok or not val then
      result.code=10004
      result.data = '玩家id格式不正确'
      ngx.say(cjson.encode(result))
      return 
  end

  uid1=val
  local biao = keysutils.get_user_map(uid1-10000)
  if not biao then
      result.code=10005
      result.data = '数据错误'
      ngx.say(cjson.encode(result))
      return 
  end

  local uid = red:get(biao)
  if not uid then
      result.code=10006
      result.data = '该玩家不存在'
      ngx.say(cjson.encode(result))
      return 
  end

  local players = {}
  local v = red:hgetall(GAMENAME..":user:"..uid)
  table.insert(players,utils.redis_pack(v))
  result.code=20000
  result.data = players
  ngx.say(cjson.encode(result))
else
  -- 查询所有玩家
  local all = {}
  all.players = {}

  local kill = arg.kill
  
  if kill == 'true' then
  	red:set(GAMENAME..":userkill",kill)
  else
  	red:del(GAMENAME..":userkill")
  end


  local allplayers=red:get(GAMENAME..":usercounter")

  local ok ,value = pcall(tonumber,allplayers)

  if ok then
      allplayers = value
  else
      allplayers = 0
  end
  all.count = allplayers
  for i=1,allplayers do
     local cursor=red:get(GAMENAME..":usermap:"..i)
     if cursor then
          local v = red:hgetall(GAMENAME..":user:"..cursor)
          local item = utils.redis_pack(v)
          item.zhanghao = cursor
          table.insert(all.players,item)
     end
  end
  ngx.header['Content-Type']="text/html;charset=UTF-8"
  result.code=20000
  result.data = all.players
  ngx.say(cjson.encode(result))
end








