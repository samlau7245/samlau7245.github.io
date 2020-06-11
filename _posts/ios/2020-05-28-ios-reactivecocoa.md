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

### RACMulticastConnection

```objc
RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    NSLog(@"发送信号1");
    [subscriber sendNext:@"1"];
    return nil;
}];
[signal subscribeNext:^(id  _Nullable x) { NSLog(@"第一次订阅：%@",x);}];
[signal subscribeNext:^(id  _Nullable x) { NSLog(@"第二次订阅：%@",x);}];
/*
2020-06-08 16:20:16.479977+0800 RACExample[46980:352112] 发送信号1
2020-06-08 16:20:16.480517+0800 RACExample[46980:352112] 第一次订阅：1
2020-06-08 16:20:16.480976+0800 RACExample[46980:352112] 发送信号1
2020-06-08 16:20:16.481336+0800 RACExample[46980:352112] 第二次订阅：1
*/
```

在信号`signal`被订阅2次以后，`createSignal:`block也被触发了2次。通过`RACMulticastConnection`可以解决信号被n次订阅后，block也会被触发n次的情况。

```objc
RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    NSLog(@"发送信号1");
    [subscriber sendNext:@"1"];
    return nil;
}];
RACMulticastConnection *signalBconnect = [signal publish];
[signalBconnect.signal subscribeNext:^(id  _Nullable x) { NSLog(@"第一次订阅：%@",x);}];
[signalBconnect.signal subscribeNext:^(id  _Nullable x) { NSLog(@"第二次订阅：%@",x);}];
[signalBconnect connect];
/*
2020-06-08 16:25:18.009553+0800 RACExample[47186:354797] 发送信号1
2020-06-08 16:25:18.009805+0800 RACExample[47186:354797] 第一次订阅：1
2020-06-08 16:25:18.009907+0800 RACExample[47186:354797] 第二次订阅：1
*/
```

也可以通过`RACSignal`热信号去解决，其实`RACMulticastConnection`就相当于把`signal`变成了热信号：

```objc
RACSubject *subject = [RACSubject subject];
[subject subscribeNext:^(id  _Nullable x) { NSLog(@"第一次订阅：%@",x);}];
[subject subscribeNext:^(id  _Nullable x) { NSLog(@"第二次订阅：%@",x);}];
NSLog(@"发送信号1");
[subject sendNext:@"1"];
/*
2020-06-08 16:26:34.201680+0800 RACExample[47240:355739] 发送信号1
2020-06-08 16:26:34.202059+0800 RACExample[47240:355739] 第一次订阅：1
2020-06-08 16:26:34.202349+0800 RACExample[47240:355739] 第二次订阅：1
*/
```

### 线程操作

* 副作用：关于信号与线程,我们把在创建信号时block中的代码称之为副作用。
* `deliverON`：切换到指定线程中，可用于回到主线中刷新UI,内容传递切换到指定线程中，
* `subscribeOn`：内容传递和副作用都会切换到指定线程中。
* `deliverOnMainThread`：能保证原信号`subscribeNext`，`sendError`，`sendCompleted`都在主线程`MainThread`中执行。

```objc
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"sendNext1:%@",[NSThread currentThread]);// sendNext1:<NSThread: 0x600001f36300>{number = 4, name = (null)}
        [subscriber sendNext:@"1"];
        return nil;
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"subscribeNext%@:%@",x,[NSThread currentThread]);//subscribeNext1:<NSThread: 0x600001f36300>{number = 4, name = (null)}
    }];
});
// 发送消息、接收消息都是在异步线程。

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"sendNext1:%@",[NSThread currentThread]);// sendNext1:<NSThread: 0x600003e40040>{number = 4, name = (null)}
        [subscriber sendNext:@"1"];
        return nil;
    }] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id  _Nullable x) {
        NSLog(@"subscribeNext%@:%@",x,[NSThread currentThread]);//subscribeNext1:<NSThread: 0x600003e04980>{number = 1, name = main}
    }];
});
// 接收消息在主线程。

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"sendNext1:%@",[NSThread currentThread]);// sendNext1:<NSThread: 0x6000035fcbc0>{number = 1, name = main}
        [subscriber sendNext:@"1"];
        return nil;
    }] subscribeOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id  _Nullable x) {
        NSLog(@"subscribeNext%@:%@",x,[NSThread currentThread]);//subscribeNext1:<NSThread: 0x6000035fcbc0>{number = 1, name = main}
    }];
});
// 发送消息、接收消息都是在主线程。
```

