#!/bin/sh
nginx -p `pwd` -s stop
rm `pwd`/logs/*.log
nginx -p `pwd` -c conf/nginx.conf

