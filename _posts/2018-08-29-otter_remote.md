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

服务注册与action绑定

```
//ConfigRemoteServiceImpl.java
public ConfigRemoteServiceImpl(){
    // 注册一下事件处理
    CommunicationRegistry.regist(ConfigEventType.findChannel, this);
    CommunicationRegistry.regist(ConfigEventType.findNode, this);
    CommunicationRegistry.regist(ConfigEventType.findTask, this);
    CommunicationRegistry.regist(ConfigEventType.findMedia, this);
}
//CanalRemoteServiceImpl.java
public CanalRemoteServiceImpl(){
    CommunicationRegistry.regist(CanalEventType.findCanal, this);
    CommunicationRegistry.regist(CanalEventType.findFilter, this);
}
```

CommunicationClient是客户端的接口，默认实现DefaultCommunicationClientImpl，DefaultCommunicationClientImpl内部才是调用的是CommunicationConnection的

canal服务的client实现

```
Canal canal = canalConfigClient.findCanal(destination);
//canalConfigClient.java
public Canal findCanal(String destination) {
FindCanalEvent event = new FindCanalEvent();
event.setDestination(destination);
try {
    Object obj = delegate.callManager(event);
    if (obj != null && obj instanceof Canal) {
        return (Canal) obj;
    } else {
        throw new CanalException("No Such Canal by [" + destination + "]");
    }
} catch (Exception e) {
    throw new CanalException("call_manager_error", e);
}
//CanalCommmunicationClient
public Object callManager(final Event event) {
    CommunicationException ex = null;
    Object object = null;
    for (int i = index; i < index + managerAddress.size(); i++) { // 循环一次manager的所有地址
        String address = managerAddress.get(i % managerAddress.size());
        try {
            object = delegate.call(address, event);
            index = i; // 更新一下上一次成功的地址
            return object;
        } catch (CommunicationException e) {
            // retry next address;
            ex = e;
        }
    }

    throw ex; // 走到这一步，说明肯定有出错了
}
//DefaultCommunicationClientImpl
public Object call(final String addr, final Event event) {
    Assert.notNull(this.factory, "No factory specified");
    CommunicationParam params = buildParams(addr);
    CommunicationConnection connection = null;
    int count = 0;
    Throwable ex = null;
    while (count++ < retry) {
        try {
            connection = factory.createConnection(params);
            return connection.call(event);
        } catch (Exception e) {
            logger.error(String.format("call[%s] , retry[%s]", addr, count), e);
            try {
                Thread.sleep(count * retryDelay);
            } catch (InterruptedException e1) {
                // ignore
            }
            ex = e;
        } finally {
            if (connection != null) {
                connection.close();
            }
        }
    }

    logger.error("call[{}] failed , event[{}]!", addr, event.toString());
    throw new CommunicationException("call[" + addr + "] , Event[" + event.toString() + "]", ex);
}
//DubboCommunicationConnection
public Object call(Event event) {
    // 调用rmi传递数据到目标server上
    return endpoint.acceptEvent(event);
}
//AbstractCommunicationEndpoint
public Object acceptEvent(Event event) {
    if (event instanceof HeartEvent) {
        return event; // 针对心跳请求，返回一个随意结果
    }

    try {
        Object action = CommunicationRegistry.getAction(event.getType());
        if (action != null) {

            // 通过反射获取方法并执行
            String methodName = "on" + StringUtils.capitalize(event.getType().toString());
            Method method = ReflectionUtils.findMethod(action.getClass(), methodName,
                                                       new Class[] { event.getClass() });
            if (method == null) {
                methodName = DEFAULT_METHOD; // 尝试一下默认方法
                method = ReflectionUtils.findMethod(action.getClass(), methodName, new Class[] { event.getClass() });

                if (method == null) { // 再尝试一下Event参数
                    method = ReflectionUtils.findMethod(action.getClass(), methodName, new Class[] { Event.class });
                }
            }
            // 方法不为空就调用指定的方法,反之调用缺省的处理函数
            if (method != null) {
                try {
                    ReflectionUtils.makeAccessible(method);
                    return method.invoke(action, new Object[] { event });
                } catch (Throwable e) {
                    throw new CommunicationException("method_invoke_error:" + methodName, e);
                }
            } else {
                throw new CommunicationException("no_method_error for["
                                                 + StringUtils.capitalize(event.getType().toString())
                                                 + "] in Class[" + action.getClass().getName() + "]");
            }

        }

        throw new CommunicationException("eventType_no_action", event.getType().name());
    } catch (RuntimeException e) {
        logger.error("endpoint_error", e);
        throw e;
    } catch (Exception e) {
        logger.error("endpoint_error", e);
        throw new CommunicationException(e);
    }
}
}
```

