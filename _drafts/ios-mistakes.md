---
title: iOS开发错误记录
layout: post
categories:
 - ios
---



--- 

```objc
[Application] The app delegate must implement the window property if it wants to use a main storyboard file.
```

用XCode11新建一个工程支持的最小iOS版本小于iOS13的话，XCode控制台会爆出提示

```objc
@implementation AppDelegate
@synthesize window = _window; // 添加这一句就行了
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}
@end
```
## 参考资料

* [stackoverflow](https://stackoverflow.com/questions/tagged/ios%2bobjective-c?tab=Votes)