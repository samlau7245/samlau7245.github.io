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

# 图形验证码

要实现一个高复用的图形验证码功能，就得实现一下三种方案：

* 验证码基本参数可配(验证码宽度、验证码高度、验证码字数长度、验证码过期时间(秒)....)
* 验证码拦截的接口可配。(通过配置来让指定接口实现验证码校验功能)
* 验证码的生成逻辑可配。(可以让使用者自己选择使用默认生成图形验证码还是自己实现图形验证码逻辑)

## 图形验证码基础参数配置模型、接口拦截

```java
// 默认配置
public class ImageCodeProperties {
	private int width = 67;
	private int height = 23;
	private int length = 4;
	private int expireIn = 60;
	private String url;//接口 xxx,yyyy,zzz
}

// 在中间加一层这个类是因为后面还有短信验证码，把验证码逻辑都统一到ValidateCodeProperties类里。
public class ValidateCodeProperties {
	private ImageCodeProperties image = new ImageCodeProperties();
}

@ConfigurationProperties(prefix = "imooc.security")
public class SecurityProperties {
	private ValidateCodeProperties code = new ValidateCodeProperties();
}
```

## 验证码的生成逻辑可配

<!-- ## 抽象验证码生成逻辑 -->

* 将图形验证码生成逻辑封装成一个接口

```java
public interface ValidateCodeGenerator {
	ImageCode generate(ServletWebRequest request);// ImageCode 是图形验证码工具类
}
// 定义一个工具类存放图形验证码信息：
public class ImageCode {
	private BufferedImage image;
	private String code;
	private LocalDateTime expireTime;
	//...其他逻辑，看示例
}
```

* 实现这个接口，实现一个默认生成图形二维码逻辑

```java
public class ImageCodeGenerator implements ValidateCodeGenerator{
	@Autowired
	private SecurityProperties securityProperties;
	
	@Override
	public ImageCode generate(ServletWebRequest request) {
		int width = ServletRequestUtils.getIntParameter(request.getRequest(), "width",
				securityProperties.getCode().getImage().getWidth());
		int height = ServletRequestUtils.getIntParameter(request.getRequest(), "height",
				securityProperties.getCode().getImage().getHeight());
		BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
		//...其他逻辑，看示例
		return new ImageCode(image, sRand, securityProperties.getCode().getImage().getExpireIn());
	}
	//...其他逻辑，看示例
}
```
* 把接口的实现设置成可配置，可以让别人定义自己的生成图形验证码逻辑。

```java
@Configuration
public class ValidateCodeBeanConfig {
	@Autowired
	private SecurityProperties securityProperties;
	
	@Bean
	@ConditionalOnMissingBean(name = "imageCodeGenerator")
	public ValidateCodeGenerator imageCodeGenerator() {
		ImageCodeGenerator codeGenerator = new ImageCodeGenerator(); 
		codeGenerator.setSecurityProperties(securityProperties);
		return codeGenerator;
	}
}
```

> `@ConditionalOnMissingBean(name = "imageCodeGenerator")`: 在系统启动时，`ConditionalOnMissingBean`会现在`Spring`容器中找一下是不是存在`name=imageCodeGenerator`的bean，如果能找到就不会触发`imageCodeGenerator`方法，如果找不到就执行`imageCodeGenerator`方法。


## 在项目中进行配置自定义基础参数

### 应用级配置:`imooc-security-demo`

在`application.properties`配置图形验证码基本参数:

```java
imooc.security.code.image.length = 6
imooc.security.code.image.width = 100
imooc.security.code.image.url = /user/*,/user
```
### 请求级配置

在请求的URL中去设置基本参数：`/code/image?width=200`

### 自定义图形验证码生成逻辑

```java
@Component("imageCodeGenerator")
public class DemoImageCodeGenerator implements ValidateCodeGenerator {
	@Override
	public ImageCode generate(ServletWebRequest request) {
		System.out.println("更高级的图形验证码生成代码");
		return null;
	}
}
```

## 创建图形验证码过滤器

要实现图形验证码过滤器功能，需要自己定一个`OncePerRequestFilter`过滤器，并且放在`UsernamePasswordAuthenticationFilter`前面。

![项目结构](/assets/images/ss_tec/08.png)

> `OncePerRequestFilter`: 实际上是一个实现了`Filter`接口的抽象类；它能够确保在一次请求中只通过一次`Filter`，而需要重复的执行。

* 创建`OncePerRequestFilter`类：

```java
public class ValidateCodeFilter extends OncePerRequestFilter implements InitializingBean {

	private Set<String> urls = new HashSet<>();
	private SecurityProperties securityProperties;// 这参数会在browser模块中进行赋值

	// 当配置的时候可能配置带有*的URLS，如: /user,/user/*
	private AntPathMatcher pathMatcher = new AntPathMatcher();

	private AuthenticationFailureHandler authenticationFailureHandler;
	
	private SessionStrategy sessionStrategy = new HttpSessionSessionStrategy();

	@Override
	public void afterPropertiesSet() throws ServletException {
		super.afterPropertiesSet();
		// 把需要进行图形验证的接口存放到urls数组中
		String[] configUrls = StringUtils
				.splitByWholeSeparatorPreserveAllTokens(securityProperties.getCode().getImage().getUrl(), ",");
		for (String configUrl : configUrls) {
			urls.add(configUrl);
		}
		urls.add("/authentication/form");
	}

	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
			throws ServletException, IOException {
		boolean action = false;
		for (String url : urls) {
			if (pathMatcher.match(url, request.getRequestURI())) { // 判断请求的URL是否和配置需要验证的URL匹配，则action=True
				action = true;
			}
		}
		if (action) {
			try {
				validate(new ServletWebRequest(request));
			} catch (ValidateCodeException e) {
				authenticationFailureHandler.onAuthenticationFailure(request, response, e);
				return;
			}
		}
		filterChain.doFilter(request, response);
	}
	//.... 其他代码看示例
}
```

