#!/bin/bash
#	TO BACKUP MYSQL DATABASES	#

#	mysql_backup.conf 是数据库的配置文件，包含用户和密码，脚本放在同一路径	#
#	 配置示例 	#
#	用户,密码,数据库名	#

#####

#	mysql_mail.properties 是发送邮件的配置文件，和脚本放在同一路径	#
#	配置如下	#
#	sender="sysmail@topvdn.com"	#	发件邮箱
#	smtpaddr="smtp.topvdn.com"	#	发件服务器
#	mailuser="sysmail@topvdn.com"	#	邮箱用户
#	mailpasswd="Megaium!"		#	邮箱密码
#	title="${1:-"mysql备份"} on `date "+%Y-%m-%d %H:%M:%S"`"	#	邮件标题
#	toaddress="heyunyu@lingdanet.com"	#	收件人邮箱，多个收件人以空格为分隔符

#####

#	一些基本配置	#
DATEDAY=`date "+%Y-%m-%d"`
DATENOW=`date "+%Y-%m-%d_%H%M%S"`
USERLIST="mysql_backup.conf"	
PATH_FOR_BACKUP_FILE="/data/mysql_backup"
LOG_PATH="/var/log/mysql.backup"
MYNAME=`basename $0`
BACKUP_FILE="$MYNAME"_"$DATENOW.sql"
LOG_FILE="$MYNAME"_"$DATEDAY.log"
#####

#	创建目录	#
if [  ! -d "$PATH_FOR_BACKUP_FILE" ] ; then
mkdir $PATH_FOR_BACKUP_FILE
fi
if [  ! -d "$LOG_PATH" ] ; then
mkdir $LOG_PATH
fi
#####

cd `dirname $0`

while read line
do
  BACK_UP_USER=`echo $line|awk -F ',' '{print $1}'`
  BACK_UP_PASSWORD=`echo $line|awk -F ',' '{print $2}'`
  BACK_UP_DATABASE=`echo $line|awk -F ',' '{print $3}'`

  if [ -z $BACK_UP_DATABASE ] ; then
    backup_opts="--all-databases"
    filename=all
  else
    backup_opts="$BACK_UP_DATABASE"
    filename=$BACK_UP_DATABASE
  fi
  if [ -z "$BACK_UP_PASSWORD" ] ; then
    /opt/zbox/run/mysql/mysqldump -u$BACK_UP_USER $backup_opts  > $PATH_FOR_BACKUP_FILE/$BACK_UP_USER"_"$filename"_"$BACKUP_FILE
  else
    /opt/zbox/run/mysql/mysqldump -u$BACK_UP_USER -p$BACK_UP_PASSWORD $backup_opts  > $PATH_FOR_BACKUP_FILE/$BACK_UP_USER"_"$filename"_"$BACKUP_FILE
  fi
  gzip $PATH_FOR_BACKUP_FILE/$BACK_UP_USER"_"$filename"_"$BACKUP_FILE 
  
done < mysql_backup.conf &>> $LOG_PATH/$LOG_FILE.err
echo "备份时间：`date "+%Y-%m-%d %H:%M:%S"`
备份主机：`hostname`  :  `hostname -i`
数据库名 : $BACK_UP_DATABASE
备份文件大小，路径 : 
`du -sh   $PATH_FOR_BACKUP_FILE/*$BACKUP_FILE.gz` " >> $LOG_PATH/$LOG_FILE
echo "备份日志：
`cat $LOG_PATH/$LOG_FILE.err` " >> $LOG_PATH/$LOG_FILE


#	发送邮件	#

#/usr/local/bin/sendEmail -f $sender -t $toaddress -s $smtpaddr -u "Mysql backup on $DATEDAY" -xu $mailuser -xp $mailpasswd -m "`cat $LOG_PATH/$LOG_FILE`" &>>$LOG_PATH/$LOG_FILE

source mysql_mail.properties
text=`cat  $LOG_PATH/$LOG_FILE`		#邮件内容
/usr/local/bin/sendEmail -f $sender -t $toaddress -s $smtpaddr -u "$title" -xu $mailuser -xp $mailpasswd -m "$text" &>> $LOG_PATH/$LOG_FILE
#####
