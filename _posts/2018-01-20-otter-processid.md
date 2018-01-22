---
layout: post
title: "Otter调度模型之ProcessId"
author: "Lu Yee"
date: 2018-01-20 10:33:32
categories: ["mysql"]
tags: ["mysql"]
description: >
  otter调度模型
---

[Otter调度模型](https://github.com/alibaba/otter/wiki/Otter%E8%B0%83%E5%BA%A6%E6%A8%A1%E5%9E%8B)
#### Otter S.E.T.L 

1. otter通过select模块串行获取canal的批数据，注意是串行获取，每批次获取到的数据，就会有一个全局标识，otter里称之为processId.
2. select模块获取到数据后，将其传递给后续的ETL模型. 这里E和T模块会是一个并行处理
3. 将数据最后传递到Load时，会根据每批数据对应的processId，按照顺序进行串行加载。 ( 比如有一个processId=2的数据先到了Load模块，但会阻塞等processId=1的数据Load完成后才会被执行)


主要包括： 令牌生成(processId) + 事件通知.

令牌生成：

基于AtomicLong.inc()机制，(纯内存机制，解决同机房，单节点同步需求，不需要多节点交互)
基于zookeeper的自增id机制，(解决异地机房，多节点协作同步需求)
事件通知： (简单原理： 每个stage都会有个block queue，接收上一个stage的single信号通知，当前stage会阻塞在该block queue上，直到有信号通知)

block queue + put/take方法，(纯内存机制)
block queue + rpc + put/take方法 (两个stage对应的node不同，需要rpc调用，需要依赖负载均衡算法解决node节点的选择问题)
block queue + zookeeper watcher ()

### processId

在processSelect()（SelectTask.java）函数里，可以看到这个ProcessId来自于EtlEventData，最后构成一个Identity放在rowBatch中的

```
final EtlEventData etlEventData = arbitrateEventService.selectEvent().await(pipelineId);
RowBatch rowBatch = new RowBatch();
// 构造唯一标识
Identity identity = new Identity();
identity.setChannelId(channel.getId());
identity.setPipelineId(pipelineId);
identity.setProcessId(etlEventData.getProcessId());
rowBatch.setIdentity(identity);
```

关键看这个ProcessId

