---
title: ReactiveCocoa
layout: post
categories:
 - ios
---

[代码的仓库](https://gitee.com/samcoding/RACExample.git)

## 基础

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

### skip、take、takeUntil、takeLast

* `take`:从开始一共取N次的信号
* `takeLast`:取最后N次的信号,前提条件，订阅者必须调用完成，因为只有完成，就知道总共有多少信号.
* `takeUntil`:(RACSignal):获取信号直到某个信号执行完成(原始信号一直发送信号，直到，替代的信号发出事件，原始信号终止)。
* `skip`:(NSUInteger):跳过几个信号,不接受。

```objc
-(RACSignal*)createSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        for (int i = 0; i < 5; i++) {
            NSLog(@"subscriber sendNext -- %d", i);
            [subscriber sendNext:@(i)];
        }
        NSLog(@"sendCompleted");
        [subscriber sendCompleted];
        
        return nil;
    }];
}
-(void)test_take{
    RACSignal *signal = [self createSignal];
   [signal subscribeNext:^(id  _Nullable x) {
       NSLog(@"subscribeNext -- %@", x);
   }];
    /*
     2020-06-03 14:51:53.558366+0800 RACExample[30888:2260368] subscriber sendNext -- 0
     2020-06-03 14:51:53.558606+0800 RACExample[30888:2260368] subscribeNext -- 0
     2020-06-03 14:51:53.558714+0800 RACExample[30888:2260368] subscriber sendNext -- 1
     2020-06-03 14:51:53.558807+0800 RACExample[30888:2260368] subscribeNext -- 1
     2020-06-03 14:51:53.558898+0800 RACExample[30888:2260368] subscriber sendNext -- 2
     2020-06-03 14:51:53.558985+0800 RACExample[30888:2260368] subscribeNext -- 2
     2020-06-03 14:51:53.559069+0800 RACExample[30888:2260368] subscriber sendNext -- 3
     2020-06-03 14:51:53.559159+0800 RACExample[30888:2260368] subscribeNext -- 3
     2020-06-03 14:51:53.559249+0800 RACExample[30888:2260368] subscriber sendNext -- 4
     2020-06-03 14:51:53.559439+0800 RACExample[30888:2260368] subscribeNext -- 4
     2020-06-03 14:51:53.559708+0800 RACExample[30888:2260368] sendCompleted
     */
```

上面是正常的订阅。

```objc
-(void)test_take{
    [[signal take:2] subscribeNext:^(id  _Nullable x) {
        NSLog(@"subscribeNext -- %@", x);
    }];
    /*
     2020-06-03 14:53:40.530949+0800 RACExample[30990:2262219] subscriber sendNext -- 0
     2020-06-03 14:53:40.531286+0800 RACExample[30990:2262219] subscribeNext -- 0
     2020-06-03 14:53:40.531476+0800 RACExample[30990:2262219] subscriber sendNext -- 1
     2020-06-03 14:53:40.531610+0800 RACExample[30990:2262219] subscribeNext -- 1
     2020-06-03 14:53:40.531734+0800 RACExample[30990:2262219] subscriber sendNext -- 2
     2020-06-03 14:53:40.531829+0800 RACExample[30990:2262219] subscriber sendNext -- 3
     2020-06-03 14:53:40.531924+0800 RACExample[30990:2262219] subscriber sendNext -- 4
     2020-06-03 14:53:40.532056+0800 RACExample[30990:2262219] sendCompleted
     */
}
```

`take:2` : 只取前两次订阅的信号。

```objc
-(void)test_take{
    [[[signal skip:1] take:1] subscribeNext:^(id  _Nullable x) {
        NSLog(@"subscribeNext -- %@", x);
    }];
    /*
     2020-06-03 14:59:58.615703+0800 RACExample[31246:2265921] subscriber sendNext -- 0 ==> 虽然发送的数据，但是 subscriber 没有使用，跳过这一条
     2020-06-03 14:59:58.616069+0800 RACExample[31246:2265921] subscriber sendNext -- 1
     2020-06-03 14:59:58.616254+0800 RACExample[31246:2265921] subscribeNext -- 1       ==> take:1
     2020-06-03 14:59:58.616376+0800 RACExample[31246:2265921] subscriber sendNext -- 2
     2020-06-03 14:59:58.616494+0800 RACExample[31246:2265921] subscriber sendNext -- 3
     2020-06-03 14:59:58.616608+0800 RACExample[31246:2265921] subscriber sendNext -- 4
     */
}
```
`skip:1`和`take:1` : 跳过第一条开始接收数据，并且只取前一条数据。

```objc
-(void)test_takeLast{
    [[signal takeLast:1] subscribeNext:^(id  _Nullable x) {
        NSLog(@"subscribeNext -- %@", x);
    }];
    /*
     2020-06-03 15:04:32.363153+0800 RACExample[31419:2268388] signal -- 0
     2020-06-03 15:04:32.363415+0800 RACExample[31419:2268388] signal -- 1
     2020-06-03 15:04:32.363534+0800 RACExample[31419:2268388] signal -- 2
     2020-06-03 15:04:32.363639+0800 RACExample[31419:2268388] signal -- 3
     2020-06-03 15:04:32.363741+0800 RACExample[31419:2268388] signal -- 4
     2020-06-03 15:04:32.363943+0800 RACExample[31419:2268388] subscribeNext -- 3
     2020-06-03 15:04:32.364053+0800 RACExample[31419:2268388] subscribeNext -- 4
     */
}
```

`takeLast:1` : 只获取最新的数据。

### map、flattenMap(拦截信号处理数据)

> 用于拦截信号发出的信号和处理数据 <br>
>`flattenMap` : `map`用于把源信号内容映射成新的内容。

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

### 其他使用

* `distinctUntilChanged`:当上一次的值和当前的值有明显的变化就会发出信号，否则会被忽略掉。
* `switchToLatest`:用于signalOfSignals（信号的信号），有时候信号也会发出信号，会在signalOfSignals中，获取signalOfSignals发送的最新信号。
* `doNext`: 执行Next之前，会先执行这个Block
* `doCompleted`: 执行sendCompleted之前，会先执行这个Block
* `timeout`：超时，可以让一个信号在一定的时间后，自动报错。
* `interval` 定时：每隔一段时间发出信号
* `retry重试` ：只要失败，就会重新执行创建信号中的block,直到成功.
* `replay重放`：当一个信号被多次订阅,反复播放内容
* `throttle节流`:当某个信号发送比较频繁时，可以使用节流，在某一段时间不发送信号内容，过了一段时间获取信号的最新内容发出。

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## RACCommand的使用

> RACCommand：处理事件的操作,和UI关联.(主线程中执行)，最常用于两个地方，监听按钮点击，网络请求。

```objc
- (instancetype)initWithSignalBlock:(RACSignal<ValueType> * (^)(InputType _Nullable input))signalBlock;
- (instancetype)initWithEnabled:(nullable RACSignal<NSNumber *> *)enabledSignal signalBlock:(RACSignal<ValueType> * (^)(InputType _Nullable input))signalBlock;
- (RACSignal<ValueType> *)execute:(nullable InputType)input;
```

#### 示例：登录

```objc
/*================================================宏================================================*/
#define GreenBgColor [UIColor colorWithRed:0.8 green:1.0 blue:0.8 alpha:1]
#define RedBgColor   [UIColor colorWithRed:1.0 green:0.8 blue:0.8 alpha:1]
#define WhiteBgColor [UIColor whiteColor]
#define ConvertInputStateToColor(signal) [InputStateToColorConverter convert:signal]
#define ConvertTextToInputState(signal, minimum, maximum) [TextToInputStateConverter convert:signal m##inimum:minimum m##aximum:maximum]
typedef enum : NSUInteger {
    InputStateEmpty,
    InputStateValid,
    InputStateInvalid
} InputState;

/*================================================V层-InputStateToColorConverter================================================*/
@interface InputStateToColorConverter : NSObject
+ (RACSignal *)convert:(RACSignal *)signal;
@end
@implementation InputStateToColorConverter
+ (RACSignal *)convert:(RACSignal *)signal{
    return [signal map:^id(NSNumber *inputStateNumber) {
        InputState inputState = [inputStateNumber unsignedIntegerValue];
        switch (inputState) {
            case InputStateValid:
                return GreenBgColor;
            case InputStateInvalid:
                return RedBgColor;
            default:
                return WhiteBgColor;
        }
    }];
}
@end
/*================================================V层-TextToInputStateConverter================================================*/
@interface TextToInputStateConverter : NSObject
+ (RACSignal *)convert:(RACSignal *)signal minimum:(NSInteger)minimum maximum:(NSInteger)maximum;
+ (InputState)inputStateForText:(NSString *)text minimum:(NSInteger)minimum maximum:(NSInteger)maximum;
@end
@implementation TextToInputStateConverter
+ (RACSignal *)convert:(RACSignal *)signal minimum:(NSInteger)minimum maximum:(NSInteger)maximum{
    NSAssert(minimum > 0, @"TextToInputStateConverter: minimum must be greater than zero");
    NSAssert(maximum >= minimum, @"TextToInputStateConverter: maximum must be greater than or equal to minimum");
    return [signal map:^id(NSString *text) {
        return @([TextToInputStateConverter inputStateForText:text minimum:minimum maximum:maximum]);
    }];
}
+ (InputState)inputStateForText:(NSString *)text minimum:(NSInteger)minimum maximum:(NSInteger)maximum{
    if ([text length] >= minimum && [text length] <= maximum) {
        return InputStateValid;
    } else {
        if ([text length] == 0) {
            return InputStateEmpty;
        } else {
            return InputStateInvalid;
        }
    }
}
@end
#pragma mark - ====================VM层====================
@interface LoginViewModel : NSObject
@property (copy, nonatomic) NSString *usename;
@property (copy, nonatomic) NSString *password;

@property (nonatomic, assign, readonly) InputState usernameInputState;
@property (nonatomic, assign, readonly) InputState passwordInputState;
@property (nonatomic, assign, readonly) BOOL loginEnabled;
@end

@interface LoginViewModel()
@property (nonatomic, assign, readwrite) InputState usernameInputState;
@property (nonatomic, assign, readwrite) InputState passwordInputState;
@property (nonatomic, assign, readwrite) BOOL loginEnabled;
@end

@implementation LoginViewModel
#pragma mark - init
-(instancetype)init{
    if (self = [super init]) {
        [self racInit];
    }
    return self;
}
#pragma mark - business
- (void)racInit {
    RAC(self,usernameInputState) = ConvertTextToInputState(RACObserve(self,usename), 2, 4);
    RAC(self,passwordInputState) = ConvertTextToInputState(RACObserve(self,password), 5, 10);
    
    RAC(self,loginEnabled) = [RACSignal combineLatest:@[RACObserve(self,usernameInputState),RACObserve(self,passwordInputState)] reduce:^id(NSNumber *usernameInputStateValue,NSNumber *passwordInputStateValue){
        if ([usernameInputStateValue unsignedIntegerValue] == InputStateValid &&
            [passwordInputStateValue unsignedIntegerValue] == InputStateValid) {
            return @(YES);
        }
        return @(NO);
    }];
}
#pragma mark - getter
@end

#pragma mark - ====================V层====================
@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usenameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextFeidl;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property(nonatomic, strong) LoginViewModel *viewModel;
@end

@implementation LoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self segInitViews];
    [self bindViewModel];
}

#pragma mark - init Views
-(void)segInitViews{
}

#pragma mark - RAC Data Binding
- (void)bindViewModel {
    // bind input signals
    RAC(self.viewModel,usename) = self.usenameTextField.rac_textSignal;
    RAC(self.viewModel,password) = self.passwordTextFeidl.rac_textSignal;
    // bind output signals
    RAC(self.usenameTextField,backgroundColor) = ConvertInputStateToColor(RACObserve(self.viewModel, usernameInputState));
    RAC(self.passwordTextFeidl,backgroundColor) = ConvertInputStateToColor(RACObserve(self.viewModel, passwordInputState));
    RAC(self.loginButton, enabled) = RACObserve(self.viewModel, loginEnabled);
    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"Login....");
    }];
}

#pragma mark - getter
-(LoginViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[LoginViewModel alloc]init];
    }
    return _viewModel;
}
@end
```

<img src="/assets/images/iOS/rac/14.gif"/>

#### 示例：豆瓣列表

```objc
#pragma mark - ====================VM层====================
//定义命令、网络请求、获取数据、发送数据
@interface DouBanDetailViewModel : NSObject
@property (nonatomic, copy, readonly) NSArray<NSString*> *movies;
@property (nonatomic, strong, readonly) RACCommand *requestCommand;
@property (nonatomic, strong, readonly) AFHTTPSessionManager *manager;
@end
@implementation DouBanDetailViewModel
#pragma mark - init
-(instancetype)init{
    if (self = [super init]) {
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.douban.com"]];
        [self racInit];
    }
    return self;
}
#pragma mark - business
- (void)racInit {
    @weakify(self)
    _requestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        // 网络请求
        RACSignal *requestSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            [self.manager GET:@"/v2/movie/in_theaters" parameters:input progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                NSLog(@"sendNext");
                [subscriber sendNext:responseObject];
                [subscriber sendCompleted];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [subscriber sendError:error];
                NSLog(@"sendError");
            }];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"disposableWithBlock");
            }];
        }];
        // 业务逻辑处理
        return [requestSignal map:^id _Nullable(id  _Nullable value) {
            NSLog(@"map");
            NSMutableArray *tempt = [NSMutableArray array];
            NSMutableArray *dictArray = value[@"subjects"];
            for (NSDictionary *object in dictArray) {
                [tempt addObject:[object valueForKey:@"title"]];
            }
            self->_movies = [NSArray arrayWithArray:tempt];;
            return nil;
        }];
    }];
}
#pragma mark - getter
@end
#pragma mark - ====================V层====================

@interface DouBanViewDetailController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic, strong) DouBanDetailViewModel *viewModel;
@end

@implementation DouBanViewDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self segInitViews];
    [self bindViewModel];
}

#pragma mark - init Views
-(void)segInitViews{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - RAC Data Binding
- (void)bindViewModel {
    @weakify(self)
    [[[self.viewModel.requestCommand executionSignals] switchToLatest] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        NSLog(@"switchToLatest:%@",x);
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    }];

    [self.viewModel.requestCommand.errors subscribeNext:^(NSError * _Nullable x) {
        NSLog(@"errors subscribeNext:%@",x);
        [SVProgressHUD dismiss];
    }];
    
    // 发起网络请求
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"apikey"] = @"0df993c66c0c636e29ecbb5344252a4a";
    [self.viewModel.requestCommand execute:parameters];
    [SVProgressHUD show];
}

// 或者可以这样
- (void)bindViewModel {
    @weakify(self)
    [[self.viewModel.requestCommand executionSignals] subscribeNext:^(RACSignal*  _Nullable x) {
        NSLog(@"subscribeNext1:%@",x);
        [SVProgressHUD show];
        [x subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            NSLog(@"subscribeNext2:%@",x);
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        }];
    }];
    
    [self.viewModel.requestCommand.errors subscribeNext:^(NSError * _Nullable x) {
        NSLog(@"errors subscribeNext:%@",x);
        [SVProgressHUD dismiss];
    }];
    // 发起网络请求
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"apikey"] = @"0df993c66c0c636e29ecbb5344252a4a";
    [self.viewModel.requestCommand execute:parameters];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.viewModel.movies.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DouBanDetailTableViewCell *cell = [DouBanDetailTableViewCell cellWithTableView:tableView indexPath:indexPath];
    cell.textLabel.text = self.viewModel.movies[indexPath.row];
    return cell;
}

#pragma mark - getter
-(DouBanDetailViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[DouBanDetailViewModel alloc]init];
    }
    return _viewModel;
}
@end
```

<img src="/assets/images/iOS/rac/13.gif"/>

#### RACCommand中的sendError没反应的解答

* [RAC中用RACCommand处理指令](https://blog.harrisonxi.com/2017/09/RAC%E4%B8%AD%E7%94%A8RACCommand%E5%A4%84%E7%90%86%E6%8C%87%E4%BB%A4.html)

```objc
// 这样使用就可以捕捉到Error了。
[self.viewModel.requestCommand.errors subscribeNext:^(NSError * _Nullable x) {
     NSLog(@"errors subscribeNext:%@",x);
}];
```

#### 示例:多接口请求

```objc
@interface DouBanDetailViewModel : NSObject
@property (nonatomic, strong, readonly) RACCommand *requestCommand;
@end
@implementation DouBanDetailViewModel
#pragma mark - init
-(instancetype)init{
    if (self = [super init]) {
        [self racInit];
    }
    return self;
}
#pragma mark - business
- (void)racInit {
    _requestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        //网络请求1
        RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"网络请求1");
            [subscriber sendNext:@"网络请求1"];
            return  nil;
        }];
        
        //网络请求2
        RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"网络请求2");
            [subscriber sendNext:@"网络请求2"];
            return  nil;
        }];
        
        //网络请求3
        RACSignal *signal3 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"网络请求3");
            [subscriber sendNext:@"网络请求3"];
            return  nil;
        }];
        
        return [self rac_liftSelector:@selector(dealDataWithData1:data2:data3:) withSignalsFromArray:@[signal1,signal2,signal3]];
    }];
}

-(void)dealDataWithData1:(id)data1 data2:(id)data2 data3:(id)data3{}
#pragma mark - getter
@end
```

V层使用：

```objc
- (void)bindViewModel {
    // 发起网络请求
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"q"] = _conditions;
    parameters[@"apikey"] = @"0df993c66c0c636e29ecbb5344252a4a";
    [self.viewModel.requestCommand execute:parameters];
    [SVProgressHUD show];
    
    [self.viewModel.requestCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        [self.tableView reloadData];
        [SVProgressHUD dismiss];
    }];
    [self.viewModel.requestCommand.executionSignals subscribeError:^(NSError * _Nullable error) {
        [SVProgressHUD dismiss];
        NSLog(@"subscribeError");
    }];
    [[[self.viewModel.requestCommand executing] skip:1] subscribeNext:^(NSNumber * _Nullable x) {
    }];
}
```

#### 示例：RAC、distinctUntilChanged

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

#### 示例：发邮件

```objc
#pragma mark - ====================VM层====================
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
#pragma mark - ====================V层====================
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

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## RACChannel

### [RACChannel实现双向绑定](https://blog.harrisonxi.com/2017/07/RAC%E4%B8%AD%E7%94%A8RACChannel%E5%AE%9E%E7%8E%B0%E5%8F%8C%E5%90%91%E7%BB%91%E5%AE%9A.html)

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

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

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

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

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

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

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## rac_deallocDisposable、rac_deallocDisposable、rac_prepareForReuseSignal

* `NSObject` : `rac_deallocDisposable`
* `NSObject` : `rac_willDeallocSignal`
* `UITableViewCell` : `rac_prepareForReuseSignal`

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## Tips

```objc
@interface HomeViewModel : NSObject
@property (nonatomic, copy) NSString *searchConditons;
@property (nonatomic, strong, readonly) RACSignal  *searchBtnEnableSignal;
@end
@implementation HomeViewModel
-(instancetype)init{
    if (self = [super init]) {
        [self setUp];
    }
    return self;
}
- (void)setUp{
    [self setupSearchBtnEnableSignal];
}
- (void)setupSearchBtnEnableSignal {
    _searchBtnEnableSignal = [RACSignal combineLatest:@[RACObserve(self, searchConditons)] reduce:^id(NSString *searchConditions){
        return @(searchConditions.length);
    }];
}
@end

// =====================================================

@interface MovieViewModel : NSObject
@property (nonatomic, strong, readonly) RACCommand *requestCommand;
@property (nonatomic, copy, readonly) NSArray *movies;
@end
@implementation MovieViewModel

-(instancetype)init{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}
- (void)setup {
    _requestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"%@", input);
        RACSignal *requestSignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NetworkManager *manager = [NetworkManager manager];
            [manager getDataWithUrl:@"https://api.douban.com/v2/movie/search" parameters:input success:^(id json) {
                [subscriber sendNext:json];
                [subscriber sendCompleted];
            } failure:^(NSError *error) {
                
            }];
            
            return nil;
        }];
        return [requestSignal map:^id _Nullable(id  _Nullable value) {
            NSMutableArray *dictArray = value[@"subjects"];
            NSArray *modelArray = [dictArray.rac_sequence map:^id(id value) {
                return [Movie movieWithDict:value];
            }].array;
           NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"year" ascending:NO];
            _movies = [modelArray sortedArrayUsingDescriptors:@[sortDescriptor]];
            NSLog(@"%@",_movies.description);
            
            return nil;
        }];
    }];
}
@end
```

在两个VM中，一个用的是`RACSignal`，一个用的是`RACCommand`：

* `RACSignal`是单向的，就像1个人在做演讲，观众听到就结束了
* `RACCommand`是双向的，演讲者做演讲，下面的观众听到后还反馈了意见，而演讲者对反馈还做了回复。(V中发出命令，VM收到命令后进行网络请求，并将获取的网络数据包发送出去，V对收到的数据进行解析和显示)。

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## RAC&MVVM开发规约

### VM层

```objc
@implementation SEGMenberPointsViewModel
#pragma mark - init
-(instancetype)init{
    if (self = [super init]) {
        [self racInit];
    }
    return self;
}
#pragma mark - business
- (void)racInit {}
#pragma mark - getter
@end
```

### V层

#### Controller
```objc
@interface LoginViewController ()
@property(nonatomic, strong) RACAndMVVMViewModel *viewModel;
@end