### 信号节流:throttle

* `throttle节流`:当某个信号发送比较频繁时，可以使用节流，在某一段时间不发送信号内容，过了一段时间获取信号的最新内容发出。

```objc
[[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    NSLog(@"11");[subscriber sendNext:@"发送消息11"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"21");[subscriber sendNext:@"发送消息21"];
        NSLog(@"22");[subscriber sendNext:@"发送消息22"];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"31");[subscriber sendNext:@"发送消息31"];
        NSLog(@"32");[subscriber sendNext:@"发送消息32"];
        NSLog(@"33");[subscriber sendNext:@"发送消息33"];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"41");[subscriber sendNext:@"发送消息41"];
        NSLog(@"42");[subscriber sendNext:@"发送消息42"];
        NSLog(@"43");[subscriber sendNext:@"发送消息43"];
        NSLog(@"44");[subscriber sendNext:@"发送消息44"];
    });
    return nil;
}] throttle:2] subscribeNext:^(id  _Nullable x) {
    NSLog(@"Next:%@",x);
}];

/*
2020-06-08 19:09:37.356497+0800 RACExample[54681:455884] 11
2020-06-08 19:09:39.357101+0800 RACExample[54681:455884] Next:发送消息11
2020-06-08 19:09:39.357366+0800 RACExample[54681:455884] 21
2020-06-08 19:09:39.357518+0800 RACExample[54681:455884] 22
2020-06-08 19:09:40.540307+0800 RACExample[54681:455884] 31
2020-06-08 19:09:40.541107+0800 RACExample[54681:455884] 32
2020-06-08 19:09:40.541341+0800 RACExample[54681:455884] 33
2020-06-08 19:09:41.357386+0800 RACExample[54681:455884] 41
2020-06-08 19:09:41.357600+0800 RACExample[54681:455884] 42
2020-06-08 19:09:41.357734+0800 RACExample[54681:455884] 43
2020-06-08 19:09:41.357856+0800 RACExample[54681:455884] 44
2020-06-08 19:09:43.369260+0800 RACExample[54681:455884] Next:发送消息44
*/
```


### 信号错误重试:retry

* `retry重试` ：只要失败，就会重新执行创建信号中的block,直到成功.

```objc
static int signalANum = 0;
RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    if (signalANum >= 5) {
        NSLog(@"sendNext %d",signalANum);
        [subscriber sendNext:[NSString stringWithFormat:@"尝试次数累计：%d",signalANum]];
        [subscriber sendCompleted];
    }else{
        NSLog(@"sendError %d",signalANum);
        [subscriber sendError:[NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"Something is wrong!"}]];
    }
    signalANum++;
    return nil;
}];

[[signal retry] subscribeNext:^(id  _Nullable x) {
    NSLog(@"subscribeNext：%@",x);
} error:^(NSError * _Nullable error) {
    NSLog(@"error info: %@",error.localizedDescription);
}];
/*
2020-06-08 19:03:16.750255+0800 RACExample[54389:451981] sendError 0
2020-06-08 19:03:16.774608+0800 RACExample[54389:451981] sendError 1
2020-06-08 19:03:16.774899+0800 RACExample[54389:451981] sendError 2
2020-06-08 19:03:16.775074+0800 RACExample[54389:451981] sendError 3
2020-06-08 19:03:16.775254+0800 RACExample[54389:451981] sendError 4
2020-06-08 19:03:16.775446+0800 RACExample[54389:451981] sendNext 5
2020-06-08 19:03:16.775579+0800 RACExample[54389:451981] subscribeNext：尝试次数累计：5
*/
```

