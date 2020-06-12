---
title: Masonry
layout: post
categories:
 - ios
---

[仓库地址](https://gitee.com/samcoding/MasonryExample.git )

## 官方推荐布局的位置

```objc
@implementation DIYCustomView
- (id)init {
    self = [super init];
    if (!self) return nil;
    // --- Create your views here ---
    self.button = [[UIButton alloc] init];
    return self;
}
// tell UIKit that you are using AutoLayout
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}
// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    // --- remake/update constraints here
    [self.button remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(self.buttonSize.width));
        make.height.equalTo(@(self.buttonSize.height));
    }];
    //according to apple super should be called at end of method
    [super updateConstraints];
}
- (void)didTapButton:(UIButton *)button {
    // --- Do your changes ie change variables that affect your layout etc ---
    self.buttonSize = CGSize(200, 200);
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];
}
-(void)layoutSubviews{
    [super layoutSubviews];
}
@end
```

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## 一些属性的讲解

### activate、deactivate

### NSArray

```objc
make.height.equalTo(@[view1.mas_height, view2.mas_height]);
make.height.equalTo(@[view1, view2]);
make.left.equalTo(@[view1, @100, view3.right]);
```

### greaterThanOrEqualTo、lessThanOrEqualTo

* `greaterThanOrEqualTo` : 小于等于。
* `lessThanOrEqualTo` : 大于等于。

```objc
//width >= 200 && width <= 400
make.width.greaterThanOrEqualTo(@200);
make.width.lessThanOrEqualTo(@400);

//creates view.left = view.superview.left + 10
make.left.lessThanOrEqualTo(@10)
```

### inset、sizeOffset、offset、centerOffset

* inset和insets的用法差不多,值为正数时往视图内部偏移，负数则往远离视图的方向偏移。

```objc
make.size.equalTo(view2).sizeOffset(CGSizeMake(10, -20));
make.center.equalTo(view2).centerOffset(CGPointMake(0, 100));
```

### insets

```objc
[self.yellowView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view).with.offset(10);
    make.top.equalTo(self.view).with.offset(10);
    make.right.equalTo(self.view).with.offset(-10);
    make.bottom.equalTo(self.view).with.offset(-10);
}];

// 通过insets简化设置内边距的方式
[self.blueView mas_makeConstraints:^(MASConstraintMaker *make) {
    // 下、右不需要写负号，insets方法中已经为我们做了取反的操作了。
    make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(10, 10, 10, 10));
}];
```

### firstBaseline、lastBaseline

* `firstBaseline`、`lastBaseline`就是基线对齐则。

<img src="/assets/images/masonry/18.png"/>

### leading、trailing、left、right

* `leading`与`left`，`trailing`与`right` 在正常情况下是等价的。

### animator

```objc
// 是否在修改约束时通过动画代理
@property (nonatomic, copy, readonly) MASConstraint *animator;

// 如果OS支持就激活一个NSLayoutConstraint，否则就调用install
- (void)activate;
// 销毁前面安装或者激活的NSLayoutConstraint
- (void)deactivate;
//创建一个NSLayoutConstraint并将它添加到合适的view上
- (void)install;
//移除以前安装的NSLayoutConstraint
- (void)uninstall;
```

#### 示例：动态添加控件

<img src="/assets/images/masonry/20.gif"/>

```objc
static UIEdgeInsets padding;
static CGFloat height = 100;
static int num = 0;

@interface MASExampleAutoAddView()
@property (nonatomic, strong) UIView *superView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, weak) MASConstraint *bottomConstraint;
@end


@implementation MASExampleAutoAddView
- (id)init {
    self = [super init];
    if (!self) return nil;
    padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.superView = [LayoutUtils createView];
    [self addSubview:self.superView];
    [self.superView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(padding);
    }];
    
    UIButton *tapButton = [LayoutUtils createButtonWithTitle:@"Add" target:self selector:@selector(clickButton:)];
    [self.superView addSubview:tapButton];
    [tapButton makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(padding);
        self.bottomConstraint = make.bottom.mas_equalTo(padding);//记录下这个约束对象
        make.height.equalTo(@(height));
    }];
    self.bottomView = tapButton;
    
    UIView *bottomView = [LayoutUtils createView];
    [self.superView addSubview:bottomView];
    [bottomView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(padding);
        make.top.mas_equalTo(self.superView.mas_bottom).mas_equalTo(padding);
        make.height.mas_equalTo(@(height));
    }];
    
    return self;
}

-(void)clickButton:(UIButton*)sender{
    [self.bottomConstraint uninstall];//卸载旧的底部约束
    num += 1;
    UILabel *label = [LayoutUtils fixedLabelWithText:[NSString stringWithFormat:@"控件%d", num]];
    [self.superView addSubview:label];
    [label makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(padding);
        make.top.equalTo(self.bottomView.mas_bottom).mas_equalTo(padding);
        self.bottomConstraint = make.bottom.equalTo(self.superView.mas_bottom).mas_equalTo(padding);//添加新的底部约束
        make.height.equalTo(@(height));
    }];
    self.bottomView = label;
}
@end
```

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## 优先级

* `priority(value)` : 手动设置优先级的数值，优先级最大数值是`1000`。`priority(200)`
* `priorityLow()` : 约束优先级-低。
* `priorityMedium()` : 约束优先级-中。`priorityMedium()=500`
* `priorityHigh()` : 约束优先级-高。

```objc
// 别挤我
- (void)setContentCompressionResistancePriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis;
// 抱紧，类似于sizefit，不会根据父view长度变化
- (void)setContentHuggingPriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis;
```

```objc
@interface MASTableViewPriorityCell : MASTableViewBasicCell
@property (strong, nonatomic) UILabel *leftLabel; // 必须显示完整
@property (strong, nonatomic) UILabel *middleLabel; // 可以显示全就显示，显示不全展示(XXXX...)
@property (strong, nonatomic) UIButton *rightButton; // rightView 在 middleLabel 的右边，完全显示，不能超过右边屏幕
@end

@implementation MASTableViewPriorityCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.leftLabel = [LayoutUtils fixedLabelWithText:@"0万"];
        [self.contentView addSubview:self.leftLabel];
        [self.leftLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(kPadding);
        }];
        
        self.middleLabel = [LayoutUtils fixedLabelWithText:@""];
        self.middleLabel.numberOfLines = 1;
        self.middleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.middleLabel];
        [self.middleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(kPadding);
            make.left.equalTo(self.leftLabel.mas_right).inset(kPadding.right);
        }];
        self.rightButton = [LayoutUtils createButtonWithTitle:@"置顶" target:self selector:@selector(buttonClick:)];
        [self.contentView addSubview:self.rightButton];
        [self.rightButton makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(kPadding);
            make.left.equalTo(self.middleLabel.mas_right).inset(kPadding.right);
            make.right.lessThanOrEqualTo(self.contentView).inset(kPadding.right);
        }];
        
        //宽度不够时，可以被压缩
        [self.middleLabel setContentCompressionResistancePriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];
        // 抱紧
        [self.middleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        //不可以被压缩，尽量显示完整
        [self.leftLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

    }
    return self;
}
-(void)updateData{
    self.leftLabel.text = [NSString stringWithFormat:@"%@万",self.cellData.playCount];
    self.middleLabel.text = self.cellData.content;
}
@end
```

<img src="/assets/images/masonry/26.png"/>

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## layoutMarginsGuide

`UIView` 有一个`UIEdgeInsets` 类型的属性 `layoutMargins`。它表示一个视图的内容和它四个边界之间的空隙。

`UIView` 的 `layoutMarginsGuide` 属性其实是 `layoutMargins` 的另一种表现形式，可用于创建布局约束。`layoutMarginsGuide` 是一个 **只读** 属性。

<img src="/assets/images/masonry/15.png"/>

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## safeAreaLayoutGuide

在 iOS 11 时，苹果提出了 Safe Area 的概念。因为 iOS 11 搭载的 iPhone X 取消了 Home 键，要为操作保留一些空间，这正好把原来的 Navigation Bar, Status Bar, Tab Bar 包含在里面。`safeAreaLayoutGuide` 属性正是伴随 Safe Area 出现的。`safeAreaLayoutGuide` 是一个 **只读** 属性。

<img src="/assets/images/masonry/16.png"/>

> `Masonry 1.1.0` 最新版本对`safeAreaLayoutGuide`是会crach的。

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## 系统布局相关

### UIView

```objc
+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}

@property(class, nonatomic, readonly) BOOL requiresConstraintBasedLayout;
/// update constraints now so we can animate the change
- (void)updateConstraintsIfNeeded; 
/// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints;
- (BOOL)needsUpdateConstraints;
/// tell constraints they need updating
- (void)setNeedsUpdateConstraints;

/// 告知页面需要更新，但是不会立刻开始更新。执行后会立刻调用 layoutSubviews 
- (void)setNeedsLayout;
/// 告知页面布局立刻更新。所以一般都会和 setNeedsLayout 一起使用。如果希望立刻生成新的 frame 需要调用此方法，利用这点一般布局动画可以在更新布局后直接使用这个方法让动画生效。
- (void)layoutIfNeeded;
/// 系统重写布局
- (void)layoutSubviews;
```

用法：

```objc
- (void)updateConstraints {
    // Layout code here...
    [super updateConstraints];
}

-(void)tap{
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.4 animations:^{
        [self layoutIfNeeded];
    }];
}
```

```objc
// iOS系统最低配为iOS8.0
__IPHONE_OS_VERSION_MIN_REQUIRED >= 80000
```
<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## 动画

### 安全范围内移动控件

<img src="/assets/images/masonry/31.gif"/>

```objc
@interface MASExampleTouchMoveView()
@property (nonatomic, strong) MASConstraint *leftConstraint; // 保存左边的约束，用于在移动时调整位置
@property (nonatomic, strong) MASConstraint *topConstraint; // 保存顶部的约束，用于在移动时调整位置
@end

@implementation MASExampleTouchMoveView
- (id)init {
    self = [super init];
    if (!self) return nil;
    UILabel *label = [LayoutUtils fixedLabelWithText:@"Move Me"];
    [self addSubview:label];
    [label makeConstraints:^(MASConstraintMaker *make) {
        self.leftConstraint = make.centerX.equalTo(self.mas_left).with.offset(50).priorityHigh();
        self.topConstraint = make.centerY.equalTo(self.mas_top).with.offset(50).priorityHigh();
        
        // 边界条件约束，保证内容可见，优先级1000
        make.left.greaterThanOrEqualTo(kPadding);
        make.right.lessThanOrEqualTo(kPadding);
        make.top.greaterThanOrEqualTo(kPadding);
        make.bottom.lessThanOrEqualTo(kPadding);
    }];
    return self;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    NSLog(@"%@",NSStringFromCGPoint(touchLocation));
    self.leftConstraint.offset = touchLocation.x;
        self.topConstraint.offset = touchLocation.y;
}
@end
```

### 更新动画

```objc
@implementation MASExampleTotalUpdateAnimateView

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    self.superView = [LayoutUtils createView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
    [self.superView addGestureRecognizer:tap];
    [self addSubview:self.superView];
    
    self.sonView = [LayoutUtils createView];
    [self addSubview:self.sonView];
    
    [self setNeedsUpdateConstraints];
    
    return self;
}

-(void)updateConstraints{
    [self.superView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(kPadding);
        make.right.equalTo(kPadding);
        if (self.isExpanded) {
            make.bottom.equalTo(kPadding);
        } else {
            make.bottom.mas_equalTo(-300);
        }
    }];
    
    [self.sonView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.superView);
        // 这里使用优先级处理
        // 设置其最大值为250，最小值为90
        if (!self.isExpanded) {
            make.width.height.mas_equalTo(100 * 0.5).priorityLow();
        } else {
            make.width.height.mas_equalTo(100 * 3).priorityLow();
        }
        make.width.height.lessThanOrEqualTo(@250);// 最大值为250
        make.width.height.greaterThanOrEqualTo(@90);// 最小值为90
    }];
    
    [super updateConstraints];
}

-(void)onTap{
    self.isExpanded = !self.isExpanded;
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.4 animations:^{
        [self layoutIfNeeded];
    }];
}
@end
```

<img src="/assets/images/masonry/27.gif"/>

### 约束放到数组中

<img src="/assets/images/masonry/05.gif"/>

```objc
- (id)init {
    self = [super init];
    if (!self) return nil;
    
    [blueView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(update)]];
    [blueView setUserInteractionEnabled:YES];

    UIView *superview = self;
    int padding = self.padding = 10;
    UIEdgeInsets paddingInsets = UIEdgeInsetsMake(self.padding, self.padding, self.padding, self.padding);

    self.animatableConstraints = NSMutableArray.new;

    [greenView mas_makeConstraints:^(MASConstraintMaker *make) {
        [self.animatableConstraints addObjectsFromArray:@[
            make.edges.equalTo(superview).insets(paddingInsets).priorityLow(),
            make.bottom.equalTo(blueView.mas_top).offset(-padding),
        ]];

        make.size.equalTo(redView);
        make.height.equalTo(blueView.mas_height);
    }];

    [redView mas_makeConstraints:^(MASConstraintMaker *make) {
        [self.animatableConstraints addObjectsFromArray:@[
            make.edges.equalTo(superview).insets(paddingInsets).priorityLow(),
            make.left.equalTo(greenView.mas_right).offset(padding),
            make.bottom.equalTo(blueView.mas_top).offset(-padding),
        ]];

        make.size.equalTo(greenView);
        make.height.equalTo(blueView.mas_height);
    }];

    [blueView mas_makeConstraints:^(MASConstraintMaker *make) {
        [self.animatableConstraints addObjectsFromArray:@[
            make.edges.equalTo(superview).insets(paddingInsets).priorityLow(),
        ]];

        make.height.equalTo(greenView.mas_height);
        make.height.equalTo(redView.mas_height);
    }];

    return self;
}

-(void)update{
    int padding = self.isChangePadding ? 100 : self.padding;
    UIEdgeInsets paddingInsets = UIEdgeInsetsMake(padding, padding, padding, padding);
    for (MASConstraint *constraint in self.animatableConstraints) {
        constraint.insets = paddingInsets;
    }
    [UIView animateWithDuration:1 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.isChangePadding = !self.isChangePadding;
    }];
}
```

### 移除-更新约束

<img src="/assets/images/masonry/02.gif"/>

```objc
+ (BOOL)requiresConstraintBasedLayout{
    return YES;
}
- (void)updateConstraints {
    [self.movingButton remakeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(100));
        make.height.equalTo(@(100));
        
        if (self.topLeft) {
            make.left.equalTo(self.left).with.offset(10);
            make.top.equalTo(self.top).with.offset(10);
        }
        else {
            make.bottom.equalTo(self.bottom).with.offset(-10);
            make.right.equalTo(self.right).with.offset(-10);
        }
    }];
    [super updateConstraints];
}

- (void)toggleButtonPosition {
    self.topLeft = !self.topLeft;
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];
    
    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        [self layoutIfNeeded];
    }];
}
```

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## Masonry 代码示例

* `makeConstraints:` : 添加约束。
* `updateConstraints:` : 更新约束、亦可添加新约束。
* `remakeConstraints:` : 重置之前的约束。
* `mas_distributeViewsAlongAxis:withFixedSpacing:leadSpacing:tailSpacing:`
* `mas_distributeViewsAlongAxis:withFixedItemLength:leadSpacing:tailSpacing:`

* `multipler` : 表示约束值为约束对象的乘因数。
* `dividedBy` : 表示约束值为约束对象的除因数。

### 布局使用结构体

```objc
make.center.equalTo(CGPointMake(0, 50));
make.size.equalTo(CGSizeMake(200, 100));
make.edges.equalTo(superview).insets(UIEdgeInsetsMake(self.padding, self.padding, self.padding, self.padding));
make.edges.mas_equalTo(UIEdgeInsetsMake(10, 0, 10, 0));
make.left.mas_equalTo(view).mas_offset(UIEdgeInsetsMake(10, 0, 10, 0));
```

#### insets的链式使用

```objc
UIEdgeInsets padding = UIEdgeInsetsMake(15, 10, 15, 10);
[greenView mas_makeConstraints:^(MASConstraintMaker *make) {
    // chain attributes
    make.top.and.left.equalTo(superview).insets(padding);

    // which is the equivalent of
    // make.top.greaterThanOrEqualTo(superview).insets(padding);
    // make.left.greaterThanOrEqualTo(superview).insets(padding);

    make.bottom.equalTo(blueView.mas_top).insets(padding);
    make.right.equalTo(redView.mas_left).insets(padding);
    make.width.equalTo(redView.mas_width);

    make.height.equalTo(@[redView, blueView]);
}];

[redView mas_makeConstraints:^(MASConstraintMaker *make) {
    // chain attributes
    make.top.and.right.equalTo(superview).insets(padding);

    make.left.equalTo(greenView.mas_right).insets(padding);
    make.bottom.equalTo(blueView.mas_top).insets(padding);
    make.width.equalTo(greenView.mas_width);

    make.height.equalTo(@[greenView, blueView]);
}];

[blueView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(greenView.mas_bottom).insets(padding);
    // chain attributes
    make.left.right.and.bottom.equalTo(superview).insets(padding);
    make.height.equalTo(@[greenView, redView]);
}];
```

<img src="/assets/images/masonry/08.png"/>


### 约束

```objc
@property (nonatomic, strong, readonly) MASConstraint *left;
@property (nonatomic, strong, readonly) MASConstraint *top;
@property (nonatomic, strong, readonly) MASConstraint *right;
@property (nonatomic, strong, readonly) MASConstraint *bottom;
@property (nonatomic, strong, readonly) MASConstraint *leading;
@property (nonatomic, strong, readonly) MASConstraint *trailing;
@property (nonatomic, strong, readonly) MASConstraint *width;
@property (nonatomic, strong, readonly) MASConstraint *height;
@property (nonatomic, strong, readonly) MASConstraint *centerX;
@property (nonatomic, strong, readonly) MASConstraint *centerY;
@property (nonatomic, strong, readonly) MASConstraint *baseline;

@property (nonatomic, strong, readonly) MASConstraint *firstBaseline;
@property (nonatomic, strong, readonly) MASConstraint *lastBaseline;

@property (nonatomic, strong, readonly) MASConstraint *leftMargin;
@property (nonatomic, strong, readonly) MASConstraint *rightMargin;
@property (nonatomic, strong, readonly) MASConstraint *topMargin;
@property (nonatomic, strong, readonly) MASConstraint *bottomMargin;
@property (nonatomic, strong, readonly) MASConstraint *leadingMargin;
@property (nonatomic, strong, readonly) MASConstraint *trailingMargin;
@property (nonatomic, strong, readonly) MASConstraint *centerXWithinMargins;
@property (nonatomic, strong, readonly) MASConstraint *centerYWithinMargins;

@property (nonatomic, strong, readonly) MASConstraint *edges;
@property (nonatomic, strong, readonly) MASConstraint *size;
@property (nonatomic, strong, readonly) MASConstraint *center;
```


### 等宽高布局

* 不管父视图如何布局，子视图内部都是等宽高的布局。

<img src="/assets/images/masonry/01.png"/>

```objc
UIView *superview = self;
int padding = 10;
[greenView makeConstraints:^(MASConstraintMaker *make) {
    make.top.greaterThanOrEqualTo(superview.top).offset(padding);
    make.left.equalTo(superview.left).offset(padding);
    make.bottom.equalTo(blueView.top).offset(-padding);
    make.right.equalTo(redView.left).offset(-padding);
    make.width.equalTo(redView.width);

    make.height.equalTo(redView.height);
    make.height.equalTo(blueView.height);
    
}];

//with is semantic and option
[redView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(superview.mas_top).with.offset(padding); //with with
    make.left.equalTo(greenView.mas_right).offset(padding); //without with
    make.bottom.equalTo(blueView.mas_top).offset(-padding);
    make.right.equalTo(superview.mas_right).offset(-padding);
    make.width.equalTo(greenView.mas_width);
    
    make.height.equalTo(@[greenView, blueView]); //can pass array of views
}];

[blueView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(greenView.mas_bottom).offset(padding);
    make.left.equalTo(superview.mas_left).offset(padding);
    make.bottom.equalTo(superview.mas_bottom).offset(-padding);
    make.right.equalTo(superview.mas_right).offset(-padding);
    make.height.equalTo(@[greenView.mas_height, redView.mas_height]); //can pass array of attributes
}];
```

### 混合布局

```objc
UIView *lastView = self;
for (int i = 0; i < 10; i++) {
    UIView *view = UIView.new;
    view.backgroundColor = [self randomColor];
    view.layer.borderColor = UIColor.blackColor.CGColor;
    view.layer.borderWidth = 2;
    [self addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(lastView).insets(UIEdgeInsetsMake(5, 10, 15, 20));
    }];
    
    lastView = view;
}
```

<img src="/assets/images/masonry/03.png"/>

### Masonry Aspect

<img src="/assets/images/masonry/04.gif"/>

```objc
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectZero];
    multipliedBy = 1;
    
    if (self) {
        
        // Create views
        self.topView = [[UIView alloc] initWithFrame:CGRectZero];
        self.topInnerView = [[UIView alloc] initWithFrame:CGRectZero];
        self.bottomView = [[UIView alloc] initWithFrame:CGRectZero];
        self.bottomInnerView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [self.topInnerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(update)]];
        [self.topInnerView setUserInteractionEnabled:YES];
        
        
        // Set background colors
        UIColor *blueColor = [UIColor colorWithRed:0.663 green:0.796 blue:0.996 alpha:1];
        [self.topView setBackgroundColor:blueColor];

        UIColor *lightGreenColor = [UIColor colorWithRed:0.784 green:0.992 blue:0.851 alpha:1];
        [self.topInnerView setBackgroundColor:lightGreenColor];

        UIColor *pinkColor = [UIColor colorWithRed:0.992 green:0.804 blue:0.941 alpha:1];
        [self.bottomView setBackgroundColor:pinkColor];
        
        UIColor *darkGreenColor = [UIColor colorWithRed:0.443 green:0.780 blue:0.337 alpha:1];
        [self.bottomInnerView setBackgroundColor:darkGreenColor];
        
        // 顶部(topView)、底部(bottomView) View 高度均分。
        [self addSubview:self.topView];
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.and.top.equalTo(self);
        }];
        
        [self addSubview:self.bottomView];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.and.bottom.equalTo(self);
            make.top.equalTo(self.topView.mas_bottom);
            make.height.equalTo(self.topView);
        }];

        // Inner views are configured for aspect fit with ratio of 3:1
        [self.topView addSubview:self.topInnerView];
        [self.topInnerView mas_makeConstraints:^(MASConstraintMaker *make) {
            // 宽度是其自身高度的三倍
            make.width.equalTo(self.topInnerView.mas_height).multipliedBy(multipliedBy);
            
            // 宽度和高度都不超过其父视图的宽度和高度
            make.width.and.height.lessThanOrEqualTo(self.topView);
            // 宽度和高度等于其父视图的宽度 优先级低
            make.width.and.height.equalTo(self.topView).with.priorityLow();

            make.center.equalTo(self.topView);
        }];

        [self.bottomView addSubview:self.bottomInnerView];
        [self.bottomInnerView mas_makeConstraints:^(MASConstraintMaker *make) {
            //高度等于其自身宽度的3倍
            make.height.equalTo(self.bottomInnerView.mas_width).multipliedBy(3);
            
            // 宽度和高度都不超过其父视图的宽度和高度
            make.width.and.height.lessThanOrEqualTo(self.bottomView);
            // 宽度和高度等于其父视图的宽度 优先级低
            make.width.and.height.equalTo(self.bottomView).with.priorityLow();

            make.center.equalTo(self.bottomView);
        }];
    }
    
    return self;
}

+(BOOL)requiresConstraintBasedLayout{
    return YES;
}

-(void)updateConstraints{
    [self.topInnerView remakeConstraints:^(MASConstraintMaker *make) {
        //1. 确定坐标
        make.center.equalTo(self.topView);
        //2. 宽度和高度等于其父视图的宽度 优先级低
        make.width.and.height.equalTo(self.topView).with.priorityLow();
        //3. 宽度是其自身高度的三倍
        make.width.equalTo(self.topInnerView.mas_height).multipliedBy(self->multipliedBy);// width=height*4 ==> width/height=4/1
        //4. 宽度和高度都不超过其父视图的宽度和高度
        make.width.and.height.lessThanOrEqualTo(self.topView);
    }];
    [super updateConstraints];
}

-(void)update{
    multipliedBy += 1;
    NSLog(@"%f",multipliedBy);
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [UIView animateWithDuration:0.4 animations:^{
        [self layoutIfNeeded];
    }];
}
```

### 给Masonry添加Debug

* 当约束冲突时，打印的日志比较难定位是哪些控件的约束或者说是哪条约束，Masonry已经给我们提供了相关的方法:`MASAttachKeys()`、给约束设置`key`。

```objc
greenView.mas_key = @"greenView";
```

```objc
MASAttachKeys(greenView, redView, blueView, superview);
[blueView mas_makeConstraints:^(MASConstraintMaker *make) {
    //you can also attach debug keys to constaints
    make.edges.equalTo(@1).key(@"ConflictingConstraint"); //composite constraint keys will be indexed
    make.height.greaterThanOrEqualTo(@5000).key(@"ConstantConstraint");

    make.top.equalTo(greenView.mas_bottom).offset(padding);
    make.left.equalTo(superview.mas_left).offset(padding);
    make.bottom.equalTo(superview.mas_bottom).offset(-padding).key(@"BottomConstraint");
    make.right.equalTo(superview.mas_right).offset(-padding);
    make.height.equalTo(greenView.mas_height);
    make.height.equalTo(redView.mas_height).key(@340954); //anything can be a key
}];
```

```
// 添加Debug前
"<MASLayoutConstraint:ConstantConstraint UILabel:0x7f82ef709550.height >= 5000>",
"<MASLayoutConstraint:ConflictingConstraint[2] UILabel:0x7f82ef709550.top == MASExampleDebuggingView:0x7f82ef422490.top + 1>",
"<MASLayoutConstraint:0x600003756f40 UILabel:0x7f82ef709550.top == UIView:0x7f82ef717f10.bottom + 10>",
"<MASLayoutConstraint:0x60000375e1c0 UILabel:0x7f82ef709550.height == UIView:0x7f82ef717f10.height>",
"<MASLayoutConstraint:0x60000375e520 UIView:0x7f82ef717f10.top >= MASExampleDebuggingView:0x7f82ef422490.top + 10>"

// 添加Debug后
"<MASLayoutConstraint:ConstantConstraint UILabel:blueView.height >= 5000>",
"<MASLayoutConstraint:ConflictingConstraint[2] UILabel:blueView.top == MASExampleDebuggingView:superview.top + 1>",
"<MASLayoutConstraint:0x600003b2d800 UILabel:blueView.top == UIView:greenView.bottom + 10>",
"<MASLayoutConstraint:0x600003b2d6e0 UILabel:blueView.height == UIView:greenView.height>",
"<MASLayoutConstraint:0x600003b2d9e0 UIView:greenView.top >= MASExampleDebuggingView:superview.top + 10>"
```

### UILabel布局

#### 多行UILabel

```objc
static UIEdgeInsets const kPadding = {10, 10, 10, 10};
- (id)init {
    self = [super init];
    if (!self) return nil;

    self.longLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.longLabel.text = @"Bacon ipsum dolor sit amet spare ribs fatback kielbasa salami, tri-tip jowl pastrami flank short loin rump sirloin. Tenderloin frankfurter chicken biltong rump chuck filet mignon pork t-bone flank ham hock.";
    
    [self.longLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.left).insets(kPadding);
        make.top.equalTo(self.top).insets(kPadding);
    }];
    [self.shortLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.longLabel.lastBaseline);
        make.right.equalTo(self.right).insets(kPadding);
    }];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    // for multiline UILabel's you need set the preferredMaxLayoutWidth
    // you need to do this after [super layoutSubviews] as the frames will have a value from Auto Layout at this point

    // stay tuned for new easier way todo this coming soon to Masonry

    CGFloat width = CGRectGetMinX(self.shortLabel.frame) - kPadding.left;
    width -= CGRectGetMinX(self.longLabel.frame);
    self.longLabel.preferredMaxLayoutWidth = width;

    // need to layoutSubviews again as frames need to recalculated with preferredLayoutWidth
    [super layoutSubviews];
}
```

<img src="/assets/images/masonry/06.png"/>

### UILabel自适应宽度/高度

<img src="/assets/images/masonry/23.gif"/>

```objc
@interface MASExampleMulLabelAutoSizeView()
@property (nonatomic, strong) UILabel *label;
@end

@implementation MASExampleMulLabelAutoSizeView

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    self.label = [LayoutUtils fixedLabelWithText:@"最近是用Masonry自动布局UILabel的时候，;这些东西之后，label还是没有换行。最近是用Masonry自动布局UILabel的时候，"];
    self.label.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(100);
        make.left.mas_equalTo(15);
    }];
    
    UIButton *button = [LayoutUtils createButtonWithTitle:@"添加文字" target:self selector:@selector(clickButton:)];
    [self addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.label.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(self);
        make.height.mas_equalTo(50);
        make.width.mas_lessThanOrEqualTo(300);
    }];
    
    return self;
}

-(void)clickButton:(UIButton*)sender{
    self.label.text = [self.label.text stringByAppendingString:@"Masonry自动布局YYLabel"];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.label.preferredMaxLayoutWidth = CGRectGetWidth(self.frame) - 30;
}
@end
```

### UIScrollView布局

> 在使用`Masonry`对`UIScrollView`设置约束后，`contentSize`属性就不管用了，需要通过`Masonry`的规则在`scrollView`中添加一个`contentView`,其它的子视图全部添加到 `contentView` 上，让`contentView`来撑起`UIScrollview`的`contentSize`。

#### 垂直方向

<img src="/assets/images/masonry/07.png"/>

```objc
@interface MASExampleScrollView ()
@property (strong, nonatomic) UIScrollView* scrollView;
@end

@implementation MASExampleScrollView

- (id)init {
    self = [super init];
    if (!self) return nil;
    
    UIScrollView *scrollView = UIScrollView.new;
    self.scrollView = scrollView;
    scrollView.backgroundColor = [UIColor grayColor];
    [self addSubview:scrollView];
    [self.scrollView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self generateContent];

    return self;
}

- (void)generateContent {
    UIView* contentView = UIView.new;
    [self.scrollView addSubview:contentView];
    
    [contentView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    UIView *lastView;
    CGFloat height = 25;
    
    for (int i = 0; i < 10; i++) {
        UIView *view = UIView.new;
        view.backgroundColor = [self randomColor];
        [contentView addSubview:view];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [view addGestureRecognizer:singleTap];
        
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lastView ? lastView.bottom : @0);
            make.left.equalTo(@0);
            make.width.equalTo(contentView.width);
            make.height.equalTo(@(height));
        }];
        
        height += 25;
        lastView = view;
    }
    
    [contentView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lastView.bottom);
    }];
}

- (UIColor *)randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

- (void)singleTap:(UITapGestureRecognizer*)sender {
    [sender.view setAlpha:sender.view.alpha / 1.20]; // To see something happen on screen when you tap :O
    [self.scrollView scrollRectToVisible:sender.view.frame animated:YES];
};

@end
```

#### 水平方向

<img src="/assets/images/masonry/21.gif"/>

```objc
static UIEdgeInsets padding;
@implementation MASExampleScrollHorView

- (id)init {
    self = [super init];
    if (!self) return nil;
    padding = UIEdgeInsetsMake(10, 10, 10, 10);
    
    UIScrollView *scrollView = [LayoutUtils creatUIScrollView];
    [self addSubview:scrollView];
    [scrollView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(padding); // make.edges.equalTo(self).mas_equalTo(padding);
    }];
    
    // 设置scrollView的子视图，即过渡视图contentSize
    UIView* contentView = [LayoutUtils createView];
    [scrollView addSubview:contentView];
    [contentView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.height.equalTo(scrollView);
    }];
    
    // 动态添加子视图到 contentView 上
    UIView *lastView = nil;
    for (int i = 0; i <= 10; i++) {
        UILabel *label = [LayoutUtils fixedLabelWithText:[NSString stringWithFormat:@"水平方向\n第 %d 个视图", (i + 1)]];
        [contentView addSubview:label];
        [label makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(padding);
            make.width.equalTo(scrollView).offset(-(padding.left+padding.right));
            if (lastView) {
                make.left.mas_equalTo(lastView.mas_right).offset(padding.left+padding.right);
            } else {
                make.left.mas_equalTo(padding);
            }
        }];
        lastView = label;
    }

    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(lastView.mas_right).offset(padding.left+padding.right);
    }];
    
    return self;
}

@end
```

### Array的Button数组

```objc
- (id)init {
    self = [super init];
    if (!self) return nil;
    [lowerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(10.0);
    }];
    [centerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
    }];
    [raiseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-10);
    }];
    self.buttonViews = @[ raiseButton, lowerButton, centerButton ];
    return self;
}
- (void)centerAction {
    self.offset = 0.0;
}
- (void)raiseAction {
    self.offset -= kArrayExampleIncrement;
}
- (void)lowerAction {
    self.offset += kArrayExampleIncrement;
}
- (void)setOffset:(CGFloat)offset {
    _offset = offset;
    [self setNeedsUpdateConstraints];
}
- (void)updateConstraints {
    [self.buttonViews updateConstraints:^(MASConstraintMaker *make) {
        make.baseline.equalTo(self.mas_centerY).with.offset(self.offset);
    }];
    [super updateConstraints];
}
```

### layoutMargins

```objc
```

### mas_distributeViewsAlongAxis

```objc
[arr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:20 leadSpacing:5 tailSpacing:5];
[arr makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(@60);
    make.height.equalTo(@60);
}];
```

<img src="/assets/images/masonry/09.png"/>

```objc
[arr mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedSpacing:20 leadSpacing:5 tailSpacing:5];
[arr makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(@0);
    make.width.equalTo(@60);
}];
```

<img src="/assets/images/masonry/10.png"/>

```objc
[arr mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:30 leadSpacing:200 tailSpacing:30];
[arr makeConstraints:^(MASConstraintMaker *make) {
    make.top.equalTo(@60);
    make.height.equalTo(@60);
}];
```

<img src="/assets/images/masonry/11.png"/>

```objc
[arr mas_distributeViewsAlongAxis:MASAxisTypeVertical withFixedItemLength:30 leadSpacing:30 tailSpacing:200];
[arr makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(@0);
    make.width.equalTo(@60);
}];
```

<img src="/assets/images/masonry/12.png"/>

```objc
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}
- (id)init {
    self = [super init];
    if (!self) return nil;
    
    NSLog(@"%s:%@",__FUNCTION__,NSStringFromCGRect(self.frame));
    
    UIView *contentView = [LayoutUtils createView];
    [self addSubview:contentView];
    [contentView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(@(20));
        make.left.right.equalTo(self);
    }];
    
    UIView *lastView = nil;
    
    NSInteger itemsCount = 11;
    NSInteger rowCount = 3;// 设置每行有4个Item
    NSInteger rowNum = (itemsCount/rowCount) + ((NSInteger)(itemsCount%rowCount>0));//显示的总行数
    NSInteger itemHeight = 80;
    
    for (int j = 0; j < rowNum; j++) {
        
        NSMutableArray<UILabel*> *rowArray = [NSMutableArray array];
        
        for (int i = 0; i < rowCount; i++) {
            NSInteger index = j*rowCount+i;
            UILabel *label = [LayoutUtils fixedLabelWithText:[NSString stringWithFormat:@"content:%zd",index]];
            [contentView addSubview:label];
            [rowArray addObject:label];
            lastView = label;
            
            if (index > itemsCount - 1) {
                label.text = @"";
                [label setBackgroundColor:UIColor.clearColor];
            }
        }
        if (rowArray.count > 0) {
            [rowArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:15 leadSpacing:10 tailSpacing:10];
            [rowArray makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@((itemHeight+20)*j));
                make.height.equalTo(@(itemHeight));
            }];
        }
    }
    
    if (lastView) {
        [contentView makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(lastView.mas_bottom);
        }];
    }
    
    UIView *bottomView = [LayoutUtils createView];
    [self addSubview:bottomView];
    [bottomView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView.mas_bottom).offset(@(20));
        make.left.right.equalTo(self);
        make.height.equalTo(@(40));
    }];
    return self;
}
```

<img src="/assets/images/masonry/24.png"/>

### 多行label的约束问题?

* `preferredMaxLayoutWidth`: 多行label的约束问题。

```objc
// 已经确认好了位置
// 在layoutSubviews中确认label的preferredMaxLayoutWidth值
- (void)layoutSubviews {
    [super layoutSubviews];
    // 你必须在 [super layoutSubviews] 调用之后，longLabel的frame有值之后设置preferredMaxLayoutWidth
    self.longLabel.preferredMaxLayoutWidth = self.frame.size.width-100;
    // 设置preferredLayoutWidth后，需要重新布局
    [super layoutSubviews];
}
```

### multipler、dividedBy

<img src="/assets/images/masonry/13.png"/>

```objc
[view makeConstraints:^(MASConstraintMaker *make) {
    make.center.equalTo(self);
    make.width.equalTo(view.mas_height).multipliedBy(2); // width = height*2 ==> height = width/2
    //make.height.equalTo(view.mas_width).dividedBy(2);// height = width/2
    make.width.and.height.equalTo(self).width.priorityLow();
}];
```

### UITableView

<img src="/assets/images/masonry/14.png"/>

#### UITableViewDataSource

```objc
// ================= MASTableViewDataSorceImpl ====================
@interface MASTableViewDataSorceImpl : NSObject<UITableViewDataSource>
@property (strong, nonatomic) NSArray *dataSource;
@end
@implementation MASTableViewDataSorceImpl
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MASTableViewNormalCell cellWithTableView:tableView indexPath:indexPath];
}
@end
// ================= MASTableViewDataSorceSubImpl ====================
@interface MASTableViewDataSorceSubImpl : MASTableViewDataSorceImpl
@end
@implementation MASTableViewDataSorceSubImpl
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MASTableViewNormalCell *cell = [MASTableViewNormalCell cellWithTableView:tableView indexPath:indexPath];
    cell.titleLabel.text = self.dataSource[indexPath.row];
    return cell;
}
@end
```

#### MASTableViewNormalCell

```objc
// ================= .h ====================
@interface MASTableViewNormalCell : UITableViewCell
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) UILabel *titleLabel;
+(NSString*)reuseIdentifier;
+(MASTableViewNormalCell*)cellWithTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;
@end

// ================= .m ====================

static UIEdgeInsets const kPadding = {10, 10, 10, 10};
@implementation MASTableViewNormalCell
#pragma mark - Init Views
+(NSString*)reuseIdentifier{
    return NSStringFromClass([self class]);
}

+(MASTableViewNormalCell*)cellWithTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath{
    MASTableViewNormalCell *cell = [tableView dequeueReusableCellWithIdentifier:[self reuseIdentifier]];
    if (!cell) {
        cell = [[MASTableViewNormalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[self reuseIdentifier]];
    }
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle =UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.titleLabel];
        
        [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(self.contentView).insets(kPadding); // 关键代码
        }];
    }
    return self;
}
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_titleLabel setNumberOfLines:0];
        [_titleLabel setTextColor:UIColor.blackColor];
    }
    return _titleLabel;
}
#pragma mark setter
@end
```

#### UITableView

```objc
@interface MASExampleTableView()
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MASTableViewDataSorceSubImpl *dataSource;
@property (strong, nonatomic) NSArray *data;
@end

@implementation MASExampleTableView

- (instancetype)init {
    if (self == [super init]) {
        self.dataSource = [MASTableViewDataSorceSubImpl new];
        self.dataSource.dataSource = self.data;
        
        [self addSubview:self.tableView];
        self.tableView.dataSource = self.dataSource;
        self.tableView.delegate = self.delegate;
        [self.tableView reloadData];
        
        [self.tableView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.estimatedRowHeight = 44;
        _tableView.rowHeight = UITableViewAutomaticDimension;//默认值可省略。
    }
    return _tableView;
}
@end
```

### 外部的部分靠内部支撑

<img src="/assets/images/masonry/19.png"/>

```objc
UIView *superView = [LayoutUtils createView];
UIButton *tapButton = [LayoutUtils createButtonWithTitle:@"Add" selector:@selector(add)];

UIEdgeInsets padding = UIEdgeInsetsMake(10, 10, 10, 10);
[superView addSubview:tapButton];

[superView makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.top.mas_equalTo(padding); // 父控件只适配了left.right.top的边距，bottom的的距离根据其内子控件的 bottom
}];

[tapButton makeConstraints:^(MASConstraintMaker *make) {
    make.left.right.top.mas_equalTo(padding);
    make.bottom.mas_equalTo(padding);// 
    make.height.equalTo(@(100));
}];
```

### UIButton自适应宽度

<img src="/assets/images/masonry/20.gif"/>

```objc
- (id)init {
    self = [super init];
    if (!self) return nil;
    
    UIButton *button = [LayoutUtils createButtonWithTitle:@"UIButton宽度" target:self selector:@selector(clickButton:)];
    [self addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        //make.height.mas_equalTo(@[button.titleLabel.mas_height,button.imageView.mas_height]);
        make.height.mas_equalTo(@[button.titleLabel.mas_height]);
        make.width.mas_lessThanOrEqualTo(300);
    }];
    return self;
}
-(void)clickButton:(UIButton*)sender{
    [sender setTitle:[sender.currentTitle stringByAppendingString:@"自适应"] forState:UIControlStateNormal];
}
```

### UITableView九宫格

<img src="/assets/images/masonry/25.gif"/>

```objc
@implementation MASTableViewImagesCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _imagesArr = [NSArray array];

        self.picContentView = [LayoutUtils createView];
        [self.contentView addSubview:self.picContentView];
        [self.picContentView makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.contentView);
        }];
        
        self.bottomView = [LayoutUtils createView];
        [self.contentView addSubview:self.bottomView];
        [self.bottomView makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.picContentView.mas_bottom).insets(kPadding);
            make.height.equalTo(@100);
            make.left.bottom.right.equalTo(kPadding);
        }];
    }
    return self;
}

-(void)updateData{
    NSLog(@"%s",__func__);
    if (self.cellData.imgs && self.cellData.imgs.length > 0) {
        NSString *temptString = self.cellData.imgs;
        if ([[temptString substringFromIndex:temptString.length-1] isEqualToString:@","]) {
            temptString = [temptString substringToIndex:[temptString length]-1];
        }
        self.imagesArr = [temptString componentsSeparatedByString:@","];
        [self createPicView:self.imagesArr.count];
    }
}
- (void)createPicView:(NSInteger)itemNum {
    if (itemNum <= 0) return;
    
    for (UIView *object in self.picContentView.subviews) {
        [object removeFromSuperview];
    }
    
    //假设要显示 num 个item
    NSInteger num = itemNum;
    //每行显示的个数
    NSInteger count = 3;
    //显示的总行数
    NSInteger rowNum = (num/count) + ((NSInteger)(num%count>0));
    
    UIView *lastView = nil;
    for (int i = 0; i < rowNum; i ++) {
        NSMutableArray *masonryViewArray = [NSMutableArray array];
        for (int j = 0; j < count; j ++) {
            NSInteger currentIndex = i * count + j;
            
            UIView *view = [LayoutUtils createView];
            if (currentIndex > num-1) {
                view.backgroundColor = [UIColor clearColor];
                view.layer.borderColor = [UIColor clearColor].CGColor;
            }
            [self.picContentView addSubview:view];
            
            [masonryViewArray addObject:view];
            lastView = view;
        }
        // 固定 item 之间的间距，item 的宽或者高自动缩放
        [masonryViewArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:15 leadSpacing:kPadding.left tailSpacing:kPadding.right];
        // 设置array的垂直方向的约束
        [masonryViewArray makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@((100 * i) + kPadding.top));
            make.height.equalTo(@80).priorityLow();
        }];
    }
    [self.picContentView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lastView.mas_bottom).priorityLow();
    }];
}
@end
```

### UITableView 折叠、展开

<img src="/assets/images/masonry/28.gif"/>

```objc
@interface MASTableViewProfieCell()
@property (strong, nonatomic) MASConstraint* masHeight;
@end

@implementation MASTableViewProfieCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.headImageView = [LayoutUtils createView];
        self.headImageView.layer.cornerRadius = 30;
        self.headImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.headImageView];
        [self.headImageView makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@60);
            make.height.equalTo(@60).priorityLow();
            make.left.top.equalTo(kPadding);
        }];
        [self.headImageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
        self.titleLabel = [LayoutUtils fixedLabelWithText:@""];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.numberOfLines = 1;
        [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(kPadding);
            make.left.equalTo(self.headImageView.mas_right).insets(kPadding);
            make.right.lessThanOrEqualTo(kPadding);
        }];
        
        
        self.descabel = [LayoutUtils fixedLabelWithText:@""];
        self.descabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.descabel];
        [self.descabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headImageView.mas_right).insets(kPadding);
            make.top.equalTo(self.headImageView.mas_centerY);
            make.right.lessThanOrEqualTo(kPadding);
            
            make.bottom.equalTo(kPadding);
            make.bottom.greaterThanOrEqualTo(self.headImageView);
            //self.masHeight = make.height.lessThanOrEqualTo(@100);
        }];
        
    }
    return self;
}
-(void)updateData{
    self.titleLabel.text = self.cellData.content;
    self.descabel.text = self.cellData.content;
    if (self.cellData.isExpended) {
        NSLog(@"==1==");
        //[self.masHeight uninstall];
        self.descabel.numberOfLines = 0;
    }else{
        NSLog(@"==2==");
        //[self.masHeight install];
        self.descabel.numberOfLines = 3;
    }
    
    [super updateData];
}
@end
```

另外一种布局约束，既可以解决`headImageView.bottom<-cell.bottom` cell的底部必须超过`heaImageView`，同时如果`descLabel.bottom<-cell.bottom` cell的底部必须超过`descLabel`；也支持折叠、展开。

<img src="/assets/images/masonry/29.png"/>

```objc
@interface MASTableViewProfieCell()
@property (strong, nonatomic) MASConstraint* masHeight;
@end


@implementation MASTableViewProfieCell
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.headImageView = [LayoutUtils createView];
        self.headImageView.layer.cornerRadius = 30;
        self.headImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.headImageView];
        [self.headImageView makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@60);
            make.height.equalTo(@60).priorityLow();
            make.left.top.equalTo(kPadding);
            make.bottom.lessThanOrEqualTo(kPadding); //关键代码
        }];
        [self.headImageView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
        self.titleLabel = [LayoutUtils fixedLabelWithText:@""];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.numberOfLines = 1;
        [self.titleLabel makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(kPadding);
            make.left.equalTo(self.headImageView.mas_right).insets(kPadding);
            make.right.lessThanOrEqualTo(kPadding);
        }];
        
        
        self.descabel = [LayoutUtils fixedLabelWithText:@""];
        self.descabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:self.descabel];
        [self.descabel makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headImageView.mas_right).insets(kPadding);
            make.top.equalTo(self.headImageView.mas_centerY);
            make.right.lessThanOrEqualTo(kPadding);
            
            //make.bottom.equalTo(kPadding);
            self.masHeight = make.height.lessThanOrEqualTo(@100); //关键代码
            //make.bottom.greaterThanOrEqualTo(self.headImageView);
            make.bottom.lessThanOrEqualTo(kPadding); //关键代码
        }];
        
    }
    return self;
}
-(void)updateData{
    self.titleLabel.text = self.cellData.content;
    self.descabel.text = self.cellData.content;
    if (self.cellData.isExpended) {
        NSLog(@"==1==");
        [self.masHeight uninstall]; //关键代码
        self.descabel.numberOfLines = 0;
    }else{
        NSLog(@"==2==");
        [self.masHeight install]; //关键代码
        self.descabel.numberOfLines = 3;
    }
    
    [super updateData];
}

-(void)updateConstraints{
    [super updateConstraints];
}
@end
```
<img src="/assets/images/masonry/30.png"/>

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## 资料

* [系统理解 iOS 自动布局](http://chuquan.me/2019/09/25/systematic-understand-ios-autolayout/)