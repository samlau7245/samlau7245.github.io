---
title: Masonry
layout: post
categories:
 - ios
---

## Masonry

* `priorityLow` : 约束优先级-低。
* `priorityMedium` : 约束优先级-中。
* `priorityHigh` : 约束优先级-高。

* `makeConstraints:` : 添加约束。
* `updateConstraints:` : 更新约束、亦可添加新约束。
* `remakeConstraints:` : 重置之前的约束。
* `mas_distributeViewsAlongAxis:withFixedSpacing:leadSpacing:tailSpacing:`
* `mas_distributeViewsAlongAxis:withFixedItemLength:leadSpacing:tailSpacing:`

* `multipler` : 表示约束值为约束对象的乘因数。
* `dividedBy` : 表示约束值为约束对象的除因数。

* `greaterThanOrEqualTo` : 。
* `lessThanOrEqualTo` : 。

### 布局使用结构体

```objc
make.center.equalTo(CGPointMake(0, 50));
make.size.equalTo(CGSizeMake(200, 100));
make.edges.equalTo(superview).insets(UIEdgeInsetsMake(self.padding, self.padding, self.padding, self.padding));
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

### 给Masonry添加Debug

* 当约束冲突时，打印的日志比较难定位是哪些控件的约束或者说是哪条约束，Masonry已经给我们提供了相关的方法:`MASAttachKeys()`、给约束设置`key`。

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

### 搭配Frame用于Label

```objc
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

### UIScrollView布局

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

### 外部的部分靠内部支撑

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

