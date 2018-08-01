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
mysqldump  -p  -u  -hip   -P3322 --single-transaction --flush-logs --master-data=2 dbname  tbname >xxx.sql
```


导入

```
 nohup mysql  -u -p -P3331 </tmp/3322_db.sql  >log.log & 2>&1  &
```

### mysqldump 文件简单分割！

grep -n找到相应数据库或者表(按库或者表的粒度)的sql 语句的行
```
grep -n 'USE `agreement`' 3322_db.sql
grep -n  'DROP TABLE IF EXISTS `sub_account_log`' account.sql  
```
awk从指定行分割文件(假设4433行)

```
nohup awk '{if (NR<4433) print $0 >"account1.sqll";if (NR>=4433) print $0>"account2.sql"}'  account.sql   >account.log & 2>&1  &
```


### sql 日期函数

Date函数

```
select * from t_borrower_repay where date(pay_date) >= date('2017-08-01') and date(pay_date)<date('2017-12-07')  and date(data_date) =date('2017-11-06')
```

unix_timestamp函数

```
select * from t_borrower_repay where unix_timestamp(pay_date) >= unix_timestamp('2017-08-01') and unix_timestamp(pay_date)<unix_timestamp('2017-12-07')  and unix_timestamp(data_date) =unix_timestamp('2017-11-06')
```


### sql

增加字段到指定字段之后

```
 alter table table add column  `update_time` timestamp NULL DEFAULT '2017-11-23 00:00:00' COMMENT '更新时间' after create_time;
```
增加多个字段到指定字段之后

```
alter table  t_apply_work_info 
ADD COLUMN  `company_revenue` varchar(50) DEFAULT NULL COMMENT '经营流水（万元）' after `max_salary`,
ADD COLUMN  `occupation` int(11) DEFAULT '0' COMMENT '职业 1 学生 2 工薪 3 老板 4 农民' after `company_revenue`,
ADD COLUMN  `business_term` varchar(10) DEFAULT NULL COMMENT '经营年限' after `occupation`,
ADD COLUMN  `is_social_security` int(2) DEFAULT NULL COMMENT '现单位是否缴纳社保 after `business_term`',
ADD COLUMN  `working_years` int(2) DEFAULT NULL COMMENT '1 3个月以内 ，2 3-6个月，3 6-12个月 ，4 12月以上' after `is_social_security` ;
```


调整已有字段的顺序

```
alter table table CHANGE created_time `created_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时 间' after modified_time;
```



