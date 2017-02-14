#!/bin/sh
#Author:zhangkai
#Date:2016.9.19
#To same the conf between master and slave

#源目录
src1="/usr/local/nginx/conf"
#目的目录
dst1="/usr/local/nginx/conf"
ipdst1=172.30.30.39
Date_now=$(date +%F)

sudo chown -R nginxadmin.nginxadmin /usr/local/nginx/conf
sudo chown nginxadmin.nginxadmin /usr/local/nginx/sbin/inotify.sh
chmod 700 /usr/local/nginx/sbin/inotify.sh
[ -f /var/log/inotify.log ] || sudo touch /var/log/inotify.log
sudo chown nginxadmin.nginxadmin /var/log/inotify.log
chmod 700 /var/log/inotify.log
chmod 755 -R $src1

/usr/local/bin/inotifywait -mrq -e create,delete,modify,move,attrib $src1  | while read line;do
  /usr/sbin/unison -servercmd=/usr/sbin/unison -times -owner=true -group=true -fastcheck=true -perms=-1 -silent -batch $src1 ssh://$ipdst1/$dst1
  sudo /usr/local/nginx/sbin/nginx -s reload
#  touch /var/log/inotify.log
  echo -n "$line ">> /var/log/inotify.log
  echo -n "$line ">> /var/log/inotify.log
  echo -n "nginx reload">> /var/log/inotify.log
  echo -n "$line ">> /var/log/inotify.log
  echo "`date | cut -d "" -f1-5`" >> /var/log/inotify.log
  done