@implementation LoginViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self segInitViews];
    [self bindViewModel];
}
#pragma mark - init Views
-(void)segInitViews{}

#pragma mark - Layout
- (void)updateViewConstraints {
    [super updateViewConstraints];
}

#pragma mark - RAC Data Binding
- (void)bindViewModel {}

#pragma mark - getter
-(RACAndMVVMViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[RACAndMVVMViewModel alloc]init];
    }
    return _viewModel;
}
@end
```

有些方案会把`Controller`中的`View`也自定义出来，成为主`View`，具体样例：

VM层：

```objc
#pragma mark - ====================VM层====================
@interface LoginMainViewModel : NSObject
// Demo RACSubject
@property (nonatomic, strong) RACSubject *pushSubject;
@end
@implementation LoginMainViewModel
#pragma mark - init
-(instancetype)init{
    if (self = [super init]) {
        [self racInit];
    }
    return self;
}

#pragma mark - business
- (void)racInit {}

#pragma mark - getter
- (RACSubject *)pushSubject {
    if (!_pushSubject) {
        _pushSubject = [RACSubject subject];
    }
    return _pushSubject;
}
@end
```

主View层：

```objc
#pragma mark - ====================V层====================
@interface LoginMainView : UIView
// Demo Button
@property(nonatomic,strong) UIButton* button;
@property(nonatomic,strong) LoginMainViewModel* viewModel;
- (instancetype)initWithViewModel:(LoginMainViewModel*)viewModel;
@end

