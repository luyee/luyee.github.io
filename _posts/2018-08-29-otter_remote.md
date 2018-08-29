---
layout: post
title: " otter中的远程调用"
author: "Lu Yee"
date: 2018-08-29 15:03:32
categories: ["java"]
tags: ["java"]
description: >
  otter中的远程调用
---

### otter中的远程调用主要有rmi与dubbo

分别对应DubboCommunicationConnection与RmiCommunicationConnection，这两个都实现CommunicationConnection

```
public interface CommunicationConnection {

    public Object call(Event event);

    public CommunicationParam getParams();

    public void close() throws CommunicationException;
}
```
其创建和关闭都在中CommunicationConnectionFactory管理

```
public interface CommunicationConnectionFactory {

    CommunicationConnection createConnection(CommunicationParam params);

    void releaseConnection(CommunicationConnection connection);
}
```
DubboCommunicationConnectionFactory中能看到dubbo的相关代码

```
private final String                       DUBBO_SERVICE_URL = "dubbo://{0}:{1}/endpoint?client=netty&codec=dubbo&serialization=java&lazy=true&iothreads=4&threads=50&connections=30&acceptEvent.timeout=50000&payload={2}";

private DubboProtocol                      protocol          = DubboProtocol.getDubboProtocol();
private ProxyFactory                       proxyFactory      = ExtensionLoader.getExtensionLoader(ProxyFactory.class)
                                                               .getExtension("javassist");
public DubboCommunicationConnectionFactory(){
    connections = OtterMigrateMap.makeComputingMap(new Function<String, CommunicationEndpoint>() {

        public CommunicationEndpoint apply(String serviceUrl) {
            return proxyFactory.getProxy(protocol.refer(CommunicationEndpoint.class, URL.valueOf(serviceUrl)));
        }
    });
}

public CommunicationConnection createConnection(CommunicationParam params) {
    if (params == null) {
        throw new IllegalArgumentException("param is null!");
    }

    // 构造对应的url， String.valueOf() 为避免数字包含千位符
    String serviceUrl = MessageFormat.format(DUBBO_SERVICE_URL, params.getIp(), String.valueOf(params.getPort()), String.valueOf(payload));
    CommunicationEndpoint endpoint = connections.get(serviceUrl);
    return new DubboCommunicationConnection(params, endpoint);

}
```
