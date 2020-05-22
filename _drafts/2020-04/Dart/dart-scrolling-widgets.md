---
title: Flutter Widgets - PageView
layout: post
categories:
 - dart
---

涉及到的类名：

* widgets
  * page_storage.dart
  * page_view.dart
  * pages.dart
* material
  * [page.dart](https://juejin.im/post/5b3ee117f265da0fb0184db4)、[导航到新页面并返回](https://flutterchina.club/cookbook/navigation/navigation-basics/)
  * page_transitions_theme.dart

## [PageView](https://api.flutter.dev/flutter/widgets/PageView-class.html)

PageView 是一个可以一页一页滑动的组件，可以通过来 ，也可以 PageView 的偏移量。

[PageController](https://api.flutter.dev/flutter/widgets/PageController-class.html)的作用：

* 控制PageView的哪一页是可视的 View。
* 控制 PageView 的偏移量。
* `PageController.initialPage` 控制PageView在初始化的时候，显示哪一页。
* `PageController.viewportFraction` 每个页面应占据的视口比例。

```dart
// 如果数据源固定，那么可以通过这个构造函数来创建PageView
PageView({
  Key key,
  this.scrollDirection = Axis.horizontal, //滑动方向-默认水平
  this.reverse = false,
  PageController controller,
  this.physics,
  this.pageSnapping = true,
  this.onPageChanged,
  List<Widget> children = const <Widget>[],
  this.dragStartBehavior = DragStartBehavior.start,
  this.allowImplicitScrolling = false,
});

// 如果数据量比较大可以通过这个来创建PageView
PageView.builder({
  Key key,
  this.scrollDirection = Axis.horizontal,//滑动方向-默认水平
  this.reverse = false,
  PageController controller,
  this.physics,
  this.pageSnapping = true,
  this.onPageChanged,
  @required IndexedWidgetBuilder itemBuilder,
  int itemCount,
  this.dragStartBehavior = DragStartBehavior.start,
  this.allowImplicitScrolling = false,
});

PageView.custom({
  Key key,
  this.scrollDirection = Axis.horizontal,//滑动方向-默认水平
  this.reverse = false,
  PageController controller,
  this.physics,
  this.pageSnapping = true,
  this.onPageChanged,
  @required this.childrenDelegate,
  this.dragStartBehavior = DragStartBehavior.start,
  this.allowImplicitScrolling = false,
})
```

在`PageView.custom`中，需要创建代理`this.childrenDelegate -> SliverChildDelegate`，而`SliverChildDelegate`是一个抽象类不能直接使用，可以使用子类`SliverChildBuilderDelegate` 、`SliverChildListDelegate`。

```dart
const SliverChildBuilderDelegate(
  this.builder, { // 构造器
  this.findChildIndexCallback, // 回调函数
  this.childCount,// 子组件总数
  this.addAutomaticKeepAlives = true,
  this.addRepaintBoundaries = true,
  this.addSemanticIndexes = true,
  this.semanticIndexCallback = _kDefaultSemanticIndexCallback,
  this.semanticIndexOffset = 0,
});

SliverChildListDelegate(
  this.children, {
  this.addAutomaticKeepAlives = true,
  this.addRepaintBoundaries = true,
  this.addSemanticIndexes = true,
  this.semanticIndexCallback = _kDefaultSemanticIndexCallback,
  this.semanticIndexOffset = 0,
})
```

## PageController

```dart
PageController({
  this.initialPage = 0,// 设定开始页面
  this.keepPage = true,
  this.viewportFraction = 1.0,
});
```

## PageMetrics
## PageScrollPhysics

```dart
import 'package:flutter/material.dart';

class ServicePage extends StatefulWidget {
  @override
  _ServicePageState createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  PageController _pageController = PageController(
    initialPage: 1, // 设定开始页面
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PageView Demo"),
      ),
      body: PageView(
        controller: _pageController,
        //scrollDirection: Axis.vertical,
        children: [
          Center(child: Text("Page1")),
          Center(child: Text("Page2")),
          Center(child: Text("Page3")),
          Center(child: Text("Page4")),
        ],
        onPageChanged: (int index) {},
      ),
    );
  }
}
```
## 资料
* [flutter.cn-Scrolling widgets](https://flutter.cn/docs/development/ui/widgets/scrolling)
