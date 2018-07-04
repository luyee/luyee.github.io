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

现象描述：

   在mysql-->mysql的单向同步中，出现部分数据丢失，经过排查发现:在一开始insert插入数据都是正常的，在进行update操作后   
就有可能出现某些字段的数据丢失，为0或者为空。
翻了下[issue](https://github.com/alibaba/otter/issues)，看到有人提了类似的[issue-507](https://github.com/alibaba/otter/issues/507)   
说的是在load阶段insert跟update在merge的时候有个bug，导致其原本在一个