> `InitializingBean`: 实现这个接口的方法`afterPropertiesSet()`,作用是：在其他参数都组装完毕后才回去执行这个方法，这里就是在其他参数准备好以后再去初始化`URL`的值。

* 在`Web`配置类中添加到`UsernamePasswordAuthenticationFilter`前面

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
	@Autowired
	private AuthenticationFailureHandler imoocAuthenticationFailureHandler;

	@Override
	protected void configure(HttpSecurity http) throws Exception {
		ValidateCodeFilter validateCodeFilter = new ValidateCodeFilter();
		validateCodeFilter.setAuthenticationFailureHandler(imoocAuthenticationFailureHandler);
		validateCodeFilter.setSecurityProperties(securityProperties);
		validateCodeFilter.afterPropertiesSet();

		http.addFilterBefore(validateCodeFilter, UsernamePasswordAuthenticationFilter.class).formLogin()
				.loginPage("/authentication/require").loginProcessingUrl("/authentication/form")
				.successHandler(imoocAuthenticationSuccessHandler).failureHandler(imoocAuthenticationFailureHandler)
				.and().authorizeRequests()
				.antMatchers("/authentication/require", securityProperties.getBrowser().getLoginPage(),"/code/image").permitAll()
				.anyRequest().authenticated().and().csrf().disable();
	}
}
```

## 实现图形验证码接口

图形验证码请求接口的实现要有以下几种步骤：

* 根据随机数生成图片
* 将随机数存到session中
* 将生成的图片写到接口的响应中

```java
@RestController
public class ValidateCodeController {
	public static final String SESSION_KEY = "SESSION_KEY_IMAGE_CODE";
	private SessionStrategy sessionStrategy = new HttpSessionSessionStrategy();
	@Autowired
	private ValidateCodeGenerator imageCodeGenerator; // 生成图形验证码的接口
	@GetMapping("/code/image")
	public void createCode(HttpServletRequest request, HttpServletResponse response) throws IOException {
		ImageCode imageCode = imageCodeGenerator.generate(new ServletWebRequest(request));//根据随机数生成图片
		sessionStrategy.setAttribute(new ServletWebRequest(request), SESSION_KEY, imageCode);//将随机数存到session中
		ImageIO.write(imageCode.getImage(), "JPEG", response.getOutputStream());//将生成的图片写到接口的响应中
	}
}
```

## 获取代码

```
git clone -b section/4-7_4-8 https://gitee.com/BackEndLearning/ss_sts_example.git
```

# 记住我功能

## 记住我功能的基本原理

* 记住我过滤器`RememberMeAuthenticationFilter`在整个过滤链中的位置：这个过滤器是放在所有过滤器(绿色部分)倒数第二个位置，就是在所有过滤器不通过的情况下尝试用记住我过滤器看是否通过认证：

![项目结构](/assets/images/ss_tec/10.png)

![项目结构](/assets/images/ss_tec/11.png)


> 1. 浏览器 –认证请求–> UsernamePasswordAuthenticationFilter –> 认证成功以后RememberMeService 会将Token写到DB中，同时将Token写到浏览器Cookie中。 <br>
> 2. 浏览器再次登录时，直接走RememberMeAuthenticationFilter过滤器不用走登录过滤器逻辑 RememberMeAuthenticationFilter会读取Cookie中的Token,然后把Token交给RememberMeService RememberMeService中的TokenRepository会去DB中查找有没有Token，如果有的话就把用户名和密码返回。

## 实现记住我功能

* 网页中创建记住我功能：

```html
<input name="remember-me" type="checkbox" value="true" />
```

* 记住我是长参数设置为可配置：

```java
public class BrowserProperties {
	private String loginPage = "/imooc-signIn.html";
	private LoginType loginType = LoginType.JSON;
	private int rememberMeSeconds = 3600; // 设置默认记住我时长
}
```

* 在`WebSecurityConfigurerAdapter`网页适配器中配置`TokenRepository`：

```java
@Configuration
public class BrowserSecurityConfig extends WebSecurityConfigurerAdapter {
	@Bean
	public PersistentTokenRepository persistentTokenRepository() {
		JdbcTokenRepositoryImpl tokenRepository = new JdbcTokenRepositoryImpl();
		tokenRepository.setCreateTableOnStartup(true); // 创建DB
		return tokenRepository;
	}
}
```

在我们执行`tokenRepository.setCreateTableOnStartup(true);`时等价于执行下面的SQL语句：

```sql
create table persistent_logins (username varchar(64) not null, series varchar(64) primary key,token varchar(64) not null, last_used timestamp not null)
```

* 在`WebSecurityConfigurerAdapter`网页适配器中配置记住我过滤器：

```java
@Configuration
public class BrowserSecurityConfig extends WebSecurityConfigurerAdapter {
	@Autowired
	private SecurityProperties securityProperties;
	@Autowired
	private UserDetailsService userDetailsService
	@Override
	protected void configure(HttpSecurity http) throws Exception {
		http.formLogin().and()
				.rememberMe().tokenRepository(persistentTokenRepository()) // 返回一个JDBC实现
				.tokenValiditySeconds(securityProperties.getBrowser().getRememberMeSeconds()) // 设置token有效时间
				.userDetailsService(userDetailsService);// 用户信息
	}
}
```


![项目结构](/assets/images/ss_tec/12.png)

































































































