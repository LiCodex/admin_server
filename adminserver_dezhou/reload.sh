#!/bin/sh
openresty -p `pwd` -s stop
rm `pwd`/logs/*.log
openresty -p `pwd` -c conf/nginx.conf