@implementation LoginMainView
- (instancetype)initWithViewModel:(LoginMainViewModel*)viewModel {
    if (self == [super init]) {
        _viewModel = viewModel;
        [self segInitViews];
        [self updateConstraints];
        [self bindViewModel];
    }
    return self;
}

#pragma mark - init Views
-(void)segInitViews{}

#pragma mark - Layout
- (void)updateConstraints {
    [super updateConstraints];
}
#pragma mark - RAC Data Binding
- (void)bindViewModel {
    // Demo sendNext
    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self.viewModel.pushSubject sendNext:@"1"];
    }];
}

#pragma mark - getter
-(LoginMainViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[LoginMainViewModel alloc]init];
    }
    return _viewModel;
}
@end
```

Controller层：

```objc
#pragma mark - ====================V层====================
@interface LoginViewController ()
@property (nonatomic, strong) LoginMainView *mainView;
@property(nonatomic, strong) LoginMainViewModel *viewModel;
@end
@implementation LoginViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self segInitViews];
    [self bindViewModel];
}
#pragma mark - init Views
-(void)segInitViews{
    [self.view addSubview:self.mainView];
}

#pragma mark - Layout
- (void)updateViewConstraints {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [super updateViewConstraints];
}

#pragma mark - RAC Data Binding
- (void)bindViewModel {
    // Demo subscribeNext
    @weakify(self);
    [self.viewModel.pushSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self.navigationController pushViewController:[UIViewController new] animated:YES];
    }];
}

