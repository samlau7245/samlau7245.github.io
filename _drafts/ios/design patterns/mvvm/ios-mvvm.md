---
title: MVVM
layout: post
categories:
 - ios
---

<!-- 
<img src="/assets/images/ios-dev-patterns/01.png" width = "50%" height = "50%"/> 
-->

<img src="/assets/images/ios-dev-patterns/01.png" width = "50%" height = "50%"/> 

<img src="/assets/images/ios-dev-patterns/02.png" width = "50%" height = "50%"/> 


`ViewModel`的定位：ViewModel存在目的在于抽离ViewController中展示业务逻辑，而不是替代ViewController，视图的操作业务等还是应该放在ViewController中实现。既然不负责视图操作逻辑，ViewModel中就不应该存在任何View对象，更不应该存在Push/Present等视图跳转逻辑。

ViewModel用于处理视图展示逻辑，ViewModel负责将数据业务层提供的数据转化为界面展示所需的VO。其与View一一对应，**没有View就没有ViewModel**。

```objc
self.personVO.sex = personDO.sex == 0 ? @"男": @"女";
```

* `VO(View Object)` : 视图对象，用于展示层，它的作用是把某个指定页面（或组件）的所有数据封装起来。
* `DO(Domain Object)` : 领域对象，就是从现实世界中抽象出来的有形或无形的业务实体-接口数据模型。

```objc
@interface ViewModel : NSObject
// viewmodel中切不可存在view对象，更不该出现push或者present代码
- (instancetype)initWithTableView:(UITableView *)tableView;
@end
```

`MVVM（Model–View–Viewmodel)`



* Controller
	* `Controller`负责控制`View`、`ViewModel`的绑定关系。
	* 仅关注于用 view-model 的数据配置和管理各种各样的视图, 并在先关用户输入时让 view-model 获知并需要向上游修改数据. Controller不需要了解关于网络服务调用, Core Data, 模型对象等。
	* view-model 在Controller上以一个属性的方式存在. 
* Model： 数据模型、访问数据库的操作和网络请求等。
	* Domain(DO)
		* Domain层不应该存在任何状态变量
	* Data(PO)
		* Data层对应数据层逻辑，一般以Manager或者Service身份存在，数据来源主要包括Api、DB或者Cache等。Data数据层操作对象主要为PO持久化对象，对象一旦创建，原则上不可修改。
* ViewModel	
	* 实现View的展示逻辑。没有View就没有ViewModel。
	* viewModel 中的代码是与 UI 无关的，所以它具有良好的可测试性。
	* viewmodel中切不可存在view对象，更不该出现push或者present代码。
* View
	* 把 view 看作是 viewModel 的可视化形式。	
* binder
	* 实现 view 和 viewModel 的同步。	

```objc
//===============ViewModel 层===============
@interface ViewModel : NSObject
// viewmodel中切不可存在view对象，更不该出现push或者present代码
- (instancetype)initWithTableView:(UITableView *)tableView;
@end

//===============Model 层===============
@interface PersonModel : NSObject
@property (nonatomic, assign) NSInteger sex;
@property (nonatomic, readonly) NSString *sexDescription;
@end
@implementation PersonModel
// model中不应该存在业务逻辑代码
- (NSString *)sexDescription {
    return self.sex == 0 ? @"男": @"女";
}
@end

//===============Data 层===============
@implementation PersonDBAccess
// Data层不应该存在任何视图相关代码
- (NSArray *)fetchPersonModels {
    [SVProgressHUD showWithStatus:@"加载中。。。"];
}
@end
```

* `VO(View Object)` : 视图对象，用于展示层，它的作用是把某个指定页面（或组件）的所有数据封装起来
* `DO(Domain Object)` : 领域对象，就是从现实世界中抽象出来的有形或无形的**业务实体**--类似Entity
* `PO(Persistent Object)` : 持久化对象，它跟持久层（通常是关系型数据库）的数据结构形成一一对应的映射关系，如果持久层是关系型数据库，那么，数据表中的每个字段（或若干个）就对应PO的一个（或若干个）属性
* `Domain` : 领域驱动层，是用户与数据库交互的核心中转站，控制用户数据收集，控制请求转向等

