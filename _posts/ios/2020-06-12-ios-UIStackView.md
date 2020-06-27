---
title: UIStackView
layout: post
categories:
 - ios
---

> 系统：9.0以上。

`UIStackView`像一个容器，类似于`UITableView`，`UICollectionView`。

[仓库地址](https://gitee.com/samcoding/MasonryExample.git )

## 创建

初始化方式：

```objc
- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithArrangedSubviews:(NSArray<__kindof UIView *> *)views;
@property(nonatomic,readonly,copy) NSArray<__kindof UIView *> *arrangedSubviews;
```

```objc
UIStackView *sv = [LayoutUtils creatStackView];
[self addSubview:sv];

UIView *subView1 = [LayoutUtils createView];
UIView *subView2 = [LayoutUtils createView];

// 子View 实例加到 UIStackView 里
[sv addArrangedSubview:subView1];
[sv addArrangedSubview:subView2];

NSArray<UIView *> *arrangedSubviews = sv.arrangedSubviews;
NSLog(@"%@",arrangedSubviews);
/*
2020-06-12 09:39:59.898694+0800 MasonryExample[65963:3203047] (
    "<UIView: 0x7fcb28c40940; frame = (0 0; 0 0); layer = <CALayer: 0x6000039cfd60>>",
    "<UIView: 0x7fcb28c40ab0; frame = (0 0; 0 0); layer = <CALayer: 0x6000039cfda0>>"
)
*/
```

```objc
UILabel *subLabel1 = [LayoutUtils fixedLabelWithText:@"Sub1"];
UILabel *subLabel2 = [LayoutUtils fixedLabelWithText:@"Sub2"];

UIStackView *sv = [[UIStackView alloc] initWithArrangedSubviews:@[subLabel1,subLabel2]];
[self addSubview:sv];

NSArray<UIView *> *arrangedSubviews = sv.arrangedSubviews;
NSLog(@"%@",arrangedSubviews);
/*
2020-06-12 09:42:19.734773+0800 MasonryExample[66066:3204972] (
    "<UILabel: 0x7f909d73d010; frame = (0 0; 0 0); text = 'Sub1'; userInteractionEnabled = NO; layer = <_UILabelLayer: 0x600000803200>>",
    "<UILabel: 0x7f909d7430b0; frame = (0 0; 0 0); text = 'Sub2'; userInteractionEnabled = NO; layer = <_UILabelLayer: 0x6000008032f0>>"
)
*/
```

从结构上看`@interface UIStackView : UIView`，`UIStackView`是继承自`UIView`，对比下他们的关系：

* `subviews`：它的顺序实际上是图层覆盖顺序，也就是视图元素的`z`轴。
* `arrangedSubviews`：它的顺序代表了 `stack` 堆叠的位置顺序，即视图元素的`x`轴和`y`轴。
* 如果一个元素没有被 `addSubview`，调用 `arrangedSubviews` 会自动 `addSubview`。
* 当一个元素被 `removeFromSuperview` ，则 `arrangedSubviews`也会同步移除。
* 当一个元素被 `removeArrangedSubview`， 不会触发 `removeFromSuperview`，它依然在视图结构中。

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## 布局

可以控制布局的几种方式，

```objc
@property(nonatomic) UILayoutConstraintAxis axis;
@property(nonatomic) UIStackViewDistribution distribution;
@property(nonatomic) UIStackViewAlignment alignment;
@property(nonatomic) CGFloat spacing;
@property(nonatomic,getter=isBaselineRelativeArrangement) BOOL baselineRelativeArrangement;
@property(nonatomic,getter=isLayoutMarginsRelativeArrangement) BOOL layoutMarginsRelativeArrangement;
```

<img src="/assets/images/masonry/40.png"/>

### axis 布局方向（轴）

```objc
@property(nonatomic) UILayoutConstraintAxis axis;

typedef NS_ENUM(NSInteger, UILayoutConstraintAxis) {
    UILayoutConstraintAxisHorizontal = 0, // 水平方向
    UILayoutConstraintAxisVertical = 1 // 垂直方向
};
```

### distribution 子视图的分布

```objc
@property(nonatomic) UIStackViewDistribution distribution;

typedef NS_ENUM(NSInteger, UIStackViewDistribution) {
    UIStackViewDistributionFill = 0,// 默认，轴方向上填充
    UIStackViewDistributionFillEqually, //轴方向等宽或登高
    UIStackViewDistributionFillProportionally,// 轴方向，比例分布
    UIStackViewDistributionEqualSpacing,// 子视图间隔一致
    UIStackViewDistributionEqualCentering, // 子视图中心距离一致
}
```

#### UIStackViewDistributionFill

* `UILayoutConstraintAxisHorizontal`:
	* `UIStackView`中的所有子视图的宽度等于`UIStackView`的宽。
	* 当`UIStackView`中有1个子视图，则子视图的宽度就等于UIStackView的宽。
	* 当`UIStackView`中有2个子视图，且优先级一样，则会拉伸或压缩某个子视图，使两个子视图的宽度之和等于UIStackView的宽。
	* 当`UIStackView`中有2个子视图，且优先级不一样，则会按优先级从高到低设置子视图的位置，对优先级最低的子视图进行必要的拉伸或压缩。
* `UILayoutConstraintAxisVertical`:
	* `UIStackView`中的所有子视图的宽度等于`UIStackView`的高。
	* 当`UIStackView`中有1个子视图，则子视图的高度就等于UIStackView的高。
	* 当`UIStackView`中有2个子视图，且优先级一样，则会拉伸或压缩某个子视图，使两个子视图的高度之和等于UIStackView的高。
	* 当`UIStackView`中有2个子视图，且优先级不一样，则会按优先级从高到低设置子视图的位置，对优先级最低的子视图进行必要的拉伸或压缩。

`UIStackViewDistributionFill`基本就是在轴方向上对子视图进行填充，类似对所有的子视图执行了下面两个方法：

```objc
// 别挤我
- (void)setContentCompressionResistancePriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis;
// 抱紧，类似于sizefit，不会根据父view长度变化
- (void)setContentHuggingPriority:(UILayoutPriority)priority forAxis:(UILayoutConstraintAxis)axis;
```

<img src="/assets/images/masonry/37.png"/>

#### UIStackViewDistributionFillEqually

* `UILayoutConstraintAxisHorizontal`:
	* 所有子视图在轴方向上等宽。
* `UILayoutConstraintAxisVertical`:
	* 所有子视图在轴方向上等高。

<img src="/assets/images/masonry/38.png"/>

```objc
[subView1 makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@(CGSizeMake(40, 100))).priorityLow();
}];
[subView2 makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@(CGSizeMake(100, 80))).priorityLow();
}];
[subView3 makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@(CGSizeMake(70, 120))).priorityLow();
}];

[stackView makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view);
    make.top.equalTo(@100);
    make.right.lessThanOrEqualTo(self.view);
    make.height.equalTo(@200);
}];
```

<img src="/assets/images/masonry/41.png"/>

#### UIStackViewDistributionFillProportionally

该属性设置后会根据原先子视图的比例来拉伸或压缩子视图的宽或高，如果三个子视图原先设置的宽度是1：2：3，所以水平方向上显示时，会按照这个比例进行拉伸。

<img src="/assets/images/masonry/46.png"/>

```objc
[subView1 makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@(CGSizeMake(1, 200))).priorityLow();
}];
[subView2 makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@(CGSizeMake(2, 200))).priorityLow();
}];
[subView3 makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@(CGSizeMake(3, 200))).priorityLow();
}];

[stackView makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view);
    make.top.equalTo(@100);
    make.right.equalTo(self.view);
    make.height.equalTo(@200);
}];
```

<img src="/assets/images/masonry/43.png"/>

#### UIStackViewDistributionEqualSpacing

该属性会保持子视图的宽高，所有子视图中间的间隔保持一致。

<img src="/assets/images/masonry/39.png"/>

```objc
[subView1 makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@(CGSizeMake(40, 100))).priorityLow();
}];
[subView2 makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@(CGSizeMake(100, 80))).priorityLow();
}];
[subView3 makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@(CGSizeMake(70, 120))).priorityLow();
}];

[stackView makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view);
    make.top.equalTo(@100);
    make.right.lessThanOrEqualTo(self.view);
    make.height.equalTo(@200);
}];
```

<img src="/assets/images/masonry/44.png"/>

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *subView1 = [LayoutUtils createView];
    UIView *subView2 = [LayoutUtils createView];
    UIView *subView3 = [LayoutUtils createView];
    
    subView1.tag = 0;
    subView2.tag = 1;
    subView3.tag = 2;
    
    subView1.backgroundColor = UIColor.redColor;
    subView2.backgroundColor = UIColor.greenColor;
    subView3.backgroundColor = UIColor.blueColor;
    
    [subView1 makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(CGSizeMake(130, 100)));
    }];
    [subView2 makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(CGSizeMake(130, 80)));
    }];
    [subView3 makeConstraints:^(MASConstraintMaker *make) {
    	// priorityLow() 是为了防止子视图总宽度超过，UIStackView 限制的宽度被挤压而产生的约束不合法。
        make.size.equalTo(@(CGSizeMake(130, 120))).priorityLow();
    }];
    // 130 * 3 = 390 > 375 ，超过屏幕的宽度了，subView3 优先级比较低，所以首先会被挤压。
    
    sv = [[UIStackView alloc] initWithArrangedSubviews:@[subView1,subView2,subView3]];
    sv.alignment = UIStackViewAlignmentBottom;
    sv.distribution = UIStackViewDistributionEqualSpacing;
    sv.spacing = 30;
    [self.view addSubview:sv];
    // 不设置宽度，让它宽度自适应
    [sv makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(kPadding);
        make.top.equalTo(@100);
        make.right.lessThanOrEqualTo(kPadding);
        make.height.equalTo(200);
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (UIView *object in sv.arrangedSubviews) {
        if (object.tag == 1) {
            [object setHidden:YES]; // [object removeFromSuperview];
        }
    }
}
```

<img src="/assets/images/masonry/42.gif"/>

#### UIStackViewDistributionEqualCentering

该属性会控制所有子视图的中心之间的距离保持一致。

<img src="/assets/images/masonry/45.png"/>

```objc
[subView1 makeConstraints:^(MASConstraintMaker *make) {
     make.size.equalTo(@(CGSizeMake(40, 100))).priorityLow();
}];
[subView2 makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@(CGSizeMake(100, 80))).priorityLow();
}];
[subView3 makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@(CGSizeMake(70, 120))).priorityLow();
}];

