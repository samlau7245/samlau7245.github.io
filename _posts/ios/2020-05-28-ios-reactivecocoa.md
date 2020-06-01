---
title: ReactiveCocoa
layout: post
categories:
 - ios
---

> RAC 的核心思想：创建信号 - 订阅信号 - 发送信号.

## 基础理论

### RACSignal 触发流程

下面代码是`RACSignal`创建和被订阅的演示。

```objc
-(void)test_sig_1{
    //Create a Signal.
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        for (NSInteger i = 0; i <= 5; i++) {
            [subscriber sendNext:@(i)];
        }
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"RACDisposable block");
        }];
    }];
    // Subscribe a Signal
    // English: disposable: adj.可任意处理的；可自由使用的；用完即可丢弃的
    RACDisposable * disposable = [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"Recive signal:%@",x);
    } error:^(NSError * _Nullable error) {
        NSLog(@"Recive signal:%@",error.localizedDescription);
    } completed:^{
        NSLog(@"completed!");
    }] ;
    
    // Release the Subscriber
    [disposable dispose];
}
```

`RACSignal`底层实现:

* 创建信号，首先把`didSubscribe`保存到信号中，还不会触发。
* 当信号被订阅(调用signal的`subscribeNext:nextBlock`)时：
	* `subscribeNext`内部会创建订阅者`subscriber`，并且把`nextBlock`保存到`subscriber`中
	* `subscribeNext`内部会调用siganl的`didSubscribe`
	* 当信号订阅完成, 不在发送数据的时候, 最好调用完成发送的`[subscriber sendCompleted]`
	* 订阅完成的时候, 内部会自动调用`[RACDisposable disposable]`取消订阅信号
* 当siganl的`didSubscribe`中调用`[subscriber sendNext:@1]`时，`sendNext`底层其实就是执行`subscriber`的`nextBlock`

`RACSignal`的一些子类及作用：

```objc
//  `RACDynamicSignal`(动态信号) 是`RACSignal`的子类,使用一个`block`来实现订阅行为。
@interface RACDynamicSignal : RACSignal
// block 中 id<RACSubscriber> subscriber
+ (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe;
@end
// 一元信号，用来实现 RACSignal 的 +return:方法
@interface RACReturnSignal<__covariant ValueType> : RACSignal<ValueType>
+ (RACSignal<ValueType> *)return:(ValueType)value;
@end
// 错误信号，用来实现 RACSignal 的 +error: 方法
@interface RACErrorSignal : RACSignal
+ (RACSignal *)error:(NSError *)error;
@end

// 通道终端，代表 RACChannel 的一个终端，用来实现双向绑定
@interface RACChannelTerminal<ValueType> : RACSignal<ValueType> <RACSubscriber>
- (instancetype)init __attribute__((unavailable("Instantiate a RACChannel instead")));
- (void)sendNext:(nullable ValueType)value;
@end

// 信号提供者，自己可以充当信号，又能发送信号
@interface RACSubject<ValueType> : RACSignal<ValueType> <RACSubscriber>
+ (instancetype)subject;
- (void)sendNext:(nullable ValueType)value;
@end
```

`RACSubscriber` 订阅者协议的内容：

```objc
@protocol RACSubscriber <NSObject>
- (void)sendNext:(nullable id)value;
- (void)sendError:(nullable NSError *)error;
- (void)sendCompleted;
- (void)didSubscribeWithDisposable:(RACCompoundDisposable *)disposable;
@end
```

### RACSubject、RACReplaySubject

`RACSubject` 信号提供者：

* `RACSubject(信号提供者)`，自己可以充当信号，又能发送信号。
* 触发条件：先订阅, 再发送信号。
* 使用场景:通常用来代替代理/通知。

`RACReplaySubject` 重复提供信号：

* 先发送信号，再订阅信号


```objc
@interface TestViewModel : NSObject
@property (strong, nonatomic) RACSignal *signal;
@property (strong, nonatomic) RACReplaySubject *replaySubject;
@property (strong, nonatomic) RACSubject *subject;
@end
@implementation TestViewModel
-(RACReplaySubject *)replaySubject{
    if (!_replaySubject) {
        _replaySubject = [RACReplaySubject subject];
    }
    return _replaySubject;
}

-(RACSubject *)subject{
    if (!_subject) {
        _subject = [RACSubject subject];
    }
    return _subject;
}
@end

@interface TestViewController ()
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendSingnalButton;

@property (strong, nonatomic) TestViewModel *viewModel;
@end

@implementation TestViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"you clicked the login button!");
        [self.viewModel.replaySubject subscribeNext:^(id  _Nullable x) {
            NSLog(@"RACReplaySubject %@",x);
        }];
        [self.viewModel.subject subscribeNext:^(id  _Nullable x) {
            NSLog(@"RACSubject %@",x);
        }];
    }];
    [[self.registerButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"you clicked the register button!");
        [self.viewModel.replaySubject subscribeNext:^(id  _Nullable x) {
            NSLog(@"RACReplaySubject %@",x);
        }];
        [self.viewModel.subject subscribeNext:^(id  _Nullable x) {
            NSLog(@"RACSubject %@",x);
        }];
    }];
    [[self.sendSingnalButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self.viewModel.subject sendNext:@2];
        [self.viewModel.replaySubject sendNext:@2];
    }];
}
-(TestViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [TestViewModel new];
        [_viewModel.replaySubject sendNext:@1];
        [_viewModel.subject sendNext:@1];
    }
    return _viewModel;
}
@end

/*
you clicked the login button!
RACReplaySubject 1 ==> RACReplaySubject 先发送了信号，然后再点击login方法进行订阅。这里没有 RACSubject 的打印信息，是因为 RACSubject 必须先订阅再发送信号。

you clicked the register button!
RACReplaySubject 1 ==> RACReplaySubject 先发送了信号，然后再点击login方法进行订阅。这里没有 RACSubject 的打印信息，是因为 RACSubject 必须先订阅再发送信号。

RACSubject 2
RACSubject 2 ==> login register 两个方法各订阅了一次信号，点击几次方法就会重复订阅
RACReplaySubject 2 ==> login register 两个方法各订阅了一次信号，点击几次方法就会重复订阅
RACReplaySubject 2

RACSubject 2
RACSubject 2
RACReplaySubject 2
RACReplaySubject 2
*/
```

