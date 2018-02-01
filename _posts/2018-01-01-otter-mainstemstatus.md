---
layout: post
title: "Otter之MainStemStatus"
author: "Lu Yee"
date: 2018-01-20 10:33:32
categories: ["mysql"]
tags: ["mysql"]
description: >
  otter调度模型
---

两种状态

```
 public enum Status {
        /** 已追上 */
        OVERTAKE,
        /** 追赶中 */
        TAKEING;
```

OVERTAKE是在OtterDownStreamHandler更新的，在CanalEmbedSelector中通过destination产生特定的 CanalInstance的时候，

会把OtterDownStreamHandler添加到handler队列的头

```
CanalEventSink eventSink = instance.getEventSink();
if (eventSink instanceof AbstractCanalEventSink) {
    handler = new OtterDownStreamHandler();
    handler.setPipelineId(pipelineId);
    handler.setDetectingIntervalInSeconds(canal.getCanalParameter().getDetectingIntervalInSeconds());
    OtterContextLocator.autowire(handler); // 注入一下spring资源
    ((AbstractCanalEventSink) eventSink).addHandler(handler, 0); // 添加到开头
    handler.start();
 }
                
```

