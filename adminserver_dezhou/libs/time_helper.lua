local cjson = require "cjson"
local mp = require 'MessagePack'

local MyProto = {}
function MyProto.encode(data)
    if not MP then
        return cjson.encode(data)
    else
        return mp.pack(data)
    end
end

function MyProto.decode(data)
    if not MP then
        return cjson.decode(data)
    else
        return mp.unpack(data)
    end
end

return MyProto