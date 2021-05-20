--通信中心节点
-- 一个工作进程一个中心节点
local _M            = { _VERSION = '0.01'  }
local d             = require "dispatcher"
local workerId      = ngx.worker.id()
local resty_lock    = require "resty.lock"
local dclient       = d.new('client')
local droom
local drobo

if ROOM_DISPATCH then
    droom         = d.new('room')
end

if ROBO_DISPATCH then
    drobo         = d.new('robo')
end

local dcenter       = d.new('center')
local centerhandler = require "centerhandler"
local sessionId   = nil
local sema        = nil
local closeFlag   = false
local push_thread = nil

local mask = 2^32
local server_mask = 2^36

local function push_thread_function()
    sessionId = dcenter:getSessionId()
    ngx.log(ngx.INFO,"center sessionId",ngx.worker.id(),"->",sessionId)
    sema = dcenter:getSemaphore(sessionId)
    while closeFlag == false do
        local ok,err = sema:wait(3)
        if ok then
            local messages = dcenter:getMessage(sessionId) or {}
            if #messages > 0 then
                for i,message in ipairs(messages) do
                    local f = centerhandler['CMD']
                    if f then
                        f(message)
                    end
                end
            end
        else
            --ngx.log(ngx.DEBUG,'timeout')
        end

        if ( closeFlag ) then
            d:destory(sessionId);
            break
        end
    end
end

function _M.getCenterId(workerId)
    local sessionId = SERVER_ID*server_mask+workerId * mask
    return sessionId
end

function _M.getWorkerId(sessionId)
    return dcenter.getWorkerId(sessionId)
end

function _M.dispatchCenterMessage()
    dcenter:dispatchMessage()
end

function _M.dispatchClientMessage()
    dclient:dispatchMessage()
end

function _M.dispatchRoomMessage()
    droom:dispatchMessage()
end

function _M.dispatchRoboMessage()
    drobo:dispatchMessage()
end

--消息分发
function _M.dispatchMessage()
    --分发消息
    -- dclient:dispatchMessage()
    -- droom:dispatchMessage()
    -- dcenter:dispatchMessage()

    if not push_thread then
        push_thread = ngx.thread.spawn(push_thread_function)
        local function tick()
            centerhandler.tick()

            ngx.timer.at(60,function (premature)
                tick()
            end)
        end
        tick()
    end
end

function _M.send2room(roomId,message)
    droom:dispatch(roomId,message)
end

function _M.send2robo(roboId,message)
    drobo:dispatch(roboId,message)
end

function _M.test()
    return 1
end

function _M.send2client(sessionId,message)
    dclient:dispatch(sessionId,message)
end

function _M.send2center(message,wId)
    local centerId = _M.getCenterId(wId or workerId)
    ngx.log(ngx.INFO,'中心准备收到信息：',centerId)
    dcenter:dispatch(centerId,message)
end

--获得客户端分发器
function _M.getClientDispatcher()
    return dclient
end

--获得房间分发器
function _M.getRoomDispatcher()
    return droom
end

function _M.getRoboDispatcher()
    return drobo
end

--获得中心分发器
function _M.getCenterDispatcher()
    return dcenter
end


return _M
