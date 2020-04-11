---
title: 设计模式-简单工厂模式
layout: post
categories:
 - Design Patterns
---

面向对象程序要做到：通过封装、继承、多态使程序易维护、易拓展、易复用。

用工厂类实现一个计算器：

```objc
// 抽象类
@interface Operation : NSObject
@property (nonatomic, assign) CGFloat numberA;
@property (nonatomic, assign) CGFloat numberB;
-(CGFloat)getResult;
@end
@implementation Operation
-(CGFloat)getResult{return 0;}
@end
// 加
@interface OperationAdd : Operation
@end
@implementation OperationAdd
-(CGFloat)getResult{return self.numberA + self.numberB;}
@end
// 减
@interface OperationSub : Operation
@end
@implementation OperationSub
-(CGFloat)getResult{return self.numberA - self.numberB;}
@end
// 乘
@interface OperationMul : Operation
@end
@implementation OperationMul
-(CGFloat)getResult{return self.numberA * self.numberB;}
@end
// 除
@interface OperationDiv : Operation
@end
@implementation OperationDiv
-(CGFloat)getResult{return self.numberA / self.numberB;}
@end
// 工厂模式
@interface OperationFactory : NSObject
@end
@implementation OperationFactory
// 通过多态返回父类的方式来实现。
+(Operation*)createFactory:(NSString*)operation{
    Operation *oper;
    // 这里推荐用switch，不过objc的switch只支持整数。
    if ([operation isEqualToString:@"+"]) oper = [OperationAdd new];
    if ([operation isEqualToString:@"-"]) oper = [OperationSub new];
    if ([operation isEqualToString:@"*"]) oper = [OperationMul new];
    if ([operation isEqualToString:@"/"]) oper = [OperationMul new];
    return oper;
}
@end

@implementation SAMFactoryDemo
-(void)use{
    // 没有使用工厂模式
    OperationAdd *add = [OperationAdd new];
    add.numberA = 10;
    add.numberB = 20;
    NSLog(@"%f",[add getResult]);
    
    OperationMul *mul = [OperationMul new];
    mul.numberA = 10;
    mul.numberB = 20;
    NSLog(@"%f",[mul getResult]);
    
    // 使用工厂模式
    Operation *oper;
    oper = [OperationFactory createFactory:@"+"];
    oper.numberA = 10;
    oper.numberB = 20;
    NSLog(@"%f",[oper getResult]);
    
    oper = [OperationFactory createFactory:@"*"];
    oper.numberA = 10;
    oper.numberB = 20;
    NSLog(@"%f",[oper getResult]);
}
@end
```