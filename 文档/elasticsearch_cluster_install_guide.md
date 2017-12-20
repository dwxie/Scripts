# Elasticsearch 5.x 集群安装

---

## 1. 环境

* elasticsearch-5.0.2
* Ubuntu 16.04.1 LTS
* java version "1.8.0_101"

## 2. 安装

### 安装Elasticsearch

本文主要讲解es cluster安装配置，os、java安装不在本文讨论范围。

首先从[这里](https://www.elastic.co/downloads/elasticsearch)下载安装包，然后在集群中所有机器上安装elasticsearch。

```
root@localhost:~# dpkg -i elasticsearch-5.0.2.deb
正在选中未选择的软件包 elasticsearch。
(正在读取数据库 ... 系统当前共安装有 355545 个文件和目录。)
正准备解包 elasticsearch-5.0.2.deb  ...
正在解包 elasticsearch (5.0.2) ...
正在设置 elasticsearch (5.0.2) ...
正在处理用于 systemd (229-4ubuntu10) 的触发器 ...
正在处理用于 ureadahead (0.100.0-19) 的触发器 ...
root@localhost:~# systemctl enable elasticsearch
Synchronizing state of elasticsearch.service with SysV init with /lib/systemd/systemd-sysv-install...
Executing /lib/systemd/systemd-sysv-install enable elasticsearch
Created symlink from /etc/systemd/system/multi-user.target.wants/elasticsearch.service to /usr/lib/systemd/system/elasticsearch.service.
```

### 配置es cluster

根据服务器实际情况修改下列配置项。

```
root@barrostest-OptiPlex-7040:~# grep -v \# /etc/elasticsearch/elasticsearch.yml |grep .
cluster.name: es-cluster
node.name: node-1
path.data: /srv/es/data
path.logs: /srv/es/logs
network.host: 192.168.100.15
discovery.zen.ping.unicast.hosts: ["192.168.100.12", "192.168.100.15"]
discovery.zen.minimum_master_nodes: 2
```

* 那么为了防止脑裂的出现，`discovery.zen.minimum_master_nodes`配置当前集群中最少的主节点数，对于多于两个节点的集群环境，计算公式如下：`(master_eligible_nodes / 2) + 1`。比如我这里有2个master node，那么最小的主节点数就是：2/2+1=2；
* 注意检查`path.data`和`path.logs`配置的文件夹权限，必须elasticsearch用户可写。

> 参考文档：https://www.elastic.co/guide/en/elasticsearch/reference/5.x/important-settings.html

## 3. 系统设置和基本优化

### JVM Heap Size

一般设置为50%-60%的系统物理内存大小。

```
root@localhost:~# grep Xm /etc/elasticsearch/jvm.options |grep -v \#
-Xms2g
-Xmx2g
```

### File Descriptors和Max Thread Number

操作具体配置方法这里不在赘述，可通过命令`su - elasticsearch -s /bin/bash -c 'ulimit -n'`查看。

按照下面修改elasticsearch配置文件`/etc/default/elasticsearch`：

```
root@localhost:~# grep -v \# /etc/default/elasticsearch |grep -i max
MAX_OPEN_FILES=65536
MAX_LOCKED_MEMORY=unlimited
```

### 禁用swap

```
root@localhost:~# swapoff -a     # 临时禁用
root@localhost:~# vim /etc/fstab # swap行取消注释，永久禁用
```

### 内核参数调整

```
root@localhost:~# grep max_map_count /etc/sysctl.conf
vm.max_map_count=262144
```

## 4. elasticsearch操作

### 启动服务

```
systemctl start elasticsearch
```

### 查看es状态

#### 检查集群状态

`curl -XGET 'http://server_ip:9200/_cluster/state?pretty'`

`curl -XGET 'http://server_ip:9200/_cluster/health?pretty'`

输出示例：
```
root@barrostest-OptiPlex-7040:/data/elasticsearch-5.0.1/data/nodes/0/indices# curl -XGET 'http://192.168.100.15:9200/_cluster/health?pretty'
{
  "cluster_name" : "es-cluster",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 2,
  "number_of_data_nodes" : 2,
  "active_primary_shards" : 1,
  "active_shards" : 2,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}
```
这里最重要的就是status这行。status有三个可能的值：

green 绿灯，所有分片都正确运行，集群非常健康。

yellow 黄灯，所有主分片都正确运行，但是有副本分片缺失。这种情况意味着 ES 当前还是正常运行的，但是有一定风险。注意，在 Kibana4 的 server 端启动逻辑中，即使是黄灯状态，Kibana 4 也会拒绝启动，死循环等待集群状态变成绿灯后才能继续运行。

red 红灯，有主分片缺失。这部分数据完全不可用。而考虑到 ES 在写入端是简单的取余算法，轮到这个分片上的数据也会持续写入报错。

#### 查看node信息

`curl -XGET http://server_ip:9200`

`curl -XGET 'http://server_ip:9200/_nodes/process?pretty'`

`curl -XGET 'http://server_ip:9200/_nodes/stats`

通过nodes/stats可以看到很多信息，包括：写入、读取、搜索性能，JVM等数据。

## 5. CYQZ项目

### 安装ik分词插件

1. 下载分词插件：elasticsearch-analysis-ik-5.0.2.zip
2. 在elasticsearch插件目录创建ik目录:`mkdir /usr/share/elasticsearch/plugins/ik`
1. 解压插件：`unzip elasticsearch-analysis-ik-5.0.2.zip`