### 获取信号中的信号: switchToLatest

* `switchToLatest`只能用于信号中的信号(否则崩溃)，获取最新发送的信号。
* `switchToLatest`:用于`signalOfSignals（信号的信号）`，有时候信号也会发出信号，会在`signalOfSignals`中，获取`signalOfSignals`发送的最新信号。

### 信号发送顺序:doNext、doCompleted

* 发送信号前与发送信号后操作：`doNext`、`doCompleted`。
* `doNext`：在订阅者发送消息sendNext之前执行。
* `doCompleted`：在订阅者发送完成sendCompleted之后执行。

```objc
RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    NSLog(@"发送信号：1");
    [subscriber sendNext:@"发送信号：1"];
    [subscriber sendCompleted];
    return nil;
}];
[[[signal doNext:^(id  _Nullable x) {
    NSLog(@"doNext,%@",x);
}] doCompleted:^{
    NSLog(@"doCompleted");
}] subscribeNext:^(id  _Nullable x) {
    NSLog(@"激活信号：%@",x);
}];
/*
2020-06-08 18:49:53.413848+0800 RACExample[53730:443023] 发送信号：1
2020-06-08 18:49:53.414098+0800 RACExample[53730:443023] doNext,发送信号：1
2020-06-08 18:49:53.414220+0800 RACExample[53730:443023] 激活信号：发送信号：1
2020-06-08 18:49:53.414823+0800 RACExample[53730:443023] doCompleted
*/
```

### 信号取值:take、takeUntil、takeLast

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

* `map` ：将信号内容修改为另一种新值。改变了传递的值。
* `flattenMap`：将源信号映射修改为另一种新的信号(`RACSignal`),修改了信号本身。

#### 示例

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

#### 示例

```objc
//创建一个普通信号
RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    for (NSInteger i = 0; i <= 5; i ++) {
        [subscriber sendNext:@(i)];
    }
    [subscriber sendCompleted];
    return nil;
}];

//创建一个发送信号的信号，信号的信号
RACSignal *signalOfSignals = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    [subscriber sendNext:signal];
    [subscriber sendCompleted];
    return nil;
}];

[signalOfSignals subscribeNext:^(id  _Nullable x) {
    //不使用flattenMap，会打印出内部信号
    NSLog(@"订阅signalOfSignals：%@",x);
}];

[[signalOfSignals flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
    return [value filter:^BOOL(NSNumber*  _Nullable value) {
        NSLog(@"filter：%@",value);
        return [value integerValue] >= 2 ? YES: NO;
    }];
}] subscribeNext:^(id  _Nullable x) {
    //使用flattenMap，会打印内部信号的值
    NSLog(@"使用flattenMap后订阅signalOfSignals：%@",x);
}];

/*
2020-06-08 17:54:26.211401+0800 RACExample[51286:408356] 订阅signalOfSignals：<RACDynamicSignal: 0x6000011c3880> name: 
2020-06-08 17:54:26.213350+0800 RACExample[51286:408356] filter：0
2020-06-08 17:54:26.213911+0800 RACExample[51286:408356] filter：1
2020-06-08 17:54:26.214308+0800 RACExample[51286:408356] filter：2
2020-06-08 17:54:26.214501+0800 RACExample[51286:408356] 使用flattenMap后订阅signalOfSignals：2
2020-06-08 17:54:26.214642+0800 RACExample[51286:408356] filter：3
2020-06-08 17:54:26.214780+0800 RACExample[51286:408356] 使用flattenMap后订阅signalOfSignals：3
2020-06-08 17:54:26.214903+0800 RACExample[51286:408356] filter：4
2020-06-08 17:54:26.215048+0800 RACExample[51286:408356] 使用flattenMap后订阅signalOfSignals：4
2020-06-08 17:54:26.215221+0800 RACExample[51286:408356] filter：5
2020-06-08 17:54:26.215357+0800 RACExample[51286:408356] 使用flattenMap后订阅signalOfSignals：5
*/
```

### 信号操作时间:delay(延迟)

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

