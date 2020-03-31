---
title: iOS中__attribute__
layout: post
categories:
 - ios
---

`__attribute__`是一个编译器指令，方便开法则向编译器表达某种要求，一般为了方便使用会被定义成宏。像系统库中`NS_AVAILABLE_IOS(5_0)`。

## GCC

GCC环境下提供可以使用的编译属性。

### format

`format`属性指定一个函数具有`printf`，`scanf`，`strftime`或者`strfmon`根据格式字符串类型的参数，是对于数据类型的检查。在OC中使用`__NSString__`具有相同的效果。

```c
FOUNDATION_EXPORT void NSLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_NO_TAIL_CALL;
```

在系统库的`NSLog`方法定义中，`NS_FORMAT_FUNCTION(1,2)` 宏定义的意思是：`NS_FORMAT_FUNCTION(F,A) __attribute__((format(__NSString__, F, A)))`

### nonnull

`nonnull`属性指定某些函数参数应为非空指针。

```
extern void * testFunc(void *var1, const void *var2) __attribute__((nonnull(1,2)));
```

### unused

### pure / const

### noreturn

`noreturn`：这个属性告诉编译器函数不会返回，这可以用来抑制关于未达到代码路径的错误。

```c
// stdlib.h
void abort(void) __attribute__((noreturn));
void exit(int) __attribute__((noreturn));        
```

