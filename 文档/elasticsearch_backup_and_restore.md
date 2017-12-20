# ElasticSearch备份与恢复

标签（空格分隔）： ELK

---

Elasticsearch的Snapshot and restore模块允许创建单个索引或者整个集群的快照到远程仓库。 在初始版本里只支持共享文件系统的仓库，但是现在通过官方的仓库插件可以支持各种各样的后台仓库。

## 仓库

共享文件系统仓库`"type": "fs"`是使用共享的文件系统去存储快照。在location参数里指定的具体存储路径必须和共享文件系统里的位置是一样的并且能被所有的数据节点和master节点访问。 另外还支持如下的一些参数设置：

* location
  指定快照的存储位置。必须要有。
* compress
  指定是否对快照文件进行压缩。默认是 true.
* chunk_size
  如果需要在做快照的时候大文件可以被分解成几块。这个参数指明了每块的字节数。也可用不同的单位标识。比如，1g，10m，5k等。默认是null(表示不限制块大小)。
* max_restore_bytes_per_sec
  每个节点恢复数据的最高速度限制。默认是20mb/s
* max_snapshot_bytes_per_sec	
  每个节点做快照的最高速度限制默认是20mb/s

在进行任何快照或者恢复操作之前必须有一个快照仓库注册在Elasticsearch里。下面的这个命令注册了 一个名为backup的共享文件系统仓库，快照将会存储在`/srv/backup/es`这个目录。

```
$ curl -XPUT 'http://localhost:9200/_snapshot/backup' -d '{
    "type": "fs",
    "settings": {
        "location": "/srv/backup/es",
        "compress": true
    }
}'
```

一旦仓库被注册了，就可以用下面的命令去获取这个仓库的信息。

```
$ curl -XGET 'http://localhost:9200/_snapshot/backup?pretty'
{
  "backup" : {
    "type" : "fs",
    "settings" : {
      "compress" : "true",
      "location" : "/srv/backup/es"
    }
  }
}
```

如果没有指定仓库名字，或者使用 `_all`作为仓库名字，Elasticsearch将返回该集群当前注册的所有仓库的信息。

## 快照

一个仓库可以包含同一个集群的多个快照。快照根据集群中的唯一名字进行区分。在仓库`backup`里创建一个名为snapshot_1的快照可以通过下面的命令:

```
$ curl -XPUT "http://localhost:9200/_snapshot/backup/snapshot_1?wait_for_completion=true&pretty"
{
  "snapshot" : {
    "snapshot" : "snapshot_1",
    "uuid" : "-hyMT2xITEy1avVM85N-fg",
    "version_id" : 5000299,
    "version" : "5.0.2",
    "indices" : [
      "test_index"
    ],
    "state" : "SUCCESS",
    "start_time" : "2017-07-21T08:42:58.007Z",
    "start_time_in_millis" : 1500626578007,
    "end_time" : "2017-07-21T08:43:07.511Z",
    "end_time_in_millis" : 1500626587511,
    "duration_in_millis" : 9504,
    "failures" : [ ],
    "shards" : {
      "total" : 30,
      "failed" : 0,
      "successful" : 30
    }
  }
}
```

`wait_for_completion`参数指定创建snapshot的请求是否等待快照创建完成再返回。
默认情况下，集群中所有打开和启动的索引都会被创建快照。可以通过在API请求body里列出需要创建快照的索引：

```
$ curl -XPUT "localhost:9200/_snapshot/backup/snapshot_1" -d '{
    "indices": "index_1,index_2",
    "ignore_unavailable": "true",
    "include_global_state": false
    "partial": "false"
}'
```

上述命令中通过`indices`参数指定快照包含的索引。
快照请求同样支持`ignore_unavailable`选项。把这个选项设置为`true`的时候，在创建快照的过程中会忽略不存在的索引。默认情况下，如果没有设置`ignore_unavailable`，在索引不存在的情况下快照请求将会失败。
通过设置`include_global_state`为`false`能够防止集群的全局状态被作为快照的一部分存储起来。
默认情况下，如果快照中的1个或多个索引不是全部主分片都可用会导致整个创建快照的过程失败。通过设置`partial`为`true`可以改变这个行为。

如果快照已经建立，我们可以通过如下的命令去获得快照的信息：

```
$ curl -XGET "localhost:9200/_snapshot/backup/snapshot_1"
```

通过如下的命令可以把仓库里所有的快照列出来：

