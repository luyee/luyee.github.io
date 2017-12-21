---
layout: post
title: "Mysql INSERT IGNORE INTO & ON DUPLICATE KEY UPDATE & REPLACE INTO "
author: "Lu Yee"
date: 2017-12-21 10:12:32
categories: ["mysql"]
tags: ["mysql"]
description: >
  Mysql INSERT IGNORE INTO & ON DUPLICATE KEY UPDATE & REPLACE INTO
---

主键/key冲突直接忽略

## INSERT IGNORE INTO

```
CREATE TABLE `test_ignore` (  
  `id` int(50) NOT NULL AUTO_INCREMENT,  
  `a` varchar(30) DEFAULT NULL,  
  `b` varchar(30) DEFAULT NULL,  
  PRIMARY KEY (`id`),  
  UNIQUE KEY `kk_uq` (`a`)  
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8

mysql> insert into test_ignore(id,a,b)values(1,1,'abc')
    -> ;
Query OK, 1 row affected (0.01 sec)

mysql> insert into test_ignore(id,a,b)values(3,2,'abcd');
Query OK, 1 row affected (0.01 sec)

mysql> insert into test_ignore(id,a,b)values(4,3,'abcde');
Query OK, 1 row affected (0.01 sec)

mysql> insert into test_ignore(id,a,b)values(6,5,'abcde');
Query OK, 1 row affected (0.01 sec)

//插入key冲突行
mysql> insert into test_ignore(id,a,b)values(4,7,'abcde');
ERROR 1062 (23000): Duplicate entry '4' for key 'PRIMARY'
mysql> 
mysql> insert ignore into test_ignore(id,a,b)values(4,7,'abcde');
Query OK, 0 rows affected, 1 warning (0.01 sec)
mysql> 
mysql> insert into test_ignore(id,a,b)values(5,3,'abcde');
ERROR 1062 (23000): Duplicate entry '3' for key 'kk_uq'
mysql> 
mysql> insert ignore into test_ignore(id,a,b)values(5,3,'abcde');
Query OK, 0 rows affected, 1 warning (0.00 sec)
//插入不冲突行
mysql> insert ignore into test_ignore(id,a,b)values(5,4,'abcde');
Query OK, 1 row affected (0.00 sec)

mysql>

```