[stackView makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view);
    make.top.equalTo(@100);
    make.right.equalTo(self.view);
    make.height.equalTo(@200);
}];
```

<img src="/assets/images/masonry/47.png"/>

### alignment

`alignment` : 控制子视图之间的间隔大小。在`distribution`属性设置为`UIStackViewDistributionFill`、`UIStackViewDistributionFillEqually`、`UIStackViewDistributionFillProportionally`值的时候，子视图是没有间隔的，我们就可以通过`alignment`属性来设置子视图之间的间距。

```objc
@property(nonatomic) UIStackViewAlignment alignment;

typedef NS_ENUM(NSInteger, UIStackViewAlignment) {
    UIStackViewAlignmentFill,
    UIStackViewAlignmentLeading,
    UIStackViewAlignmentTop = UIStackViewAlignmentLeading,
    UIStackViewAlignmentFirstBaseline, 
    UIStackViewAlignmentCenter,
    UIStackViewAlignmentTrailing,
    UIStackViewAlignmentBottom = UIStackViewAlignmentTrailing,
    UIStackViewAlignmentLastBaseline, 
}
```

<img src="/assets/images/masonry/51.png"/>

#### `UIStackViewAlignmentFill`

尽可能铺满

<img src="/assets/images/masonry/48.png"/>


#### UIStackViewAlignmentLeading、UIStackViewAlignmentTop 

* `UILayoutConstraintAxisVertical` :
	* `UIStackViewAlignmentLeading` 按 leading 方向对齐
* `UILayoutConstraintAxisHorizontal` :
	* `UIStackViewAlignmentTop` 按 top 方向对齐。

<img src="/assets/images/masonry/32.png"/>

```objc
[subView1 makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@(CGSizeMake(40, 100))).priorityLow();
}];
[subView2 makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@(CGSizeMake(100, 80))).priorityLow();
}];
[subView3 makeConstraints:^(MASConstraintMaker *make) {
    make.size.equalTo(@(CGSizeMake(70, 120))).priorityLow();
}];

