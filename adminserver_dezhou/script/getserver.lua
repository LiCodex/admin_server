local cjson = require "cjson"
local string = require "string"


local arg=ngx.req.get_uri_args()

if not arg.r then
    ngx.say(cjson.encode({err=1,msg="param error",arg=arg}))
    return
end


local result={}

result.host = HOST
--result.host = '127.0.0.1:19000/lua/web_socket'
result.port = PORT
result.gameservers=GAMESERVERS

ngx.say(cjson.encode({err=0,data=result,vc=_VERSION}))

