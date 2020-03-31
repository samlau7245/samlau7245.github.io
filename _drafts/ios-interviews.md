---
title: iOS面试 building...
description: building...
layout: post
date: 2019-12-21 05:20:00
categories:
 - ios
---

## UIButton

### 修改`UIButton`中`imageView`的图片颜色

```objc
UIImage *image = [UIImage imageNamed:@"back"];
image = [image imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];

UIButton *_goBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
[_goBackButton setImage:image forState:UIControlStateNormal];
_goBackButton.tintColor = [UIColor redColor];
```

## UIImageView

### 修改`imageView`的图片颜色

```objc
UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back"]];
imgView.image = [imgView.image imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
imgView.tintColor = [UIColor whiteColor];
```

### [iOS NSError HTTP错误码大全](https://www.cnblogs.com/yang-shuai/p/6830142.html)

## Foundation

### 字典(NSDictionary)和JSON字符串(NSString)之间互转

### NSNotificationCenter

```objc
// 在 ViewControllerA 中定义了通知
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderPayResult:) name:@"NSNotificationName" object:@"A"]

// 在 ViewControllerB 中定义了通知
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderPayResult:) name:@"NSNotificationName" object:@"B"]

// 在ViewControllerC中发起通知，发起这个通知就只会在 ViewControllerA 的 getOrderPayResult 才会触发
[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NSNotificationName" object:@"A" userInfo:@{}]];

// 在ViewControllerC中发起通知，发起这个通知就只会在 ViewControllerB 的 getOrderPayResult 才会触发
[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NSNotificationName" object:@"B" userInfo:@{}]];

// 在ViewControllerC中发起通知，ViewControllerB ViewControllerA 都收不到通知
[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NSNotificationName" object:nil userInfo:@{}]];
```

