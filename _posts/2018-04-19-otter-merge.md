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

```

```

