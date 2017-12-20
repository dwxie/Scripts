# coding: utf-8
# eg: python3 zk.py 192.168.100.20 2181 CYQZ/redis-config

from kazoo.client import KazooClient
import sys

hosts = sys.argv[1]
port = sys.argv[2]
node = sys.argv[3]
connect = '{0}:{1}'.format(hosts,port)

zk = KazooClient(connect)
zk.start()

node = node.replace('/','-')

fileName = "zkdump_{0}{1}.log".format(hosts,node)

with open(fileName, "r", encoding="utf-8" ) as f:
    for line in f.readlines():
        iterm = line.strip('\n').split('=')
        zk.ensure_path(iterm[0])
        zk.set(iterm[0], bytes(iterm[1], encoding='utf-8'))
zk.stop()