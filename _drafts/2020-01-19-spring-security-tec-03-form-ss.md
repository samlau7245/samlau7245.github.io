---
title: Spring Security技术栈03-基于表单的登录
layout: post
description: Spring Security技术栈开发企业级认证与授权-使用Spring Security开发基于表单的登录
categories:
 - spring-security
---

# 使用`Spring Security`开发基于表单的登录

## 基本原理

在`imooc-security-browser` 浏览器安全代码包中创建Web适配器。

```java
package com.imooc.security.browser;
@Configuration 
public class BrowserSecurityConfig extends WebSecurityConfigurerAdapter { //WebSecurityConfigurerAdapter是Web安全适配器
	@Override
	protected void configure(HttpSecurity http) throws Exception {
		http.formLogin() // formLogin表示表单登录
//		http.httpBasic() // Spring Security的默认认证登录方式
				.and().authorizeRequests() // 设置权限 -拦截
				.anyRequest() // 任何请求 -拦截
				.authenticated(); // 都需要鉴权 -拦截
	}
}
```

### 过滤器链

![项目结构](/assets/images/ss_tec/08.png)

![项目结构](/assets/images/ss_tec/07.png)

有点像切片的流程，最外层是`Filter`，等到所有的`Filter`执行完成后再次执行`Interceptor`。

### 获取代码

```
git clone -b section/4-2 https://gitee.com/BackEndLearning/ss_sts_example.git
```

# 自定义用户认证

在实际的开发中，用户的信息要存储在数据库中的。`Spring Security` 提供了一套用户认证的功能。

* `UserDetailsService`: 用于处理用户信息获取逻辑
* `UserDetails`: 处理用户的校验逻辑
* `UserDetails`: 处理用户密码的加密解密

```java
public interface UserDetailsService {
	UserDetails loadUserByUsername(String username) throws UsernameNotFoundException;
}
public interface UserDetails extends Serializable {
	Collection<? extends GrantedAuthority> getAuthorities(); // 权限信息
	String getPassword();
	String getUsername();
	boolean isAccountNonExpired();// ture用户没有过期
	boolean isAccountNonLocked();// false 账户被冻结-可以恢复
	boolean isCredentialsNonExpired(); // ture 密码过期了
	boolean isEnabled();// ture 账户被删掉-不可恢复
}
public interface PasswordEncoder {
	String encode(CharSequence rawPassword); // 用于加密
	boolean matches(CharSequence rawPassword, String encodedPassword); //比对密码是否匹配
}
```

## 处理用户校验逻辑

* 创建类`MyUserDetailsService`，继承自`UserDetailsService`

```java
@Component
public class MyUserDetailsService implements UserDetailsService {
	private Logger logger = LoggerFactory.getLogger(getClass());

	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		logger.info("登录用户名:" + username);

		// 这里返回的不一定是User，只要遵守UserDetails协议的对象就行，具体根据自己的需求
		return new User(username, "123456",AuthorityUtils.commaSeparatedStringToAuthorityList("admin"));// 多权限用逗号隔开
		//return new User(username, password, authorities)
		//return new User(username, password, enabled, accountNonExpired, credentialsNonExpired, accountNonLocked, authorities)
	}

}
```

因为`User`是继承了`UserDetails`，所以这里返回`User`对象，在开发自己的系统时不一定要使用`User`，只要遵守了`UserDetails`的类都可以使用。

```java
public class User implements UserDetails, CredentialsContainer {}
```

## 用户密码加密

* 要使用用户加解密的功能，需要配置`PasswordEncoder`的`Bean`。

```java
package com.imooc.security.browser;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;

@Configuration
public class BrowserSecurityConfig extends WebSecurityConfigurerAdapter {
	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder(); // 密码类型
	}
	@Override
	protected void configure(HttpSecurity http) throws Exception {
		http.formLogin().and().authorizeRequests().anyRequest().authenticated(); 
	}
}
```

* 在`MyUserDetailsService`中给用户密码加密

```java
@Component
public class MyUserDetailsService implements UserDetailsService {
	private Logger logger = LoggerFactory.getLogger(getClass());
	@Autowired
	private PasswordEncoder passwordEncoder;

	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		logger.info("登录用户名:" + username);
		String password = passwordEncoder.encode("123456"); // 密码加密
		logger.info("数据库密码是:" + password);
		return new User(username, password, AuthorityUtils.commaSeparatedStringToAuthorityList("admin"));// 多权限用逗号隔开
	}
}

// 输出
//登录用户名:user
//数据库密码是:$2a$10$/0HHPsdGlwK8bBgHxLCpyOK2U6BrJQTVHWhElO4QVJ2CfDW7Qu.QO
```

### 获取代码

```
git clone -b section/4-3 https://gitee.com/BackEndLearning/ss_sts_example.git
```

## 创建配置属性

![项目结构](/assets/images/ss_tec/01.png)