### 信号操作时间:interval(定时)

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

### 信号操作时间:timeout(超时)

* `timeout`：超时，可以让一个信号在一定的时间后，自动报错。

```objc
[[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    [[RACScheduler mainThreadScheduler] afterDelay:3 schedule:^{
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
    }];
    return nil;
}] timeout:2.0 onScheduler:[RACScheduler currentScheduler]] subscribeNext:^(id  _Nullable x) {
    NSLog(@"subscribeNext：%@",x);
} error:^(NSError * _Nullable error) {
    NSLog(@"error：%@",error.localizedDescription);
} completed:^{
    NSLog(@"completed");
}];
/*
error：The operation couldn’t be completed. (RACSignalErrorDomain error 1.)
*/
```

### 信号过滤:distinctUntilChanged

> `distinctUntilChanged`:当上一次的值和当前的值有明显的变化就会发出信号，否则会被忽略掉。

```objc
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
```

### 信号过滤:ignore(忽略)

> 忽略完某些值的信号，针对信号值的某一种状态进行忽略，忽略时不会发送消息。

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


### 信号过滤:filter(过滤)

> 过滤信号，使用它可以获取满足条件的信号,符合条件的信号才能发出消息。

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

### 信号合并:combineLatest(结合)、reduce(聚合)

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

### 信号合并:zipWith(压缩)

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

### 信号合并:merge(合并)

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

### 信号拼接:then(连接)

* 使用then连接信号，上一个信号完成后，才会连接then返回的信号，所以then连接的上一个信号必须使用`sendCompleted`，否则后续信号无法执行。
* then连接的多个信号与concat不同的是：**之前的信号会被忽略掉，即订阅信号只会接收到最后一个信号的值**。

```objc
[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    NSLog(@"signalOne");
    [subscriber sendNext:@"signalOne"];
    [subscriber sendCompleted];
    return nil;
}] subscribeNext:^(id  _Nullable x) {
    NSLog(@"信号被激活:%@",x);
}];
/*
2020-06-08 18:28:17.835711+0800 RACExample[52619:427692] signalOne
2020-06-08 18:28:17.836206+0800 RACExample[52619:427692] 信号被激活:signalOne
*/
```

添加一个`then`信号：

```objc
[[[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    NSLog(@"signalOne");
    [subscriber sendNext:@"signalOne"];
    [subscriber sendCompleted];
    return nil;
}] then:^RACSignal * _Nonnull{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"signalTwo");
        [subscriber sendNext:@"signalTwo"];
        [subscriber sendCompleted];
        return nil;
    }];
}] then:^RACSignal * _Nonnull{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"signalThree");
        [subscriber sendNext:@"signalThree"];
        [subscriber sendCompleted];
        return nil;
    }];
}] subscribeNext:^(id  _Nullable x) {
    NSLog(@"信号被激活:%@",x);
}];
/*
2020-06-08 18:34:42.158566+0800 RACExample[52963:432992] signalOne
2020-06-08 18:34:42.159054+0800 RACExample[52963:432992] signalTwo
2020-06-08 18:34:42.159283+0800 RACExample[52963:432992] signalThree
2020-06-08 18:34:42.159633+0800 RACExample[52963:432992] 信号被激活:signalThree
*/
```

### 信号拼接:concat(合并)

* 使用`concat`可以按序拼接多个信号，拼接后的信号按序执行。
* 只有前面的信号执行`sendCompleted`，后面的信号才会被激活。

<img src="/assets/images/iOS/rac/04.png" width = "50%" height = "50%"/>

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    
    RACSignal *signalOne = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"signalOne"];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalTwo = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"signalTwo"];
