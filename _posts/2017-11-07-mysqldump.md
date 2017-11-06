---
layout: post
title: "Mysqldump 使用"
author: "Lu Yee"
date: 2017-11-07 02:12:32
categories: ["mysql"]
tags: ["mysql"]
description: >
  Mysqldump 使用
---

### Mysqldump 使用

####  仅导出表结构，建表语句(-d )

```

```

可能没有锁表权限(-skip-lock-table)

```
mysqldump -p   -u  -hip -Pport --databases table_a table_b table_c  --skip-lock-table >skip-lock-table.sql 
```

导出带有binlog position的文件(--single-transaction --flush-logs --master-data=2)

```
mysqldump  -p  -u  -hip   -P3322 --single-transaction --flush-logs --master-data=2 dbname  tbname  --skip-lock-tables >xxx.sql
```
