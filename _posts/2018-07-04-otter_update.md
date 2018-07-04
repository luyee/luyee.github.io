---
layout: post
title: " 记一次Otter中update bug"
author: "Lu Yee"
date: 2018-07-04 15:03:32
categories: ["java"]
tags: ["java"]
description: >
  记一次Otter的OOM排查过程
---

### 现象描述：

   在mysql-->mysql的单向同步中，出现部分数据丢失，经过排查发现:在一开始insert插入数据都是正常的，在进行update操作
后就有可能出现某些字段的数据丢失，为0或者为空。
翻了下[issue](https://github.com/alibaba/otter/issues)，看到有人提了类似的[issue-507](https://github.com/alibaba/otter/issues/507)   
说的是在load阶段insert跟update在merge的时候有个bug，导致其原本在一个batch的数据不能合并为一条数据，这样在后续的入   库阶段是交个线程池处理的没法保证顺序，这个时候一旦出现update先于insert执行就出现数据丢失。

按照这个思路，给目标库的binlog加了监控，对出现异常的数据进行监控并接入钉钉报警，另外otter开启select与load的详细日志  
在收到报警后对比select与load的详细log, 

### select日志

#### 第一条sql语句，insert
 ```
 -----------------
- PairId: 7 , TableId: 14 , EventType : I , Time : 1529566470000 
- Consistency :  , Mode :  
-----------------
---Pks
	EventColumn[index=0,columnType=-5,columnName=id,columnValue=492720286920519680,isNull=false,isKey=true,isUpdate=true]
---oldPks

---Columns
	EventColumn[index=1,columnType=-5,columnName=application_id,columnValue=492720286832439296,isNull=false,isKey=false,isUpdate=true]
	EventColumn[index=2,columnType=-5,columnName=request_id,columnValue=1205201806210011611,isNull=false,isKey=false,isUpdate=true]
	EventColumn[index=3,columnType=12,columnName=loan_stage,columnValue=pre,isNull=false,isKey=false,isUpdate=true]
	EventColumn[index=4,columnType=4,columnName=channel,columnValue=1205,isNull=false,isKey=false,isUpdate=true]
	EventColumn[index=5,columnType=-5,columnName=order_id,columnValue=492720286899548160,isNull=false,isKey=false,

 ```
#### 第二条sql update
 ```
 -----------------
- PairId: 7 , TableId: 14 , EventType : U , Time : 1529566470000 
- Consistency :  , Mode :  
-----------------
---Pks
	EventColumn[index=0,columnType=-5,columnName=id,columnValue=492720286899548160,isNull=false,isKey=true,isUpdate=false]
---oldPks
	EventColumn[index=0,columnType=-5,columnName=id,columnValue=492720286899548160,isNull=false,isKey=true,isUpdate=false]
---Columns
	EventColumn[index=5,columnType=12,columnName=proc_inst_id,columnValue=86556550,isNull=false,isKey=false,isUpdate=true]
	EventColumn[index=6,columnType=12,columnName=proc_def_id,columnValue=SE10080010:1:77922504,isNull=false,isKey=false,isUpdate=true]
	EventColumn[index=7,columnType=12,columnName=proc_def_key,columnValue=SE10080010,isNull=false,isKey=false,
 ```
### load日志

####  第一条sql,insert
```
-----------------
- PairId: 7 , TableId: 14 , EventType : I , Time : 1529566470000 
- Consistency :  , Mode :  
-----------------
---Pks
	EventColumn[index=0,columnType=-5,columnName=id,columnValue=492720286899548160,isNull=false,isKey=true,isUpdate=true]
---oldPks

---Columns
	EventColumn[index=1,columnType=-5,columnName=application_id,columnValue=492720286832439296,isNull=false,isKey=false,isUpdate=true]
	EventColumn[index=2,columnType=4,columnName=channel,columnValue=1205,isNull=false,isKey=false,isUpdate=true]
	EventColumn[index=3,columnType=-5,columnName=request_id,columnValue=1205201806210011611,isNull=false,isKey=false,isUpdate=true]
	EventColumn[index=4,columnType=-5,columnName=user_id,columnValue=1529566341573,isNull=false,isKey=false,isUpdate=true]
	EventColumn[index=5,columnType=12,columnName=proc_inst_id,columnValue=<null>,isNull=true,isKey=false,isUpdate=true]
	EventColumn[index=6,columnType=12,columnName=proc_def_id,columnValue=<null>,isNull=true,isKey=false,isUpdate=true]
	EventColumn[index=7,columnType=12,columnName=proc_def_key,columnValue=<null>,isNull=true,isKey=false,
```
#### 第二条sql update 

```
-----------------
- PairId: 7 , TableId: 14 , EventType : U , Time : 1529566470000 
- Consistency :  , Mode :  
-----------------
---Pks
	EventColumn[index=0,columnType=-5,columnName=id,columnValue=492720286899548160,isNull=false,isKey=true,isUpdate=false]
---oldPks
	EventColumn[index=0,columnType=-5,columnName=id,columnValue=492720286899548160,isNull=false,isKey=true,isUpdate=false]
---Columns
	EventColumn[index=5,columnType=12,columnName=proc_inst_id,columnValue=86556550,isNull=false,isKey=false,isUpdate=true]
	EventColumn[index=6,columnType=12,columnName=proc_def_id,columnValue=SE10080010:1:77922504,isNull=false,isKey=false,isUpdate=true]
	EventColumn[index=7,columnType=12,columnName=proc_def_key,columnValue=SE10080010,isNull=false,isKey=false,
```

看起来select 阶段与load阶段没有什么区别，数据好像是正常的，但是仔细看了下的Time,这个是同一批数据，在select阶段是正常的两条语句，但是在load阶段经过merge之后同一个batch的数据不可能出现同一个表的相同id有多条数据存在。

由此可以确定是merge的问题，看下merge的代码是依据RowKey来比较是不是同一条数据的

```
private static void mergeUpdate(EventData eventData, Map<RowKey, EventData> result) {
    RowKey rowKey = new RowKey(eventData.getTableId(), eventData.getSchemaName(), eventData.getTableName(),
                               eventData.getKeys());
    if (!CollectionUtils.isEmpty(eventData.getOldKeys())) {// 存在主键变更
        // 需要解决(1->2 , 2->3)级联主键变更的问题
        RowKey oldKey = new RowKey(eventData.getTableId(), eventData.getSchemaName(), eventData.getTableName(),
                                   eventData.getOldKeys());
        if (!result.containsKey(oldKey)) {// 不需要级联
            result.put(rowKey, eventData);
        } else {
            EventData oldEventData = result.get(oldKey);
            eventData.setSize(oldEventData.getSize() + eventData.getSize());
            // 如果上一条变更是insert的，就把这一条的eventType改成insert，并且把上一条存在而这一条不存在的字段值拷贝到这一条中
            if (oldEventData.getEventType() == EventType.INSERT) {
                eventData.setEventType(EventType.INSERT);
                // 删除当前变更数据老主键的记录.
                result.remove(oldKey);

                EventData mergeEventData = replaceColumnValue(eventData, oldEventData);
                mergeEventData.getOldKeys().clear();// 清空oldkeys，insert记录不需要
                result.put(rowKey, mergeEventData);
            } else if (oldEventData.getEventType() == EventType.UPDATE) {
                // 删除当前变更数据老主键的记录.
                result.remove(oldKey);

                // 如果上一条变更是update的，把上一条存在而这一条不存在的数据拷贝到这一条中
                EventData mergeEventData = replaceColumnValue(eventData, oldEventData);
                result.put(rowKey, mergeEventData);
            } else {
                throw new LoadException("delete(has old pks) + update impossible happed!");
            }
        }
    } else {
        if (!result.containsKey(rowKey)) {// 没有主键变更
            result.put(rowKey, eventData);
        } else {
            EventData oldEventData = result.get(rowKey);
            // 如果上一条变更是insert的，就把这一条的eventType改成insert，并且把上一条存在而这一条不存在的字段值拷贝到这一条中
            if (oldEventData.getEventType() == EventType.INSERT) {
                eventData.setEventType(EventType.INSERT);

                EventData mergeEventData = replaceColumnValue(eventData, oldEventData);
                result.put(rowKey, mergeEventData);
            } else if (oldEventData.getEventType() == EventType.UPDATE) {// 可能存在
                                                                         // 1->2
                                                                         // ,
                                                                         // 2update的问题

                // 如果上一条变更是update的，把上一条存在而这一条不存在的数据拷贝到这一条中
                EventData mergeEventData = replaceColumnValue(eventData, oldEventData);
                result.put(rowKey, mergeEventData);
            } else if (oldEventData.getEventType() == EventType.DELETE) {
                //异常情况，出现 delete + update，那就直接更新为update
                result.put(rowKey, eventData);
            }
        }
    }
}

```
看到RowKey的构成SchemaName，TableName应该没问题，那么就是keys的问题了，这里的keys就是List<EventColumn>，
list的比较也是hashcode(),看下EventColumn是包括columnName,columnType,columnValue,index,isKey,isNull,isUpdate共同构成的

```
public int hashCode() {
    final int prime = 31;
    int result = 1;
    result = prime * result + ((columnName == null) ? 0 : columnName.hashCode());
    result = prime * result + columnType;
    result = prime * result + ((columnValue == null) ? 0 : columnValue.hashCode());
    result = prime * result + index;
    result = prime * result + (isKey ? 1231 : 1237);
    result = prime * result + (isNull ? 1231 : 1237);
    result = prime * result + (isUpdate ? 1231 : 1237);
    return result;
}
```
从日志看这个update在insert与update在load阶段是不一致的， 重写下Rowkey,EventColumn的hashcode()

```
//Rowkey
public int hashCode() {
    final int prime = 31;
    int result = 1;
  //  result = prime * result + ((keys == null) ? 0 : keys.hashCode());
    result = prime * result + ((keys == null) ? 0 : getHashCode());
    result = prime * result + ((schemaName == null) ? 0 : schemaName.hashCode());
    result = prime * result + ((tableId == null) ? 0 : tableId.hashCode());
    result = prime * result + ((tableName == null) ? 0 : tableName.hashCode());
    return result;
}
public int getHashCode(){
  int hashCode = 1;
  for (EventColumn e : keys) {
    hashCode = 31*hashCode + (e==null ? 0 : e.hashCode2());
  }
}
//EventColumn
public int hashCode2() {
    final int prime = 31;
    int result = 1;
    result = prime * result + ((columnName == null) ? 0 : columnName.hashCode());
    result = prime * result + columnType;
    result = prime * result + ((columnValue == null) ? 0 : columnValue.hashCode());
    result = prime * result + index;
    result = prime * result + (isKey ? 1231 : 1237);
    result = prime * result + (isNull ? 1231 : 1237);
   // result = prime * result + (isUpdate ? 1231 : 1237);
    return result;
}
```