```
$ curl -XGET "localhost:9200/_snapshot/backup/_all"
```

可以通过如下的命令将仓库里的某个快照删除：

```
$ curl -XDELETE "localhost:9200/_snapshot/backup/snapshot_1"
```

## 恢复

快照可以使用如下的操作来恢复：

```
$ curl -XPOST "localhost:9200/_snapshot/backup/snapshot_1/_restore"
```

默认情况下，快照中的所有索引以及集群状态都会被恢复。在恢复请求中可以通过`indices`来指定需要被恢复的索引，同样可以使用`include_global_state`选项来防止恢复集群的状态。`indices`支持配置多个索引。`rename_pattern`和`rename_replacement`选项可以在恢复的时候使用正则表达式来重命名`index`。

```
$ curl -XPOST "localhost:9200/_snapshot/backup/snapshot_1/_restore" -d '{
    "indices": "index_1,index_2",
    "ignore_unavailable": "true",
    "include_global_state": false,
    "rename_pattern": "index_(.+)",
    "rename_replacement": "restored_index_$1"
}'
```

恢复操作可以在正在运行的集群上操作。尽管如此，已经存在的index只有在关闭之后才能被恢复。恢复操作会自动打开关闭的恢复索引，并且如果索引不存在,则创建新的索引。如果集群状态也是恢复的，如果恢复的模板不存在会被新建，如果同名的模板已经存在则会被覆盖代替。恢复的持久性设置会被增加到现存的持久性设置里。

## 快照状态

正在运行的快照的详细信息可以通过如下的命令来获取：
```
$ curl -XGET "localhost:9200/_snapshot/_status"
```

在这种格式下，这个命令将会返回所有正在运行的快照的信息。通过指明仓库名字，能够把结果限定到具体的一个仓库。

```
$ curl -XGET "localhost:9200/_snapshot/backup/_status"
```

如果仓库名字和快照id都指明了，这个命令就会返回这个快照的详细信息，甚至这个快照不是正在运行。

```
$ curl -XGET "localhost:9200/_snapshot/backup/snapshot_1/_status"
```

同样支持多个快照id：

```
$ curl -XGET "localhost:9200/_snapshot/backup/snapshot_1,snapshot_2/_status"
```

## 脚本

### 备份脚本

```
#!/bin/bash

# 脚本参数 #
repo_name=backup          # es仓库名称
repo_dir=/srv/backup/es   # 对应仓库路径
es_host=localhost         # es服务器地址


filename=`date +%Y%m%d`
backesFile=es_$filename.tar.gz
cd $repo_dir
curl -XDELETE http://${es_host}:9200/_snapshot/${repo_name}/$filename?pretty > /dev/null 2>&1
curl -XPUT http://${es_host}:9200/_snapshot/${repo_name}/$filename?wait_for_completion=true\&pretty
tar czf $backesFile * --exclude=*.tar.gz
if [[ `pwd` == $repo_dir ]]; then
  ls | grep -v tar.gz | xargs rm -rf
fi
find ./ -name '*.tar.gz' -ctime +30 -exec rm -f {} \;
echo "备份完成，备份文件为：${repo_dir}/$backesFile"
```

### 恢复脚本

```
#/bin/bash

# 脚本参数 #
repo_name=backup          # es仓库名称
repo_dir=/srv/backup/es   # 对应仓库路径
es_host=localhost         # es服务器地址

if [ -z $1 ];then
  echo "请指定需要恢复的备份文件（tar.gz格式）。"
  exit 1
elif [ ! -f $1 ]
  echo "备份文件$1不存在。"
  exit 1
fi
backupFile=$1
rm -rf $repo_dir/index* $repo_dir/*.dat $repo_dir/indices
tar zxf $backupFile -C $repo_dir/
snapshot_list=`curl http://${es_host}:9200/_snapshot/${repo_name}/_all 2> /dev/null`
snapshot=`echo $snapshot_list | jq .snapshots[0].snapshot | sed 's/"//g'`
indices=`echo $snapshot_list | jq .snapshots[0].indices | grep \" | sed 's/,//g' | sed 's/"//g'`
for i in $indices; do
  curl -XPOST http://${es_host}:9200/$i/_close > /dev/null 2>&1
done
curl -XPOST http://${es_host}:9200/_snapshot/${repo_name}/$snapshot/_restore?pretty -d '
{
	"indices": "*",
	"ignore_unavailable": "true"
}'
```