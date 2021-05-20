local mysql = require "resty.mysql"
local utilsdate  = require "utilsdate"
local template  = require "template"
local genid  = require "genid"
require "functions"


local sqlquery={}

sqlquery.exchange_usdt2tbk=100
sqlquery.exchange_tbk2usdt=101
sqlquery.market_hangsell=102
sqlquery.market_hangsellno=103
sqlquery.market_hangsellyes=104
sqlquery.exchange_tibi=105
sqlquery.admin_shangfen=106       -- 后台管理员上分(充TBK)
sqlquery.admin_shangusdt=107      -- 后台管理员上USDT(充usdt)
sqlquery.admin_tixian_jujue=108   -- 玩家提现拒绝(反还给玩家usdt)
sqlquery.admin_chongzi_fanxian=109  -- 玩家充值返现(返给推荐人玩家USDT)
sqlquery.admin_zhongcai_fanwanjia=110     -- 挂单仲裁还给卖家


local function gennonce()
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local noncestr = ""
    for i=1,15 do
        local num = math.random(1,#chars)
        noncestr = noncestr..string.sub(chars,num,num)
    end

    return noncestr
end


-- 查询指定玩家有没有充钱
function sqlquery.querychongzhicount(uid)
  local db, err = mysql:new()
  local ok, err, errcode, sqlstate = db:connect{
                    host = MYSQL_CONFIG.ip,
                    port = MYSQL_CONFIG.port,
                    database = MYSQL_CONFIG.db,
                    user = MYSQL_CONFIG.user,
                    password = MYSQL_CONFIG.password,
                    charset = "utf8",
                    max_packet_size = 1024 * 1024,
                }

  local tmp = {}
  tmp.uid = uid
  local sql= [[SELECT COUNT(*) as `chongzhi` FROM `tbklog` WHERE uid={{uid}} and tp=100]]
  local sqlstr = template.render(sql,tmp)
  -- ngx.log(ngx.INFO,"[[[[",sqlstr,"]]______________querychongzhicount")
  local rows, err, errno, sqlstate = db:query(sqlstr)

  if err and errno then
    ngx.log(ngx.INFO,"queryyouxiaocntlog: select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)
    return -1
    -- return nil
  end
  local cnt = 0
  if rows then
        table.dumpdebug(rows,"______rows_____:")
        for i, row in ipairs(rows) do 
            if row['chongzhi'] then
                cnt = row['chongzhi']
            end
            table.dumpdebug(row,"______youxiaorenshu::::_____:")
            table.dumpdebug(cnt,"______youxiaorenshu::::_____:")
        end
    end
  return cnt
end

-- 有效人数
function sqlquery.queryyouxiaocntlog()
  local db, err = mysql:new()
  local ok, err, errcode, sqlstate = db:connect{
                    host = MYSQL_CONFIG.ip,
                    port = MYSQL_CONFIG.port,
                    database = MYSQL_CONFIG.db,
                    user = MYSQL_CONFIG.user,
                    password = MYSQL_CONFIG.password,
                    charset = "utf8",
                    max_packet_size = 1024 * 1024,
                }

  local tmp = {}
  tmp.tp = 101
  local sql= [[SELECT COUNT( DISTINCT `uid`) as `youxiao` FROM `usdtlog` WHERE tp=100]]
  -- local sqlstr = template.render(sql,tmp)
  -- ngx.log(ngx.INFO,"[[[[",sqlstr,"]]______________youxiaocnt sql")
  local res, err, errno, sqlstate = db:query(sql)

  if err and errno then
    ngx.log(ngx.INFO,"queryyouxiaocntlog: select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
    return nil
  end
  return res
end

-- 全网数据
function sqlquery.queryquanwangSUMlog()
  local db, err = mysql:new()
  local ok, err, errcode, sqlstate = db:connect{
                    host = MYSQL_CONFIG.ip,
                    port = MYSQL_CONFIG.port,
                    database = MYSQL_CONFIG.db,
                    user = MYSQL_CONFIG.user,
                    password = MYSQL_CONFIG.password,
                    charset = "utf8",
                    max_packet_size = 1024 * 1024,
                }

  -- local sql = [[SELECT * FROM `usdtlog` WHERE uid={{uid}}]]
  local sqlstr= [[SELECT SUM(`tbk`) as `tbk`, SUM(`usdt`) as `usdt` FROM `dailystatic` WHERE 1]]
  -- local sqlstr = template.render(sql,tmp)
  local res, err, errno, sqlstate = db:query(sqlstr)

  if err and errno then
    ngx.log(ngx.INFO,"queryquanwangSUMlog: select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
    return nil
  end
  return res
end

function sqlquery.queryquanwanglog()
  local db, err = mysql:new()
  local ok, err, errcode, sqlstate = db:connect{
                    host = MYSQL_CONFIG.ip,
                    port = MYSQL_CONFIG.port,
                    database = MYSQL_CONFIG.db,
                    user = MYSQL_CONFIG.user,
                    password = MYSQL_CONFIG.password,
                    charset = "utf8",
                    max_packet_size = 1024 * 1024,
                }


  -- local sql = [[SELECT * FROM `usdtlog` WHERE uid={{uid}}]]
  local sqlstr= [[SELECT * FROM `dailystatic` WHERE 1]]
  -- local sqlstr = template.render(sql,tmp)
  local res, err, errno, sqlstate = db:query(sqlstr)

  if err and errno then
    ngx.log(ngx.INFO,"queryquanwanglog: select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
    return nil
  end
  return res
end


-- 查询usdt记录
function sqlquery.queryusdtlog(uid)
  local db, err = mysql:new()
  local ok, err, errcode, sqlstate = db:connect{
                    host = MYSQL_CONFIG.ip,
                    port = MYSQL_CONFIG.port,
                    database = MYSQL_CONFIG.db,
                    user = MYSQL_CONFIG.user,
                    password = MYSQL_CONFIG.password,
                    charset = "utf8",
                    max_packet_size = 1024 * 1024,
                }


  local tmp = {}
  tmp.uid = uid

  local sql = [[SELECT * FROM `usdtlog` WHERE uid={{uid}}]]
  local sqlstr = template.render(sql,tmp)
  local res, err, errno, sqlstate = db:query(sqlstr)

  if err and errno then
    ngx.log(ngx.INFO,"queryusdtlog: select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
    return nil
  end
  return res
end

-- 查询tbk记录
function sqlquery.querytbklog(uid)
  local db, err = mysql:new()
  local ok, err, errcode, sqlstate = db:connect{
                    host = MYSQL_CONFIG.ip,
                    port = MYSQL_CONFIG.port,
                    database = MYSQL_CONFIG.db,
                    user = MYSQL_CONFIG.user,
                    password = MYSQL_CONFIG.password,
                    charset = "utf8",
                    max_packet_size = 1024 * 1024,
                }


  local tmp = {}
  tmp.uid = uid

  local sql = [[SELECT * FROM `tbklog` WHERE uid={{uid}}]]
  local sqlstr = template.render(sql,tmp)
  local res, err, errno, sqlstate = db:query(sqlstr)

  if err and errno then
    ngx.log(ngx.INFO,"queryTBKlog: select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
    return nil
  end
  return res
end


-- 查询算力产生的TBK
function sqlquery.querytbklog_bytp(uid,tp)
  local db, err = mysql:new()
  local ok, err, errcode, sqlstate = db:connect{
                    host = MYSQL_CONFIG.ip,
                    port = MYSQL_CONFIG.port,
                    database = MYSQL_CONFIG.db,
                    user = MYSQL_CONFIG.user,
                    password = MYSQL_CONFIG.password,
                    charset = "utf8",
                    max_packet_size = 1024 * 1024,
                }


  local tmp = {}
  tmp.tp = tp
  tmp.uid = uid

-- SELECT * FROM `tbklog` WHERE uid=938409 && tp = 111
  local sql = [[SELECT * FROM `tbklog` WHERE uid={{uid}}&&tp={{tp}}]]
  local sqlstr = template.render(sql,tmp)
  local res, err, errno, sqlstate = db:query(sqlstr)

  if err and errno then
    ngx.log(ngx.INFO,"queryTBKlog: select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
    return nil
  end
  return res
end

-- 查询游戏反利
function sqlquery.queryGameFanLilog(uid)
  local db, err = mysql:new()
  local ok, err, errcode, sqlstate = db:connect{
                    host = MYSQL_CONFIG.ip,
                    port = MYSQL_CONFIG.port,
                    database = MYSQL_CONFIG.db,
                    user = MYSQL_CONFIG.user,
                    password = MYSQL_CONFIG.password,
                    charset = "utf8",
                    max_packet_size = 1024 * 1024,
                }


  local tmp = {}
  tmp.uid = uid

-- SELECT * FROM `tbklog` WHERE uid=938409 && tp = 111
  local sql = [[SELECT * FROM `gamefanlilog` WHERE uid={{uid}}]]
  local sqlstr = template.render(sql,tmp)
  local res, err, errno, sqlstate = db:query(sqlstr)

  if err and errno then
    ngx.log(ngx.INFO,"queryGameFanLilog: select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
    return nil
  end
  return res
end


-- 根据uid查询挂单记录
function sqlquery.queryOrderlog(uid)
  local db, err = mysql:new()
  local ok, err, errcode, sqlstate = db:connect{
                    host = MYSQL_CONFIG.ip,
                    port = MYSQL_CONFIG.port,
                    database = MYSQL_CONFIG.db,
                    user = MYSQL_CONFIG.user,
                    password = MYSQL_CONFIG.password,
                    charset = "utf8",
                    max_packet_size = 1024 * 1024,
                }


  local tmp = {}
  tmp.uid = uid

-- SELECT * FROM `tbklog` WHERE uid=938409 && tp = 111
  local sql = [[SELECT * FROM `gamefanlilog` WHERE uid={{uid}}]]
  local sqlstr = template.render(sql,tmp)
  local res, err, errno, sqlstate = db:query(sqlstr)

  if err and errno then
    ngx.log(ngx.INFO,"queryGameFanLilog: select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
    return nil
  end
  return res
end

return sqlquery