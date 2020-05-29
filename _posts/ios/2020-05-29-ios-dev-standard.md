---
title: Objective-C 开发规范
layout: post
categories:
 - ios
---

## 编程规约

### 注释规约

* **【强制】**
* **【推荐】** 善于使用标记代码标记。

```
//MARK: <#Write here#>
//TODO: <#Write here#>
//FIXME: <#Write here#>
//!!!!: <#Write here#>
//???: <#Write here#>
```

<img src="/assets/images/ios-records/02.png" width = "25%" height = "25%"/>

* **【参考】**

### RAC&MVVM开发规约

#### V层

```objc
@interface RACAndMVVMViewController ()
@property(nonatomic, strong) RACAndMVVMViewModel *viewModel;
@end

@implementation RACAndMVVMViewController02
- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindViewModel];
}

#pragma mark - RAC Data Binding
- (void)bindViewModel {
}

#pragma mark - getter
-(RACAndMVVMViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [RACAndMVVMViewModel new];
    }
    return _viewModel;
}
@end
```