//        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalThree = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@"signalThree"];
        [subscriber sendCompleted];
        return nil;
    }];
    //拼接了三个信号，订阅之后，三个信号依次激活
    RACSignal *concatSignal = [[signalOne concat:signalTwo] concat:signalThree];
    [concatSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"信号被激活:%@",x);
    }];
}
/*
2020-06-08 18:20:53.103639+0800 RACExample[52202:421372] 信号被激活:signalOne
2020-06-08 18:20:53.103922+0800 RACExample[52202:421372] 信号被激活:signalTwo
*/
```

从上面代码看出`signalOne->signalTwo->signalThree`按照顺序连接，但是在信号`signalTwo`中没发送`sendCompleted`，所以后面的信号`signalThree`没有被激活。

```objc
RACSignal *signalTwo = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
    [subscriber sendNext:@"signalTwo"];
    [subscriber sendCompleted];
    return nil;
}];
/*
2020-06-08 18:23:40.588477+0800 RACExample[52340:423182] 信号被激活:signalOne
2020-06-08 18:23:40.589093+0800 RACExample[52340:423182] 信号被激活:signalTwo
2020-06-08 18:23:40.589539+0800 RACExample[52340:423182] 信号被激活:signalThree
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

* `replay重放`：当一个信号被多次订阅,反复播放内容

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## RACCommand

> RACCommand：处理事件的操作,和UI关联.(主线程中执行)，最常用于两个地方，监听按钮点击，网络请求。

```objc
@property (nonatomic, strong, readonly) RACSignal<RACSignal<ValueType> *> *executionSignals;
@property (nonatomic, strong, readonly) RACSignal<NSNumber *> *executing;
@property (nonatomic, strong, readonly) RACSignal<NSNumber *> *enabled;
@property (nonatomic, strong, readonly) RACSignal<NSError *> *errors;
@property (atomic, assign) BOOL allowsConcurrentExecution;

- (instancetype)initWithSignalBlock:(RACSignal<ValueType> * (^)(InputType _Nullable input))signalBlock;
// 初始化RACCommand的入参enabledSignal就决定了RACCommand是否能开始执行。入参enabledSignal就是触发条件。
- (instancetype)initWithEnabled:(nullable RACSignal<NSNumber *> *)enabledSignal signalBlock:(RACSignal<ValueType> * (^)(InputType _Nullable input))signalBlock;
- (RACSignal<ValueType> *)execute:(nullable InputType)input;
```

`executionSignals`:是一个高阶信号，所以在使用的时候需要进行降阶操作(`flatten`，`switchToLatest`，`concat`)，降阶的方式根据需求来选取。一般选择的原则：一般不允许并发(`dispatch_queue_concurrent`)的`RACCommand`使用`switchToLatest`，允许并发的使用`flatten`。

`executing`:表示了当前`RACCommand`是否在执行，信号里面的值都是`BOOL`类型的。`YES`表示的是`RACCommand`正在执行过程中，命名也说明的是正在进行时ing。`NO`表示的是`RACCommand`没有被执行或者已经执行结束。

`enabled`: 信号就是一个开关，判断`RACCommand`是否可用:<br>
* `RACCommand` 初始化传入的`enabledSignal`信号，如果返回`NO`，那么`enabled`信号就返回`NO`。
* `RACCommand`开始执行中，`allowsConcurrentExecution`为`NO`，那么`enabled`信号就返回`NO`。
* 除去以上2种情况以外，`enabled`信号基本都是返回YES。

`errors`: 信号就是`RACCommand`执行过程中产生的错误信号。

> 在对`RACCommand`进行错误处理的时候，我们不应该使用`subscribeError:`对`RACCommand`的`executionSignals` 进行错误的订阅，因为`executionSignals`这个信号是不会发送`error`事件的。

```objc
// 用subscribeNext:去订阅错误信号。
[commandSignal.errors subscribeNext:^(NSError *x) {     
    NSLog(@"ERROR! --> %@",x);
}];
```

`allowsConcurrentExecution`: 用来表示当前`RACCommand`是否允许并发执行。默认值是`NO`。按照上面说的则`enabled`的值也会为`NO`。

`allowsConcurrentExecution`在具体实现中是用的`volatile`原子的操作，在实现中重写了它的get和set方法。

```objc
// 重写 get方法
- (BOOL)allowsConcurrentExecution {
    return _allowsConcurrentExecution != 0;
}

// 重写 set方法
- (void)setAllowsConcurrentExecution:(BOOL)allowed {
    [self willChangeValueForKey:@keypath(self.allowsConcurrentExecution)];
    
    if (allowed) {
        // OSAtomicOr32Barrier是原子运算，它的意义是进行逻辑的“或”运算。通过原子性操作访问被volatile修饰的_allowsConcurrentExecution对象即可保障函数只执行一次。
        OSAtomicOr32Barrier(1, &_allowsConcurrentExecution);
    } else {
        // OSAtomicAnd32Barrier是原子运算，它的意义是进行逻辑的“与”运算。
        OSAtomicAnd32Barrier(0, &_allowsConcurrentExecution);
    }
    
    [self didChangeValueForKey:@keypath(self.allowsConcurrentExecution)];
}
```

`initWithSignalBlock:`与`initWithEnabled:signalBlock:`的区别：

```objc
- (instancetype)initWithSignalBlock:(RACSignal<id> * (^)(id input))signalBlock {
    return [self initWithEnabled:nil signalBlock:signalBlock];// nil 相当于：[RACSignal return:@YES]
}
```

### 使用

```objc
RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber * _Nullable input) {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"发送信号：%@",input);//2
        [subscriber sendNext:input];
        [subscriber sendError:[NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"----"}]];
        [subscriber sendCompleted];
        return nil;
    }];
}];
[command.executionSignals subscribeNext:^(id  _Nullable x) {
    
    NSLog(@"收到信号(subscribeNext)：%@",x);// 我们可以在这里把处理事件(网络请求、逻辑处理)之前的逻辑(showHUD...)放到这。
    
    [x subscribeNext:^(id  _Nullable x) {
        NSLog(@"x-收到信号(subscribeNext)：%@",x);// 收到信号B：1
    } error:^(NSError * _Nullable error) {
        NSLog(@"x-收到信号(error)：%@",x);//收不到error，因为 executionSignals 不会处理 error
    } completed:^{
        NSLog(@"x-收到信号(completed)");
    }];

} error:^(NSError * _Nullable error) {
    NSLog(@"收到信号(error)：%@",error.localizedDescription);//收不到error，因为 executionSignals 不会处理 error
} completed:^{
    NSLog(@"收到信号(completed)");
}];
[command execute:@1];
/*
收到信号(subscribeNext)：<RACDynamicSignal: 0x60000318f5a0> name: 
发送信号：1
x-收到信号(subscribeNext)：1
x-收到信号(completed)
收到信号(completed)
*/
```

换一种方式进行信号处理：

```objc
RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSNumber * _Nullable input) {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"发送信号：%@",input);//2
        [subscriber sendNext:input];
        [subscriber sendError:[NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"----"}]];
        [subscriber sendCompleted];
        return nil;
    }];
}];
// 通过 switchToLatest 把高阶信号降阶处理。
[[command.executionSignals switchToLatest] subscribeNext:^(id  _Nullable x) {
    NSLog(@"收到信号(switchToLatest)：%@",x);
}];
[command.errors subscribeNext:^(NSError * _Nullable x) {
    NSLog(@"收到信号(errors)：%@",x.localizedDescription);
}];
[command.executing subscribeNext:^(NSNumber * _Nullable x) {
    if([x boolValue] == YES){
        NSLog(@"RACCommand命令正在执行...");
    }else{
        NSLog(@"RACCommand命令不在执行中！！！");
    }
}];
[command execute:@1];
/*
RACCommand命令不在执行中！！！
RACCommand命令正在执行...     <==== 我们可以在这里把处理事件(网络请求、逻辑处理)之前的逻辑(showHUD...)放到这。
发送信号：1
收到信号(switchToLatest)：1
收到信号(errors)：----
RACCommand命令不在执行中！！！
*/
```

我们对`executing`进行一下处理，去掉无用的触发。

```objc
[[[command.executing skip:1] take:1] subscribeNext:^(NSNumber * _Nullable x) {
    if([x boolValue] == YES){
        NSLog(@"RACCommand命令正在执行...");
    }else{
        NSLog(@"RACCommand命令不在执行中！！！");
    }
}];
/*
2020-06-08 17:00:00.488046+0800 RACExample[49056:380458] RACCommand命令正在执行...
2020-06-08 17:00:00.488513+0800 RACExample[49056:380458] 发送信号：1
2020-06-08 17:00:00.488740+0800 RACExample[49056:380458] 收到信号(switchToLatest)：1
2020-06-08 17:00:00.489372+0800 RACExample[49056:380458] 收到信号(errors)：----
*/
```

或者直接订阅信号：

```objc
[[command execute:@1] subscribeNext:^(id  _Nullable x) {
    NSLog(@"接收信号(subscribeNext)：%@",x);
} error:^(NSError * _Nullable error) {
    NSLog(@"接收信号(error)：%@",error.localizedDescription);
} completed:^{
    NSLog(@"接收信号(completed)");
}];
/*
发送信号：1
接收信号(subscribeNext)：1
接收信号(error)：----
*/
```

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
// =============================.h=============================
@interface WLMSelectedApplyMerchantVM :NSObject
@property (nonatomic, strong, readonly) RACCommand *requestCommand;
@property (strong, nonatomic, readonly) RACSubject *messageSubject;
@end
// =============================.m=============================
@interface WLMSelectedApplyMerchantVM()
@property (nonatomic, strong, readwrite) RACCommand *requestCommand;
@property (strong, nonatomic, readwrite) RACSubject *messageSubject;
@end
@implementation WLMSelectedApplyMerchantVM
#pragma mark - Init
-(instancetype)init{
    if (self = [super init]) {
        [self racInit];
    }
    return self;
}

-(void)dealloc{
    [self.requestCommand rac_deallocDisposable];
    [self.messageSubject rac_deallocDisposable];
}

- (void)racInit {

    //@weakify(self);
    _requestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            //@strongify(self);

            // Code here...
            
            return [RACDisposable disposableWithBlock:^{
            }];
        }];
    }];
}

#pragma mark - Publish Methods

#pragma mark - Private Methods

#pragma mark - Getter
-(RACSubject *)messageSubject{
    if (!_messageSubject) {
        _messageSubject = [RACSubject subject];
    }
    return _messageSubject;
}
#pragma mark - Stter
@end
```

