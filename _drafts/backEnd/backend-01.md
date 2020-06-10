---
title: 后台学习(1)
layout: post
categories:
 - back_end
---

## 单体架构设计与准备工作

### 前端技术选型

* SpringMVC : 是框架，配置(XML)。
* SpringBoot : 是工具，配置(yml)，引用很多中间件，外置tomcat变为内置tomvat。

### 技术选型考虑

* 切合业务。
* 社区活跃度。
* 团队技术水平。
* 版本更新迭代周期。
* 试错精神。多去体验新技术方案-不一定是在项目中，可以自己学习。
* 安全性。
* 成功案例。
* 开源案例。考虑框架是否会被收费。

### 前后端分离

<img src="/assets/images/backend/01.png"/> <!--  width = "25%" height = "25%" -->

### Maven创建聚合项目

* 聚合工程中顶级工程(`pom`)中的子工程在Maven中被称为模块(module)，模块之间是平级的；是可以相互依赖的。
* 子模块可以使用顶级工程中的所有资源。子模块之间如果需要使用资源，必须要构建依赖(`dependencies`)。
* 一个顶级工程是可以有多个不同的子工程组成。

#### 创建Maven项目

通过Maven创建一个聚合项目，整体的项目结构：

```
foodie-dev -> 顶级pom工程
├── foodie-dev-api -> Module 对外提供接口的模块
│   └── pom.xml
├── foodie-dev-common -> Module 公共模块
│   └── pom.xml
├── foodie-dev-mapper -> Module：这里是数据层，对应生成一些接口，这些接口和mapper.xml是映射关系；又一个mapper.xml就有一个mapper的类。mapper.xml里面方法就是查询数据库有关的语句
│   └── pom.xml
├── foodie-dev-pojo -> Module:这是是放所有的实体类
│   └── pom.xml
├── foodie-dev-service -> Module
│   └── pom.xml
└── pom.xml

// 工程层级
foodie-dev-common <- foodie-dev-mapper <- foodie-dev-pojo <- foodie-dev-service
```

使用IntelliJ IDEA 创建这个Maven项目的步骤：

<img src="/assets/images/backend/03.png"/>

#### foodie-dev 的pom结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.imooc</groupId>
    <artifactId>foodie-dev</artifactId>
    <version>1.0-SNAPSHOT</version>
    <modules>
        <module>foodie-dev-common</module>
        <module>foodie-dev-pojo</module>
        <module>foodie-dev-mapper</module>
        <module>foodie-dev-service</module>
        <module>foodie-dev-api</module>
    </modules>
    <packaging>pom</packaging>
</project>
```

#### foodie-dev-common 的pom结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>foodie-dev</artifactId>
        <groupId>com.imooc</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>foodie-dev-common</artifactId>
</project>
```

#### foodie-dev-mapper 的pom结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>foodie-dev</artifactId>
        <groupId>com.imooc</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>foodie-dev-mapper</artifactId>

    <dependencies>
        <dependency>
            <groupId>com.imooc</groupId>
            <artifactId>foodie-dev-pojo</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>
    </dependencies>
</project>
```

#### foodie-dev-pojo 的pom结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>foodie-dev</artifactId>
        <groupId>com.imooc</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>foodie-dev-pojo</artifactId>

    <dependencies>
        <dependency>
            <groupId>com.imooc</groupId>
            <artifactId>foodie-dev-common</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>
    </dependencies>
</project>
```

#### foodie-dev-api 的pom结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>foodie-dev</artifactId>
        <groupId>com.imooc</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>foodie-dev-api</artifactId>

    <dependencies>
        <dependency>
            <groupId>com.imooc</groupId>
            <artifactId>foodie-dev-service</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>
    </dependencies>
