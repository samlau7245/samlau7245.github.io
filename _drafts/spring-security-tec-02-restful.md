---
title: Spring Security技术栈02-RESTful API
layout: post
description: Spring Security技术栈开发企业级认证与授权-使用Spring MVC开发RESTful API
categories:
 - spring-security
---

## Restful API

### 使用测试用例

如果在项目中使用单元测试的功能，需要在`pom.xml`中先添加依赖：

```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-test</artifactId>
</dependency>
```

在类中实现：

```java
@RunWith(SpringRunner.class)
@SpringBootTest
public class UserControllerTest {
	@Test
	public void testfunc() {
		// test contents
	}
}
```

### 常用注解

* `@RestController`: 标明此`Controller`提供`RestfulAPI`。
* `@RequestMapping`
	* `@GetMapping`
	* `@PostMapping`
	* `@PutMapping`
	* `@DeleteMapping`
