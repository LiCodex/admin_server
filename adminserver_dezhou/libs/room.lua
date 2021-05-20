-- 房间逻辑代码
-- jack
-- 2017-06-20
--

require "functions"

local cjson = require "cjson"
local _M = { }
_M._VERSION = '1.0'
local mt          = {__index = _M}
local workerId    = ngx.worker.id()
function _M.start(self)
    local function push_thread_function()
        local center = require "center"
        local droom = center.getRoomDispatcher()
        while self.loop do
            local ok,err = self.sema:wait(5)
            local messages = droom:getMessage(self.roomId) or {}
            for i,message in ipairs(messages) do
                ngx.log(ngx.DEBUG,cjson.encode(message))
                local f = self.handler['CMD']
                if f then
                    f(self.handler,message)
                end
            end
            if not self.loop then
                droom:destory(self.roomId);
            break
        end
        end
    end
    self.push_thread = ngx.thread.spawn(push_thread_function)
    --房间多长时间不开始销毁定时器
end

function _M.getRoomId(self)
    assert(self.roomId~=nil,'房间号不存在')
    return self.roomId
end

function _M.getKey(self)
    return self.key
end

function _M.getSema(self)
    return self.sema
end

function _M.new(roomId,key,owner,sema,config,h)
    local room = {}
    assert(roomId~=nil,'房间号不存在')
    room.loop = true
    room.sema    = sema
    room.key     = key
    room.roomId  = roomId
    room.owner   = owner
    room.handler = h
    room.config  = config
    h.room = room
    return setmetatable(room,mt)
end

return _M

