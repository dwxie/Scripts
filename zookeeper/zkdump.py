# coding: utf-8
#eg: python3 zkdump.py 192.168.100.20 2181 CYQZ

from kazoo.client import KazooClient
import logging
import sys

logging.basicConfig()
hosts = sys.argv[1]
port = sys.argv[2]
node = sys.argv[3]

connect = '{0}:{1}'.format(hosts,port)
zk = KazooClient(connect)
zk.start()

url = []
def get_url(path):
    if zk.get_children(path).__len__() == 0:
        url.append(path)
    else:
        for u in zk.get_children(path):
            get_url(path + "/" + u)
    return url


text = ""
for n in get_url("/{0}".format(node)):
    data, stat = zk.get(n)
    text = text + n + "=" + data.decode("utf-8") + "\n"
    
fileName = "zkdump_{0}{1}.log".format(hosts,node)
with open(fileName.replace('/','-'), "w", encoding="utf-8" ) as fd:
    fd.write(text)
zk.stop()