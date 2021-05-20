# -*- coding: utf-8 -*-
import paramiko
import config
import os
import datetime



#生成包名
a=datetime.datetime.now().strftime('%Y_%m_%d_%H_%M_%S')

try:
    print '准备开始连接服务器:' + config.ip
    print 'IP:' + config.ip
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(config.ip,config.port,config.username,config.password)
    s="""
        cd ..
        sh ./build.sh %s
    """%(a)
    os.system(s)
    print "打包完成"

    

    # 5.添加crontab
    tran = paramiko.Transport((config.ip,config.port))
    tran.connect(username=config.username,password=config.password)
    sftp=paramiko.SFTPClient.from_transport(tran)
    filename = a+".tar.gz"
    sftp.put("../out/"+filename,"/home/proj/"+filename)
    tran.close()

    print "解压缩文件"
    s="""
        cd /home/proj/
        tar -zxvf %s 
    """%(filename)
    stdin,stdout,stderr = ssh.exec_command(s)
    print stdout.readlines()

    ssh.close()
except Exception as e:
    raise
else:
    pass
finally:
    pass