<img src="/assets/images/iOS/rac/02.gif"/>

做一个`RACSubject`作为代理的简单示例：

```objc
@interface TestViewModel : NSObject
@property (strong, nonatomic) RACSubject *subject;

-(void)loadData;
@end
@implementation TestViewModel
-(void)loadData{
    // request service data,return data to vc
    [self.subject sendNext:@1];
}

-(RACSubject *)subject{
    if (!_subject) {
        _subject = [RACSubject subject];
    }
    return _subject;
}
@end

@interface TestViewController ()
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *sendSingnalButton;

@property (strong, nonatomic) TestViewModel *viewModel;
@end

@implementation TestViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewModel.subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"Service data: %@",x);
    }];
    @weakify(self)
    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        NSLog(@"you clicked the login button!");
        [self.viewModel loadData];
    }];
}
-(TestViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [TestViewModel new];
    }
    return _viewModel;
}
@end
```

<img src="/assets/images/iOS/rac/03.gif"/>

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## 冷信号与热信号

### 热信号

* **热信号是主动的，即使你没有订阅事件，它仍然会时刻推送。** 例中：信号在 19:37:55 被创建，在 19:37:56 发出信号1，但是没有订阅，在 19:37:57发出信号2，这是有一个订阅。
* **热信号可以有多个订阅者，是一对多，信号可以与订阅者共享信息。** 例中：订阅者1和订阅者2都在 19:37:58 收到了数据。

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    
    RACMulticastConnection * connection = [[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
            [subscriber sendNext:@1];
        }];
        [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
            [subscriber sendNext:@2];
        }];
        [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{
            [subscriber sendNext:@3];
        }];
        [[RACScheduler mainThreadScheduler] afterDelay:4 schedule:^{
            [subscriber sendCompleted];
        }];
        return nil;
    }]publish];
    [connection connect];
    RACSignal *signal = connection.signal;
    NSLog(@"Signal was created.");
    
    [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
        [signal subscribeNext:^(id  _Nullable x) {
            NSLog(@"Subscriber 1 recveive: %@", x);
        }];
    }];
    [[RACScheduler mainThreadScheduler] afterDelay:2.1 schedule:^{
        [signal subscribeNext:^(id x) {
            NSLog(@"Subscriber 2 recveive: %@", x);
        }];
    }];
}
/*
2020-05-28 19:37:55.689906+0800 RACExample[56065:11840136] Signal was created. 
2020-05-28 19:37:57.690140+0800 RACExample[56065:11840136] Subscriber 1 recveive: 2
2020-05-28 19:37:58.690022+0800 RACExample[56065:11840136] Subscriber 1 recveive: 3
2020-05-28 19:37:58.690210+0800 RACExample[56065:11840136] Subscriber 2 recveive: 3
*/
```

### 冷信号

* **冷信号是被动的，只有当你订阅的时候，它才会发送消息。**
* **冷信号只能一对一，当有不同的订阅者，消息会从新完整发送。** 例中：两个订阅者没有联系，都是基于各自的订阅时间开始接收消息的。

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
            [subscriber sendNext:@1];
        }];
        [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
            [subscriber sendNext:@2];
        }];
        [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{
            [subscriber sendNext:@3];
        }];
        [[RACScheduler mainThreadScheduler] afterDelay:4 schedule:^{
            [subscriber sendCompleted];
        }];
        return nil;
    }];
    NSLog(@"Signal was created.");
    
    [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
        [signal subscribeNext:^(id  _Nullable x) {
            NSLog(@"Subscriber 1 recveive: %@", x);
        }];
    }];
    [[RACScheduler mainThreadScheduler] afterDelay:2.1 schedule:^{
        [signal subscribeNext:^(id x) {
            NSLog(@"Subscriber 2 recveive: %@", x);
        }];
    }];
}
/*
2020-05-28 19:42:38.439542+0800 RACExample[56245:11843585] Signal was created.
2020-05-28 19:42:40.540420+0800 RACExample[56245:11843585] Subscriber 1 recveive: 1
2020-05-28 19:42:41.537044+0800 RACExample[56245:11843585] Subscriber 1 recveive: 2
2020-05-28 19:42:41.849789+0800 RACExample[56245:11843585] Subscriber 2 recveive: 1
2020-05-28 19:42:42.669102+0800 RACExample[56245:11843585] Subscriber 1 recveive: 3
2020-05-28 19:42:42.884800+0800 RACExample[56245:11843585] Subscriber 2 recveive: 2
2020-05-28 19:42:43.841321+0800 RACExample[56245:11843585] Subscriber 2 recveive: 3
*/
```

### 冷信号、热信号比较