[stackView makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view);
    make.top.equalTo(@100);
    make.right.equalTo(self.view);
    make.height.equalTo(@200);
}];
```

<img src="/assets/images/masonry/50.png"/>

#### UIStackViewAlignmentTrailing、UIStackViewAlignmentBottom

* `UILayoutConstraintAxisVertical` :
	* `UIStackViewAlignmentTrailing` 按 trailing 方向对齐。
* `UILayoutConstraintAxisHorizontal` :
	* `UIStackViewAlignmentBottom` 按 bottom 方向对齐。

<img src="/assets/images/masonry/33.png"/>

#### UIStackViewAlignmentCenter

居中对齐

<img src="/assets/images/masonry/34.png"/>

#### UIStackViewAlignmentFirstBaseline

* `UILayoutConstraintAxisVertical` : 垂直方向无效。
* `UILayoutConstraintAxisHorizontal` : 水平方向**有效**，按首行基线对齐。

<img src="/assets/images/masonry/35.png"/>

#### UIStackViewAlignmentLastBaseline

* `UILayoutConstraintAxisVertical` : 垂直方向无效。
* `UILayoutConstraintAxisHorizontal` : 水平方向**有效**，按文章底部基线对齐。

<img src="/assets/images/masonry/36.png"/>

### spacing

```objc
// 设置元素之间的边距值
@property(nonatomic) CGFloat spacing;
```

### baselineRelativeArrangement

```objc
// 决定了垂直轴如果是文本的话，是否按照 baseline 来参与布局，默认 false。
@property(nonatomic,getter=isBaselineRelativeArrangement) BOOL baselineRelativeArrangement;
```

### layoutMarginsRelativeArrangement

```objc
// 如果打开则通过 layout margins 布局，关闭则通过 bounds，默认 false。
@property(nonatomic,getter=isLayoutMarginsRelativeArrangement) BOOL layoutMarginsRelativeArrangement;
```

### 刷新布局

```objc
UIView *subView = [LayoutUtils createView];
[self.topStackView addArrangedSubview:subView];
[UIView animateWithDuration:0.25 animations:^{
    [self.topStackView layoutIfNeeded];
}];
```

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## 子视图操作

```objc
// 新增
- (void)addArrangedSubview:(UIView *)view;
// 移除
- (void)removeArrangedSubview:(UIView *)view;
// 插入
- (void)insertArrangedSubview:(UIView *)view atIndex:(NSUInteger)stackIndex;
```

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## 示例

### 点赞

<img src="/assets/images/masonry/49.png"/>

```objc
NSMutableArray<UIView*> *imageViewArray = [NSMutableArray array];
for (int i = 0; i < 5; i ++) {
    UIView *subView = [LayoutUtils createView];
    [subView makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(CGSizeMake(50, 50)));
    }];
    subView.layer.cornerRadius = 25;
    subView.layer.masksToBounds = YES;
    subView.clipsToBounds = true;
    [imageViewArray addObject:subView];
}

