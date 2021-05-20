math.randomseed(os.time())
--房间已经满了
local mongo = require "resty.mongol"
local redis = require "redis"
local keysutils = require "keysutils"
local utils = require "utils"
local genid = require "genid"
local utilsdate = require "utilsdate"
local sqlquery = require 'sqlquery'
-- local loginput = require 'loginput'

local testdata = {}

function testdata.code()
    local begin = utilsdate.daybegin()
    local month = utilsdate.month()
    local restyoneday = utilsdate.restyoneday()
    local month = utilsdate.month(os.time())

    local cc_lstm = utilsdate.lastmonth()

    local t = utilsdate.lastmonthbegin()
    table.dumpdebug(cc_lstm,"+++++begin====")

    table.dumpdebug(t,"+++++begin3333====")

    table.dumpdebug(month,"+++++month====")
    table.dumpdebug(restyoneday,"+++++yestoneday====")

end


function testdata.init()
    if ngx.worker.id()==0 then

        table.dumpdebug("___________mysql_insert test:")
        -- loginput.loggamefanli(938409,735177,112,'ddz',5,5,100)


        -- local rows,err,errno,sqlstate = sqlquery.queryexecbyuid(1245)
        -- local rows,err,errno,sqlstate = sqlquery.queryusdtlog(938409)

        -- table.dumpdebug(err,"___________db1:")
        -- table.dumpdebug(errno,"___________db2:")
        -- table.dumpdebug(sqlstate,"___________db3:")
        -- if rows and not err then
        --     table.dumpdebug(rows,"___________db query:::")
        --     for i, row in ipairs(rows) do  
        --         table.dumpdebug("select row ", i, " :  = ", row )  
        --        -- for name, value in pairs(row) do  
        --        --   ngx.log(ngx.INFO,"select row ", i, " : ", name, " = ", value, "___mysqlres:")  
        --        -- end  
        --     end 
        -- end


        -- res, err, errno, sqlstate = db:query(insert_sql)  
  
        -- ngx.say("insert rows : ", res.affected_rows, " , id : ", res.insert_id, "<br/>")  
          
         
        -- local update_sql = "update test set ch = 'hello2' where id =" .. res.insert_id  
        -- res, err, errno, sqlstate = db:query(update_sql)  
        -- if not res then  
        --    ngx.say("update error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
        --    return close_db(db)  
        -- end  
          
        -- ngx.say("update rows : ", res.affected_rows, "<br/>")  
          
        -- local select_sql = "select id, ch from test"  
        -- res, err, errno, sqlstate = db:query(select_sql)  
        -- if not res then  
        --    ngx.say("select error : ", err, " , errno : ", errno, " , sqlstate : ", sqlstate)  
        --    return close_db(db)  
        -- end  
          
          
        -- for i, row in ipairs(res) do  
        --    for name, value in pairs(row) do  
        --      ngx.say("select row ", i, " : ", name, " = ", value, "<br/>")  
        --    end  
        -- end  
          
        -- ngx.say("<br/>")


        -- local conn = mongo:new()
        -- conn:set_timeout(10000)
        -- local ok, err = conn:connect(MONGO_USER_CONFIG.host,MONGO_USER_CONFIG.port)
        -- local db=conn:new_db_handle(GAMENAME)
        -- local col1 = db:get_col("shopitems")
        -- 商城的配置
        -- col1:drop()
     

        --攻略的设置
        -- local col2 = db:get_col('notice')
        -- col2:drop()
        -- col2:insert({{_id=genid.gen(),title='测试公告标题',content='测试公告1',index=1,datetime=os.time(),}})
        -- col2:insert({{_id=genid.gen(),title='测试公告标题',content='测试公告2',index=2,datetime=os.time(),}})
        -- col2:insert({{_id=genid.gen(),title='测试公告标题',content='测试公告3',index=3,datetime=os.time(),}})
        -- col2:insert({{_id=genid.gen(),title='测试公告标题',content='测试公告4',index=4,datetime=os.time(),}})
        -- col2:insert({{_id=genid.gen(),title='测试公告标题',content='测试公告5',index=5,datetime=os.time(),}})
        -- col2:insert({{_id=genid.gen(),title='测试公告标题',content='测试公告6',index=6,datetime=os.time(),}})


        --砸蛋的设置
        -- local col3 = db:get_col('zadan')
        -- col3:drop()
        -- col3:insert({{_id=genid.gen(),title='香蕉',gailv=1,index=1,datetime=os.time(),}})
        -- col3:insert({{_id=genid.gen(),title='茄子',gailv=20,index=2,datetime=os.time(),}})
        -- col3:insert({{_id=genid.gen(),title='黄瓜',gailv=40,index=3,datetime=os.time(),}})
        -- col3:insert({{_id=genid.gen(),title='白萝卜',gailv=60,index=4,datetime=os.time(),}})
        -- col3:insert({{_id=genid.gen(),title='水萝卜',gailv=80,index=5,datetime=os.time(),}})
        -- col3:insert({{_id=genid.gen(),title='胡萝卜',gailv=90,index=6,datetime=os.time(),}})

        --攻略的设置
        -- local col4 = db:get_col('gonglue')
        -- col4:drop()
        -- col4:insert({{_id=genid.gen(),title='测试攻略标题',content='测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1测试攻略1',index=1,datetime=os.time(),}})
        -- col4:insert({{_id=genid.gen(),title='测试攻略标题',content='测试攻略2',index=2,datetime=os.time(),url='http://img.duoziwang.com/2016/10/05/1958261611.jpg'}})
        -- col4:insert({{_id=genid.gen(),title='测试攻略标题',content='测试攻略3',index=3,datetime=os.time(),}})
        -- col4:insert({{_id=genid.gen(),title='测试攻略标题',content='测试攻略4',index=4,datetime=os.time(),url='http://img.duoziwang.com/2016/10/05/1958261611.jpg'}})
        -- col4:insert({{_id=genid.gen(),title='测试攻略标题',content='测试攻略5',index=5,datetime=os.time(),}})
        -- col4:insert({{_id=genid.gen(),title='测试攻略标题',content='测试攻略6',index=6,datetime=os.time(),url='http://img.duoziwang.com/2016/10/05/1958261611.jpg'}})


    end
end

function testdata.redisinit()
        local redis = require "redis"
        local keysutils = require "keysutils"

        -- local uid = '697390'
        -- local rediscli = redis:new({host=REDIS_USER_CONFIG.ip, port=REDIS_USER_CONFIG.port})
        -- userkey = keysutils.get_model_key('user',uid)

        -- local ok = rediscli:exists(userkey)
        -- if ok==0 then
        --     -- local uid1 = rediscli:incr(keysutils.get_user_counter())
        --     -- rediscli:setnx(userkey,uid)
        --     rediscli:hsetnx(userkey, 'uid',uid1)
        -- end
        -- rediscli:hsetnx(keysutils.get_user_main_key(uid), 'sex',1 )
        -- rediscli:hsetnx(keysutils.get_user_main_key(uid), 'avatar', "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1505368005255&di=0b13ecfdb6bb2970d0d4edda203f7cf3&imgtype=0&src=http%3A%2F%2Fis3.mzstatic.com%2Fimage%2Fthumb%2FPurple69%2Fv4%2F12%2Fb5%2F55%2F12b55509-beb8-539b-ae0a-144f4432f82b%2Fsource%2F512x512bb.jpg")

end

function testdata.mysqlinit()
    -- local loginput = require "loginput"
    -- loginput.lunpanlog(uid,tbkcnt,index,typ, count, jiangname)
    -- table.dumpdebug("________________________mysqlinit ::")
    -- loginput.lunpanlog(123456,26,6,2,188,'item.name')

    
    -- local uid =  938409
    -- local sqlquery = require 'sqlquery'
    -- local cnt = sqlquery.querychongzhicount(uid)
    -- if cnt then
    --     table.dumpdebug(cnt,"______player chongzhi count :::::")
    -- end
    
    -- local mysql = require 'mysql'
    -- local db = mysql.new()
    -- table.dumpdebug(db,"___________db::")

    -- local res, err, errcode, sqlstate =
    -- db:query("drop table if exists cats")
    -- if not res then
    --     ngx.log(ngx.INFO,"bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
    --     return
    -- end

    -- res, err, errcode, sqlstate =
    --     db:query("create table cats "
    --              .. "(id serial primary key, "
    --              .. "name varchar(5))")
    -- if not res then
    --     ngx.log(ngx.INFO,"bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
    --     return
    -- end

    -- ngx.log(ngx.INFO,"table cats created.")

    -- res, err, errcode, sqlstate =
    --     db:query("insert into cats (name) "
    --              .. "values (\'Bob\'),(\'\'),(null)")
    -- if not res then
    --     ngx.log(ngx.INFO,"bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
    --     return
    -- end

    -- ngx.log(ngx.INFO,res.affected_rows, " rows inserted into table cats ",
    --         "(last insert id: ", res.insert_id, ")")

    -- -- run a select query, expected about 10 rows in
    -- -- the result set:
    -- res, err, errcode, sqlstate =
    --     db:query("select * from cats order by id asc", 10)
    -- if not res then
    --     ngx.log(ngx.INFO,"bad result: ", err, ": ", errcode, ": ", sqlstate, ".")
    --     return
    -- end

    -- local cjson = require "cjson"
    -- ngx.say("result: ", cjson.encode(res))

    -- -- put it into the connection pool of size 100,
    -- -- with 10 seconds max idle timeout
    -- local ok, err = db:set_keepalive(10000, 100)
    -- if not ok then
    --     ngx.log(ngx.INFO,"failed to set keepalive: ", err)
    --     return
    -- end
end

return testdata