```objc
// 冷信号代码
-(void)test_Signal{
    // Create an RACReplaySubject signals
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        // Send Signals
        [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
            [subscriber sendNext:@"replaySubject send package 1"];
        }];
        // Send Signals
        [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
            [subscriber sendNext:@"replaySubject send package 2"];
        }];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"disposable");
        }];
    }];
    NSLog(@"create Signal");
    
    // Subscribe the signal
    [[RACScheduler mainThreadScheduler] afterDelay:0.1 schedule:^{
        //Subscriber1
        [signal subscribeNext:^(id  _Nullable x) {
            NSLog(@"Subscriber 1 get a next value: %@ from replay subject", x);
        }];
        
        //Subscriber2
        [signal subscribeNext:^(id  _Nullable x) {
            NSLog(@"Subscriber 2 get a next value: %@ from replay subject", x);
        }];
    }];
    
    // Subscribe the signal
    [[RACScheduler mainThreadScheduler] afterDelay:1.1 schedule:^{
        //Subscriber3
        [signal subscribeNext:^(id  _Nullable x) {
            NSLog(@"Subscriber 3 get a next value: %@ from replay subject", x);
        }];
        
        //Subscriber4
        [signal subscribeNext:^(id  _Nullable x) {
            NSLog(@"Subscriber 4 get a next value: %@ from replay subject", x);
        }];
    }];
}
// Subject 热信号代码
-(void)test_RACSubject{
    // Create a RACSubject signal
    RACSubject *subject = [RACSubject subject];
    NSLog(@"create Signal");
    
    // Subscribe the signal
    [[RACScheduler mainThreadScheduler] afterDelay:0.1 schedule:^{
        //Subscriber1
        [subject subscribeNext:^(id  _Nullable x) {
            NSLog(@"Subscriber 1 get a next value: %@ from subject", x);
        }];
        //Subscriber2
        [subject subscribeNext:^(id  _Nullable x) {
            NSLog(@"Subscriber 2 get a next value: %@ from subject", x);
        }];
    }];
    
    // Send Signals
    [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
        [subject sendNext:@"subject send package 1"];
    }];
    
    // Subscribe the signal
    [[RACScheduler mainThreadScheduler] afterDelay:1.1 schedule:^{
        //Subscriber3
        [subject subscribeNext:^(id  _Nullable x) {
            NSLog(@"Subscriber 3 get a next value: %@ from subject", x);
        }];
        
        //Subscriber4
        [subject subscribeNext:^(id  _Nullable x) {
            NSLog(@"Subscriber 4 get a next value: %@ from subject", x);
        }];
       
    }];
    
    // Send Signals
    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        [subject sendNext:@"subject send package 2"];
    }];
}
// ReplaySubject 热信号代码
-(void)test_RACReplaySubject{
    // Create an RACReplaySubject signals
    RACSubject *replaySubject = [RACReplaySubject subject];
    NSLog(@"create Signal");
    
    // Subscribe the signal
    [[RACScheduler mainThreadScheduler] afterDelay:0.1 schedule:^{
        //Subscriber1
        [replaySubject subscribeNext:^(id  _Nullable x) {
            NSLog(@"Subscriber 1 get a next value: %@ from replay subject", x);
        }];
        
        //Subscriber2
        [replaySubject subscribeNext:^(id  _Nullable x) {
            NSLog(@"Subscriber 2 get a next value: %@ from replay subject", x);
        }];
    }];
    
    // Send Signals
    [[RACScheduler mainThreadScheduler] afterDelay:1 schedule:^{
        [replaySubject sendNext:@"replaySubject send package 1"];
    }];
    
    // Subscribe the signal
    [[RACScheduler mainThreadScheduler] afterDelay:1.1 schedule:^{
        //Subscriber3
        [replaySubject subscribeNext:^(id  _Nullable x) {
            NSLog(@"Subscriber 3 get a next value: %@ from replay subject", x);
        }];
        
        //Subscriber4
        [replaySubject subscribeNext:^(id  _Nullable x) {
            NSLog(@"Subscriber 4 get a next value: %@ from replay subject", x);
        }];
    }];
    
    // Send Signals
    [[RACScheduler mainThreadScheduler] afterDelay:2 schedule:^{
        [replaySubject sendNext:@"replaySubject send package 2"];
    }];
}
```

`RACSignal`和热信号`RACSubject`时间比较：

* `RACSubject`中，4个订阅者共享`subject`,在`subject`发送信号的时候，所有的订阅者都能收到信号数据；因为`subscriber3`、`subscriber4`订阅的时间稍后，错过了`subject`发送的信号数据。
* 对比发现: `subject`类似<mark>直播，错过了就不再处理</mark>。而`signal`类似<mark>点播，每次订阅都会从头开始</mark>。所以我们有理由认定`subject`天然就是热信号。

<img src="/assets/images/iOS/rac/07.png"/>

冷信号`RACSignal`和热信号`ReplayRACSubject`时间比较：

<img src="/assets/images/iOS/rac/08.png"/>

热信号`RACSubject`和热信号`ReplayRACSubject`时间比较：

* `ReplayRACSubject`中，`Subscriber 3`与`Subscriber 4`在订阅后马上接收到了“历史值”。对于`Subscriber 3`和`Subscriber 4`来说，它们只关心“历史的值”而不关心“历史的时间线”。·

<img src="/assets/images/iOS/rac/09.png"/>

热信号和冷信号类：

<img src="/assets/images/iOS/rac/10.png"/>

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## 基础使用

### delay(延迟)

> 延迟发送next。

```objc
[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    [subscriber sendNext:@(1)];
    [subscriber sendCompleted];
    return nil;
}] delay:2] subscribeNext:^(id  _Nullable x) {
    NSLog(@"subscribeNext:%@", x);
}];
```

### interval(定时)

> 每隔一段时间发出信号

```objc
-(void)test_interval_onScheduler{
    [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
        NSLog(@"interval -- %@", x);
    }];
    // 保证上面的延时操作得以完成
    [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        return nil;
    }] asynchronouslyWaitUntilCompleted:nil];
}
/*
2019-08-07 10:10:38.795691+0800 RACDemo02[45596:1122009] interval -- Wed Aug  7 10:10:38 2019
2019-08-07 10:10:39.796486+0800 RACDemo02[45596:1122009] interval -- Wed Aug  7 10:10:39 2019
2019-08-07 10:10:40.796486+0800 RACDemo02[45596:1122009] interval -- Wed Aug  7 10:10:40 2019
2019-08-07 10:10:41.796472+0800 RACDemo02[45596:1122009] interval -- Wed Aug  7 10:10:41 2019
2019-08-07 10:10:42.796452+0800 RACDemo02[45596:1122009] interval -- Wed Aug  7 10:10:42 2019
2019-08-07 10:10:43.796631+0800 RACDemo02[45596:1122009] interval -- Wed Aug  7 10:10:43 2019
2019-08-07 10:10:44.796494+0800 RACDemo02[45596:1122009] interval -- Wed Aug  7 10:10:44 2019
2019-08-07 10:10:45.796493+0800 RACDemo02[45596:1122009] interval -- Wed Aug  7 10:10:45 2019
*/
```

