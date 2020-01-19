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

#### 映射请求参数：`@RequestParam`

```java
@RestController 
@RequestMapping("/user")
public class UserController {
	@GetMapping("/a")
	public void testfunc1(@RequestParam String name) {}
	@GetMapping("/b")
	public void testfunc2(@RequestParam(value = "name",required = false,defaultValue = "1") String name) {}
}
```

#### 映射请求参数：`数据模型`

```java
@GetMapping("/d")
public void testfunc4(UserQueryCondition condition) {
}

// 请求参数模型类
public class UserQueryCondition {
	private String username;
	private int age;
	private int ageTo;
	private String xxx;
}
```

#### 映射请求参数：`@RequestBody` [就是请求体]

```java
@RestController
@RequestMapping("/user")
public class UserController {
	@PostMapping // POST请求
	public User testfunc9(@RequestBody User user) {
		return user;
	}
}
```


#### 映射请求参数：`@PathVariable`

```java
@GetMapping("/e/{id}")
public void testfunc5(@PathVariable String id) {
}
```

#### 在URL中使用正则表达式

```java
// 这个正则表达式意思为：URL参数id限制只能是整数
@GetMapping("/f/{id:\\d+}")
public void testfunc6(@PathVariable String id) {
}
```

#### `@PageableDefault` 分页

```java
public @interface PageableDefault {
	int value() default 10;
	int size() default 10;
	int page() default 0;
	String[] sort() default {};
	Direction direction() default Direction.ASC;
}
```

示例：

```java
@GetMapping("/c")
public void testfunc3(@PageableDefault(page = 2, size = 17, sort = "username,asc") Pageable pageable) {
	System.out.println(pageable.getPageSize());
	System.out.println(pageable.getPageNumber());
	System.out.println(pageable.getSort());
}
```

#### `@JsonView` 控制JSON输出内容

`@JsonView`的使用步骤：

* 在模型中，使用接口来声明多个视图
* 在模型字段的get方法上指定视图
* 在`Controller`方法上指定视图

> 示例：用户模型`User`，在接口`/user/jv1`中不能展示`password`字段，在接口`/user/jv2`中能展示`password`字段

设计数据模型：

```java
public class User {
	public interface UserSimpleView {
	}; // 用户简单视图

	public interface UserDetailView extends UserSimpleView {
	}; // 用户复杂视图

	private String id;
	private String username;
	private String password;
	private Date birthday;

	@JsonView(UserSimpleView.class)
	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	@JsonView(UserSimpleView.class) // password 字段会在复杂视图、简单视图上展示
	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	@JsonView(UserDetailView.class) // password 字段只会在复杂视图上展示，
	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	@JsonView(UserSimpleView.class)
	public Date getBirthday() {
		return birthday;
	}

	public void setBirthday(Date birthday) {
		this.birthday = birthday;
	}
}
```

设计接口请求：

```java
@RestController
@RequestMapping("/user")
public class UserController {
	@GetMapping("/jv1")
	@JsonView(User.UserSimpleView.class)
	public User testfunc7(@PathVariable String id) {
		User user = new User();
		user.setUsername("tom");
		return user;
	}
	
	@GetMapping("/jv2")
	@JsonView(User.UserDetailView.class)
	public User testfunc8(@PathVariable String id) {
		User user = new User();
		user.setUsername("tom");
		return user;
	}
}
```

#### 日期类型的数据处理

* 使用`Date`->`import java.util.Date;`
* 使用时间戳

#### 使用`@Valid`和`BindingResult`校验数据

```java
@RestController 
@RequestMapping("/user")
public class UserController {
	@PostMapping // POST请求
	public User testfunc10(@Valid @RequestBody User user, BindingResult errors) {
		if (errors.hasErrors()) {
			errors.getAllErrors().stream().forEach(error -> System.out.println(error.getDefaultMessage()));
		}
		user.setId("1");
		return user;
	}
}
```

### 验证注解

#### 常用验证注解

![项目结构](/assets/images/ss_tec/04.png)

![项目结构](/assets/images/ss_tec/05.png)

示例：

```java
public class User {
	private String username;
	@NotBlank(message = "密码不能为空")

	private String password;
	@Past(message = "生日必须是过去的时间")
	private Date birthday;
}
```

#### 自定验证注解

* 自定义验证注解接口`MyConstraint`

