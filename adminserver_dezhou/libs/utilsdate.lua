--全局id生成器
local utilsdate={}

local function onedaybegin(t)
    t = t or os.time()
    local temp1 = os.date('*t',t)
    return os.time({year=temp1.year, month=temp1.month, day=temp1.day, hour=0,min=0,sec=0})
end

function monthbegin(t)
    t = t or os.time()
    local d = os.date("*t",t)
    return os.time({year=d.year,month=d.month,day=1, hour=0,min=0,sec=0})
end

function lastmonthbegin()
    t = os.time()
    local d = os.date("*t",t)
    return os.time({year=d.year,month=d.month-1,day=1, hour=0,min=0,sec=0})
end

function utilsdate.daybegin(t)
    local d = os.date("*t",t)
    local s = string.format("%04d%02d%02d",d.year,d.month,d.day)
    return s
end

function utilsdate.month(t)
    local d = os.date("*t",t)
    local s = string.format("%04d%02d",d.year,d.month)
    return s
end

function utilsdate.lastmonth()
    local t = lastmonthbegin()
    local d = os.date("*t",t)
    local s = string.format("%04d%02d",d.year,d.month)
    return s
end

utilsdate.lastmonthbegin=lastmonthbegin
utilsdate.monthbegin=monthbegin

utilsdate.onedaybegin=onedaybegin
function utilsdate.restyoneday(t)
    local a = onedaybegin(t)
    a=a+24*3600*2
    local expire = a-os.time()
    return expire
end

return utilsdate