UIStackView *stackView = [[UIStackView alloc] initWithArrangedSubviews:imageViewArray];
stackView.distribution = UIStackViewDistributionFillEqually;
stackView.alignment = UIStackViewAlignmentCenter;
stackView.spacing = -15;
[self.view addSubview:stackView];

[stackView makeConstraints:^(MASConstraintMaker *make) {
    make.left.equalTo(self.view);
    make.top.equalTo(@100);
    //make.right.equalTo(self.view);
    make.height.equalTo(@50);
}];
```

### 给人打星评价

<img src="/assets/images/masonry/52.gif"/>

```objc
@interface UIKitExampleStackViewStarController ()
@property(nonatomic,strong) UIStackView *topStackView;
@property(nonatomic,strong) UIStackView *bottomStackView;
@end

@implementation UIKitExampleStackViewStarController
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"点击星星";
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _topStackView = [[UIStackView alloc] init];
    _topStackView.axis = UILayoutConstraintAxisVertical;
    _topStackView.alignment = UIStackViewAlignmentCenter;
    _topStackView.distribution = UIStackViewDistributionFillEqually;
    _topStackView.spacing = 6;
    
    _bottomStackView = [[UIStackView alloc] init];
    _bottomStackView.alignment = UIStackViewAlignmentCenter;
    _bottomStackView.distribution = UIStackViewDistributionFillEqually;
    _bottomStackView.spacing = 6;
    
    [self.view addSubview:self.topStackView];
    [self.view addSubview:self.bottomStackView];
    
    [self.topStackView makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(@100);
        make.height.equalTo(400);
    }];
    
    [self.bottomStackView makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.topStackView.mas_bottom);
    }];
    
    UILabel *titleLabel = [LayoutUtils fixedLabelWithText:@"给个评价吧？"];
    UIView *logoView = [LayoutUtils createView];
    UIButton *addStarButton = [LayoutUtils createButtonWithTitle:@"Star" target:self selector:@selector(addStar)];
    UIButton *removeStarButton = [LayoutUtils createButtonWithTitle:@"Remove Star" target:self selector:@selector(removeStar)];
    UIStackView *operation = [[UIStackView alloc] initWithArrangedSubviews:@[addStarButton,removeStarButton]];
    operation.distribution = UIStackViewDistributionFillEqually;
    
    [self.topStackView addArrangedSubview:titleLabel];
    [self.topStackView addArrangedSubview:logoView];
    [self.topStackView addArrangedSubview:operation];
    
    [logoView makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(CGSizeMake(50, 50))).priorityLow();
    }];
    
    [self.topStackView layoutIfNeeded];
}
-(void)addStar{
    UIView *starView = [LayoutUtils createView];
    [self.bottomStackView addArrangedSubview:starView];
    [starView makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(@(CGSizeMake(50, 50))).priorityHigh();
    }];
    starView.layer.cornerRadius = 25;
    starView.layer.masksToBounds = YES;
    starView.clipsToBounds = true;
    [UIView animateWithDuration:0.2 animations:^{
        [self.bottomStackView layoutIfNeeded];
    }];
}
-(void)removeStar{
    if (self.bottomStackView.arrangedSubviews.count >= 1) {
        [self.bottomStackView.arrangedSubviews.lastObject removeFromSuperview];
        [UIView animateWithDuration:0.2 animations:^{
            [self.bottomStackView layoutIfNeeded];
        }];
    }
}
@end
```

### 添加边距

```objc
stackView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 10);
[stackView setLayoutMarginsRelativeArrangement:YES];
```

### 翻译

<!-- 










 -->
<!--====================================================================================================-->
<!-- 










 -->

## 资料

* [掘金-UIStackView 入坑指南](https://juejin.im/post/5c2ee162e51d4550fc42ac57)
* [iOS 9: Getting Started with UIStackView](https://code.tutsplus.com/tutorials/ios-9-getting-started-with-uistackview--cms-24193)