#pragma mark - getter
- (LoginMainView *)mainView {
    if (!_mainView) {
        _mainView = [[LoginMainView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}
-(LoginMainViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[LoginMainViewModel alloc]init];
    }
    return _viewModel;
}
@end
```

#### 自定义UIView

```objc
@interface  LoginTableView: UIView
@property(nonatomic,strong) LoginTableViewModel* viewModel;
- (instancetype)initWithViewModel:(LoginTableViewModel*)viewModel;
@end
@implementation LoginTableView
- (instancetype)initWithViewModel:(LoginTableViewModel*)viewModel {
    if (self == [super init]) {
        _viewModel = viewModel;
        [self segInitViews];
        [self updateConstraints];
        [self bindViewModel];
    }
    return self;
}

#pragma mark - init Views
-(void)segInitViews{}

#pragma mark - Layout
- (void)updateConstraints {
    [super updateConstraints];
}
#pragma mark - RAC Data Binding
- (void)bindViewModel {}

#pragma mark - getter
-(LoginTableViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[LoginTableViewModel alloc]init];
    }
    return _viewModel;
}
@end
```

#### 自定义复用机制UIView

> 有复用机制的View：UICollectionviewCell、UITableViewCell...,因为有复用机制，会有部份cell不会走`init`方法，而是直接走`cell复用池`。

```objc
@interface  LoginTableViewCell: UITableViewCell
@property (strong, nonatomic) NSIndexPath *indexPath;
@property(nonatomic,strong) CircleListMainViewCellViewModel* viewModel;

