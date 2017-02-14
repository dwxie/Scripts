#!/bin/bash
###Author:kaiz
###Date:2016.9.18
Date_now=$(date +%F)
[ -d /usr/local/nginx/conf_bak ] || mkdir /usr/local/nginx/conf_bak
cp -r /usr/local/nginx/conf /usr/local/nginx/conf_bak/conf_$Date_now
ps -fe|grep inotify |grep -v grep
if [ $? -ne 0 ];then
su - nginxadmin -c "/usr/local/nginx/sbin/inotify.sh"
echo "`date +'%F %X'` start inotify process.....">> /var/log/inotify.log
else
echo "`date +'%F %X'` inotify is runing.....">> /var/log/inotify.log
fi
