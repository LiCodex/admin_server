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
        local drobo = center.getRoboDispatcher()
        while self.loop do
            -- ngx.log(ngx.DEBUG,"robo loop key=",self.key," roboid=",self.roboId)
            local ok,err = self.sema:wait(5)
            local messages = drobo:getMessage(self.roboId) or {}
            for i,message in ipairs(messages) do
                local f = self.handler['CMD']
                if f then
                    f(self.handler,message)
                end
            end
            if not self.loop then
                drobo:destory(self.roboId)
            break
        end

        end
        ngx.log(ngx.DEBUG,'机器人线程退出')
    end
    self.push_thread = ngx.thread.spawn(push_thread_function)
    --房间多长时间不开始销毁定时器
end

function _M.getRoboId(self)
    assert(self.roboId~=nil,'机器人编号不存在')
    return self.roboId
end

function _M.getUid(self)
    return self.uid
end

function _M.getJwt(self)
    return self.jwt
end

function _M.getSema(self)
    return self.sema
end

function _M.new(roboId,sema,h)
    assert(roboId~= nil,'房间号不存在')

    local robo   = {}
    robo.loop    = true
    robo.sema    = sema
    robo.roboId  = roboId
    robo.handler = h
    h.robo       = robo

    return setmetatable(robo,mt)
end

return _M