+(NSString*)reuseIdentifier;
+(CircleListMainViewCell*)cellWithTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;
@end
@implementation LoginTableViewCell
#pragma mark - init Views
+(NSString*)reuseIdentifier{
    return NSStringFromClass([self class]);
}

+(CircleListMainViewCell*)cellWithTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath{
    CircleListMainViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier]];
    if (!cell) {
        cell = [[CircleListMainViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self reuseIdentifier]];
    }
    cell.indexPath = indexPath;
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self segInitViews];
        [self updateConstraints];
    }
    return self;
}

-(void)segInitViews{}

#pragma mark - Layout
- (void)updateConstraints {
    [super updateConstraints];
}

#pragma mark - RAC Data Binding
- (void)bindViewModel {}

#pragma mark - getter

#pragma mark setter
-(void)setViewModel:(LoginTableViewCellViewModel *)viewModel{
    _viewModel = viewModel;
    if (!viewModel)  return;
    [self bindViewModel];
}
@end
```

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## MVVM&RAC

### 使用设计

* 一个V(`ViewController`也是一个V)对应一个VM，V界面元素属性与 VM 处理后的数据属性绑定。
* `ViewController`对应的VM算是主VM。主 VM 承担了网络请求、点击事件协议、初始化子 VM 并且给子VM的属性赋初值；网络请求成功返回数据过后，主 ViewModel 还需要给子 ViewModel 的属性赋予新的值。

```objc
@interface mainViewModel : NSObject
@property (nonatomic, strong) MineHeaderViewModel *mineHeaderViewModel;
@property (nonatomic, strong) NSArray<MineTopCollectionViewCellViewModel *> *dataSorceOfMineTopCollectionViewCell;
@property (nonatomic, strong) NSArray<MineDownCollectionViewCellViewModel *> *dataSorceOfMineDownCollectionViewCell;
@property (nonatomic, strong) RACCommand *autoLoginCommand;//用于网络请求
@property (nonatomic, strong) RACSubject *pushSubject;//相当于协议，这里用于点击事件的代理
@end
```

### 示例：列表刷新

具体效果：

<img src="/assets/images/iOS/rac/15.gif"/>

```
2020-06-03 14:20:34.431310+0800 RACExample[29796:2244630] refreshDataCommand execute
2020-06-03 14:20:34.464985+0800 RACExample[29796:2244630] executing subscribeNext
2020-06-03 14:20:34.465376+0800 RACExample[29796:2244630] RefreshLoading
2020-06-03 14:20:35.088477+0800 RACExample[29796:2244630] refreshDataCommand subscriber sendNext
2020-06-03 14:20:35.088770+0800 RACExample[29796:2244630] switchToLatest subscribeNext
2020-06-03 14:20:35.092880+0800 RACExample[29796:2244630] RefreshUI
2020-06-03 14:20:35.093239+0800 RACExample[29796:2244630] refreshDataCommand subscriber sendCompleted
2020-06-03 14:20:37.458024+0800 RACExample[29796:2244630] refreshDataCommand subscriber sendNext
2020-06-03 14:20:37.458241+0800 RACExample[29796:2244630] switchToLatest subscribeNext
2020-06-03 14:20:37.458642+0800 RACExample[29796:2244630] RefreshUI
2020-06-03 14:20:37.458772+0800 RACExample[29796:2244630] refreshDataCommand subscriber sendCompleted
2020-06-03 14:20:38.549670+0800 RACExample[29796:2244630] refreshDataCommand subscriber sendNext
2020-06-03 14:20:38.549901+0800 RACExample[29796:2244630] switchToLatest subscribeNext
2020-06-03 14:20:38.550304+0800 RACExample[29796:2244630] RefreshUI
2020-06-03 14:20:38.550600+0800 RACExample[29796:2244630] refreshDataCommand subscriber sendCompleted
2020-06-03 14:20:40.055668+0800 RACExample[29796:2244630] refreshDataCommand subscriber sendNext
2020-06-03 14:20:40.055887+0800 RACExample[29796:2244630] switchToLatest subscribeNext
2020-06-03 14:20:40.056336+0800 RACExample[29796:2244630] RefreshUI
2020-06-03 14:20:40.056514+0800 RACExample[29796:2244630] refreshDataCommand subscriber sendCompleted
```

他们的项目结构：

```
├── Controller
│   ├── CircleListViewController.h
│   └── CircleListViewController.m
├── Model
│   ├── DouBanTheatersModel.h
│   └── DouBanTheatersModel.m
├── View
│   ├── CircleListMainView.h
│   ├── CircleListMainView.m
│   ├── CircleListMainViewCell.h
│   └── CircleListMainViewCell.m
└── ViewModel
    ├── CircleListMainViewCellViewModel.h
    ├── CircleListMainViewCellViewModel.m
    ├── CircleListMainViewModel.h
    └── CircleListMainViewModel.m
```

#### CircleListViewController

```objc
@interface CircleListViewController ()
@property (nonatomic, strong) CircleListMainView *mainView;
@property(nonatomic, strong) CircleListMainViewModel *viewModel;
@end

@implementation CircleListViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self segInitViews];
    [self bindViewModel];
}
#pragma mark - init Views
-(void)segInitViews{
    [self.view addSubview:self.mainView];
}

#pragma mark - Layout
- (void)updateViewConstraints {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [super updateViewConstraints];
}