### ignore(忽略)

> 忽略完某些值的信号

```objc
[[self.textField.rac_textSignal ignore:@"123"] subscribeNext:^(NSString * _Nullable x) {
   NSLog(@"%@",x);
}];

/*
2020-05-28 19:02:21.305235+0800 RACExample[54835:11820168] 1
2020-05-28 19:02:22.011735+0800 RACExample[54835:11820168] 12
2020-05-28 19:02:23.618772+0800 RACExample[54835:11820168] 1234
2020-05-28 19:02:24.323828+0800 RACExample[54835:11820168] 12345
2020-05-28 19:02:25.367480+0800 RACExample[54835:11820168] 123456
2020-05-28 19:02:26.316891+0800 RACExample[54835:11820168] 12345
2020-05-28 19:02:26.874963+0800 RACExample[54835:11820168] 1234
2020-05-28 19:02:29.028761+0800 RACExample[54835:11820168] 12
2020-05-28 19:02:29.442549+0800 RACExample[54835:11820168] 1
2020-05-28 19:02:30.029542+0800 RACExample[54835:11820168] 
*/
```

<img src="/assets/images/iOS/rac/06.gif"/>


### filter(过滤)

> 过滤信号，使用它可以获取满足条件的信号.

```objc
RAC(self.textLabel,text) = [self.textField.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
    NSLog(@"%@",value);
    return [value isEqualToString:@"12345"];
}];

[[self.textField.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
    return [value isEqualToString:@"12345"];
}] subscribeNext:^(NSString * _Nullable x) {
    NSLog(@"%@",x);
}];
```

### combineLatest(结合)、reduce(聚合)

> combineLatest: 将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号。combineLatest 功能和 zipWith一样。 <br>
> reduce:用于信号发出的内容是元组，把信号发出元组的值聚合成一个值,一般都是先结合再聚合。

combineLatest示例:

```objc
-(void)test_combineLatest_1{
    RACReplaySubject * subjectA = [RACReplaySubject subject];
    RACReplaySubject * subjectB = [RACReplaySubject subject];
    RACReplaySubject * subjectC = [RACReplaySubject subject];
    
    // 三个对象同时发送信号，缺一不可
    [subjectA sendNext:@1];
    [subjectB sendNext:@2];
    [subjectC sendNext:@3];

    [[RACSignal combineLatest:@[subjectA,subjectB,subjectC]] subscribeNext:^(id  _Nullable x) {
        // x 的类型为 RACTuple 元组类 -> RACOneTuple、RACTwoTuple、RACThreeTuple、RACFourTuple
         NSLog(@"%@",x);
    }];
    /*
     2020-05-28 18:54:23.910080+0800 RACExample[54517:11813771] <RACTuple: 0x600002aa1410> (
         1,
         2,
         3
     )
     */
}
```

combineLatest、reduce示例:

```objc
- (void)viewDidLoad {
    [super viewDidLoad];

    RACReplaySubject * subjectA = [RACReplaySubject subject];
    RACReplaySubject * subjectB = [RACReplaySubject subject];
    RACReplaySubject * subjectC = [RACReplaySubject subject];
    
    // 三个对象同时发送信号，缺一不可
    [subjectA sendNext:@"邮件AA"];
    [subjectB sendNext:@"邮件BB"];
    [subjectC sendNext:@"邮件CC"];

    // 遵守 NSFastEnumeration 协议的类都可成为数组
    // reduce block 参数可以自己根据信号设置
    [[RACSignal combineLatest:@[subjectA,subjectB,subjectC] reduce:^id (NSString * signalA,NSString * signalB,NSString * signalC){
        // 把这 三个中任意 一个发出的信号值 聚合成一个值 NSString 类型
        return [NSString stringWithFormat:@"A = %@ , B = %@ , C = %@",signalA , signalB , signalC];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"聚合后三个值变成一个 NSString 类型的值： %@",x);
    }];
    
    // 或者
    RAC(self.textLabel,text) = [RACSignal combineLatest:@[subjectA,subjectB,subjectC] reduce:^id (NSString * signalA,NSString * signalB,NSString * signalC){
        return [NSString stringWithFormat:@"A = %@ , B = %@ , C = %@",signalA , signalB , signalC];
    }];
}
/*
2020-05-28 14:28:01.127620+0800 RACExample[44949:11647817] 聚合后三个值变成一个 NSString 类型的值： A = 邮件AA , B = 邮件BB , C = 邮件CC
*/
```

### zipWith(压缩)

> 把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件。 <br>
> 使用 zipWith 时，两个信号必须同时发出信号内容

<img src="/assets/images/iOS/rac/05.png" width = "50%" height = "50%"/>

```objc
-(void)test_zipWith{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@2];
        return nil;
    }];
    [[signalA zipWith:signalB] subscribeNext:^(id  _Nullable x) {
        // x 的类型为 RACTuple 元组类 -> RACOneTuple、RACTwoTuple、RACThreeTuple、RACFourTuple
         NSLog(@"%@",x);
    }];
}
/*
2020-05-28 18:38:30.014387+0800 RACExample[53947:11801545] <RACTwoTuple: 0x600000560900> (
    1,
    2
)
*/
```

### merge(合并)

> 把多个信号合并为一个信号，任何一个信号有新值的时候就会调用 <br>
> 只要有一个信号被发出就会被监听

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    RACReplaySubject * subjectA = [RACReplaySubject subject];
    RACReplaySubject * subjectB = [RACReplaySubject subject];
    RACReplaySubject * subjectC = [RACReplaySubject subject];
    
    // 三个对象发送信号（只需其中一个或多个发送信号时，合并的 信号对象 都可以在订阅的 block 接收到信息）
    [subjectC sendNext:@"CC"];
    [subjectA sendNext:@"AA"];
    [subjectB sendNext:@"BB"];
    
    // 合并两个信号对象变成一个接收信号对象 subjectD , subjectD 订阅 接收 subjectB 和 subjectA 发送的信号,信号输入的顺序和信号merge的顺序有关联。
    [[[subjectB merge:subjectA] merge:subjectC] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}
