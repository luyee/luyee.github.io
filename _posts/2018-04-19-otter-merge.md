---
layout: post
title: " otter insert/update合并算法"
author: "Lu Yee"
date: 2018-04-19 00:00:00
categories: ["java"]
tags: ["java"]
description: >
  otter
---

###  Otter数据入库算法

[数据合并](https://github.com/alibaba/otter/wiki/Otter%E6%95%B0%E6%8D%AE%E5%85%A5%E5%BA%93%E7%AE%97%E6%B3%95)
```
1. insert + insert -> insert (数据迁移+数据增量场景)
2. insert + update -> insert  (update字段合并到insert)
3. insert + delete -> delete 
4. update + insert -> insert (数据迁移+数据增量场景)
5. update + update -> update
6. update + delete -> delete
7. delete + insert -> insert 
8. delete + update -> update (数据迁移+数据增量场景)
9. delete + delete -> delete
```
源码
```
//DbLoadAction.load()-->DbLoadMerger.merge()
public static List<EventData> merge(List<EventData> eventDatas) {
    Map<RowKey, EventData> result = new LinkedHashMap<RowKey, EventData>();
    for (EventData eventData : eventDatas) {
        merge(eventData, result);
    }
    return new LinkedList<EventData>(result.values());
}

public static void merge(EventData eventData, Map<RowKey, EventData> result) {
    EventType eventType = eventData.getEventType();
    switch (eventType) {
        case INSERT:
            mergeInsert(eventData, result);
            break;
        case UPDATE:
            mergeUpdate(eventData, result);
            break;
        case DELETE:
            mergeDelete(eventData, result);
            break;
        default:
            break;
    }
}
```
#### mergeInsert
insert 涉及到下面几种情况

```
1. insert + insert -> insert (数据迁移+数据增量场景)
2. insert + update -> insert  (update字段合并到insert)
3. insert + delete -> delete 
9. delete + delete -> delete
```
下面看下源码
```
 private static void mergeInsert(EventData eventData, Map<RowKey, EventData> result) {
      // insert无主键变更的处理
      RowKey rowKey = new RowKey(eventData.getTableId(), eventData.getSchemaName(), eventData.getTableName(),
                                 eventData.getKeys());
      if (!result.containsKey(rowKey)) {
          result.put(rowKey, eventData);
      } else {
          EventData oldEventData = result.get(rowKey);
          eventData.setSize(oldEventData.getSize() + eventData.getSize());
          // 如果上一条变更是delete的，就直接用insert替换
          if (oldEventData.getEventType() == EventType.DELETE) {
              result.put(rowKey, eventData);
          } else if (oldEventData.getEventType() == EventType.UPDATE
                     || oldEventData.getEventType() == EventType.INSERT) {
              // insert之前出现了update逻辑上不可能，唯一的可能性主要是Freedom的介入，人为的插入了一条Insert记录
              // 不过freedom一般不建议Insert操作，只建议执行update/delete操作. update默认会走merge
              // sql,不存在即插入
              logger.warn("update-insert/insert-insert happend. before[{}] , after[{}]", oldEventData, eventData);
              // 如果上一条变更是update的，就用insert替换，并且把上一条存在而这一条不存在的字段值拷贝到这一条中
              EventData mergeEventData = replaceColumnValue(eventData, oldEventData);
              mergeEventData.getOldKeys().clear();// 清空oldkeys，insert记录不需要
              result.put(rowKey, mergeEventData);
          }
      }
  }
  
private static EventData replaceColumnValue(EventData newEventData, EventData oldEventData) {
    List<EventColumn> newColumns = newEventData.getColumns();
    List<EventColumn> oldColumns = oldEventData.getColumns();
    List<EventColumn> temp = new ArrayList<EventColumn>();
    for (EventColumn oldColumn : oldColumns) {
        boolean contain = false;
        for (EventColumn newColumn : newColumns) {
            if (oldColumn.getColumnName().equalsIgnoreCase(newColumn.getColumnName())) {
                newColumn.setUpdate(newColumn.isUpdate() || oldColumn.isUpdate());// 合并isUpdate字段
                contain = true;
            }
        }

        if (!contain) {
            temp.add(oldColumn);
        }
    }
    newColumns.addAll(temp);
    Collections.sort(newColumns, new EventColumnIndexComparable()); // 排序
    // 把上一次变更的旧主键传递到这次变更的旧主键.
    newEventData.setOldKeys(oldEventData.getOldKeys());
    if (oldEventData.getSyncConsistency() != null) {
        newEventData.setSyncConsistency(oldEventData.getSyncConsistency());
    }
    if (oldEventData.getSyncMode() != null) {
        newEventData.setSyncMode(oldEventData.getSyncMode());
    }

    if (oldEventData.isRemedy()) {
        newEventData.setRemedy(oldEventData.isRemedy());
    }
    newEventData.setSize(oldEventData.getSize() + newEventData.getSize());
    return newEventData;
}
```

