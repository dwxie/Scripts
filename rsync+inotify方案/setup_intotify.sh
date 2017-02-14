#/bin/env /bin/bash
#在安装unison之前需要首先安装ocaml软件。
set -e
dir=`pwd`
osaml_install()
{
#cd /home/nginxadmin
cd $dir
[ ! -f ./ocaml-4.03.0.tar.gz ] && wget http://caml.inria.fr/pub/distrib/ocaml-4.03/ocaml-4.03.0.tar.gz
 [ ! -d ./ocaml-4.03.0 ] && tar -zxf ocaml-4.03.0.tar.gz
 cd  ocaml-4.03.0
 ./configure
 make world opt
 make install
 sleep 3
 make clean
 ln -s /usr/local/bin/* /usr/sbin/
}

unison_install()
{
#cd /home/nginxadmin
cd $dir
[ ! -f ./unison-2.48.4.tar.gz ] &&  wget http://fossies.org/linux/misc/unison-2.48.4.tar.gz
[ ! -d ./src ] &&  tar -zxvf unison-2.48.4.tar.gz
 cd  src
 make UISTYLE=text
[ -d /root/bin ] ||  mkdir /root/bin #否则提示找不到/root/bin文件，无法完成unison执行文件的拷贝。
 make install #第一次执行出现错误，再次执行一次就可以了。
 if (($?==0));then
   echo "install success"
 else 
   make install
 fi 
cp /root/bin/unison /usr/sbin/unison
} 

inotify_install()
{
# Inotify 安装
#cd /home/nginxadmin
cd $dir
 [ ! -f ./inotify-tools-3.13.tar.gz ] &&  wget http://tenet.dl.sourceforge.net/project/inotify-tools/inotify-tools/3.13/inotify-tools-3.13.tar.gz
 [ ! -d ./inotify-tools-3.13 ] && tar zxf inotify-tools-3.13.tar.gz 
 cd inotify-tools-3.13
  ./configure
  make
  make install
  ln -s /usr/local/bin/inotifywait /usr/sbin
}

  #osaml_install
  #unison_install
  inotify_install