/*
2020-05-28 14:16:49.377200+0800 RACExample[44542:11640972] BB
2020-05-28 14:16:49.377353+0800 RACExample[44542:11640972] AA
2020-05-28 14:16:49.377509+0800 RACExample[44542:11640972] CC
*/ 
```

### then

> 用于连接两个信号，当第一个信号完成，才会连接then返回的信号

```objc
-(void)test_then{
    // 在这里尽量使用 RACReplaySubject 类 ，因为 RACReplaySubject 可以先发送信号，订阅代码可以放在之后写。
    // 如果 使用 RACSignal 或 RACSubject ，那么必须要等这些对象订阅完后，发送的信号才能接收的到
    RACReplaySubject * subjectA = [RACReplaySubject subject];
    
    // 这就是好处,先发送
    [subjectA sendNext:@"AA"];
    // 必须要调用这个方法才会来到 then 后的 block
    [subjectA sendCompleted];
    
    // 按指定的顺序接收到信号
    [[[subjectA then:^RACSignal * _Nonnull{
        
        // 当 subjectA 发送信号完成后 才执行 当前的 block
        RACReplaySubject * subjectB = [RACReplaySubject subject];
        
        // 可以单独调用发送信号完成的方法就可以接着执行下一个 then
        [subjectB sendCompleted];
        
        return subjectB ;
        
    }] then:^RACSignal * _Nonnull{
        
        // 当 subjectB 发送信号完成后 才执行 当前的 block
        RACReplaySubject * subjectC = [RACReplaySubject subject];
        
        // subjectC 发送信号
        [subjectC sendNext:@"CC"];
        
        return subjectC ;
        
    }] subscribeNext:^(id  _Nullable x) { // 这个就 "相当于" 订阅了 subjectC 对象(但真正的对象则不是 subjectC 对象) ，x = @"CC"
        NSLog(@"RACReplaySubject C x = %@",x);
    }];
}
/*
2020-05-28 14:11:53.916418+0800 RACExample[44368:11637404] RACReplaySubject C x = CC
*/
```

### concat(合并)

> 按一定顺序拼接信号，当多个信号发出的时候，有顺序的接收信号。<br>
> 只有当前一个信号发送成功之后后一个信号才能被发送。

<img src="/assets/images/iOS/rac/04.png" width = "50%" height = "50%"/>

```objc
-(void)test_concat{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        //[subscriber sendError:NULL];
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@2];
        return nil;
    }];
    // 把signalA拼接到signalB后，signalA发送完成，signalB才会被激活
    // 注意：第一个信号必须发送完成，第二个信号才会被激活
    [[signalA concat:signalB] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

/*
当 signalA 的 block 中不执行 [subscriber sendCompleted] 方法，或者执行了 [subscriber sendError:NULL] ，只会打印下面一句话。
2020-05-28 18:30:00.374674+0800 RACExample[53635:11795023] 1

当 signalA 的 block 中执行 [subscriber sendCompleted] 方法时，会输出下面的内容。
2020-05-28 18:30:00.374674+0800 RACExample[53635:11795023] 1
2020-05-28 18:30:00.374674+0800 RACExample[53635:11795023] 2
*/
```

### RACObserve

> RACObserve : KVO 监听属性内容变化

```objc
[RACObserve(self.textLabel, text) subscribeNext:^(id  _Nullable x) {
    NSLog(@"KVO 监听到 age 内容发生变化 ，变为 %@ , thread = %@",x,[NSThread currentThread]);
}];
```

### RACCommand

> RACCommand：处理事件的操作,和UI关联.(主线程中执行)，最常用于两个地方，监听按钮点击，网络请求。

```objc
- (instancetype)initWithSignalBlock:(RACSignal<ValueType> * (^)(InputType _Nullable input))signalBlock;
- (instancetype)initWithEnabled:(nullable RACSignal<NSNumber *> *)enabledSignal signalBlock:(RACSignal<ValueType> * (^)(InputType _Nullable input))signalBlock;
- (RACSignal<ValueType> *)execute:(nullable InputType)input;
```

#### 示例1

```objc
/*==================================VM层======================================*/ 
@interface RACAndMVVMViewModel01 : NSObject
// KVO TextField输入值
@property (strong, nonatomic) NSString *searchText;
//创建一个绑定View的指令.RACCommand是ReactiveCocoa中呈现UI动作的组件.它包含一个来表示UI动作结果、当前状态、标明动作是否被执行的信号量.
@property (strong, nonatomic) RACCommand *executeSearch;
@end
@implementation RACAndMVVMViewModel01
- (instancetype)init {
    if (self == [super init]) {
        [self checkSearchText];
    }
    return self;
}
// 这个方法中将执行一些业务逻辑作为执行命令的结果,并会通过信号异步地返回结果.
// 目前只完成了一个虚拟的执行情况;空信号立即完成.延迟操作增加了完成事件返回后的两秒延迟.用来使代码看起来更加真实.
- (RACSignal *)executeSearchSignal {
    return [[[[RACSignal empty] logAll] delay:2.0] logAll];
}
// 检查 searchText 输入的合法性
-(void)checkSearchText{
    /*[[RACObserve(self, searchText) map:^id _Nullable(NSString*  _Nullable value) {
     return @(value.length > 3);
     }] subscribeNext:^(id  _Nullable x) {
     NSLog(@"search text is valid %@", x);
     }];*/
    
    // distinctUntilChanged 只有输入合法才能进行打印
    RACSignal *validSearchSignal = [[RACObserve(self, searchText) map:^id _Nullable(NSString*  _Nullable value) {
        return @(value.length > 3);
    }]distinctUntilChanged];
    [validSearchSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"search text is valid %@", x);
    }];
    
    self.executeSearch = [[RACCommand alloc] initWithEnabled:validSearchSignal signalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [self executeSearchSignal];
    }];
}
/*
2020-05-29 15:57:23.746708+0800 RACExample[90175:12323634] search text is valid 0
2020-05-29 15:57:27.843193+0800 RACExample[90175:12323634] search text is valid 1
2020-05-29 15:57:34.804425+0800 RACExample[90175:12323634] search text is valid 0
*/
@end
/*==================================V层======================================*/ 
@interface RACAndMVVMViewController01 ()
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (strong, nonatomic) RACAndMVVMViewModel01 *viewModel;
@end

