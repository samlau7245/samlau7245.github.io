---
title: protocol
layout: post
categories:
 - ios
---

## 示例

### UITableViewDataSource

非常简单的例子说明，`@protocol UITableViewDataSource`，在iOS中的协议(protocol)，可看成JAVA中的接口(interface),在UITableView中：

```objc
@property (nonatomic, weak, nullable) id <UITableViewDataSource> dataSource;
```

可以看出属性`dataSource`中，你只要赋值一个遵守`<UITableViewDataSource>`协议的对象就行，也就是JAVA中的`Impl`。

```objc
@interface TableViewDataSourceImpl : NSObject<UITableViewDataSource>
@property (nonatomic,strong) NSArray *array;
@end

@implementation TableViewDataSourceImpl
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.titleLabel.text=((CustomModel *)[_array objectAtIndex:indexPath.row]).title;
    return cell;
}
@end

// ==使用
- (void)viewDidLoad {
    tableViewDataSource=[[TableViewDataSourceImpl alloc] init];
    tableView.dataSource=tableViewDataSource;
}
```