#pragma mark - RAC Data Binding
- (void)bindViewModel {
    // 点击 cell 跳转 Controller
    @weakify(self);
    [[self.viewModel.cellClickSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(CircleListMainViewCellViewModel*  _Nullable x) {
        @strongify(self);
        UIViewController *VC = [UIViewController new];
        VC.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController pushViewController:VC animated:YES];
    }];
}

#pragma mark - getter
- (CircleListMainView *)mainView {
    if (!_mainView) {
        _mainView = [[CircleListMainView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}
-(CircleListMainViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[CircleListMainViewModel alloc]init];
    }
    return _viewModel;
}
@end
```

#### ViewModel

##### CircleListMainViewModel

```objc
typedef enum : NSUInteger {
    RefreshLoading, // 正在刷新
    RefreshError, // 刷新出错
    RefreshUI, // 仅仅刷新UI布局
} RefreshDataStatus;

@interface CircleListMainViewModel : NSObject
@property (nonatomic, strong) RACCommand *refreshDataCommand;
@property (nonatomic, strong) RACSubject *refreshDataSubject;

@property (nonatomic, strong) RACSubject *cellClickSubject;//点击cell的热信号

@property (nonatomic, strong,readonly) NSArray<CircleListMainViewCellViewModel*> *dataArray;
@end

// ============================.m==========================
@interface CircleListMainViewModel()
@property (nonatomic, strong) HttpManager *httpManager;
@property (nonatomic, strong,readwrite) NSArray<CircleListMainViewCellViewModel*> *dataArray;
@end

implementation CircleListMainViewModel
#pragma mark - init
-(instancetype)init{
    if (self = [super init]) {
        [self racInit];
    }
    return self;
}
#pragma mark - business
- (void)racInit {
    // 初始化 RACCommand ，并发起网络请求。
    _refreshDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            
            // 网络请求
            NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
            parameters[@"apikey"] = @"0df993c66c0c636e29ecbb5344252a4a";
            [self.httpManager requestNetworkDataWithUrlString:@"/v2/movie/in_theaters" Params:parameters completed:^(id  _Nonnull response, NSError * _Nonnull error) {
                if (error) {
                    NSLog(@"refreshDataCommand subscriber sendError");
                    [subscriber sendError:error];
                }else{
                    NSLog(@"refreshDataCommand subscriber sendNext");
                    [subscriber sendNext:response];
                }
                NSLog(@"refreshDataCommand subscriber sendCompleted");
                [subscriber sendCompleted];
            }];
            
            return [RACDisposable disposableWithBlock:^{
            }];
        }];
    }];
    
    // 信号流：O-O-O-O-O-O，而下面这段就是,跳过第一个信号，并且只执行一次。
    [[[_refreshDataCommand.executing skip:1] take:1] subscribeNext:^(NSNumber * _Nullable x) {
        NSLog(@"executing subscribeNext");
        [self showStatus:@"正在加载..."];
    }];
    
    // 进行业务处理
    [[[_refreshDataCommand executionSignals] switchToLatest] subscribeNext:^(NSDictionary*  _Nullable response) {
        NSLog(@"switchToLatest subscribeNext");
        
        if (!response) {
             [self showErrorStatus:@"网络有问题！"];
            return;
        }
        
        // 把 BO 数据转成 VM
        NSMutableArray<CircleListMainViewCellViewModel*>*tempt = [NSMutableArray array];
        NSArray *subjects = [response valueForKey:@"subjects"];
        for (NSDictionary *object in subjects) {;
            CircleListMainViewCellViewModel *cellViewModel = [[CircleListMainViewCellViewModel alloc] init];
            cellViewModel.model = [DouBanTheatersModel yy_modelWithJSON:object];
            [tempt addObject:cellViewModel];
        }
        self.dataArray = [NSArray arrayWithArray:tempt];
        [self showMessage:@"请求成功！"];
    }];
    
    // 错误处理
    [_refreshDataCommand.errors subscribeNext:^(NSError * _Nullable x) {
        NSLog(@"errors subscribeNext");
        [self showErrorStatus:@"网络有问题！"];
    }];
}
-(void)showMessage:(NSString*)message{
    [self.refreshDataSubject sendNext:@{@"code":@(RefreshUI),@"msg":message}];
}
-(void)showStatus:(NSString*)status{
    [self.refreshDataSubject sendNext:@{@"code":@(RefreshLoading),@"msg":status}];
}
-(void)showErrorStatus:(NSString*)error{
    [self.refreshDataSubject sendNext:@{@"code":@(RefreshError),@"msg":error}];
}

#pragma mark - getter
-(HttpManager *)httpManager{
    if (!_httpManager) {
        _httpManager = [[HttpManager alloc] initWithBaseURLString:@"https://api.douban.com"];
    }
    return _httpManager;
}
-(RACSubject *)refreshDataSubject{
    if (!_refreshDataSubject) {
        _refreshDataSubject = [RACSubject subject];
    }
    return _refreshDataSubject;
}

-(RACSubject *)cellClickSubject{
    if (!_cellClickSubject) {
        _cellClickSubject = [RACSubject subject];
    }
    return _cellClickSubject;
}
@end
```

##### CircleListMainViewCellViewModel

```objc
@interface CircleListMainViewCellViewModel : NSObject
@property (strong, nonatomic) DouBanTheatersModel *model;
@end

@implementation CircleListMainViewCellViewModel
#pragma mark - init
-(instancetype)init{
    if (self = [super init]) {
        [self racInit];
    }
    return self;
}
#pragma mark - business
- (void)racInit {}
#pragma mark - getter
-(DouBanTheatersModel *)model{
    if (!_model) {
        _model = [[DouBanTheatersModel alloc] init];
    }
    return _model;
}
@end
```

#### View

##### CircleListMainView

```objc
@interface CircleListMainView : UIView
@property(nonatomic,strong) CircleListMainViewModel* viewModel;
- (instancetype)initWithViewModel:(CircleListMainViewModel*)viewModel;
@end

// ==============================.m================================

@interface CircleListMainView()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *mainTableView;
@end

@implementation CircleListMainView
- (instancetype)initWithViewModel:(CircleListMainViewModel*)viewModel {
    if (self == [super init]) {
        self.backgroundColor = self.superview.backgroundColor;
        _viewModel = viewModel;
        [self segInitViews];
        [self setNeedsUpdateConstraints];
        [self updateConstraintsIfNeeded];
        [self bindViewModel];
    }
    return self;
}