### V层

#### Controller
```objc
// =============================.h=============================
@interface LoginViewController : UIViewController
- (instancetype)initWithViewModel:(RACAndMVVMViewModel*)viewModel;
@end
// =============================.m=============================
@interface LoginViewController ()
@property(nonatomic, strong) RACAndMVVMViewModel *viewModel;
@end

@implementation LoginViewController
#pragma mark - life cycle
- (instancetype)initWithViewModel:(RACAndMVVMViewModel*)viewModel{
    if (self == [super init]) {
        _viewModel = viewModel;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self segInitViews];
    [self bindViewModel];
}
#pragma mark - Init Views
-(void)segInitViews{}

#pragma mark - Layout
- (void)updateViewConstraints {
    [super updateViewConstraints];
}

#pragma mark - Private Methods

#pragma mark - RAC Data Binding
- (void)bindViewModel {}

#pragma mark - getter
-(RACAndMVVMViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[RACAndMVVMViewModel alloc]init];
    }
    return _viewModel;
}
#pragma mark setter
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
#pragma mark - Init
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
#pragma mark setter
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

#pragma mark - Init Views
-(void)segInitViews{}

#pragma mark - Layout
- (void)updateConstraints {
    [super updateConstraints];
}
#pragma mark - Private Methods

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
#pragma mark setter
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
#pragma mark - Init Views
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

#pragma mark - Private Methods

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
#pragma mark setter
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

#pragma mark - Init Views
-(void)segInitViews{}

#pragma mark - Layout
- (void)updateConstraints {
    [super updateConstraints];
}
#pragma mark - Private Methods

#pragma mark - RAC Data Binding
- (void)bindViewModel {}

#pragma mark - getter
-(LoginTableViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[LoginTableViewModel alloc]init];
    }
    return _viewModel;
}
#pragma mark setter
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
#pragma mark - Init Views
+(NSString*)reuseIdentifier{
    return NSStringFromClass([self class]);
}

+(CircleListMainViewCell*)cellWithTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath{
    CircleListMainViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier]];
    if (!cell) {
        cell = [[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self reuseIdentifier]];
    }
    cell.indexPath = indexPath;
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
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

#pragma mark - Private Methods

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
#pragma mark - Init Views
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

#pragma mark - Private Methods

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
#pragma mark setter
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
#pragma mark - Init
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
#pragma mark setter
@end
```