[AFNetworking 将该noreturn属性用于其网络请求线程入口点方法](https://github.com/AFNetworking/AFNetworking/blob/1.1.0/AFNetworking/AFURLConnectionOperation.m#L157)

### visibility

```c
__attribute__((visibility("default")))  //默认，设置为：default之后就可以让外面的类看见了。
__attribute__((visibility("hideen")))  //隐藏
```

## LLVM

### constructor / destructor
* `constructor / destructor`：构造器(`constructor`)和析构器(`destructor`)，加上这两个属性的函数会在分别在可执行文件（或 `shared library`）`load` 和 `unload` 时被调用，可以理解为在 `main()` 函数调用前和 `return` 后执行

```c
//main.m
__attribute__((constructor))
static void beforeMain(void){NSLog(@"beforeMain");}

__attribute__((destructor))
static void afterMain(void){NSLog(@"afterMain");}

int main(int argc, char * argv[]) {
    @autoreleasepool {
        NSLog(@"main");
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}

//ViewController01.m
#import "ViewController01.h"

__attribute__((constructor))
static void beforeMain(void){NSLog(@"ViewController01-beforeMain");}

__attribute__((destructor))
static void afterMain(void){NSLog(@"ViewController01-afterMain");}

@implementation ViewController01
+(void)load{
    NSLog(@"ViewController01-load");
}
@end

// ===> 从应用启动到消失
// 2019-08-07 17:09:33.320935+0800 RACDemo01[97014:1447204] ViewController01-load
// 2019-08-07 17:09:33.321707+0800 RACDemo01[97014:1447204] ViewController01-beforeMain
// 2019-08-07 17:09:33.322068+0800 RACDemo01[97014:1447204] beforeMain
// 2019-08-07 17:09:33.322225+0800 RACDemo01[97014:1447204] main
// 2019-08-07 17:09:52.370147+0800 RACDemo01[97014:1447204] afterMain
// 2019-08-07 17:09:52.370427+0800 RACDemo01[97014:1447204] ViewController01-afterMain
```

> `constructor`和`+load`方法都是在`main`函数执行前调用,但 `+load` 比 `constructor` 更加早一点，因为 `dyld（动态链接器，程序的最初起点）`在加载 `image（可以理解成 Mach-O 文件`）时会先通知 `objc runtime` 去加载其中所有的类， <br/>
> 每加载一个类时，它的 `+load` 随之调用，全部加载完成后，`dyld` 才会调用这个 `image` 中所有的 `constructor` 方法。

**优点**

* 因为它的生命周期是：所有 `Class` 都已经加载完成，`main` 函数还未执行，可以做一些自定义的操作。
* `constructor` 无需像 `+load` 还得挂载在一个 `Class` 中。
* `constructor` 在多个的情况下，可以设置优先级：`__attribute__((constructor(101)))`，里面的数字越小优先级越高，`1 ~ 100` 为系统保留

### objc_boxable
* `objc_boxable`：Objective-C 中的 `@(...)` 语法糖可以将基本数据类型 box 成 `NSNumber` 对象

```c
typedef struct __attribute__((objc_boxable)) {
    CGFloat x, y, width, height;
} XXRect;

// CGRect rect1 = {1, 2, 3, 4};
// NSValue *value1 = @(rect1); // <--- Compile Error
// XXRect rect2 = {1, 2, 3, 4};
// NSValue *value2 = @(rect2); // √
```

### overloadable
* `overloadable`：`Clang`在C中提供对`C++`函数重载的支持`overloadable`。

<img src="/assets/images/ios_attribute/16.png" width = "50%" height = "50%"/>

修改过以后就可以实现 重载的功能：

<img src="/assets/images/ios_attribute/17.png" width = "50%" height = "50%"/>

### deprecated

* `deprecated`：在编译时会报过时警告

<img src="/assets/images/ios_attribute/15.png" width = "50%" height = "50%"/>

### availability
`availability`：使用版本、平台情况及相关说明信息

* `introduced`：引进的版本
* `deprecated`：废弃的版本，还能使用，并没有移除，而是提醒用户迁移到其他API
* `obsoleted`：移除的版本，不能再使用
* `unavailable`：那些平台不能用
* `message`：额外提示信息，比如迁移到某某API

支持的平台：
* `ios`：Apple的iOS操作系统。
* `macosx`：Apple的OS X操作系统。

**方法**

```c
-(void)testFunction1 __attribute__((availability(ios,introduced=2_0,deprecated=4_0,obsoleted=11_0,message="这是个测试信息")));
-(void)testFunction2 NS_CLASS_DEPRECATED_IOS(2_0,9_0,"这是个测试信息"); // NS_CLASS_DEPRECATED_IOS 这是系统定义的。
```

<img src="/assets/images/ios_attribute/07.png" width = "50%" height = "50%"/>

**类**

```c
__attribute__((availability(ios,introduced=2_0,deprecated=4_0,obsoleted=11_0,message="这是个测试信息")))
@interface ViewController01 : UIViewController
@end

// 或者

NS_CLASS_DEPRECATED_IOS(2_0,9_0,"这是个测试信息")
@interface ViewController01 : UIViewController
@end
```

<img src="/assets/images/ios_attribute/08.png" width = "50%" height = "50%"/>

**unavailable**

```c
// 定义在ios平台不能用,强制使用会报错
-(void)testFunction1 __attribute__((availability(ios,unavailable,message="这是个测试信息")));
//或者
-(void)testFunction1 NS_UNAVAILABLE;
```

<img src="/assets/images/ios_attribute/09.png" width = "50%" height = "50%"/>

### unavailable
* `unavailable`：告诉编译器某方法不可用，如果强行调用编译器会提示错误

```c
@property (strong,nonatomic) id var1 NS_UNAVAILABLE;
-(void)testFunction1 __attribute__((unavailable("这是个测试信息")));
```

<img src="/assets/images/ios_attribute/10.png" width = "50%" height = "50%"/>

### nonnull
* `nonnull`：编译器对`函数参数`进行检查，不能为`null`，参数类型必须为指针类型（包括对象）

<img src="/assets/images/ios_attribute/11.png" width = "50%" height = "50%"/>

从上面的方法可以看出，`nonnull`必须为指针类型，所以优化结果：

```c
-(void)testFunctionWithPara1:(NSString*)para1 para2:(NSString*)para2 para3:(NSInteger)para3 __attribute__((nonnull(1,2)));
```

<img src="/assets/images/ios_attribute/12.png" width = "50%" height = "50%"/>

### objc_root_class
* `objc_root_class`：表示这个类是一个基类

`NSObject`就是通过`OBJC_ROOT_CLASS`来设置为基类的。

```objc
OBJC_ROOT_CLASS
@interface NSObject <NSObject> {
}
@end
```

OBJC_ROOT_CLASS

```objc
#if !defined(OBJC_ROOT_CLASS)
#   if __has_attribute(objc_root_class)
#       define OBJC_ROOT_CLASS __attribute__((objc_root_class))
#   else
#       define OBJC_ROOT_CLASS
#   endif
#endif
```

### objc_designated_initializer
* `objc_designated_initializer`：指定类的初始化方法，并不是对使用者，而是对类内部的实现
* 规则：如果该类有`objc_designated_initializer`的初始化方法，那么它必须覆盖实现`父类的objc_designated_initializer`方法

### objc_requires_super
* `objc_requires_super`：表示子类在重写父类的方法的时候，必须先调用super方法，否则会有警告

<img src="/assets/images/ios_attribute/13.png" width = "50%" height = "50%"/>

### objc_subclassing_restricted
* `objc_subclassing_restricted`：表示该类不能被继

<img src="/assets/images/ios_attribute/14.png" width = "50%" height = "50%"/>

### objc_runtime_name
* `objc_runtime_name`：用于 @interface 或 @protocol，将类或协议的名字在编译时指定成另一个。

```objc
__attribute__((objc_runtime_name("SarkGay")))
@interface Sark : NSObject
@end

NSLog(@"%@", NSStringFromClass([Sark class])); // "SarkGay"
```

最直接的用处就是进行代码混淆：

```objc
__attribute__((objc_runtime_name("40ea43d7629d01e4b8d6289a132482d0dd5df4fa")))
@interface SecretClass : NSObject
@end
```

```objc
/ @singleton 包裹了 __attribute__((objc_runtime_name(...)))
// 将类名改名成 "SINGLETON_Sark_sharedInstance"
@singleton(Sark, sharedInstance)
@interface Sark : NSObject
+ (instancetype)sharedInstance;
@end
```

在运行时用 `__attribute__((constructor))` 获取入口时机，用 `runtime` 找到这个类，反解出 `sharedInstance` 这个 `selector` 信息，动态将 `+ alloc`，`- init` 等方法替换，返回 `+ sharedInstance` 单例。


### warn_unused_result
* `warn_unused_result` 如果方法定义有返回值，调用的时候没有定义变量进行承接，就会显示警告

<img src="/assets/images/ios_attribute/18.png" width = "50%" height = "50%"/>

---

### cleanup
`__attribute__((cleanup(...)))`：用于修饰一个`变量(基础变量、系统对象类型、自定义Class类型)`，在它的`作用域结束(包括大括号结束、return、goto、break、exception等各种情况)`时可以自动执行一个指定的方法。

```objc
// 系统对象类型
// 指定一个cleanup方法，注意入参是所修饰变量的地址，类型要一样
// 对于指向objc对象的指针(id *)，如果不强制声明__strong默认是__autoreleasing，造成类型不匹配
static void stringCleanUp(__strong NSString **string) {
    NSLog(@"%@", *string);
}
// 在某个方法中：
{
    __strong NSString *string __attribute__((cleanup(stringCleanUp))) = @"sunnyxx";
} // 当运行到这个作用域结束时，自动调用stringCleanUp


// 自定义的Class
static void sarkCleanUp(__strong Sark **sark) {
    NSLog(@"%@", *sark);
}
__strong Sark *sark __attribute__((cleanup(sarkCleanUp))) = [Sark new];


// 基本类型
static void intCleanUp(NSInteger *integer) {
    NSLog(@"%d", *integer);
}
NSInteger integer __attribute__((cleanup(intCleanUp))) = 1;
```

* `cleanup`：用于修饰一个变量，在它的作用域结束时可以自动执行一个指定的方法
* [黑魔法__attribute__((cleanup))](http://blog.sunnyxx.com/2014/09/15/objc-attribute-cleanup/)

## 使用block

```objc
static void blockCleanUp(__strong void(^*block)(void)) {
    (*block)();
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 加了个`unused`的attribute用来消除`unused variable`的warning
    __strong void(^block)(void) __attribute__((cleanup(blockCleanUp), unused)) = ^{
        NSLog(@"I'm dying...");
    };
    // ... 很多代码
    return YES;
}
```

`I'm dying...` 这句话会在`didFinishLaunchingWithOptions`方法执行完以后输出。<mark>将一段写在前面的代码最后执行</mark>

可以将成对出现的代码写在一起，比如说一个lock：<br/>

```objc
NSRecursiveLock *aLock = [[NSRecursiveLock alloc] init];
[aLock lock];
// 这里有100多万行
[aLock unlock]; // 看到这儿的时候早忘了和哪个lock对应着了
```
---

## 参考资料
* [__attribute__](https://nshipster.com/__attribute__/)
* [__attribute__ 总结](https://www.jianshu.com/p/29eb7b5c8b2d)
* [Clang Attributes 黑魔法小记](http://blog.sunnyxx.com/2016/05/14/clang-attributes/)
* [Clang 3.8 documentation](http://releases.llvm.org/3.8.0/tools/clang/docs/AttributeReference.html)
