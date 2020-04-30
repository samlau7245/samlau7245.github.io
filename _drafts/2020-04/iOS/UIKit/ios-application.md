---
title: UIKit - UIApplication
layout: post
categories:
 - ios
---

```objc
// APP 前台->后台：
UIKIT_EXTERN NSNotificationName const UIApplicationDidEnterBackgroundNotification       API_AVAILABLE(ios(4.0));
- (void)applicationDidEnterBackground:(UIApplication *)application API_AVAILABLE(ios(4.0));

// APP 后台->前台：
UIKIT_EXTERN NSNotificationName const UIApplicationWillEnterForegroundNotification      API_AVAILABLE(ios(4.0));
- (void)applicationWillEnterForeground:(UIApplication *)application API_AVAILABLE(ios(4.0));
```