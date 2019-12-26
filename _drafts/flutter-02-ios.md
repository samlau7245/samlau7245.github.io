---
title: 给 iOS 开发者的 Flutter 指南 
description: building...
layout: post
categories:
 - flutter
---

* [flutter example](https://gitee.com/BackEndLearning/flutter_example)
* [Material核心widget](https://flutter.cn/docs/development/ui/widgets/material)

## [MaterialApp](https://api.flutter.dev/flutter/material/MaterialApp-class.html)

```dart
final Widget home;
final Map<String, WidgetBuilder> routes;
```

* `MaterialApp`中同时指定了`home`、`routes`，则在`routes`中不能包含`'/'`。

## [APP 结构和导航栏(NavigationBar)](https://flutter.cn/docs/development/ui/widgets/material#App%20structure%20and%20navigation)

### BottomNavigationBar. 

`MaterialApp`中要实现底部导航栏的功能，需要了解的类[BottomNavigationBar](https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html#instance-properties)、[BottomNavigationBarItem](https://api.flutter.dev/flutter/widgets/BottomNavigationBarItem-class.html#instance-properties)。其中`BottomNavigationBar`类是和`Scaffold`结合使用，作为`Scaffold`。

```dart
final Widget bottomNavigationBar
```

[查看代码](https://gitee.com/BackEndLearning/flutter_example/commit/6906c7e837e38c5662d9b3e30067d70514549423)


<!-- ### 切换导航栏

* `iOS`中可以控制`UINavigationController`来管理`viewcontroller`的显示。<br>
* `Flutter`中可以通过`Navigator`和`Routes`来控制。其中一个`Route`可以看成应用中的屏幕或者页面，可以理解为`UIViewController`，一个`Navigator`可以管理多个`Route`的`widget`。

### 跳转到其他应用

`iOS`中可以通过设置`URL scheme`来实应用间跳转。<br>
`Flutter`中可以通过插件来实现，例如：[url_launcher](https://pub.flutter-io.cn/packages/url_launcher)


### 退回到`iOS`原生的`viewcontroller`

调用：`SystemNavigator.pop()`。
 -->
<!-- 

## 视图类

### `UIView` & `Widget`

|UIView|Widget|
| --- | --- |
| `UIView`修改视图只需调用`setNeedsDisplay()`方法，不需要重新创建实例对象 | 整个生命周期不可变，只能存活到被修改的时候，一旦`Widget`的状态发生了改变，`Flutter`框架就会创建一个新的由`Widget` 实例对象构造而成的树状结构 |

### 更新`Widget`

|`Stateful widget`|`Stateless widget`|
| --- | --- |
| 状态可变 | 状态不可变 |
| 有`State`对象来存储、更新状态信息|没有`State`对象|

举个例子：

当`UIImageView` 添加一个本地logo图并且这个图不会发生变化，那么在`Flutter`中可以使用`StatelessWidget`。<br/>
当`UIImageView` 添加一个网络图片(`SDWebImage`)，应该使用`StatefulWidget`；在网络请求结束后，通知`Flutter`更新这个`widget`的`State`，然后`UI`就会得到更新。

**创建一个纯展示的文本**

在系统中`Text`就是继承与`StatelessWidget`

```dart
class Text extends StatelessWidget {}
```

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Welcome to Flutter'),
        ),
        body: Center(
          child: Text('Hello World'), // 这就是纯展示，状态不会变动
        ),
      ),
    );
  }
}
```

**点击按钮，更新文本内容**

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: UpdatePage(),
    );
  }
}

// 创建一个 StatefulWidget
class UpdatePage extends StatefulWidget {
  @override
  _UpdatePageState createState() => _UpdatePageState();
}

// 创建一个管理状态的 State
class _UpdatePageState extends State<UpdatePage> {
  String _textToShow = "I Like Flutter";

  void _updateText() {
    setState(() {
      _textToShow = "Flutter is Awesome!";
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AppBar') ,
      ),
      body: Center(
        child: Text(_textToShow),
      ),
      // 点击桌面上的按钮触发_updateText方法，更新文本内容
      floatingActionButton: FloatingActionButton(
        onPressed: _updateText,
        tooltip: 'Update Text',
        child: Icon(Icons.update),
      ),
    );
  }
}
```

### [布局Widget](https://flutter.cn/docs/development/ui/widgets/layout)

任何`widget`添加`padding`，来达到类似在`iOS`中视图约束的作用。

### 增加、移除视图

`iOS`中可以通过`addSubview()`、`removeFromSuperview()`来增加、移除子视图。<br>
`Flutter`中`widget`是不可变的，所以没有同类方法，<mark>可以通过条件判断来控制展示哪些子视图</mark>。

**点击按钮切换视图控件的展示**

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: UpdatePage(),
    );
  }
}
class UpdatePage extends StatefulWidget {
  @override
  _UpdatePageState createState() => _UpdatePageState();
}
class _UpdatePageState extends State<UpdatePage> {
  bool toggle = true;

  void _updateText() {
    setState(() {
      toggle = !toggle;
    });
  }
  // 切换展示视图组件
  Widget _getToggleChild() {
    if (toggle) {
      return Text('Toggle One');
    }
    return CupertinoButton(child: Text('Toggle Two'), onPressed: () {},
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AppBar') ,
      ),
      body: Center(
        child: _getToggleChild(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateText,
        tooltip: 'Update Text',
        child: Icon(Icons.update),
      ),
    );
  }
}
```

### 自定义`widget`

`iOS`中可以通过继承`UIView`来创建自定义`UIView`。<br>
`Flutter`中需要通过组合不同小的`widget`来实现自定义，而不是继承。

## 线程和异步

`Dart`是单线程执行模型，类似`iOS`的`main loop`；不过它是支持 `Isolate`（一种在其他线程运行 Dart 代码的方法）、事件循环和异步编程。





 -->