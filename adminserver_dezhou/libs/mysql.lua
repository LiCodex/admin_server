local mysql = require "resty.mysql"
local cjson = require "cjson"
local string = require "string"
local config = {
    host = "192.168.88.227",
    port = 3306,
    database = "guowanglian",
    user = "root",
    password = "root",
    charset = "utf8"
}

local _M = {}


function _M.new(self)
    local db, err = mysql:new()
    if not db then
        ngx.log(ngx.INFO,"db is err")
        return nil
    else
        ngx.log(ngx.INFO,"db is ok")
    end
    db:set_timeout(1000) -- 1 sec

    local ok, err, errno, sqlstate = db:connect(config)
    
    if not ok then
        return nil
    end
    db.close = close
    return db
end

function close(self)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end
    if self.subscribed then
        return nil, "subscribed state"
    end
    return sock:setkeepalive(10000, 50)
end

return _M