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


导入

```
 nohup mysql  -u -p -P3331 </tmp/3322_db.sql  >log.log & 2>&1  &
```

### mysqldump 文件简单分割！

grep -n找到相应数据库或者表的sql 语句的行
```
grep -n 'USE `agreement`' 3322_db.sql   
```
awk从指定行分割文件(假设4433行)

```
nohup awk '{if (NR<4433) print $0 >"account1.sqll";if (NR>=4433) print $0>"account2.sql"}'  account.sql   >account.log & 2>&1  &
```



