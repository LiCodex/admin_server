--全局id生成器
local cjson = require "cjson"
local logqueueutil = require "logqueueutil"
local phpsql={}


function phpsql.phpupdate(tp,num,phone)
    local msg = {}
    msg.col = tp
    msg.val = num
    msg.phone = phone
    logqueueutil.send("hall",'updateplayer',msg)
end

function phpsql.phpupdateint(tp,num,phone)
    local msg = {}
    msg.col = tp
    msg.val = num
    msg.phone = phone
    logqueueutil.send("hall",'updateplayerint',msg)
end


function phpsql.phpinsert(c,m,msg)
    local data = {c=c,m=m,msg=msg}
    ngx.log(ngx.DEBUG,'------php insert count---->',cjson.encode(data))
    logqueueutil.send(c,m,msg)
end

return phpsql
