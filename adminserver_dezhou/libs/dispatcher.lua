-- 消息分发模块
-- jack
-- 2017-06-20
--
local semaphore = require "ngx.semaphore"
local _M = { _VERSION = '0.01' }
local mt = {__index = _M}
local workerId = ngx.worker.id()
local cjson = require "cjson"
local mask = 2^32
local server_mask = 2^36
local redis = require "redis"
local util = require "utils"
local mp = require 'MessagePack'

local rediscli= redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})

require "functions"

local function getWorkerId(sessionId)
    return math.floor(tonumber(sessionId%server_mask)/mask)
end

local function getServerId(sessionId)
    return math.floor(tonumber(sessionId)/server_mask)
end

_M.getWorkerId = getWorkerId;

function _M.dispatchToAll(self,message)
    for sessionId,v in pairs(self.messageList) do
        table.insert(v,message)
        self:wakeUp(sessionId)
    end
end

function _M.dispatchToSession(self,sessionId,message)
    if ( self.messageList[sessionId] ~= nil ) then
        table.insert(self.messageList[sessionId],message)
        self:wakeUp(sessionId)
    end
end

function _M.getSessionId(self)
    local sessionId = SERVER_ID*server_mask+workerId * mask + self.incrId
    self.incrId = self.incrId + 1
    self.incrId=self.incrId%mask
    self.messageList[sessionId] = {}
    

    local sId = getServerId(sessionId)
    local wId = getWorkerId(sessionId)

    return sessionId
end

function _M.getSemaphore(self,sessionId)
    if ( self.semaMap[sessionId] == nil ) then
        self.semaMap[sessionId] = semaphore.new(0);
    end
    return self.semaMap[sessionId];
end


function _M.wakeUp(self,sessionId)
    if ( self.semaMap[sessionId] ~= nil ) then
        self.semaMap[sessionId]:post(1)
    end
end


function _M.dispatch(self,sessionId,message)
    local sId = getServerId(sessionId)
    local wId = getWorkerId(sessionId)

    
    local tmp = clone(message)
    if wId == workerId and sId==SERVER_ID then ---当前worker
        self:dispatchToSession(sessionId,tmp)
    else
        local k = string.format("%d-%s-%d",SERVER_ID,self.t,wId)
        rediscli:lpush(k,mp.pack({sessionId=sessionId,message=tmp}))
    end
end


---
-- 销毁会话
-- @param self
-- @param sessionId
--
function _M.destory(self,sessionId)
    self.messageList[sessionId] = nil
    self.semaMap[sessionId] = nil;
end

---
-- 根据会话ID获取消息
-- @param self
-- @param sessionId
--
function _M.getMessage(self,sessionId)
    if ( self.messageList[sessionId] ~= nil ) then
        local messages = {}
        table.foreach(self.messageList[sessionId],
            function(i, v)
                table.insert(messages,v);
                self.messageList[sessionId][i] = nil;
            end
        );
        return messages;
    end
end



local function getSessionIdFromKey(key)
    local i,j = string.find(key,':');
    if not i then
        return 0;
    end
    return tonumber(string.sub(key,1,i-1));
end

---
--- 分发消息
-- @param self
--
function _M.dispatchMessage(self)
    local k = string.format("%d-%s-%d",SERVER_ID,self.t,workerId)
    while true do
        local result = rediscli:brpop(k,10)
        if result then
            result = util.redis_pack(result)
            local r = result[k]
            if r then
                local v=mp.unpack(r)
                self:dispatchToSession(v.sessionId,v.message)
            end
        end
        
    end
end

function _M.new(t)
    local t = {
        semaMap = {},
        messageList = {},
        incrId = 0,
        t=t,
        smd = ngx.shared.msgqueue,
    }

    return setmetatable(t,mt)
end



return _M