</project>
```

#### foodie-dev-service 的pom结构

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <parent>
        <artifactId>foodie-dev</artifactId>
        <groupId>com.imooc</groupId>
        <version>1.0-SNAPSHOT</version>
    </parent>
    <modelVersion>4.0.0</modelVersion>

    <artifactId>foodie-dev-service</artifactId>

    <dependencies>
        <dependency>
            <groupId>com.imooc</groupId>
            <artifactId>foodie-dev-mapper</artifactId>
            <version>1.0-SNAPSHOT</version>
        </dependency>
    </dependencies>
</project>
```

整体项目结构图，右侧是每个模块的依赖关系。

<img src="/assets/images/backend/02.png"/>

#### 安装依赖

执行顶级工程的`install`，来安装每个模块的依赖，这样模块之间就可以使用资源了。

<img src="/assets/images/backend/04.png"/>

#### 创建启动项目程序

在`foodie-dev-api`模块创建(因为`foodie-dev-api`是最低层的模块): 

* `Application.java`: 用于启动。
* `application.yml`: 用于写配置文件。

```
foodie-dev
├── foodie-dev-api
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── com
│           │       └── imooc
│           │           └── Application.java
│           └── resources
│               └── application.yml
├── foodie-dev-common
│   └── pom.xml
├── foodie-dev-mapper
│   └── pom.xml
├── foodie-dev-pojo
│   └── pom.xml
├── foodie-dev-service
│   └── pom.xml
└── pom.xml
```

`Application.java`中的代码：

```java
package com.imooc;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class Application {
    public static void main(String[] args) {
        SpringApplication.run(Application.class,args);
    }
}
```

这样就可以Run项目了。

### 整合SpringBoot

```
foodie-dev -> 顶级工程
├── foodie-dev-api -> Module
│   └── pom.xml
├── foodie-dev-common -> Module
│   └── pom.xml
├── foodie-dev-mapper -> Module
│   └── pom.xml
├── foodie-dev-pojo -> Module
│   └── pom.xml
├── foodie-dev-service -> Module
│   └── pom.xml
└── pom.xml <--- 以上配置写在这里
```

给Maven项目添加基础依赖：在`foodie-dev`空壳项目中的`pom.xml`中添加下面配置：

#### 添加parent

> `spring-boot-starter-parent` 是一个特殊的`starter`，它用来提供相关的Maven默认依赖。使用它之后，常用的包依赖可以省去`version`标签。

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.1.5.RELEASE</version>
    <relativePath />
</parent>
```

#### 设置资源属性

```xml
<properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
    <java.version>1.8</java.version>
</properties>
```

#### 添加dependency依赖

* `spring-boot-starter` : 使用SpringBoot来搭建项目时，使用这个Maven依赖可以免去各种配置。
* `spring-boot-starter-logging` : 记录日志。
* `spring-boot-starter-web` : 这是SpringBoot为我们提供的Web快速开发的应用。
* `spring-boot-configuration-processor` :Spring默认使用yml中的配置，但有时候要用传统的xml或properties配置，这个依赖就是解决这个的。

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter</artifactId>
        <!-- exclusions：排除使用 spring-boot-starter-logging -->
        <exclusions>
            <exclusion>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-logging</artifactId>
            </exclusion>
        </exclusions>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-configuration-processor</artifactId>
        <optional>true</optional>
    </dependency>
</dependencies>
```

