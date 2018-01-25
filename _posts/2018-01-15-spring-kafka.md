---
layout: post
title: "Spring kafka Consumer"
author: "Lu Yee"
date: 2017-09-14 10:28:32
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