从项目结构上来看`imooc.security.browser`、`imooc.security.app`是功能模块，有些功能是可以放在`imooc.security.demo`项目中工人自定义的；我们创建一些自定义配置属性。我们在`imooc.security.core`中统一定义配置属性。

> 需求：`imooc.security.browser`中的登录页面支持用户自定义！

* 在`imooc.security.demo`的`application.properties`中配置自己的登录也路径。

```
imooc.security.browser.loginPage = /demo-signIn.html
```

* 创建`BrowserProperties`

```java
public class BrowserProperties {
	private String loginPage = "/imooc-signIn.html"; // 如果用没有配置就使用默认配置：/imooc-signIn.html
	public String getLoginPage() {
		return loginPage;
	}
	public void setLoginPage(String loginPage) {
		this.loginPage = loginPage;
	}
}
```

* 创建`SecurityProperties`

```java
//@ConfigurationProperties注解表明：SecurityProperties这个类会读取所有以imooc.security开头的配置项
@ConfigurationProperties(prefix = "imooc.security")
public class SecurityProperties {
	private BrowserProperties browser = new BrowserProperties();
	public BrowserProperties getBrowser() {
		return browser;
	}
	public void setBrowser(BrowserProperties browser) {
		this.browser = browser;
	}
}
```

* 创建`SecurityCoreConfig`，让`SecurityProperties`起效

```java
@Configuration
@EnableConfigurationProperties(SecurityProperties.class)
public class SecurityCoreConfig {
}
```

这几个类的整体模块的位置树：

```
.
├── imooc-security
├── imooc-security-app
├── imooc-security-browser
│   ├── pom.xml
│   └── src
│       └── main
│           ├── java
│           │   └── com
│           │       └── imooc
│           │           └── security
│           │               └── browser
│           │                   ├── BrowserSecurityConfig.java
│           │                   ├── BrowserSecurityController.java
│           │                   └── MyUserDetailsService.java
│           └── resources
│               └── resources
│                   └── imooc-signIn.html
├── imooc-security-core
│   ├── pom.xml
│   └── src
│       └── main
│           └── java
│               └── com
│                   └── imooc
│                       └── security
│                           └── core
│                               ├── SecurityCoreConfig.java
│                               └── properties
│                                   ├── BrowserProperties.java
│                                   └── SecurityProperties.java
└── imooc-security-demo
    ├── pom.xml
    └── src
        └── main
            ├── java
            └── resources
                ├── application.properties
                └── resources
                    └── demo-signIn.html
```

## 自定义登录页面

在`Spring Security`中提供了两种基础的登录方式样式：`formLogin`、`httpBasic`；接下来我们实现自定义的表单登录功能。

![项目结构](/assets/images/ss_tec/09.png)

整理一下结构图流程：

* 当我们接收到`HTML`请求或者数据请求的时候==> 也就是请求接口`/authentication/require`时候。

创建`BrowserSecurityController`，实现上面引发跳转的逻辑。

```java
@RestController
public class BrowserSecurityController {
	private Logger logger = LoggerFactory.getLogger(getClass());
	//  请求缓存
	private RequestCache requestCache = new HttpSessionRequestCache();
	// 做跳转的对象
	private RedirectStrategy redirectStrategy = new DefaultRedirectStrategy();
	@Autowired
	private SecurityProperties securityProperties; // 自定义的配置

	@RequestMapping("/authentication/require")
	@ResponseStatus(code = HttpStatus.UNAUTHORIZED) // 401, "Unauthorized"
	public SimpleResponse requireAuthentication(HttpServletRequest request, HttpServletResponse response)
			throws IOException {
		// 把参数缓存起来
		SavedRequest savedRequest = requestCache.getRequest(request, response);
		if (savedRequest != null) {
			String targetUrl = savedRequest.getRedirectUrl();
			logger.info("引发跳转的请求是:" + targetUrl);
			if (StringUtils.endsWithIgnoreCase(targetUrl, ".html")) {
				redirectStrategy.sendRedirect(request, response, securityProperties.getBrowser().getLoginPage());
			}
		}
		return new SimpleResponse("访问的服务需要身份认证，请引导用户到登录页");
	}
}
```

* 判断是否需要进行身份验证:从适配器`WebSecurityConfigurerAdapter`中判断是否需要进行身份验证。

```java
@Configuration
public class BrowserSecurityConfig extends WebSecurityConfigurerAdapter {
	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder(); // 密码类型
	}

	@Autowired
	private SecurityProperties securityProperties; // 自定义的配置

	@Override
	protected void configure(HttpSecurity http) throws Exception {
		http.formLogin()
				.loginPage("/authentication/require") //指定登录页面的URL
				.loginProcessingUrl("/authentication/form") // /authentication/form 提交登录请求的接口
				.and()
				.authorizeRequests()
				.antMatchers("/authentication/require", securityProperties.getBrowser().getLoginPage()).permitAll()
				.anyRequest().authenticated()
				.and()
				.csrf().disable(); //为了测试线吧跨站请求防护先取消。后面加上
	}
}
```

