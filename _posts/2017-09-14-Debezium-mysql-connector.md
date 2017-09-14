---
layout: post
title: "Debezium-mysql-connector"
author: "Lu Yee"
date: 2017-09-14 10:28:32
categories: ["kafka-connect","kafka"]
tags: ["java","kafka-connect","kafka"]
description: >
  Debezium-mysql-connector
---



### 产生消息

还是从MySqlConnectorTask.poll()看起，最终调用的是AbstractReader.poll()

```
MySqlConnectorTask.poll()-->ChainedReader.poll()-->AbstractReader.poll()
```
AbstractReader可以是SnapshotReader或者BinlogReader,增量是BinlogReader，全量是SnapshotReader

poll() 主要逻辑代码

```
logger.trace("Polling for next batch of records");
List<SourceRecord> batch = new ArrayList<>(maxBatchSize);
while (running.get() && (records.drainTo(batch, maxBatchSize) == 0) && !success.get()) {}
return batch;
```

就是从records队列一次获取maxBatchSize量的SourceRecord，这个records是一个LinkedBlockingDeque

```
 this.records = new LinkedBlockingDeque<>(context.maxQueueSize());
```
既然是BlockingDeque,直接看入队列好了，在AbstractReader.enqueueRecord()中可以找到put入队列

```
protected void enqueueRecord(SourceRecord record) throws InterruptedException {
    if (record != null) {
        if (logger.isTraceEnabled()) {
            logger.trace("Enqueuing source record: {}", record);
        }
        this.records.put(record);
    }
}
```

这个enqueueRecord在很多地方调用到

```
BinlogReader.handleInsert(Event event)
BinlogReader.handleUpdate(Event event)
BinlogReader.handleDelete(Event event)
SnapshotReader.handleQueryEvent(Event event)
SnapshotReader.execute() 
SnapshotReader.enqueueSchemaChanges
```

看下insert,update,delete事件的处理
