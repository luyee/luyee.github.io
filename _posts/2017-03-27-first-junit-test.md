---
layout: post
title: "First JUnit Test"
date: 2017-03-27 14:31:15
author: "Wei SHEN"
categories: ["junit","java","tools"]
tags: ["test"]
description: >
---

### 下载和安装
官网：http://junit.org/junit4/

下载：https://github.com/junit-team/junit4/wiki/Download-and-Install

Getting Started：https://github.com/junit-team/junit4/wiki/Getting-started

主要就两个包：
* junit.jar
* hamcrest-core.jar

库文件，按照惯例，放在`lib`文件夹下面，原先项目根目录`.`下`/src`存放`.java`源码，`/bin`存放`.class`文件。现在`/lib`存放库包。
```
.
├── bin
│   └── com
│       └── ciaoshen
│           └── leetcode
│               └── ThreeSum.class
├── src
│   └── com
│       └── ciaoshen
│           └── leetcode
│               └── ThreeSum.java
└── lib
    ├── hamcrest-core-1.3.jar
    └── junit-4.12.jar
```


### Test源码叫什么，放哪儿？
测试类也是一个`.java`文件，也会产生`.class`文件。业界的一个良好实践是：
> The way we do our JUnit test cases is to put them in the same package, but in a different root directory.

测试类取名可以在被测试类名后面加一个`Test`，就像下面这样，
```
src/main/java/com/foo/Bar.java
src/test/java/com/foo/BarTest.java
```

### 我的第一个JUnit测试用例
有一对最简单的java代码和对应的测试用例，分别是`ThreeSum.java`和`ThreeSumTest.java`。`ThreeSum.java`在`/src`路径下，`ThreeSumTest.java`在`/test`路径下。但对java编译器来说，他们处于同一个包`com.ciaoshen.leetcode`。编译后的两个`.class`文件，都在`/bin`路径下。
```bash
.
├── bin
│   └── com
│       └── ciaoshen
│           └── leetcode
│               ├── ThreeSum.class
│               └── ThreeSumTest.class // class文件可以放在一起
├── lib
│   ├── hamcrest-core-1.3.jar
│   └── junit-4.12.jar
├── src
│   └── com
│       └── ciaoshen
│           └── leetcode
│               └── ThreeSum.java // 被测试代码
└── test
    └── com
        └── ciaoshen
            └── leetcode
                └── ThreeSumTest.java // 单元测试代码
```

#### 代码
`ThreeSum.java`执行一个简单的加法。
```java
/**
 * Leetcode 3 Sum
 */
package com.ciaoshen.leetcode;
import java.util.*;

public class ThreeSum{
    public int threeSum(int a, int b, int c) {
        return a + b + c;
    }
}
```
`ThreeSumTest.java`测试`1+2+3`的结果是否等于`6`。
```java
/**
 * Unit Test of Three Sum Problem
 */
package com.ciaoshen.leetcode;
import static org.junit.Assert.assertEquals;
import org.junit.Test;
import java.util.*;

public class ThreeSumTest {
    @Test
    public void testThreeSum() {
        ThreeSum ts = new ThreeSum();
        int result = ts.threeSum(1,2,3);
        assertEquals(result,6);
    }
}
```

编译执行的`bash`文件如下：
```bash
BASE_DIR="/Users/Wei/JavaCode"
CLASS_PATH="$BASE_DIR/bin"
SOURCE_PATH="$BASE_DIR/src"
LIB_PATH="$BASE_DIR/lib"
TEST_PATH="$BASE_DIR/test"

# to use JUnit
JUNIT="$LIB_PATH/junit-4.12.jar"
HAMCREST="$LIB_PATH/hamcrest-core-1.3.jar"

# sub dir for each project
LEETCODE_PACK="com/ciaoshen/leetcode"
LEETCODE_SRC="$SOURCE_PATH/$LEETCODE_PACK"
LEETCODE_TEST="$TEST_PATH/$LEETCODE_PACK"

###################
#   leetcode
###################
# Compile the Source code and the Corresponding Unit Test Code
javac -d $CLASS_PATH -cp $CLASS_PATH:$JUNIT $LEETCODE_SRC/$1.java $LEETCODE_TEST/$1Test.java
java -cp $CLASS_PATH:$JUNIT:$HAMCREST org.junit.runner.JUnitCore com.ciaoshen.leetcode.$1Test
```

#### 结果
测试结果如下：
```bash
MacBook-Pro-de-Wei:JavaCode Wei$ sh run.sh ThreeSum
JUnit version 4.12
.
Time: 0,007

OK (1 test)
```

要让他出错，把源代码里的函数改一下，
```java
public int threeSum(int a, int b, int c) {
    return a + b + c + 1; // WRONG ANSWER
}
```

