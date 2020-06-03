---
title: Objective-C 开发规范
layout: post
categories:
 - ios
published: true
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

## UITableView

```objc
@interface DouBanDetailTableViewCell()
@end

@implementation DouBanDetailTableViewCell
+(NSString*)reuseIdentifier{
    return NSStringFromClass([self class]);
}

+(DouBanDetailTableViewCell*)cellWithTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath{
    DouBanDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[DouBanDetailTableViewCell reuseIdentifier]];
    if (!cell) {
        cell = [[DouBanDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[DouBanDetailTableViewCell reuseIdentifier]];
    }
    cell.indexPath = indexPath;
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self cellAddSubViews];
    }
    return self;
}

#pragma mark - init Views
-(void)cellAddSubViews{
}

#pragma mark - Layout
-(void)updateConstraints{
    [super updateConstraints];
}

#pragma mark - getter
@end
```