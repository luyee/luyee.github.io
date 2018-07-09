---
layout: post
title: "Exactly-once Kafka Dynamic Consumer via Subscribe"
author: "Lu Yee"
date: 2018-07-08 10:28:32
categories: ["kafka"]
tags: ["java","kafka"]
description: >
  Spring kafka
---

可以通过consumer在subscribe的时候引入一个ConsumerRebalanceListener来实现exactly once

```
consumer = new KafkaConsumer(getKafkaConsumerConfig());
consumer.subscribe(Arrays.asList(this.topic.split(",")),
				new OffsetTrackingRebalanceListener(consumer, offsetManager));
```

看下OffsetTrackingRebalanceListener，这个就是ConsumerRebalanceListener的实现

```
public class OffsetTrackingRebalanceListener implements ConsumerRebalanceListener {
	private OffsetManager offsetManager;
	private Consumer<String, String> consumer;
	public OffsetTrackingRebalanceListener(Consumer<String, String> consumer,OffsetManager offsetManager) {
		this.consumer = consumer;
		this.offsetManager = offsetManager;
	}

	@Override
	public void onPartitionsRevoked(Collection<TopicPartition> partitions) {
		for (TopicPartition partition : partitions) {
			offsetManager.saveOffsetInExternalStore(partition.topic(), partition.partition(),
					consumer.position(partition));
		}
	}
	
	@Override
	public void onPartitionsAssigned(Collection<TopicPartition> partitions) {
		for (TopicPartition partition : partitions) {
			consumer.seek(partition,
					offsetManager.readOffsetFromExternalStore(partition.topic(), partition.partition()));
		}
	}
}
```

在里边通过一个外部的存储管理offsets

```
public class OffsetManager {
	private String storagePrefix;
	
	private RedisClient redisClient;
	
	public OffsetManager(RedisClient redisClient, String storagePrefix) {
		this.storagePrefix = storagePrefix;
		this.redisClient = redisClient;
	}


	public void saveOffsetInExternalStore(String topic, int partition, long offset) {
		try {

			redisClient.set(storageName(topic, partition), String.valueOf(offset));

		} catch (Exception e) {
			e.printStackTrace();
			throw new RuntimeException(e);
		}
	}

	@SuppressWarnings({ "resource" })
	public long readOffsetFromExternalStore(String topic, int partition) {
		long ret = 0;
		try {

			String offset = redisClient.get(storageName(topic, partition));
			ret = StringUtils.isEmpty(offset)? 0: Long.parseLong(offset);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return ret;
	}

	private String storageName(String topic, int partition) {
		return "../position/"+storagePrefix + "_" + topic + "_" + partition;
	}

}

```


link:   
[Exactly-once Kafka Dynamic Consumer via Subscribe](https://dzone.com/articles/kafka-clients-at-most-once-at-least-once-exactly-o)

[ExactlyOncePersonConsumer](https://github.com/luyee/KafkaExample/blob/master/src/main/java/com/gmail/alexandrtalan/kafka/consumers/ExactlyOncePersonConsumer.java)
