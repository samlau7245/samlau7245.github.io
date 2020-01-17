---
title: Spring Security技术栈03-基于表单的登录
layout: post
description: Spring Security技术栈开发企业级认证与授权-使用Spring Security开发基于表单的登录
categories:
 - spring-security
---

# 使用`Spring Security`开发基于表单的登录

## 基本原理

在`imooc-security-browser` 浏览器安全代码包中创建Web适配器

```java
package com.imooc.security.browser;
@Configuration 
public class BrowserSecurityConfig extends WebSecurityConfigurerAdapter { //WebSecurityConfigurerAdapter是Web安全适配器
	@Override
	protected void configure(HttpSecurity http) throws Exception {
		http.formLogin() // formLogin表示表单登录
//		http.httpBasic() // Spring Security的默认认证登录方式
				.and().authorizeRequests() // 设置权限
				.anyRequest() // 任何请求
				.authenticated(); // 都需要鉴权
	}
}
```

### 过滤器链：

![项目结构](/assets/images/ss_tec/08.png)