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

###  otter中对insert/update事件的合并算法

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