* [用户操作界面，每个模块触发的逻辑](http://www.cocoachina.com/articles/11930)

数据通讯：

* ReactiveCocoa
* KVO
* Notification
* block
* Delegate
* Target-Action


view-model 一词的确不能充分表达我们的意图. 一个更好的术语可能是 “View Coordinator”(感谢Dave Lee提的这个 “View Coordinator” 术语, 真是个好点子)。你可以认为它就像是电视新闻主播背后的研究人员和作家团队。它从必要的资源(数据库, 网络服务调用, 等)中获取原始数据, 运用逻辑, 并处理成 view (controller) 的展示数据. 它(通常通过属性)暴露给视图控制器需要知道的仅关于显示视图工作的信息(理想地你不会暴漏你的 data-model 对象)。 它还负责对上游数据的修改(比如更新模型/数据库, API POST 调用)。






<img src="/assets/images/ios-dev-patterns/03.gif"/>

<img src="/assets/images/ios-dev-patterns/04.png" width = "50%" height = "50%"/> 

<img src="/assets/images/ios-dev-patterns/05.png" width = "50%" height = "50%"/> 


```
Functional Core, Imperative Shell

view-model 这种通往应用设计的方法是一块应用设计之路上的垫脚石, 这种被称作“Functional Core, Imperative Shell”的应用设计由Gary Bernhardt创造.

Functional Core

view-model 就是 “functional core”, 尽管实际上在 iOS/Objective-C 中达到纯函数水平是很棘手的(Swift 提供了一些附加的函数性, 这会让我们更接近). 大意是让我们的 view-model 尽可能少的对剩余的”应用世界”的依赖和影响. 那意味着什么?想起你第一次学编程时可能学到的简单函数吧. 它们可能接受一两个参数并输出一个结果. 数据输入, 数据输出.这个函数可能是做一些数学运算或是将姓和名结合到一起. 无论应用的其他地方发生啥, 这个函数总是对相同的输入产生相同的输出. 这就是函数式方面.

这就是我们为 view-model 谋求的东西. 他们富有逻辑和转换数据并将结果存到属性的功能. 理想上相同的输入(比如网络服务响应)将会导出相同的输出(属性的值). 这意味着尽可能多地消除由”应用世界”剩余部分带来的可能影响输出的因素, 比如使用一堆状态. 一个好的第一步就是不要再 view-model 头文件中引入 UIKit.h.

Imperative (Declarative?) Shell

命令式外壳 (Imperative Shell) 是我们需要做所有的状态转换, 应用世界改变的苦差事的地方, 为的是将 view-model 数据转成给用户在屏幕上看到的东西. 这是我们的视图(控制器), 实际上我们在这分离 UIKit 的工作. 我仍将特别注意尽可能消除状态并用 ReactiveCocoa 这种陈述性质的东西做这方面工作, 而 iOS 和 UIKit 在设计上是命令式的. (表格的 data source 就是个很好的例子, 因为它的委托模式强制将状态应用到委托中, 为了当请求发生时能够为表格视图提供信息. 实际上委托模式通常强制一大堆状态的使用)
```

## ReactiveCocoa

### 简单使用

### 记录UITextField输入值变动

```objc
@interface UITextField (RACSignalSupport)
// 给UITextField生成一个信号
- (RACSignal<NSString *> *)rac_textSignal;
- (RACChannelTerminal<NSString *> *)rac_newTextChannel;
@end
```

示例：

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.nameTextField.rac_textSignal subscribeNext:^(NSString *newName) {
        NSLog(@"%@", newName);
    }];
}
```

<img src="/assets/images/iOS/mvvm/01.gif"/>

### 记录字符串值变动

```objc
// 当 username 变量值变动时，记录出来
@interface PersonViewController ()
@property (copy, nonatomic) NSString *username;
@end
@implementation PersonViewController
-(void)bindViewModel{
    [RACObserve(self, username) subscribeNext:^(NSString *newName) {
        NSLog(@"username: %@", newName);
    }];
}
```

<img src="/assets/images/iOS/mvvm/02.gif"/>

### 过滤输入的值

```objc
[[self.nameTextField.rac_textSignal filter:^BOOL(NSString *newName) {
    return [newName hasPrefix:@"j"];
}] subscribeNext:^(NSString *newName) {
    NSLog(@"username: %@", newName);
}];
```

<img src="/assets/images/iOS/mvvm/03.gif"/>

### 信号对比

```objc
// 当输入的数据与本地数据相匹配时，返回ture状态
@interface PersonViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (copy, nonatomic) NSString *passwordConfirmation;
@end

@implementation PersonViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.passwordConfirmation = @"123";
    [self bindViewModel];
}
-(void)bindViewModel{
    RAC(self,createEnabled) = [RACSignal combineLatest:@[RACObserve(self.nameTextField,text),RACObserve(self,passwordConfirmation)] reduce:^id (NSString *password, NSString *passwordConfirm){
        return @([passwordConfirm isEqualToString:password]);
    }];
    @weakify(self)
    [RACObserve(self, createEnabled) subscribeNext:^(NSNumber*  createEnabled) {
        @strongify(self)
        if (createEnabled.boolValue) {
            [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
        }else{
            [self.loginButton setTitle:@"Input Info" forState:UIControlStateNormal];
        }
    }];

}
// 更改按钮颜色
-(void)bindViewModel{
    RAC(self.loginButton,backgroundColor) = [RACSignal combineLatest:@[RACObserve(self.nameTextField,text),RACObserve(self,passwordConfirmation)] reduce:^id (NSString *password, NSString *passwordConfirm){
        if ([passwordConfirm isEqualToString:password]) {
            return [UIColor greenColor];
        }
        return [UIColor grayColor];
    }];
}
@end
```

<img src="/assets/images/iOS/mvvm/04.gif"/>

### 实现按钮点击

```objc
[[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
    NSLog(@"button点击了");
}];

self.loginButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
    NSLog(@"button was pressed!");
    return [RACSignal empty];
}];
```

<img src="/assets/images/iOS/mvvm/05.gif"/>

### RAC & AFN ? 

###UI callbacks


, network responses, and KVO notifications

## 参考资料
* [MVVM奇葩说](http://www.cocoachina.com/articles/16004)
* [唐巧的博客](http://blog.devtang.com/)