单元测试不通过，会抛出`AssertionError`，并指出得到的结果`7`和正确答案`6`不一致：
```bash
MacBook-Pro-de-Wei:JavaCode Wei$ sh run.sh ThreeSum
JUnit version 4.12
.E
Time: 0,011
There was 1 failure:
1) testThreeSum(com.ciaoshen.leetcode.ThreeSumTest)
java.lang.AssertionError: expected:<7> but was:<6>
	at org.junit.Assert.fail(Assert.java:88)
	at org.junit.Assert.failNotEquals(Assert.java:834)
	at org.junit.Assert.assertEquals(Assert.java:645)
	at org.junit.Assert.assertEquals(Assert.java:631)
	at com.ciaoshen.leetcode.ThreeSumTest.testThreeSum(ThreeSumTest.java:14)
	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
	at java.lang.reflect.Method.invoke(Method.java:497)
	at org.junit.runners.model.FrameworkMethod$1.runReflectiveCall(FrameworkMethod.java:50)
	at org.junit.internal.runners.model.ReflectiveCallable.run(ReflectiveCallable.java:12)
	at org.junit.runners.model.FrameworkMethod.invokeExplosively(FrameworkMethod.java:47)
	at org.junit.internal.runners.statements.InvokeMethod.evaluate(InvokeMethod.java:17)
	at org.junit.runners.ParentRunner.runLeaf(ParentRunner.java:325)
	at org.junit.runners.BlockJUnit4ClassRunner.runChild(BlockJUnit4ClassRunner.java:78)
	at org.junit.runners.BlockJUnit4ClassRunner.runChild(BlockJUnit4ClassRunner.java:57)
	at org.junit.runners.ParentRunner$3.run(ParentRunner.java:290)
	at org.junit.runners.ParentRunner$1.schedule(ParentRunner.java:71)
	at org.junit.runners.ParentRunner.runChildren(ParentRunner.java:288)
	at org.junit.runners.ParentRunner.access$000(ParentRunner.java:58)
	at org.junit.runners.ParentRunner$2.evaluate(ParentRunner.java:268)
	at org.junit.runners.ParentRunner.run(ParentRunner.java:363)
	at org.junit.runners.Suite.runChild(Suite.java:128)
	at org.junit.runners.Suite.runChild(Suite.java:27)
	at org.junit.runners.ParentRunner$3.run(ParentRunner.java:290)
	at org.junit.runners.ParentRunner$1.schedule(ParentRunner.java:71)
	at org.junit.runners.ParentRunner.runChildren(ParentRunner.java:288)
	at org.junit.runners.ParentRunner.access$000(ParentRunner.java:58)
	at org.junit.runners.ParentRunner$2.evaluate(ParentRunner.java:268)
	at org.junit.runners.ParentRunner.run(ParentRunner.java:363)
	at org.junit.runner.JUnitCore.run(JUnitCore.java:137)
	at org.junit.runner.JUnitCore.run(JUnitCore.java:115)
	at org.junit.runner.JUnitCore.runMain(JUnitCore.java:77)
	at org.junit.runner.JUnitCore.main(JUnitCore.java:36)

FAILURES!!!
Tests run: 1,  Failures: 1

```

### 什么是Hamcrest? 为什么JUnit需要它？
Hamcrest是一个`断言框架(Assertion Framework)`。但本质上讲，它就是一个`Matcher`，一个配合`assertThat()`函数使用的`Matcher`。

#### 什么是`assertThat()`？为什么要用`assertThat()`?
原生的Java断言如果想表达`result == 6`，会写成：
```java
assert result == 6;
```
我们刚才用的`assertEquals()`函数，把刚才的一个语句封装成一个“函数”。
```java
assertEquals(result,6);
```
但，这样的缺点是，实际工作中需要判断的情况比单纯比较是否相等复杂地多。比如说判断：是否我得到的List返回值中每一个元素都是以日期开头。这需要一个非常复杂的判断过程。**每一个判断都需要写成一个新函数，断言函数的数量就会爆炸**。

解决办法就是换成`assertThat()`。它的语法非常类似英语中的重句。
> I assert that balabalabala...

它的通用形式如下：
```java
assertThat([value], [matcher statement]);
```
要表达`result == 6`可以写成下面这样。这里`equalsTo()`函数就是`Matcher`。
```java
assertThat(result,equalsTo(6));
```
这样还看不出写成`assertThat()`的好处，但如果想表达`result != 6`，
```java
assertThat(result,not(equalsTo(6)));
```
是的！这就是`Matcher`最大的优势，
> **`Matcher`可以套嵌**。

利用`装饰器`的模式，借助`JUnit`和`Hamcrest`为我们准备的一系列小颗粒`Matcher`，我们可以组装出任何我们想要的判断条件。
```java
assertThat(responseString, either(containsString("color")).or(containsString("colour")));
```
上面这个例子，表达的是`responseString要么包含color，要么包含colour`。有了`Matcher`和`assertThat()`，装配断言的逻辑条件，简单地就和说话一样。

#### Hamcrest为我们设计了一组很实用的`Matcher`
这就是为什么`JUnit`需要`Hamcrest`。

#### 在线Doc链接
JUnit Matcher online Doc: <http://junit.org/junit4/javadoc/latest/org/junit/matchers/JUnitMatchers.html>

Hamcrest Matcher online Doc: <http://junit.org/junit4/javadoc/latest/org/hamcrest/CoreMatchers.html>

#### 参考文献
Hamcrest Wiki: <https://en.wikipedia.org/wiki/Hamcrest>

Another tutorial: <http://www.vogella.com/tutorials/Hamcrest/article.html>