#pragma mark - init Views
-(void)segInitViews{
    [self addSubview:self.mainTableView];
}

#pragma mark - Layout
- (void)updateConstraints {
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [super updateConstraints];
}
#pragma mark - RAC Data Binding
- (void)bindViewModel {
    [SVProgressHUD setMinimumDismissTimeInterval:1.0];
    
    // 数据请求
    NSLog(@"refreshDataCommand execute");
    [self.viewModel.refreshDataCommand execute:nil];
    // 数据刷新
    [self.viewModel.refreshDataSubject subscribeNext:^(NSDictionary*  _Nullable x) {
        [self.mainTableView.mj_header endRefreshing];
        [self.mainTableView.mj_footer endRefreshing];
        
        [self.mainTableView reloadData];
        
        NSInteger code = [[x valueForKey:@"code"] integerValue];
        NSString* msg = [x valueForKey:@"msg"];
        
        switch (code) {
            case RefreshLoading:
                NSLog(@"RefreshLoading");
                [SVProgressHUD show];
                break;
            case RefreshError:
                NSLog(@"RefreshError");
                [SVProgressHUD showErrorWithStatus:msg];
                break;
            case RefreshUI:
                NSLog(@"RefreshUI");
                [SVProgressHUD showSuccessWithStatus:msg];
                break;
            default:
                break;
        }
    }];
}

#pragma mark - getter
-(CircleListMainViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[CircleListMainViewModel alloc]init];
    }
    return _viewModel;
}
- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] init];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.backgroundColor = self.backgroundColor;
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            [self.viewModel.refreshDataCommand execute:nil];
        }];
        _mainTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [self.viewModel.refreshDataCommand execute:nil];
        }];
    }
    return _mainTableView;
}

#pragma mark - ====================delegate====================

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CircleListMainViewCell *cell = [CircleListMainViewCell cellWithTableView:tableView indexPath:indexPath];
    if (self.viewModel.dataArray.count > indexPath.row) {
        cell.viewModel = self.viewModel.dataArray[indexPath.row];
    }
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.dataArray.count > indexPath.row) {
        [self.viewModel.cellClickSubject sendNext:self.viewModel.dataArray[indexPath.row]];
    }
}
@end
```

##### CircleListMainViewCell

```objc
@interface CircleListMainViewCell : UITableViewCell
@property (strong, nonatomic) NSIndexPath *indexPath;
@property(nonatomic,strong) CircleListMainViewCellViewModel* viewModel;

+(NSString*)reuseIdentifier;
+(CircleListMainViewCell*)cellWithTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;
@end

@implementation CircleListMainViewCell
#pragma mark - init Views
+(NSString*)reuseIdentifier{
    return NSStringFromClass([self class]);
}

+(CircleListMainViewCell*)cellWithTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath{
    CircleListMainViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier]];
    if (!cell) {
        cell = [[CircleListMainViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self reuseIdentifier]];
    }
    cell.indexPath = indexPath;
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self segInitViews];
        [self updateConstraints];
    }
    return self;
}

-(void)segInitViews{}

#pragma mark - Layout
- (void)updateConstraints {
    [super updateConstraints];
}

#pragma mark - RAC Data Binding
- (void)bindViewModel {
    self.textLabel.text = self.viewModel.model.title;
    
    //RAC(self.textLabel,text) = RACObserve(self.viewModel.model, title); ==> 这个在数据刷新的时候报错！因为KVO的keypath重复绑定。
    //RAC(self.textLabel,text) = [RACObserve(self.viewModel.model, title) takeUntil:self.rac_prepareForReuseSignal]; ==> 可以通过这样的方式搞定。
    //在cell里面创建的信号加上takeUntil:cell.rac_prepareForReuseSignal，这个是让cell在每次重用的时候都去disposable创建的信号。
}

#pragma mark - getter

#pragma mark setter
-(void)setViewModel:(CircleListMainViewCellViewModel *)viewModel{
    _viewModel = viewModel;
    if (!viewModel)  return;
    [self bindViewModel];
}
@end
```

### TableView&UIButton

在`UITableViewCell`中有`UIButton`按钮，点击按钮出发回调，会有如下一种错误场景：**刷新数据时，会重复订阅，导致方法多次触发**

<img src="/assets/images/iOS/rac/16.gif"/>

**CircleListMainView:**

```objc
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CircleListMainViewCell *cell = [CircleListMainViewCell cellWithTableView:tableView indexPath:indexPath];
    if (self.viewModel.dataArray.count > indexPath.row) {
        cell.viewModel = self.viewModel.dataArray[indexPath.row];
    }
    [cell.viewModel.buttonClickSubject subscribeNext:^(id  _Nullable x) {
        NSLog(@"raiseButton subscribeNext--%@",x);
    }];
    return cell;
}
```

**CircleListMainViewCell:**

```objc
@implementation CircleListMainViewCell
#pragma mark - RAC Data Binding
- (void)bindViewModel {
   @weakify(self);
   [[self.raiseButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
       @strongify(self);
       [self.viewModel.buttonClickSubject sendNext:self.viewModel.model];
   }];
}
@end
```

在`UITableViewCell`的分类中，有一个属性`rac_prepareForReuseSignal`，可以解决这一问题。

```objc
@implementation CircleListMainViewCell
#pragma mark - RAC Data Binding
- (void)bindViewModel {
    @weakify(self);
    [[[self.raiseButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self.viewModel.buttonClickSubject sendNext:self.viewModel.model.title];
    }];
}
@end
```

<img src="/assets/images/iOS/rac/17.gif"/>

### TableView&UITextField

```objc
RACChannelTo(self.viewModel,leftString) =  RACChannelTo(self.leftTextField,text);
[RACObserve(self.viewModel,leftString) subscribeNext:^(id  _Nullable x) {
    NSLog(@"leftString %@",x);
}];
[[self.clickButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
    self.viewModel.leftString = @"代码设置StringValue";
}];
```

<img src="/assets/images/iOS/rac/18.gif"/>

通过`RACChannelTo`对`TextField.txt`和`VM.leftString`进行双向绑定，可以发现，`TextField`进行键盘输入时，`VM.leftString`的值不会更新。当通过代码去对`VM.leftString`进行赋值时，`TextField.txt`的值更新了。而按照官方的说法就是，`UIKIt`里面的很多控件本身不支持`KVO`，而`ReactiveCocoa`本身是基于`KVO`实现的，所以就会出现这种双向绑定不成功的现象。

* `self.valueTextField.rac_newTextChannel` : sends values when you type in the text field, but not when you change the text in the text field from code.
* `RACChannelTo(self.valueTextField, text)` : sends values when you change the text in the text field from code, but not when you type in the text field.

```objc
RACChannelTo(self.viewModel,leftString) = self.leftTextField.rac_newTextChannel;
```

<img src="/assets/images/iOS/rac/19.gif"/>

#### TableViewCell&UITextField

<img src="/assets/images/iOS/rac/20.gif"/>

```objc
#pragma mark - ====================VM层====================
@interface TextFieldAndTableCellViewModel : NSObject
@property (copy, nonatomic) NSString *leftString;
@property (copy, nonatomic) NSString *rightString;
@property (strong, nonatomic) NSArray<TextFieldAndTableViewCellViewModel*> *dataArray;
@end
@implementation TextFieldAndTableCellViewModel
-(NSArray *)dataArray{
    if (!_dataArray) {
        NSMutableArray *tempt = [NSMutableArray array];
        for (NSInteger i = 0; i <= 10; i++) {
            TextFieldAndTableViewCellViewModel *data = [[TextFieldAndTableViewCellViewModel alloc] init];
            data.tag = i;
            [tempt addObject:data];
        }
        _dataArray = [NSArray arrayWithArray:tempt];
    }
    return _dataArray;
}
@end

