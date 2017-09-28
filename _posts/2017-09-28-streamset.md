---
layout: post
title: "Mysql binlog to Kudu by Streamsets"
author: "Lu Yee"
date: 2017-09-28 12:55:32
categories: ["kudu","streamsets"]
tags: ["kudu","streamsets"]
description: >
  Mysql binlog to Kudu by Streamsets
---

### streamsets  安装配置

```
tar zxvf streamsets-datacollector-all-2.6.0.1.tgz 
cd  streamsets-datacollector-2.6.0.1
```

### mysql jar包

```
cp mysql-connector-java-5.1.40.jar streamsets-libs/streamsets-datacollector-mysql-binlog-lib/lib/
```

### 启动

```
nohup bin/streamsets dc &
```
### 登录web 

地址 http://streamsetsip:18630   
用户名密码：admin/admin

### Pipeline

这里配置一个pipeline用来同步mysql binlog到kudu

1. 创建一个新的Pipeline
2. 选择一个Origin,这里选择Mysql Binary Log
3. 选择一个Process,这里可以不要，也可以选择，比如Field Renamer
4. 选择一个Destination,这里选kudu,   
     注意配置Field to Column Mapping ，这里的SDC Field必须是[数字]或者“/”开头   
     还有是如果是“/”开头，源表包含字段ID,X,y, SDC Field的格式为/Data/ID,/Data/X,/Data/y.