@implementation RACAndMVVMViewController01
- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindViewModel];
}

- (void)bindViewModel {
    RAC(self.viewModel,searchText) = self.searchTextField.rac_textSignal;
    self.loginButton.rac_command = self.viewModel.executeSearch;
}

-(RACAndMVVMViewModel01 *)viewModel{
    if (!_viewModel) {
        _viewModel = [[RACAndMVVMViewModel01 alloc] init];
    }
    return _viewModel;
}
```

<img src="/assets/images/iOS/rac/11.gif"/>

当按钮值为`Input`时，按钮的状态是`Disabled`，因为输入的内容不合法。

#### 示例2

```objc
/*================================================VM层================================================*/
@interface RACAndMVVMViewModel02 : NSObject
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *statusMessage;
@property(nonatomic, strong) RACCommand *subscribeCommand;
@end
@implementation RACAndMVVMViewModel02
-(instancetype)init{
    if (self == [super init]) {
        [self rac_init];
    }
    return self;
}
-(void)rac_init{
    @weakify(self)
    RACSignal *emailSignal = [[RACObserve(self, email) map:^id _Nullable(NSString*  _Nullable value) {
        @strongify(self)
        return @([self isValidEmail:value]);
    }]distinctUntilChanged];
    
    [emailSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    self.subscribeCommand = [[RACCommand alloc] initWithEnabled:emailSignal signalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self)
        return [self businessOperation:self.email];
    }];
    
    RACSignal *rac1 = [self.subscribeCommand.executionSignals map:^id _Nullable(id  _Nullable value) {
        NSLog(@"Request");
        return @"Request";
    }];
    RACSignal *rac2 = [self.subscribeCommand.executionSignals flattenMap:^__kindof RACSignal * _Nullable(RACSignal* signal) {
        return [[[signal materialize]filter:^BOOL(RACEvent *event) {
            NSLog(@"... RACEventType:%zd",event.eventType);
            return event.eventType == RACEventTypeCompleted;
        }] map:^id _Nullable(id  _Nullable value) {
            NSLog(@"Thanks!");
            return @"Thanks!";
        }];
    }];
    RACSignal *rac3 = [[self.subscribeCommand.errors subscribeOn:[RACScheduler mainThreadScheduler]] map:^id _Nullable(NSError * _Nullable value) {
        NSLog(@"Error");
        return @"Error";
    }];
    RAC(self,statusMessage) = [RACSignal merge:@[rac1,rac2,rac3]];
}

// 处理业务逻辑
-(RACSignal*)businessOperation:(NSString*)content{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"Loading...");
        [subscriber sendNext:@"Loading..."];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendError:nil];
        });
        return [RACDisposable disposableWithBlock:^{
        }];
    }];
}

// 检测strin是否是邮件
- (BOOL)isValidEmail:(NSString*)content {
    if (!content) return NO;
    
    NSString *emailPattern =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:emailPattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:content options:0 range:NSMakeRange(0, [content length])];
    return match != nil;
}
@end
/*================================================V层================================================*/
@interface RACAndMVVMViewController02 ()
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property(nonatomic, strong) RACAndMVVMViewModel02 *viewModel;
@end

@implementation RACAndMVVMViewController02

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindViewModel];
}

#pragma mark - RAC Data Binding
- (void)bindViewModel {
    RAC(self.viewModel,email) = self.inputTextField.rac_textSignal;
    RAC(self.statusLabel,text) = RACObserve(self.viewModel, statusMessage);
    self.loginButton.rac_command = self.viewModel.subscribeCommand;
}

#pragma mark - getter
-(RACAndMVVMViewModel02 *)viewModel{
    if (!_viewModel) {
        _viewModel = [RACAndMVVMViewModel02 new];
    }
    return _viewModel;
}
@end

