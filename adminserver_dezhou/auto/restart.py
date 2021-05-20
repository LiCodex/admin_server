# -*- coding: utf-8 -*-
import paramiko
import config
import os
import datetime

try:
    print '准备开始连接服务器:' + config.ip
    print 'IP:' + config.ip
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(config.ip,config.port,config.username,config.password)

    server = raw_input("请输入要重启的服务器目录:")
    s="""
        source ~/.bash_profile
        cd /home/proj/%s
        nginx -p `pwd` -s stop
        [ -f conf/depnginx.conf ] && nginx -p `pwd` -c conf/depnginx.conf || nginx -p `pwd` -c conf/nginx.conf
    """%(server)
    
    ok = raw_input("请输入要重启的服务器:确定在服务器%s上执行如下脚本%s"%(config.ip,s))
    if ok=='ok':
        stdin,stdout,stderr = ssh.exec_command(s)
        print stdout.readlines()
        pass
    else:
        pass
    ssh.close()
except Exception as e:
    print e
    raise
else:
    pass
finally:
    pass

print '完成'


