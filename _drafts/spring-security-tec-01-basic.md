---
title: Spring Security技术栈01-基础
layout: post
description: Spring Security技术栈开发企业级认证与授权
categories:
 - spring-security
---

## 前言

* 每一节课创建一个分支(branch)。
* [上每节课程之前先把代码拉下来预热](https://git.imooc.com/coding-134/security-new/branches)

## 环境安装

* JDK、[STS(Spring Tool Suite)](https://spring.io/tools3/sts/all)、MySql

## `Spring-Tool-Suite` 使用

### 快捷键

* `cmd+shift+f`: 格式化代码
* `Alt + /`: 代码自动提示

### 给项目添加子模块

> 例如：给`imooc-security`项目添加子模块:`imooc-security-core`、`imooc-security-borower`、`imooc-security-app`。

![项目结构](/assets/images/ss_tec/02.png)

**父模块`imooc-security`的`pom.xml`：**

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.imooc.security</groupId>
	<artifactId>imooc-security</artifactId>
	<version>1.0.0-SNAPSHOT</version>
	<packaging>pom</packaging>
	<!-- 添加了四个子模块 -->
	<modules>
		<module>../imooc-security-app</module>
		<module>../imooc-security-browser</module>
		<module>../imooc-security-core</module>
	</modules>
</project>
```

**子模块`imooc-security-core`的`pom.xml`：**

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<artifactId>imooc-security-core</artifactId>
	<!-- 关联了父模块 -->
	<parent>
		<groupId>com.imooc.security</groupId>
		<artifactId>imooc-security</artifactId>
		<version>1.0.0-SNAPSHOT</version>
		<relativePath>../imooc-security</relativePath>
	</parent>
</project>
```

`Create a Maven project` ->`[√]Create a simple project ` & [next >]

* `Group Id`:坐标，一般格式为：域[org(非营利)、com(商业组织)...].公司名.项目名
* `Artifact Id`:项目名
* `Version`:设置版本
* `Packaging`:包的形式 `pom` `jar` `war`

### 创建Class

* `New`->`Class`

![项目结构](/assets/images/ss_tec/03.png)

### 添加静态方法(全局变量)

`Preferences`->搜索：`Favorites`->`New Type...`->`Browse...`->例如：`MockMvcResultMatchers`->`Apply and Close`

## 搭建项目基础架构

### 代码结构

![项目结构](/assets/images/ss_tec/01.png)

* `imooc-security`：主项目，没有具体代码，作用就是把其他模块给统一起来让子模块统一的去执行Maven命令。
* `imooc-security-core`：核心代码。
* `imooc-security-borower`：浏览器安全代码。
* `imooc-security-app`：APP安全代码。
* `imooc-security-demo`：样例。

### `imooc-security` 管理模块

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<groupId>com.imooc.security</groupId>
	<artifactId>imooc-security</artifactId>
	<version>1.0.0-SNAPSHOT</version>
	<packaging>pom</packaging>

	<properties>
		<!-- 创建属性来控制项目版本号 -->
		<imooc.security.version>1.0.0-SNAPSHOT</imooc.security.version>
	</properties>

	<dependencyManagement>
		<dependencies>
			<dependency>
				<!-- 简单的可以认为是一个依赖维护平台，该平台将相关依赖汇聚到一起，针对每个依赖，都提供了一个版本号 -->
				<groupId>io.spring.platform</groupId>
				<artifactId>platform-bom</artifactId>
				<version>Brussels-SR4</version>
				<type>pom</type>
				<scope>import</scope>
			</dependency>
			<dependency>
				<!-- 依赖管理器,它对cloud的依赖管理 -->
				<groupId>org.springframework.cloud</groupId>
				<artifactId>spring-cloud-dependencies</artifactId>
				<version>Dalston.SR2</version>
				<type>pom</type>
				<scope>import</scope>
			</dependency>
		</dependencies>
	</dependencyManagement>

	<build>
		<plugins>
			<plugin>
				<!-- 项目编译插件 -->
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-compiler-plugin</artifactId>
				<version>2.3.2</version>
				<configuration>
					<source>1.8</source> <!-- 源代码使用的JDK版本 --> 
					<target>1.8</target> <!-- 需要生成的目标class文件的编译版本 -->
					<encoding>UTF-8</encoding> <!-- 字符集编码 -->
					<skipTests>true</skipTests><!-- 跳过测试 --> 
				</configuration>
			</plugin>
		</plugins>
	</build>

	<!-- 子模块 -->
	<modules>
		<module>../imooc-security-app</module>
		<module>../imooc-security-browser</module>
		<module>../imooc-security-core</module>
		<module>../imooc-security-demo</module>
	</modules>
</project>
```

### `imooc-security-core` 安全的核心代码模块

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<artifactId>imooc-security-core</artifactId>
	<!-- 父模块 -->
	<parent>
		<groupId>com.imooc.security</groupId>
		<artifactId>imooc-security</artifactId>
		<version>1.0.0-SNAPSHOT</version>
		<relativePath>../imooc-security</relativePath>
	</parent>

	<dependencies>
		<!-- OAuth2 鉴权 -->
		<dependency>
			<groupId>org.springframework.cloud</groupId>
			<artifactId>spring-cloud-starter-oauth2</artifactId>
		</dependency>

		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-data-redis</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-jdbc</artifactId>
		</dependency>
		<dependency>
			<groupId>mysql</groupId>
			<artifactId>mysql-connector-java</artifactId>
		</dependency>

		<!-- 第三方登录服务依赖 -->
		<dependency>
			<groupId>org.springframework.social</groupId>
			<artifactId>spring-social-config</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.social</groupId>
			<artifactId>spring-social-core</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.social</groupId>
			<artifactId>spring-social-security</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.social</groupId>
			<artifactId>spring-social-web</artifactId>
		</dependency>

		<!-- 工具 -->
		<dependency>
			<groupId>commons-lang</groupId>
			<artifactId>commons-lang</artifactId>
		</dependency>
		<dependency>
			<groupId>commons-collections</groupId>
			<artifactId>commons-collections</artifactId>
		</dependency>
		<dependency>
			<groupId>commons-beanutils</groupId>
			<artifactId>commons-beanutils</artifactId>
		</dependency>
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-configuration-processor</artifactId>
		</dependency>
	</dependencies>
</project>
```

### `imooc-security-app` APP安全代码模块

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<artifactId>imooc-security-app</artifactId>
	<!-- 父模块 -->
	<parent>
		<groupId>com.imooc.security</groupId>
		<artifactId>imooc-security</artifactId>
		<version>1.0.0-SNAPSHOT</version>
		<relativePath>../imooc-security</relativePath>
	</parent>

	<dependencies>
		<dependency>
			<groupId>com.imooc.security</groupId>
			<artifactId>imooc-security-core</artifactId>
			<!-- imooc.security.version 属性再imooc-security模块中已经定义-->
			<version>${imooc.security.version}</version>
		</dependency>
	</dependencies>
</project>
```

### `imooc-security-browser` 浏览器安全代码模块

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<artifactId>imooc-security-browser</artifactId>
	<parent>
		<groupId>com.imooc.security</groupId>
		<artifactId>imooc-security</artifactId>
		<version>1.0.0-SNAPSHOT</version>
		<relativePath>../imooc-security</relativePath>
	</parent>

	<dependencies>
		<dependency>
			<groupId>com.imooc.security</groupId>
			<artifactId>imooc-security-core</artifactId>
			<version>${imooc.security.version}</version>
		</dependency>
		<!-- 网页session服务 -->
		<dependency>
			<groupId>org.springframework.session</groupId>
			<artifactId>spring-session</artifactId>
		</dependency>
	</dependencies>
</project>
```

### `imooc-security-demo` 测试样例

在这个demo中先测试网页安全的功能，先依赖`imooc-security-browser`。

```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
	<modelVersion>4.0.0</modelVersion>
	<artifactId>imooc-security-demo</artifactId>
	<parent>
		<groupId>com.imooc.security</groupId>
		<artifactId>imooc-security</artifactId>
		<version>1.0.0-SNAPSHOT</version>
		<relativePath>../imooc-security</relativePath>
	</parent>

	<dependencies>
		<dependency>
			<groupId>com.imooc.security</groupId>
			<artifactId>imooc-security-browser</artifactId>
			<version>${imooc.security.version}</version>
		</dependency>
	</dependencies>
</project>
```

[**拉取代码**](https://gitee.com/BackEndLearning/ss_sts_example)

```sh
git clone -b section/2-2 https://gitee.com/BackEndLearning/ss_sts_example.git
```

## 启动项目

### 设置项目配置

在`imooc-security-demo`模块的路径`/src/main/resources/`下中创建`application.properties`配置文件。

```sh
# Mac 本地Terminal 连接SQL数据库：mysql -uroot -p12345678
spring.datasource.driver-class-name = com.mysql.jdbc.Driver
spring.datasource.url= jdbc:mysql://127.0.0.1:3306/imooc-demo?useUnicode=yes&characterEncoding=UTF-8&useSSL=false
spring.datasource.username = root
spring.datasource.password = 12345678
# 先关闭session集群，不然报错
spring.session.store-type = none
# 先关闭认证功能，让项目能跑起来
security.basic.enabled = false
# 设置项目运行的端口
server.port = 8060
```

### 创建项目入口

* 在`imooc-security-demo`模块的路径`/src/main/java/`中创建包：`com.imooc`；并且在包创建启动类`DemoApplication.java`。

```java
package com.imooc;
@SpringBootApplication
@RestController
public class DemoApplication {
	public static void main(String[] args) {
		SpringApplication.run(DemoApplication.class, args);
	}
	// demo 接口
	@GetMapping("/hello")
	public String hello() {
		return "hello spring security";
	}
}
```

* 访问地址：`http://127.0.0.1:8060/hello`

### 项目打包

在`imooc-security-demo`模块的`pom.xml`中新增用于打包的插件

```xml
<build>
	<plugins>
		<plugin>
			<!-- 项目打包插件 -->
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-maven-plugin</artifactId>
			<version>1.3.3.RELEASE</version>
			<executions>
				<execution>
					<goals>
						<goal>repackage</goal>
					</goals>
				</execution>
			</executions>
		</plugin>
	</plugins>
	<finalName>demo</finalName>
</build>
```

在`imooc-security`模块中执行：`Debug As`->`Maven build...`->`Goals:clean package` & `[√]Skip Test`。

```
├── pom.xml
└── src
    └── main
        ├── java
        │   └── com
        │       └── imooc
        │           └── DemoApplication.java
        └── resources
            └── application.properties
```

[**拉取代码**](https://gitee.com/BackEndLearning/ss_sts_example)

```sh
git clone -b section/2-3 https://gitee.com/BackEndLearning/ss_sts_example.git
```





















