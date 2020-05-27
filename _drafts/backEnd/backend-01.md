---
title: 后台学习(1)
layout: post
categories:
 - backEnd
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

### Maven聚合

* 聚合工程中顶级工程(`pom`)中的子工程在Maven中被称为模块(module)，模块之间是平级的；是可以相互依赖的。
* 子模块可以使用顶级工程中的所有资源。子模块之间如果需要使用资源，必须要构建依赖(`dependencies`)。
* 一个顶级工程是可以有多个不同的子工程组成。

<img src="/assets/images/backend/03.png"/>

```
示例工程的目录结构
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
└── pom.xml

// 工程层级
foodie-dev-common <- foodie-dev-mapper <- foodie-dev-pojo <- foodie-dev-service
```

不同工程的yml:

```yml
<!-- foodie-dev -->

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

<!-- foodie-dev-common -->

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

<!-- foodie-dev-common-pojo -->

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

<!-- foodie-dev-mapper -->

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

<!-- foodie-dev-service -->

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

<!-- foodie-dev-api -->

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

整体项目结构图，右侧是每个模块的依赖关系。

<img src="/assets/images/backend/02.png"/>

执行顶级工程的`install`，来安装每个模块的依赖，这样模块之间就可以使用资源了。

<img src="/assets/images/backend/04.png"/>

## 基础夯实站