```java
@Target({ ElementType.METHOD, ElementType.FIELD }) // 可以标注的地方
@Retention(RetentionPolicy.RUNTIME) // 运行时的注解
@Constraint(validatedBy = MyConstraintValidator.class) // 标明当前 MyConstraint 注解使用MyConstraintValidator类去校验
public @interface MyConstraint {
	String message(); // 注解必须实现的方法

	Class<?>[] groups() default {}; // 注解必须实现的方法

	Class<? extends Payload>[] payload() default {}; // 注解必须实现的方法
}
```

* 验证注解实现的类`MyConstraintValidator`

```java
// ConstraintValidator<T1,T2>:T1 表示需要验证的注解，T2:验证的东西的类型【如果标注在String类型上，就写String】
public class MyConstraintValidator implements ConstraintValidator<MyConstraint, Object> {
	@Override
	public void initialize(MyConstraint constraintAnnotation) { // 初始化
		System.out.println("my validator init");
	}

	@Override
	public boolean isValid(Object value, ConstraintValidatorContext context) {
		System.out.println(value);
		return false;// true 校验成功。false校验失败。
	}
}
```

* 使用自定义校验注解

```java
public class User {
	@MyConstraint(message = "这是一个测试")
	private String username;
}
```

#### 获取代码

```
git clone -b section/2-3_3-5 https://gitee.com/BackEndLearning/ss_sts_example.git
```

## 错误处理

### 系统默认的异常处理

在请求接口报错的情况下系统类`BasicErrorController`会进行异常处理。

```java
@Controller
@RequestMapping("${server.error.path:${error.path:/error}}")
public class BasicErrorController extends AbstractErrorController{
}
```

网页请求一个异常接口，返回为网页，客户端请求个异常接口，返回为JSON数据；这是因为`BasicErrorController`中会按照`URL`请求头去区分是网页请求还是客户端请求。

```java
@RequestMapping(produces = "text/html")
public ModelAndView errorHtml(HttpServletRequest request,HttpServletResponse response) {}

@RequestMapping
@ResponseBody
public ResponseEntity<Map<String, Object>> error(HttpServletRequest request) {}
```

### 用户自定义的异常处理

#### 针对网页的自定义异常处理

网页的异常处理是根据请求的状态码来的。

```
└── src
    └── main
        └── resources
            ├── application.properties
            └── resources
                └── error
                    ├── 404.html
                    └── 500.html
```

例如在`404.html`中编辑错误页面，那么请求异常接口的状态码为404的话就会展示`404.html`界面。

```html
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>404</title>
</head>
<body>
	您所访问的页面不存在
</body>
</html>
```

#### 针对客户端的自定义异常处理

> 需求：客户端请求了一个异常接口，返回体为JSON结构并且把业务字段`id`也下发到客户端。

整体的代码结构：

```
├── pom.xml
└── src
    └── main
        └── java
            └── com
                └── imooc
                    ├── DemoApplication.java
                    ├── exception
                    │   └── UserNotExistException.java
                    └── web
                        └── controller
                            ├── ControllerExceptionHandler.java
                            └── UserController.java
```

* 自定义异常类`UserNotExistException`，继承系统异常`RuntimeException`

```java
public class UserNotExistException extends RuntimeException {
	private static final long serialVersionUID = 1L;
	private String id;

	public UserNotExistException(String id) {
		super("user not exist"); // message
		this.id = id;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}
}
```

* 创建`ControllerExceptionHandler`类来关联自定义的异常类`UserNotExistException`。

```java
@ControllerAdvice
public class ControllerExceptionHandler {
	@ExceptionHandler(UserNotExistException.class) //其他类抛出UserNotExistException异常时，就会转到handleUserNotExistException类中
	@ResponseBody
	@ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
	public Map<String, Object> handleUserNotExistException(UserNotExistException ex) {
		Map<String, Object> result = new HashMap<>();
		result.put("id", ex.getId());
		result.put("message", ex.getMessage());
		return result;
	}
}
```

> `@ControllerAdvice`这个注解的功能: <br>
> 1.全局异常处理 <br>
> 2.全局数据绑定 <br>
> 3.全局数据预处理