##### CircleListMainViewCellViewModel

```objc
@interface CircleListMainViewCellViewModel : NSObject
@property (strong, nonatomic) DouBanTheatersModel *model;
@end

@implementation CircleListMainViewCellViewModel
#pragma mark - Init
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
#pragma mark setter
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

#pragma mark - Init Views
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
#pragma mark - Private Methods

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
#pragma mark - Init Views
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

#pragma mark - Private Methods

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
#pragma mark - Private Methods

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
#pragma mark - Private Methods

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
#pragma mark - Init Views
-(void)segInitViews{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - Layout
- (void)updateViewConstraints {
    [super updateViewConstraints];
}

#pragma mark - Private Methods

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

#pragma mark setter

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
#pragma mark - Init Views
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

#pragma mark - Private Methods

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
#pragma mark - Init
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

#pragma mark setter
@end
```

### 示例：登录

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
#pragma mark - Init
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

#pragma mark setter
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

#pragma mark - Init Views
-(void)segInitViews{
}

#pragma mark - Private Methods

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
#pragma mark setter
@end
```

<img src="/assets/images/iOS/rac/14.gif"/>

### 示例：豆瓣列表

```objc
#pragma mark - ====================VM层====================
//定义命令、网络请求、获取数据、发送数据
@interface DouBanDetailViewModel : NSObject
@property (nonatomic, copy, readonly) NSArray<NSString*> *movies;
@property (nonatomic, strong, readonly) RACCommand *requestCommand;
@property (nonatomic, strong, readonly) AFHTTPSessionManager *manager;
@end
@implementation DouBanDetailViewModel
#pragma mark - Init
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
#pragma mark setter
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

