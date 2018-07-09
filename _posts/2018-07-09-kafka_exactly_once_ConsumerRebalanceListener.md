---
layout: post
title: "Exactly-once Kafka Dynamic Consumer via Subscribe"
author: "Lu Yee"
date: 2018-01-25 10:28:32
categories: ["kafka"]
tags: ["java","kafka"]
description: >
  Spring kafka
---

可以通过consumer在subscribe的时候引入一个ConsumerRebalanceListener来实现exactly once


link: [Exactly-once Kafka Dynamic Consumer via Subscribe](https://dzone.com/articles/kafka-clients-at-most-once-at-least-once-exactly-o)

[ExactlyOncePersonConsumer](https://github.com/luyee/KafkaExample/blob/master/src/main/java/com/gmail/alexandrtalan/kafka/consumers/ExactlyOncePersonConsumer.java)