/*
2020-05-29 16:58:36.155235+0800 RACExample[92708:12365862] 0
2020-05-29 16:58:40.675972+0800 RACExample[92708:12365862] 1
2020-05-29 16:58:43.872743+0800 RACExample[92708:12365862] Request
2020-05-29 16:58:43.873233+0800 RACExample[92708:12365862] Loading...
2020-05-29 16:58:43.873464+0800 RACExample[92708:12365862] ... RACEventType:2 --> 0 = RACEventTypeNext
2020-05-29 16:58:45.874203+0800 RACExample[92708:12365862] ... RACEventType:0 --> 0 = RACEventTypeCompleted
2020-05-29 16:58:45.874431+0800 RACExample[92708:12365862] Thanks!
2020-05-29 16:58:45.876062+0800 RACExample[92708:12365862] Error
*/ 
```

<img src="/assets/images/iOS/rac/12.gif"/>

## Foundation

涉及`Foundation`相关的RAC分类:`NSArray`、`NSData`、`NSDictionary`、`NSEnumerator`、`NSFileHandle`、`NSIndexSet`、`NSInvocation`、`NSNotificationCenter`、`NSObject`、`NSOrderedSet`、`NSSet`、`NSString`、`NSURLConnection`、`NSUserDefaults`。

```
NSArray+RACSequenceAdditions.h
NSData+RACSupport.h
NSDictionary+RACSequenceAdditions.h
NSEnumerator+RACSequenceAdditions.h
NSFileHandle+RACSupport.h
NSIndexSet+RACSequenceAdditions.h
NSInvocation+RACTypeParsing.h
NSNotificationCenter+RACSupport.h
NSObject+RACDeallocating.h
NSObject+RACDescription.h
NSObject+RACKVOWrapper.h
NSObject+RACLifting.h
NSObject+RACPropertySubscribing.h
NSObject+RACSelectorSignal.h
NSOrderedSet+RACSequenceAdditions.h
NSSet+RACSequenceAdditions.h
NSString+RACKeyPathUtilities.h
NSString+RACSequenceAdditions.h
NSString+RACSupport.h
NSURLConnection+RACSupport.h
NSUserDefaults+RACSupport.h
```

### NSObject

```
NSObject+RACDeallocating.h
NSObject+RACDescription.h
NSObject+RACKVOWrapper.h
NSObject+RACLifting.h
NSObject+RACPropertySubscribing.h
NSObject+RACSelectorSignal.h
```

#### NSObject+RACLifting

> 等待成所有的 RACSignal 对象发送完信号再执行方法) (主程中执行)

```objc
- (RACSignal *)rac_liftSelector:(SEL)selector withSignals:(RACSignal *)firstSignal, ... NS_REQUIRES_NIL_TERMINATION;
- (RACSignal *)rac_liftSelector:(SEL)selector withSignalsFromArray:(NSArray<RACSignal *> *)signals;
- (RACSignal *)rac_liftSelector:(SEL)selector withSignalOfArguments:(RACSignal<RACTuple *> *)arguments;
```

```objc
- (IBAction)test_rac_lift:(id)sender {
    RACSignal * signalOne = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        // 现在想发出信号了
        [subscriber sendNext:@"网络请求数据 1"];
        // 不需要释放操作
        return nil ;
    }];
    
    RACSignal * signalTwo = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        // 现在想发出信号了
        [subscriber sendNext:@"网络请求数据 2"];
        // 不需要释放操作
        return nil ;
    }];
    [self rac_liftSelector:@selector(updateUIWithSignalOneMessage:signalTwoMessage:) withSignalsFromArray:@[signalOne,signalTwo]];
}
// 当所有数据都拿到手后更新UI , 传的数据就是 signalOne 和 signalTwo 发出来的信号数据 ，(所以当前设计的接收方法 也必需要有两个参数，发出的信号按顺序 传参)
// 假如当前对象方法只设计 传一个参数，那么就会导致崩溃
-(void)updateUIWithSignalOneMessage:(id)signalOneMessage signalTwoMessage:(id)signalTwoMessage{
    NSLog(@"signalOneMessage = %@ , signalTwoMessage = %@ , thread = %@",signalOneMessage,signalTwoMessage,[NSThread currentThread]);
}
//signalOneMessage = 网络请求数据 1 , signalTwoMessage = 网络请求数据 2 , thread = <NSThread: 0x600002f704c0>{number = 1, name = main}
```

### NSNotificationCenter

> RAC 把监听通知的方法改成了 block 形式

```objc
// NSNotificationCenter+RACSupport.h

- (RACSignal<NSNotification *> *)rac_addObserverForName:(nullable NSString *)notificationName object:(nullable id)object;
```

```objc
- (IBAction)test_rac_addObserverForName:(id)sender {
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidHideNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"NSNotification 1 x = %@",x.userInfo);
    }];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidHideNotification object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"NSNotification 2 x = %@",x.userInfo);
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:UIKeyboardDidHideNotification object:nil];
    
    // NSNotification 1 x = (null)
    // NSNotification 2 x = (null)
}
```

### NSString

```
NSString+RACKeyPathUtilities.h
NSString+RACSequenceAdditions.h
NSString+RACSupport.h
```

## UIKit

涉及`UIKit`相关的RAC分类：`UIActionSheet`、`UIAlertView`、`UIBarButtonItem`、`UIButton`、`UICollectionReusableView`、`UIControl`、`UIControl`、`UIDatePicker`、`UIGestureRecognizer`、`UIImagePickerController`、`UIRefreshControl`、`UISegmentedControl`、`UISlider`、`UIStepper`、`UISwitch`、`UITableViewCell`、`UITableViewHeaderFooterView`、`UITextField`、`UITextView`。

```
UIActionSheet+RACSignalSupport.h
UIAlertView+RACSignalSupport.h
UIBarButtonItem+RACCommandSupport.h
UIButton+RACCommandSupport.h
UICollectionReusableView+RACSignalSupport.h
UIControl+RACSignalSupport.h
UIControl+RACSignalSupportPrivate.h
UIDatePicker+RACSignalSupport.h
UIGestureRecognizer+RACSignalSupport.h
UIImagePickerController+RACSignalSupport.h
UIRefreshControl+RACCommandSupport.h
UISegmentedControl+RACSignalSupport.h
UISlider+RACSignalSupport.h
UIStepper+RACSignalSupport.h
UISwitch+RACSignalSupport.h
UITableViewCell+RACSignalSupport.h
UITableViewHeaderFooterView+RACSignalSupport.h
UITextField+RACSignalSupport.h
UITextView+RACSignalSupport.h
```

### UIControl+RACSignalSupportPrivate

```objc
- (RACChannelTerminal *)rac_channelForControlEvents:(UIControlEvents)controlEvents key:(NSString *)key nilValue:(nullable id)nilValue;
```

```ojbc
// 按钮点击响应
[[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) { 
}];
```

### UITextField+RACSignalSupport

```objc
- (RACSignal<NSString *> *)rac_textSignal;
- (RACChannelTerminal<NSString *> *)rac_newTextChannel;
```

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self)
    [[self.textField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
        NSLog(@"text = %@ , textField.text = %@ , thread = %@",x,self.textField.text,[NSThread currentThread]);
    }];
    RAC(self.textLabel,text) = self.textField.rac_textSignal;
}
```

<img src="/assets/images/iOS/rac/01.gif"/>

## 信号处理







### map、flattenMap

> 用于拦截信号发出的信号和处理数据

`map`的返回值类型是`id`类型、`flattenMap`的返回值类型固定为`RACSignal`类型。