#pragma mark - Init Views
-(void)segInitViews{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - Private Methods

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
#pragma mark setter
@end
```

<img src="/assets/images/iOS/rac/13.gif"/>

### RACCommand中的sendError没反应的解答

* [RAC中用RACCommand处理指令](https://blog.harrisonxi.com/2017/09/RAC%E4%B8%AD%E7%94%A8RACCommand%E5%A4%84%E7%90%86%E6%8C%87%E4%BB%A4.html)

```objc
// 这样使用就可以捕捉到Error了。
[self.viewModel.requestCommand.errors subscribeNext:^(NSError * _Nullable x) {
     NSLog(@"errors subscribeNext:%@",x);
}];
```

### 示例:多接口请求

```objc
@interface DouBanDetailViewModel : NSObject
@property (nonatomic, strong, readonly) RACCommand *requestCommand;
@end
@implementation DouBanDetailViewModel
#pragma mark - Init
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
#pragma mark setter
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

### 示例：RAC、distinctUntilChanged

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

### 示例：发邮件

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

#pragma mark - Private Methods

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
#pragma mark setter
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

## 资料

* [Github-ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)
* [响应式编程（Reactive Programming）介绍](https://www.tuicool.com/articles/BBNRRf)
* [UITextField-RAC使用详解](https://link.jianshu.com/?t=http://www.raywenderlich.com/?p=62699)
* [iOS使用RAC实现MVVM的正经姿势](https://blog.harrisonxi.com/2017/07/iOS%E4%BD%BF%E7%94%A8RAC%E5%AE%9E%E7%8E%B0MVVM%E7%9A%84%E6%AD%A3%E7%BB%8F%E5%A7%BF%E5%8A%BF.html)

http://timmy6.github.io/2019/02/27/MVVM/