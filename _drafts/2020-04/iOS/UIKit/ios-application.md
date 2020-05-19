---
title: MVVM
layout: post
categories:
 - ios
---


* Controller
	* `Controller`负责控制`View`、`ViewModel`的绑定关系。
* Model
	* 数据模型、访问数据库的操作和网络请求等。
* ViewModel	
	* 实现View的展示逻辑。
	* viewModel 中的代码是与 UI 无关的，所以它具有良好的可测试性。
* View
	* 把 view 看作是 viewModel 的可视化形式。	
* binder
	* 实现 view 和 viewModel 的同步。	

* [用户操作界面，每个模块触发的逻辑](http://www.cocoachina.com/articles/11930)

数据通讯：

* ReactiveCocoa
* KVO
* Notification
* block
* Delegate
* Target-Action
