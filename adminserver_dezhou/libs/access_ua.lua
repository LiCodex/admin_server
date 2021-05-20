local cjson     = require "cjson"
local string    = require "string"
local table_new = require "table.new"
local table     = require "table"
local jwt       = require "resty.jwt"
local mongo     = require "resty.mongol"
local redis     = require "redis"
local keysutils = require "keysutils"
local logqueueutil   = require "logqueueutil"

require "functions"

local _M={}

function _M.access(filter)
     -- if TEST then
     --     return
     -- end
     -- filter = filter or {"Windows","Mozilla","curl",}
     -- local headers = ngx.req.get_headers()
     -- local agent = headers["user-agent"]

     -- for _,v in ipairs(filter) do
     --     local regex = v
     --     local m = ngx.re.find( agent, v, 'isjo' )
     --     if m then
     --         ngx.header['Content-Type'] = 'application/json; charset=utf-8'
     --         ngx.say(cjson.encode({errcode=4001,errmsg="访问终端出现问题"}))
     --         ngx.exit(200)
     --         return
     --     end
     -- end
end


return _M