[SpringMVC 中 @ControllerAdvice 注解的三种使用场景](https://www.cnblogs.com/lenve/p/10748453.html)

* 使用

```java
@RestController
@RequestMapping("/user")
public class UserController {
	@GetMapping("/{id}")
	public User getInfo(@PathVariable String id) {
		throw new UserNotExistException(id);
	}
}
```

在客户端展示异常的URL：`127.0.0.1:8060/user/1`接口返回：

```json
{
    "id":"1",
    "message":"user not exist"
}
```

## Restful API 拦截

> 现在有个需求就是记录所有接口的请求时间，那么可以使用接口拦截的形式来实现，下面介绍三种实现拦截的方案。

```java
@RestController
@RequestMapping("/user")
public class UserController {
	@GetMapping("/{id}")
	public User getInfo(@PathVariable String id) {
		System.out.println("进入getInfo服务");
		User user = new User();
		user.setUsername("tom");
		return user;
	}
}
```

用户去请求URL接口：`127.0.0.1:8060/user/1`，记录接口请求时间。

### 过滤器:`Filter`

```java
@Component // 想要过滤器正常起作用，就要交加上这个注解
public class TimeFilter implements Filter {
	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
		System.out.println("time filter init");
	}
	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
			throws IOException, ServletException {
		System.out.println("time filter start");
		long start = new Date().getTime();
		chain.doFilter(request, response);
		System.out.println("time filter 耗时:" + (new Date().getTime() - start));
		System.out.println("time filter finish");
	}
	@Override
	public void destroy() {
		System.out.println("time filter destroy");
	}
}
```

请求接口输出日志：

```
time filter init
time filter start
进入getInfo服务
time filter 耗时:73
time filter finish
```

> 如果想要使用第三方的`Filter`，而且第三方的`Filter`没有使用`@Component`；我们可以通过配置类来实现。

* 把上面的`TimeFilter`类的`@Component`注释掉。
* 创建一个`@Configuration`的配置类，并且实现功能。

```java
import org.springframework.boot.web.servlet.FilterRegistrationBean;

@Configuration // 表明这是个配置类
public class WebConfig {
	@Bean
	public FilterRegistrationBean timeFilter() {
		FilterRegistrationBean registrationBean = new FilterRegistrationBean();
		TimeFilter timeFilter = new TimeFilter(); 
		registrationBean.setFilter(timeFilter);//设置过滤器
		List<String> urls = new ArrayList<>();
		urls.add("/*"); // 可以指定使用过滤器的URL
		registrationBean.setUrlPatterns(urls);
		return registrationBean;
	}
	/* 
	可以设置多个Filter
	@Bean
	public FilterRegistrationBean timeFilter2() {
		FilterRegistrationBean registrationBean = new FilterRegistrationBean();
		//....
		return registrationBean;
	}
	*/
}
```


### 拦截器:`Interceptor`

* 自定义拦截器实现系统`HandlerInterceptor`

```java
@Component
public class TimeInterceptor implements HandlerInterceptor {

	// 接口请求前调用
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		System.out.println("preHandle");
		System.out.println(((HandlerMethod) handler).getBean().getClass().getName()); //获取类名
		System.out.println(((HandlerMethod) handler).getMethod().getName());// 获取方法名
		request.setAttribute("startTime", new Date().getTime());
		return true;
	}
	// 接口请求成功后调用，失败则不调用
	@Override
	public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler,ModelAndView modelAndView) throws Exception {
		System.out.println("postHandle");
		Long start = (Long) request.getAttribute("startTime");
		System.out.println("time interceptor 耗时:" + (new Date().getTime() - start));
	}
	// 接口请求后，不管成功失败都会调用
	@Override
	public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
		System.out.println("afterCompletion");
		Long start = (Long) request.getAttribute("startTime");
		System.out.println("time interceptor 耗时:" + (new Date().getTime() - start));
		System.out.println("ex is " + ex);
	}
}
```

* 配置`WebMvcConfigurerAdapter`

```java
@Configuration // 表明这是个配置类
public class WebConfig extends WebMvcConfigurerAdapter{
	@Autowired
	private TimeInterceptor timeInterceptor;
	@Override
	public void addInterceptors(InterceptorRegistry registry) {
		registry.addInterceptor(timeInterceptor);
	}
}
```

* 请求接口输出日志：

```
preHandle
com.imooc.web.controller.UserController
getInfo
进入getInfo服务
postHandle
time interceptor 耗时:88
afterCompletion
time interceptor 耗时:88
ex is null
```

### AOP切面:`Aspect`

* AOP介绍

![项目结构](/assets/images/ss_tec/06.png)

* 添加AOP依赖

```xml
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-aop</artifactId>
</dependency>
```

* 实现AOP

```java
@Aspect
@Component
public class TimeAspect {
	// 什么时候起作用：@Around 包含了@Before、@After...等等,也就是说handleControllerMethod方法在任何时候都起作用。
	// 在哪些方法上起作用：通过execution实现
	@Around("execution(* com.imooc.web.controller.UserController.*(..))")
	public Object handleControllerMethod(ProceedingJoinPoint pjp) throws Throwable {
		System.out.println("time aspect start");
		Object[] args = pjp.getArgs(); // 获取方法参数集合
		for (Object arg : args) {
			System.out.println("arg is " + arg);
		}
		long start = new Date().getTime();
		Object object = pjp.proceed();// object 方法返回值
		System.out.println("time aspect 耗时:" + (new Date().getTime() - start));
		System.out.println("time aspect end");
		return object;
	}
}
```

* `execution`文档路径:[`https://spring.io/`->`projects`->`spring-framework`->`Reference Doc.`->`Core`->`Aspect Oriented Programming with Spring`->`@AspectJ support`->`Declaring a Pointcut`->`Examples`](https://docs.spring.io/spring/docs/5.2.4.BUILD-SNAPSHOT/spring-framework-reference/core.html#aop-pointcuts-examples)

* 请求接口输出日志：

```
time aspect start
arg is 1
进入getInfo服务
time aspect 耗时:2
time aspect end
```

### `RESTful API`三种方式拦截对比

![项目结构](/assets/images/ss_tec/07.png)

拦截顺序： `Filter`->`Interceptor`->`ControllerAdvice`->`Aspect`->`Controller`

RESTful API拦截有三种方式：过滤器；拦截器；AOP切面 

* 1.过滤器(Filter)：能获取到原始的http请求和响应对象，但获取不到controller对象及其处理方法以及方法参数 
* 2.拦截器(Interceptor)：能获取到原始的http请求和响应对象，能获取到controlller对象及其方法，但获取不到方法参数 
* 3.AOP切面(Aspect)：能获取到controlller对象及其方法和方法参数，但获取不到原始的http请求和响应对象 三者的范围如图

三种拦截器一起使用再次请求接口产生的日志：

```
time filter init <== Filter
time filter start <== Filter
preHandle <== Interceptor
com.imooc.web.controller.UserController$$EnhancerBySpringCGLIB$$61f8a9c4
getInfo
time aspect start <== AOP
arg is 1 <== AOP
进入getInfo服务 <== 接口
time aspect 耗时:2 <== AOP
time aspect end <== AOP
postHandle <== Interceptor
time interceptor 耗时:75 <== Interceptor
afterCompletion <== Interceptor
time interceptor 耗时:76 <== Interceptor
ex is null <== Interceptor
time filter 耗时:90 <== Filter
time filter finish <== Filter
time filter destroy <== Filter
```

### 获取代码

```sh
git clone -b section/3-7_3-8 https://gitee.com/BackEndLearning/ss_sts_example.git
```

## `Spring MVC`异步处理`Restful`服务

### `Deferredresult`

## `Swagger`自动生成文档

* 添加依赖

```xml
<dependency>
	<groupId>io.springfox</groupId>
	<artifactId>springfox-swagger2</artifactId>
	<version>2.7.0</version>
</dependency>
<dependency>
	<groupId>io.springfox</groupId>
	<artifactId>springfox-swagger-ui</artifactId>
	<version>2.7.0</version>
</dependency>
```

* 在项目的主入口添加注解`@EnableSwagger2`

```java
@SpringBootApplication
@RestController
@EnableSwagger2
public class DemoApplication {
	public static void main(String[] args) {
		SpringApplication.run(DemoApplication.class, args);
	}
}
```

* 访问`Swagger`：`/swagger-ui.html`

### `Swagger`相关注解

* `@ApiOperation`：方法描述
* `@ApiParam`：方法参数描述
* `@ApiModelProperty`：模型字段描述

```java
@RestController
@RequestMapping("/user")
public class UserController {
	@GetMapping("/{id}")
	@ApiOperation(value = "创建用户")
	public User getInfo(@ApiParam("用户id") @PathVariable String id) {
		User user = new User();
		return user;
	}
}

public class User {
	@ApiModelProperty(value = "用户名")
	private String username;

	@ApiModelProperty(value = "用户密码")
	private String password;

	@ApiModelProperty(value = "用户生日")
	private Date birthday;
}
```

#### 获取代码

```
git clone -b section/3-11 https://gitee.com/BackEndLearning/ss_sts_example.git
```