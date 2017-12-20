# RabbitMQ集群部署文档

[TOC]

## Rabbitmq安装

安装相关程序包

```
apt-get install rabbitmq-server
systemctl enable rabbitmq-server
```

启用常用插件，包括管理插件、web-stomp插件等
```
rabbitmq-plugins enable rabbitmq_management rabbitmq_web_stomp rabbitmq_stomp
```

添加集群主机IP对应关系`/etc/hosts`

```
192.168.2.214   mq1
192.168.2.213   mq2
```

更改.erlang.cookie文件的内容并重启rabbitmq-server

```
echo 'topvdn' > /var/lib/rabbitmq/.erlang.cookie
service rabbitmq-server restart
```

在从上将本机添加到组集群

```
rabbitmqctl stop_app
rabbitmqctl force_reset
rabbitmqctl join_cluster rabbit@tz-web3
rabbitmqctl start_app
```

在所有服务器上查看状态，验证是否成功

```
rabbitmqctl cluster_status
```

验证成功后执行下面策略

## 镜像队列

上述配置的RabbitMQ默认集群模式，并不包括队列的高可用性，队列内容不会复制，只能解决节点压力。一旦队列节点宕机直接导致该队列无法应用，只能守候重启，所以要想在队列节点宕机或故障也能正常应用，就要复制队列内容到集群里的每个节点，需要创建镜像队列。

在主服务上执行

```
rabbitmqctl add_user orange 831206
rabbitmqctl add_vhost /topvdn
rabbitmqctl set_permissions -p /topvdn orange ".*" ".*" ".*"
rabbitmqctl set_policy -p /topvdn ha-allqueues "^" '{"ha-mode":"all","ha-sync-mode":"automatic","ha-promote-on-shutdown":"always"}'
rabbitmqctl set_user_tags orange monitoring

rabbitmqctl add_user tracker_app Megaium!
rabbitmqctl add_vhost /tracker_app
rabbitmqctl set_permissions -p /tracker_app tracker_app ".*" ".*" ".*"
rabbitmqctl set_policy -p /tracker_app ha-allqueues "^" '{"ha-mode":"all","ha-sync-mode":"automatic","ha-promote-on-shutdown":"always"}'
rabbitmqctl set_user_tags tracker_app monitoring

# 低版本的 rabbitmq 配置策略的时候，不支持 ha-promote-on-shutdown 参数，去掉即可
rabbitmqctl set_policy -p /topvdn ha-allqueues "^" '{"ha-mode":"all","ha-sync-mode":"automatic"}'
rabbitmqctl set_policy -p /tracker_app ha-allqueues "^" '{"ha-mode":"all","ha-sync-mode":"automatic"}'


rabbitmqctl set_user_tags guest
rabbitmqctl list_permissions -p /topvdn
rabbitmqctl list_permissions -p /tracker_app
rabbitmqctl list_users
rabbitmqctl list_policies -p /topvdn
rabbitmqctl list_policies -p /tracker_app

[可选] 添加 root 超级帐号
rabbitmqctl add_user root 123456
rabbitmqctl set_permissions -p / root ".*" ".*" ".*"
rabbitmqctl set_permissions -p /tracker_app root ".*" ".*" ".*"
rabbitmqctl set_permissions -p /tracker_app root ".*" ".*" ".*"
rabbitmqctl set_user_tags root administrator


设置用户权限
rabbitmq-plugins enable rabbitmq_management
启用页面管理插件
重启 rabbitmq 服务生效
```

## 重置 rabbitmq 数据后再次加集群

假设web1需要重置并重新加入集群

先清掉数据目录

```
rm -rf /var/lib/rabbitmq/mnesia/rabbit@tz-web1*
```

再在集群的其他运行中的机器执行

```
rabbitmqctl forget_cluster_node rabbit@tz-web1
```

## 进阶

### 三种分布式消息处理方式

  RabbitMQ分布式的消息处理方式有以下三种：
  
  * Clustering：不支持跨网段，各节点需运行同版本的Erlang和RabbitMQ, 应用于同网段局域网。
  * Federation：允许单台服务器上的Exchange或Queue接收发布到另一台服务器上Exchange或Queue的消息, 应用于广域网。
  * Shovel：与Federation类似，但工作在更低层次。
  
RabbitMQ对网络延迟很敏感，在LAN环境建议使用clustering方式;在WAN环境中，则使用Federation或Shovel。我们平时说的RabbitMQ集群，说的就是clustering方式，它是RabbitMQ内嵌的一种消息处理方式，而Federation或Shovel则是以plugin形式存在。

### 两种集群模式

* 普通模式(默认)

  默认模式，以两个节点（rabbit01、rabbit02）为例来进行说明。对于Queue来说，消息实体只存在于其中一个节点rabbit01（或者rabbit02），rabbit01和rabbit02两个节点仅有相同的元数据，即队列的结构。当消息进入rabbit01节点的Queue后，consumer从rabbit02节点消费时，RabbitMQ会临时在rabbit01、rabbit02间进行消息传输，把A中的消息实体取出并经过B发送给consumer。所以consumer应尽量连接每一个节点，从中取消息。即对于同一个逻辑队列，要在多个节点建立物理Queue。否则无论consumer连rabbit01或rabbit02，出口总在rabbit01，会产生瓶颈。当rabbit01节点故障后，rabbit02节点无法取到rabbit01节点中还未消费的消息实体。如果做了消息持久化，那么得等rabbit01节点恢复，然后才可被消费；如果没有持久化的话，就会产生消息丢失的现象。

* 镜像模式(基于镜像队列)

  它是在普通模式的基础上，把需要的队列做成镜像队列，存在于多个节点来实现高可用(HA)。该模式解决了上述问题，Broker会主动地将消息实体在各镜像节点间同步，在consumer取数据时无需临时拉取。该模式带来的副作用也很明显，除了降低系统性能外，如果镜像队列数量过多，加之大量的消息进入，集群内部的网络带宽将会被大量消耗。通常地，对可靠性要求较高的场景建议采用镜像模式。

### 两种集群节点类型

* RAM Node(内存节点)：将所有的Virtual Host、Queue、Exchange、Binding、User等的元数据存储在内存中，因此性能比较出色。
* DISC Node(磁盘节点): 将元数据存储在磁盘中。
    
注：RabbitMQ单节点环境只允许是磁盘节点，防止重启RabbitMQ时丢失系统的配置信息。RabbitMQ集群环境至少要有一个磁盘节点，因为当节点加入或者离开集群时，必须要将该变更通知到至少一个磁盘节点。