* 在具体项目`imooc-security-demo`的配置项`application.properties`中添加属性，用户自己定义了登录页面`demo-signIn.html`：

```
imooc.security.browser.loginPage = /demo-signIn.html
```


### 获取代码

```
git clone -b section/4-4 https://gitee.com/BackEndLearning/ss_sts_example.git
```

## 自定义成功、失败页面

当用户登录成功或者失败返回的结果是网页还是JSON可以通过配置去实现。

* 创建配置枚举`LoginType`

```java
public enum LoginType {
	REDIRECT, // 跳转
	JSON // 返回json
}

public class BrowserProperties {
	private String loginPage = "/imooc-signIn.html";
	private LoginType loginType = LoginType.JSON;
	
	public String getLoginPage() {
		return loginPage;
	}
	public void setLoginPage(String loginPage) {
		this.loginPage = loginPage;
	}
	public LoginType getLoginType() {
		return loginType;
	}
	public void setLoginType(LoginType loginType) {
		this.loginType = loginType;
	}
}
```

###  自定义成功页面

* 实现自定义登录成功页面

```java
@Component("imoocAuthenticationSuccessHandler")
public class ImoocAuthenticationSuccessHandler extends SavedRequestAwareAuthenticationSuccessHandler {
	private Logger logger = LoggerFactory.getLogger(getClass());

	@Autowired
	private ObjectMapper objectMapper; // 转JSON的工具类

	@Autowired
	private SecurityProperties securityProperties;

	@Override
	public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
			Authentication authentication) throws ServletException, IOException {
		logger.info("登录成功");
		// 配置登录的是JSON，用我们自己的处理，否则用父类方法
		if (LoginType.JSON.equals(securityProperties.getBrowser().getLoginType())) {
			response.setContentType("application/json;charset=UTF-8");
			response.getWriter().write(objectMapper.writeValueAsString(authentication));
		} else {
			super.onAuthenticationSuccess(request, response, authentication);
		}
	}
}
```

* 把自定义页面添加到适配器中

```java
@Configuration
public class BrowserSecurityConfig extends WebSecurityConfigurerAdapter {
	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder(); // 密码类型
	}
	@Autowired
	private SecurityProperties securityProperties;
	@Autowired
	private AuthenticationSuccessHandler imoocAuthenticationSuccessHandler;
	@Override
	protected void configure(HttpSecurity http) throws Exception {
		http.formLogin().loginPage("/authentication/require").loginProcessingUrl("/authentication/form")
				.successHandler(imoocAuthenticationSuccessHandler)
				.and().authorizeRequests()
				.antMatchers("/authentication/require", securityProperties.getBrowser().getLoginPage()).permitAll()
				.anyRequest().authenticated().and().csrf().disable();
	}
}
```

* 修改自定义配置

```
#imooc.security.browser.loginPage = /demo-signIn.html
imooc.security.browser.loginType = REDIRECT
```

### 自定义失败页面

* 实现自定义失败成功页面

```java
@Component("imoocAuthenctiationFailureHandler")
public class ImoocAuthenctiationFailureHandler extends SimpleUrlAuthenticationFailureHandler {
	private Logger logger = LoggerFactory.getLogger(getClass());

	@Autowired
	private ObjectMapper objectMapper;

	@Autowired
	private SecurityProperties securityProperties;

	@Override
	public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response,
			AuthenticationException exception) throws IOException, ServletException {
		logger.info("登录失败");
		if (LoginType.JSON.equals(securityProperties.getBrowser().getLoginType())) {
			response.setStatus(HttpStatus.INTERNAL_SERVER_ERROR.value());// code：500 服务器异常
			response.setContentType("application/json;charset=UTF-8");
			response.getWriter().write(objectMapper.writeValueAsString(exception));
		} else {
			super.onAuthenticationFailure(request, response, exception);
		}
	}
}
```

* 把自定义页面添加到适配器中

```java
@Configuration
public class BrowserSecurityConfig extends WebSecurityConfigurerAdapter {
	@Bean
	public PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder(); // 密码类型
	}

	@Autowired
	private SecurityProperties securityProperties;
	@Autowired
	private AuthenticationFailureHandler imoocAuthenticationFailureHandler;

	@Override
	protected void configure(HttpSecurity http) throws Exception {
		http.formLogin().loginPage("/authentication/require").loginProcessingUrl("/authentication/form")
				.failureHandler(imoocAuthenticationSuccessHandlercationFailureHandler)
				.and().authorizeRequests()
				.antMatchers("/authentication/require", securityProperties.getBrowser().getLoginPage()).permitAll()
				.anyRequest().authenticated().and().csrf().disable();
	}
}
```


### 获取代码

```
git clone -b section/4-5 https://gitee.com/BackEndLearning/ss_sts_example.git
```










































































































