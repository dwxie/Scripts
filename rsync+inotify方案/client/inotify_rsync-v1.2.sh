#!/bin/env /bash/sh
###AUTHOR:zhangkai
###DATE:2016.9.27
#VERSION: V1.2
#FUNCTION: Keep server and client same , just when create or modify files under ~/update ,except delete 

[ -f /usr/local/bin/inotify.log ] ||  touch /usr/local/bin/inotify.log
chown root.root /usr/local/bin/inotify.log
chmod 700 /usr/local/bin/inotify.log

src=/home/frontaladmin/update
des=data                             # 目标服务器上 rsync --daemon 发布的名称，rsync --daemon这里就不做介绍了，网上搜一下，比较简单。
rsync_passwd_file=/etc/rsync.passwd            # rsync验证的密码文件
ip1=172.30.33.5                 # 目标服务器1
ip2=172.30.33.6                 # 目标服务器1
user=kaiz                            # rsync --daemon定义的验证用户名
/usr/local/bin/inotifywait -mrq --format  '%Xe %w%f' -e modify,create,delete,attrib,close_write,move $src | while read file         #此处应为绝对路径，把监控到有发生更改的"文件路径列表"循环
do
        INO_EVENT=$(echo $file | awk '{print $1}')      # 把inotify输出切割 把事件类型部分赋值给INO_EVENT
        INO_FILE=$(echo $file | awk '{print $2}')       # 把inotify输出切割 把文件路径部分赋值给INO_FILE
        echo "-------------------------------$(date)------------------------------------"
        echo $file
        #增加、修改、写入完成、移动进事件
        #增、改放在同一个判断，因为他们都肯定是针对文件的操作，即使是新建目录，要同步的也只是一个空目录，不会影响速度。
        if [[ $INO_EVENT =~ 'CREATE' ]] || [[ $INO_EVENT =~ 'MODIFY' ]] || [[ $INO_EVENT =~ 'CLOSE_WRITE' ]] || [[ $INO_EVENT =~ 'MOVED_TO' ]]         # 判断事件类型
        then
                echo 'CREATE or MODIFY or CLOSE_WRITE or MOVED_TO'
                rsync -avzcr --password-file=${rsync_passwd_file} $(dirname ${INO_FILE})/ ${user}@${ip1}::${des} &&  rsync -avzcr --password-file=${rsync_passwd_file} $(dirname ${INO_FILE})/ ${user}@${ip2}::${des} 
                 #仔细看 上面的rsync同步命令 源是用了$(dirname ${INO_FILE})变量 即每次只针对性的同步发生改变的文件的目录(只同步目标文件的方法在生产环境的某些极端环境下会漏文件 现在可以在不漏文件下也有不错的速度 做到平衡) 然后用-r参数把源的目录结构递归到目标后面 保证目录结构一致性
        fi
done
