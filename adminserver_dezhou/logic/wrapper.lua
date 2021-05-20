
local config         = require "config"
local cjson          = require "cjson"
local mongo          = require "resty.mongol"
local config         = require "config"


require "functions"

-- 包装器 返回数据包装
local wrapper = {}

function wrapper.ngx_say(retdata,funame)
    local senderr = nil
    ngx.log(ngx.DEBUG,'<================================= function:',funame," ,data:",cjson.encode(retdata))
    if retdata.code then
        retdata.code = retdata.code or retdata.errcode
        if retdata.code ~= SUCCEED_CODE then
            retdata.err = retdata.code
            retdata.errmsg = config.get('errmsg', 'e'..retdata.code) or '操作失败'
            retdata.data = config.get('errmsg', 'e'..retdata.code) or '操作失败'
            if not TEST then
                retdata['debug'] = nil
            end
        else
            if not retdata['data'] then
                retdata.data = '操作成功'
            end
        end
    elseif retdata.errcode then

    end

    table.dumpdebug(retdata, "--- dumpdebug   retdata ---->>>>>>>>")
    if retdata then
         ngx.say(cjson.encode(retdata))
    else
        table.dumpdebug("<<<<<<<<<===== err ===---- 返回数据为空 ----========")
        senderr = 1
    end
    return senderr
end

-- 连接游戏mongo db
function wrapper.conn_mongl()
    local conn = mongo:new()
    conn:set_timeout(1000)
    local ok, err = conn:connect(MONGO_CONFIG.ip,MONGO_CONFIG.port)
    if not ok then
        table.dumpdebug(err,"===========>> connect mongol err : ")
        conn:close()
        return nil
    end
    return conn:new_db_handle(GAMENAME) , conn
end

-- 半闭mongo
function wrapper.close_mongl(conn)
    if not conn then
        conn:close()
    end
end

return wrapper