* [SpringBoot自动装配原理讲解](https://class.imooc.com/lesson/1222#mid=28456)
* [远程Maven库](https://mvnrepository.com)

### 使用PDMan进行数据库建模

* `utf8mb4`: 可以支持表情。
* 每次数据库迭代基本就是对数据库的数据表进行修改，就是一种`增量迭代`。

数据库外键移除原因：

* 性能影响。(特别是分布式数据库，在检查数据库的时候)
* 热更新。
* 降低耦合度。(降低物理耦合，通过逻辑去控制)
* 数据库分库分表。

### 使用HikariCP作为数据源

[HiKariCP](https://github.com/brettwooldridge/HikariCP)是数据库连接池的一个后起之秀，号称性能最好，可以完美地PK掉其他连接池。

下面是HiKariCP的远程仓库依赖，但是如果是SpringBoot项目就不用开发者添加了，HiKariCP已经被默认添加到SpringBoot中了。

```xml
<dependency>
    <groupId>com.zaxxer</groupId>
    <artifactId>HikariCP</artifactId>
    <version>3.4.5</version>
</dependency>
```

### MyBatis整合HiKariCP

`MyBatis`是一款优秀的持久层框架，它支持定制化 SQL、存储过程以及高级映射。

#### pom项目引入MyBatis依赖

```xml
<!-- mysql驱动 -->
<dependency>
	<groupId>mysql</groupId>
	<artifactId>mysql-connector-java</artifactId>
	<version>5.1.41</version>
</dependency>
<!-- mybatis -->
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>2.1.0</version>
</dependency>
```

#### 配置MyBatis参数

在`foodie-dev-api`模块的`application.yml`配置文件中添加MyBatis参数：

```
foodie-dev-api
├── pom.xml
└── src
    └── main
        ├── java
        │   └── com
        │       └── imooc
        │           └── Application.java
        └── resources
            └── application.yml
```

```yml
############################################################
#
# 配置数据源信息
#
############################################################
spring:
  datasource:                                           # 数据源的相关配置
      type: com.zaxxer.hikari.HikariDataSource          # 数据源类型：HikariCP
      driver-class-name: com.mysql.jdbc.Driver          # mysql驱动
      url: jdbc:mysql://localhost:3306/foodie-shop-dev?useUnicode=true&characterEncoding=UTF-8&autoReconnect=true
      username: root
      password: root
    hikari:
      connection-timeout: 30000       # 等待连接池分配连接的最大时长（毫秒），超过这个时长还没可用的连接则发生SQLException， 默认:30秒
      minimum-idle: 5                 # 最小连接数
      maximum-pool-size: 20           # 最大连接数
      auto-commit: true               # 自动提交
      idle-timeout: 600000            # 连接超时的最大时长（毫秒），超时则被释放（retired），默认:10分钟
      pool-name: DateSourceHikariCP     # 连接池名字
      max-lifetime: 1800000           # 连接的生命时长（毫秒），超时而且没被使用则被释放（retired），默认:30分钟 1800000ms
      connection-test-query: SELECT 1
          
############################################################
#
# mybatis 配置
#
############################################################
mybatis:
  type-aliases-package: com.imooc.pojo          # 所有POJO类所在包路径
  mapper-locations: classpath:mapper/*.xml      # mapper映射文件
```

* 创建`com.imooc.pojo`包。
* 在`foodie-dev-mapper`模块中的`java`文件夹中创建包`com.imooc.mapper`,在`resources`中创建`mapper`文件夹存放xml映射文件。

```
foodie-dev
├── foodie-dev-api
├── foodie-dev-common
├── foodie-dev-mapper
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── com
│           │       └── imooc
│           │           └── mapper --> 这里存放所有mapper实体类
│           └── resources
│               └── mapper -> 这里存放所有mapper映射文件
├── foodie-dev-pojo
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── com
│           │       └── imooc
│           │           └── pojo --> 这里存放所有实体类
│           └── resources
├── foodie-dev-service
└── pom.xml

```

#### 配置内置Tomcat

```yml
############################################################
#
# web访问端口号  约定：8088
#
############################################################
server:
  port: 8088
  tomcat:
    uri-encoding: UTF-8
  max-http-header-size: 80KB
```

### MyBatis逆向生成工具

<img src="/assets/images/backend/09.png"/> <!--  width = "25%" height = "25%" -->

工具的配置文件：

<img src="/assets/images/backend/10.png"/> <!--  width = "25%" height = "25%" -->

生成工具生成的文件：

<img src="/assets/images/backend/11.png"/> <!--  width = "25%" height = "25%" -->

#### 使用逆向出来的文件

* pom添加依赖：

```xml
<!-- 通用mapper逆向工具 -->
<dependency>
    <groupId>tk.mybatis</groupId>
    <artifactId>mapper-spring-boot-starter</artifactId>
    <version>2.1.5</version>
</dependency>
```

* 添加yml配置

```yml
############################################################
#
# mybatis mapper 配置
#
############################################################
# 通用 Mapper 配置
mapper:
  mappers: com.imooc.my.mapper.MyMapper
  not-empty: false
  identity: MYSQL
```

* 添加生成的文件

```
foodie-dev
├── foodie-dev-api
│   └── src
│       └── main
│           ├── java
│           │   └── com
│           │       └── imooc
│           │           ├── Application.java
│           │           └── controller
│           │               └── StuFooController.java
│           └── resources
│               └── application.yml
├── foodie-dev-common
├── foodie-dev-mapper
│   └── src
│       └── main
│           ├── java
│           │   └── com
│           │       └── imooc
│           │           ├── mapper
│           │           │   └── StuMapper.java
│           │           └── my
│           │               └── mapper
│           │                   └── MyMapper.java --> Mapper实体类
│           └── resources
│               └── mapper
│                   └── StuMapper.xml --> Mapper映射文件
├── foodie-dev-pojo
│   └── src
│       └── main
│           ├── java
│           │   └── com
│           │       └── imooc
│           │           └── pojo
│           │               └── Stu.java --> pojo实体类
│           └── resources
└── foodie-dev-service
    └── src
        └── main
            ├── java
            │   └── com
            │       └── imooc
            │           └── service
            │               ├── StuService.java
            │               └── impl
            │                   └── StuServiceImpl.java
            └── resources
```

可以看到在`StuServiceImpl`中，出现一个警告。

<img src="/assets/images/backend/12.png"/>

###  事务

* `REQUIRED` : 使用当前的事务，如果当前没有事务，则自己新建一个事务，子方法是必须运行在一个事务中的；
          如果当前存在事务，则加入这个事务，成为一个整体。
          举例：领导没饭吃，我有钱，我会自己买了自己吃；领导有的吃，会分给你一起吃。
* `SUPPORTS`: 如果当前有事务，则使用事务；如果当前没有事务，则不使用事务。
          举例：领导没饭吃，我也没饭吃；领导有饭吃，我也有饭吃。
* `MANDATORY`: 该传播属性强制必须存在一个事务，如果不存在，则抛出异常
           举例：领导必须管饭，不管饭没饭吃，我就不乐意了，就不干了（抛出异常）
* `REQUIRES_NEW`: 如果当前有事务，则挂起该事务，并且自己创建一个新的事务给自己使用；
              如果当前没有事务，则同 REQUIRED
              举例：领导有饭吃，我偏不要，我自己买了自己吃
* `NOT_SUPPORTED`: 如果当前有事务，则把事务挂起，自己不适用事务去运行数据库操作
               举例：领导有饭吃，分一点给你，我太忙了，放一边，我不吃
* `NEVER`: 如果当前有事务存在，则抛出异常
       举例：领导有饭给你吃，我不想吃，我热爱工作，我抛出异常
* `NESTED`: 如果当前有事务，则开启子事务（嵌套事务），嵌套事务是独立提交或者回滚；
        如果当前没有事务，则同 REQUIRED。
        但是如果主事务提交，则会携带子事务一起提交。
        如果主事务回滚，则子事务会一起回滚。相反，子事务异常，则父事务可以回滚或不回滚。
        举例：领导决策不对，老板怪罪，领导带着小弟一同受罪。小弟出了差错，领导可以推卸责任。

<!-- 第3章 【基础夯实站】 -->
<!-- 第4章 用户登录注册模块开发 -->
<!-- 第5章 【加餐站】 -->
<!-- 第6章 【福利站】 -->

## 资料

* [Spring Boot](http://c.biancheng.net/view/4641.html)
* [打开拷贝的项目报错解决方案](https://blog.csdn.net/lk142500/article/details/81949740)


有时候我们为了保证项目结构，所以要上传空的文件夹到git ， 这时候只需要在git 根目录下执行
`find . -type d -empty -exec touch {}/.gitignore \;`