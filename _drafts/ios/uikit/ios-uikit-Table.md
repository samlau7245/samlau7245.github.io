---
title: UIKit-表格相关
layout: post
categories:
 - ios
---

## UITableView

### 底部顶部view

```objc
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *adView = [UIView new];
    adView.backgroundColor = UIColor.redColor;
    return adView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return LYScreenWidth()/6.4;
}
// 刷新footer
//-(void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    // self.tableView footerViewForSection:<#(NSInteger)#>
	// self.tableView setTableFooterView:<#(UIView * _Nullable)#>
//}
```