---
layout: post
title: "Spring kafka Consumer"
author: "Lu Yee"
date: 2018-01-25 10:28:32
categories: ["kafka"]
tags: ["java","kafka"]
description: >
  Spring kafka
---

消费端示例代码，

```
BatchAcknowledgingMessageListener  batchAcknowledgingMessageListener =new BatchAcknowledgingMessageListener<String, String>() {

			@Override
			public void onMessage(List<ConsumerRecord<String, String>> data,
					Acknowledgment acknowledgment) {
				// TODO Auto-generated method stub
				acknowledgment.acknowledge();
			}
		};

        
    AcknowledgingMessageListener cknowledgingMessageListener = new AcknowledgingMessageListener<String, String>() {

  public void onMessage(ConsumerRecord<String, String> data) {
    // TODO Auto-generated method stub

  }

  public void onMessage(ConsumerRecord<String, String> data,
      Acknowledgment acknowledgment) {
    // TODO Auto-generated method stub
    acknowledgment.acknowledge();
  }

};

    MessageListener<String, String> messageListener = new MessageListener<String, String>() {

  @Override
  public void onMessage(ConsumerRecord<String, String> record) {
    record.value()
    
  }

};

  Map<String, Object> map = new HashMap<String, Object>();
  map.put(BOOTSTRAP_SERVERS_CONFIG, brokerAddress);
  map.put(GROUP_ID_CONFIG, "groupId");
  map.put(AUTO_OFFSET_RESET_CONFIG, "earliest");
  DefaultKafkaConsumerFactory factory = new DefaultKafkaConsumerFactory<>(map,new StringDeserializer(),new StringDeserializer())

  ContainerProperties containerProperties = new ContainerProperties(topic);
  containerProperties.setMessageListener(messageListener);

  ConcurrentMessageListenerContainer container =new ConcurrentMessageListenerContainer<>(factory,containerProperties);

  container.start();
  
```
这里写了几个MessageListener


MessageListenerContainer有两个，一个是ConcurrentMessageListenerContainer，另一个是KafkaMessageListenerContainer
一个是ConcurrentMessageListenerContainer内部其实也是启动多个KafkaMessageListenerContainer，   
KafkaMessageListenerContainer创建一个ListenerConsumer

```
this.listenerConsumer = new ListenerConsumer(this.listener, this.acknowledgingMessageListener);
setRunning(true);
this.listenerConsumerFuture = containerProperties
	.getConsumerTaskExecutor()
	.submitListenable(this.listenerConsumer);
```

ListenerConsumer包装了kafka的consumer,看poll()

```
version spring-kafka1.1.7
ConsumerRecords<K, V> records = this.consumer.poll(this.containerProperties.getPollTimeout());
if (records != null && this.logger.isDebugEnabled()) {
	this.logger.debug("Received: " + records.count() + " records");
}
if (records != null && records.count() > 0) {
	if (this.containerProperties.getIdleEventInterval() != null) {
		lastReceive = System.currentTimeMillis();
	}
	// if the container is set to auto-commit, then execute in the
	// same thread
	// otherwise send to the buffering queue
	if (this.autoCommit) {
		invokeListener(records);
	}
	else {
		if (sendToListener(records)) {
			if (this.assignedPartitions != null) {
				// avoid group management rebalance due to a slow
				// consumer
				this.consumer.pause(this.assignedPartitions);
				this.paused = true;
				this.unsent = records;
			}
		}
	}
}
private boolean sendToListener(final ConsumerRecords<K, V> records) throws InterruptedException {
	if (this.containerProperties.isPauseEnabled() && CollectionUtils.isEmpty(this.definedPartitions)) {
		return !this.recordsToProcess.offer(records, this.containerProperties.getPauseAfter(),
				TimeUnit.MILLISECONDS);
	}
	else {
		this.recordsToProcess.put(records);
		return false;
	}
}
```
1.1.7 如果是自动提交走invokeListener(),这个就调用上面的listener的onMessage()方法，如果不是自动提交，会首先提交给内部的一个阻塞队列recordsToProcess，

注意这里用了consumer.pause