```objc
-(void)test_map{
    RACSignal *syncSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        for (int i = 0; i < 5; i++) {
            NSLog(@"signal -- %d", i);
            [subscriber sendNext:@(i)];
        }
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    [[syncSignal map:^id _Nullable(id  _Nullable value) {
        NSLog(@"map -- %@", value);
        return [NSString stringWithFormat:@"MAP+%@",value];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"subscribeNext -- %@", x);
    }];
}
/*
2019-08-30 14:00:05.098586+0800 RACExample[99686:2868124] signal -- 0
2019-08-30 14:00:05.098791+0800 RACExample[99686:2868124] map -- 0
2019-08-30 14:00:05.098987+0800 RACExample[99686:2868124] subscribeNext -- MAP+0
2019-08-30 14:00:05.099149+0800 RACExample[99686:2868124] signal -- 1
2019-08-30 14:00:05.099244+0800 RACExample[99686:2868124] map -- 1
2019-08-30 14:00:05.099370+0800 RACExample[99686:2868124] subscribeNext -- MAP+1
2019-08-30 14:00:05.099522+0800 RACExample[99686:2868124] signal -- 2
2019-08-30 14:00:05.099601+0800 RACExample[99686:2868124] map -- 2
2019-08-30 14:00:05.099717+0800 RACExample[99686:2868124] subscribeNext -- MAP+2
2019-08-30 14:00:05.099866+0800 RACExample[99686:2868124] signal -- 3
2019-08-30 14:00:05.100081+0800 RACExample[99686:2868124] map -- 3
2019-08-30 14:00:05.100398+0800 RACExample[99686:2868124] subscribeNext -- MAP+3
2019-08-30 14:00:05.100599+0800 RACExample[99686:2868124] signal -- 4
2019-08-30 14:00:05.100759+0800 RACExample[99686:2868124] map -- 4
2019-08-30 14:00:05.100999+0800 RACExample[99686:2868124] subscribeNext -- MAP+4
*/
```

flattenMap

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    
    RACSignal *syncSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        for (int i = 0; i < 5; i++) {
            NSLog(@"signal -- %d", i);
            [subscriber sendNext:@(i)];
        }
        [subscriber sendCompleted];
        
        return nil;
    }];

    [[syncSignal flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        NSLog(@"map -- %@", value);
        return [RACSignal return:value].logCompleted;
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"subscribeNext -- %@", x);
    }];
}
/*
2020-05-28 14:44:12.520009+0800 RACExample[45556:11658886] signal -- 0
2020-05-28 14:44:12.520142+0800 RACExample[45556:11658886] map -- 0
2020-05-28 14:44:12.520316+0800 RACExample[45556:11658886] subscribeNext -- 0
2020-05-28 14:44:12.520456+0800 RACExample[45556:11658886] <RACReturnSignal: 0x60000023e320> name:  completed
2020-05-28 14:44:12.520567+0800 RACExample[45556:11658886] signal -- 1
2020-05-28 14:44:12.520658+0800 RACExample[45556:11658886] map -- 1
2020-05-28 14:44:12.520790+0800 RACExample[45556:11658886] subscribeNext -- 1
2020-05-28 14:44:12.520902+0800 RACExample[45556:11658886] <RACReturnSignal: 0x60000023e360> name:  completed
2020-05-28 14:44:12.521116+0800 RACExample[45556:11658886] signal -- 2
2020-05-28 14:44:12.521573+0800 RACExample[45556:11658886] map -- 2
2020-05-28 14:44:12.521995+0800 RACExample[45556:11658886] subscribeNext -- 2
2020-05-28 14:44:12.522413+0800 RACExample[45556:11658886] <RACReturnSignal: 0x600000238520> name:  completed
2020-05-28 14:44:12.522804+0800 RACExample[45556:11658886] signal -- 3
2020-05-28 14:44:12.537218+0800 RACExample[45556:11658886] map -- 3
2020-05-28 14:44:12.537473+0800 RACExample[45556:11658886] subscribeNext -- 3
2020-05-28 14:44:12.537624+0800 RACExample[45556:11658886] <RACReturnSignal: 0x600000238560> name:  completed
2020-05-28 14:44:12.537738+0800 RACExample[45556:11658886] signal -- 4
2020-05-28 14:44:12.537825+0800 RACExample[45556:11658886] map -- 4
2020-05-28 14:44:12.537941+0800 RACExample[45556:11658886] subscribeNext -- 4
2020-05-28 14:44:12.538046+0800 RACExample[45556:11658886] <RACReturnSignal: 0x600000238580> name:  completed
*/
```





* `flattenMap` map 用于把源信号内容映射成新的内容。
* `distinctUntilChanged`:当上一次的值和当前的值有明显的变化就会发出信号，否则会被忽略掉。
* `take`:从开始一共取N次的信号
* `takeLast`:取最后N次的信号,前提条件，订阅者必须调用完成，因为只有完成，就知道总共有多少信号.
* `takeUntil`:(RACSignal):获取信号直到某个信号执行完成
* `skip`:(NSUInteger):跳过几个信号,不接受。
* `switchToLatest`:用于signalOfSignals（信号的信号），有时候信号也会发出信号，会在signalOfSignals中，获取signalOfSignals发送的最新信号。
* `doNext`: 执行Next之前，会先执行这个Block
* `doCompleted`: 执行sendCompleted之前，会先执行这个Block
* `timeout`：超时，可以让一个信号在一定的时间后，自动报错。
* `interval` 定时：每隔一段时间发出信号
* `retry重试` ：只要失败，就会重新执行创建信号中的block,直到成功.
* `replay重放`：当一个信号被多次订阅,反复播放内容
* `throttle节流`:当某个信号发送比较频繁时，可以使用节流，在某一段时间不发送信号内容，过了一段时间获取信号的最新内容发出。

## 信号相关类

```
RACDynamicSignal.h
RACEmptySignal.h
RACErrorSignal.h
RACGroupedSignal.h
RACReturnSignal.h
RACSignal+Operations.h
RACSignal.h
RACSignalProvider.d
RACSignalSequence.h
```

### RACSignal+Operations

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## RAC&MVVM

### 

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## 资料

* [Github-ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)
* [响应式编程（Reactive Programming）介绍](https://www.tuicool.com/articles/BBNRRf)
* [UITextField-RAC使用详解](https://link.jianshu.com/?t=http://www.raywenderlich.com/?p=62699)