#pragma mark - ====================V层====================

@interface TextFieldAndTableCellViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *leftTextField;
@property (weak, nonatomic) IBOutlet UITextField *rightTextField;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *clickButton;

@property(nonatomic, strong) TextFieldAndTableCellViewModel *viewModel;
@end

@implementation TextFieldAndTableCellViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self segInitViews];
    [self bindViewModel];
    [self.tableView reloadData];
}
#pragma mark - init Views
-(void)segInitViews{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - Layout
- (void)updateViewConstraints {
    [super updateViewConstraints];
}

#pragma mark - RAC Data Binding
- (void)bindViewModel {
    [[self.clickButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        [self.tableView endEditing:YES];
        for (TextFieldAndTableViewCellViewModel *object in self.viewModel.dataArray) {
            NSLog(@"inputValue %@",object.inputValue);
        }
    }];
}

#pragma mark - getter
-(TextFieldAndTableCellViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[TextFieldAndTableCellViewModel alloc]init];
    }
    return _viewModel;
}
#pragma mark - ====================delegate====================

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TextFieldAndTableViewCell *cell = [TextFieldAndTableViewCell cellWithTableView:tableView indexPath:indexPath];
    cell.viewModel = self.viewModel.dataArray[indexPath.row];
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
@end
```

```objc
@interface TextFieldAndTableViewCell : UITableViewCell
@property (strong, nonatomic) UITextField *inputTextField;

@property (strong, nonatomic) NSIndexPath *indexPath;
@property(nonatomic,strong) TextFieldAndTableViewCellViewModel* viewModel;

+(NSString*)reuseIdentifier;
+(TextFieldAndTableViewCell*)cellWithTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;
@end

@implementation TextFieldAndTableViewCell
#pragma mark - init Views
+(NSString*)reuseIdentifier{
    return NSStringFromClass([self class]);
}

+(TextFieldAndTableViewCell*)cellWithTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath{
    TextFieldAndTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier] forIndexPath:indexPath];
    if (!cell) {
        cell = [[TextFieldAndTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self reuseIdentifier]];
    }
    cell.indexPath = indexPath;
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self segInitViews];
        [self updateConstraints];
    }
    return self;
}

-(void)segInitViews{
    [self.contentView addSubview:self.inputTextField];
}

#pragma mark - Layout
- (void)updateConstraints {
    [self.inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.contentView).mas_offset(5);
        make.right.bottom.equalTo(self.contentView).mas_offset(-5);
    }];
    [super updateConstraints];
}

#pragma mark - RAC Data Binding
- (void)bindViewModel {
    self.inputTextField.text = self.viewModel.inputValue;
    self.inputTextField.tag = self.viewModel.tag;
    
    @weakify(self)
    [[[[self.inputTextField rac_textSignal] takeUntil:self.rac_prepareForReuseSignal] filter:^BOOL(NSString * _Nullable value) {
        NSLog(@"filter -- %@", value);
        return YES;
    }] subscribeNext:^(NSString * _Nullable x) {
        @strongify(self);
        NSLog(@"subscribeNext %@ tag:%zd",x,self.inputTextField.tag);
        self.viewModel.inputValue = x;
    }];
}

#pragma mark - getter

#pragma mark setter
-(void)setViewModel:(TextFieldAndTableViewCellViewModel *)viewModel{
    _viewModel = viewModel;
    if (!viewModel)  return;
    [self bindViewModel];
}

-(UITextField *)inputTextField{
    if (!_inputTextField) {
        _inputTextField = [[UITextField alloc] init];
        _inputTextField.font = [UIFont systemFontOfSize:16];
        _inputTextField.textColor = [UIColor blackColor];
        _inputTextField.tintColor = [UIColor blackColor];
    }
    return _inputTextField;
}
@end
```

```objc
@interface TextFieldAndTableViewCellViewModel : NSObject
@property (nonatomic, copy) NSString *inputValue;
@property (nonatomic, assign) NSInteger tag;
@end

@implementation TextFieldAndTableViewCellViewModel
#pragma mark - init
-(instancetype)init{
    if (self = [super init]) {
        [self racInit];
    }
    return self;
}
#pragma mark - business
- (void)racInit {
}
#pragma mark - getter
@end
```

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## 资料

* [Github-ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)
* [响应式编程（Reactive Programming）介绍](https://www.tuicool.com/articles/BBNRRf)
* [UITextField-RAC使用详解](https://link.jianshu.com/?t=http://www.raywenderlich.com/?p=62699)
* [iOS使用RAC实现MVVM的正经姿势](https://blog.harrisonxi.com/2017/07/iOS%E4%BD%BF%E7%94%A8RAC%E5%AE%9E%E7%8E%B0MVVM%E7%9A%84%E6%AD%A3%E7%BB%8F%E5%A7%BF%E5%8A%BF.html)

http://timmy6.github.io/2019/02/27/MVVM/