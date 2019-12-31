---
title: Flutter入门
description:
layout: post
date: 2019-12-23 03:00:00
categories:
 - flutter
---

* [Flutter 中文社区](https://flutter.cn/docs)
* [dartpad](https://dartpad.cn/)

## 安装环境

### 安装Flutter【macOS 环境】

* [下载开发包](https://flutter.cn/docs/get-started/install/macos#update-your-path)

* 把开发包移动到`/Users/shanliu/`。【根据自己的喜好】所以完整的路径：`/Users/shanliu/flutter/`
 
* 更新 PATH 环境变量

```sh
$ /Users/shanliu/flutter/
$ echo ~ # /Users/shanliu
$ export PATH="$PATH:/Users/shanliu/flutter/bin"
$ source $HOME/.bashrc # 刷新当前命令行
$ echo $PATH # 查看flutter/bin 文件夹是否已经添加到 PATH 环境变量中
$ which flutter # 验证 flutter 命令是否可用
```

* 查看当前环境是否需要安装其他的依赖

```sh
$ flutter doctor		# 查看当前环境是否需要安装其他的依赖(如果想查看更详细的输出，增加一个 -v 参数即可)

[✓] Flutter (Channel stable, v1.12.13+hotfix.5, on Mac OS X 10.14.4 18E227, locale zh-Hans-CN)
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK.
      Install Android Studio from: https://developer.android.com/studio/index.html
      On first launch it will assist you in installing the Android SDK components.
      (or visit https://flutter.dev/setup/#android-setup for detailed instructions).
      If the Android SDK has been installed to a custom location, set ANDROID_HOME to that location.
      You may also want to add it to your PATH environment variable.

[✓] Xcode - develop for iOS and macOS (Xcode 11.2.1)
[!] Android Studio (not installed)
[!] IntelliJ IDEA Ultimate Edition (version 2019.1.1)
    ✗ Flutter plugin not installed; this adds Flutter specific functionality.
    ✗ Dart plugin not installed; this adds Dart specific functionality.
[✓] VS Code (version 1.39.2)
[✓] Connected device (1 available)
```

* [更新Flutter版本](https://flutter.cn/docs/development/tools/sdk/upgrading)

### 通过命令创建一个简单的Flutter应用【iOS平台】

* 在桌面创建文件夹`FlutterDir`，用于测试Flutter项目。

```sh
$ cd /Users/shanliu/Desktop/FlutterDir
$ flutter create first_app # 创建名为first_app的flutter应用
$ cd first_app # 进到first_app应用根目录
```

* 在虚拟机上运行

```sh
$ open -a Simulator # 打开虚拟机
$ flutter run		# 运行Flutter应用。
```

* 在真机上运行

```sh
$ open ios/Runner.xcworkspace #打开 Xcode 工程，在工程中选真机对应的证书
$ flutter run		# 运行Flutter应用。这样真机中就会安装first_app应用
```

### 安装开发工具`VS Code`

* [VS Code](https://code.visualstudio.com/)，选择最新稳定版本

* `查看` > `命令面板` > `输入 "install"` > 选择`安装扩展` > 搜索`flutter`并安装 > 安装好以后，重新启动VS。

* 通过 doctor命令查看是否安装成功：`查看` > `命令面板` > `输入 "doctor"` > 选择`Flutter: Run Flutter Doctor`

## 通过`VS Code`创建Flutter应用

### 创建项目

* `查看` > `命令面板` > `输入 "flutter"` > 选择`Flutter: New Project` > 输入项目名称 > 选择项目文件夹

* 热加载：`Hot Reload`  <img src="/assets/images/offline_bolt.png">

### 使用外部 `package`

* 在`pubspec.yaml` 文件中添加依赖：

```dart
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^0.1.2
  english_words: ^3.1.0		# 添加依赖
```

* 在`lib/main.dart`中导入依赖：

```dart
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart'; //  english_words 的开源软件包，其中包含数千个最常用的英文单词以及一些实用功能。
```

### 添加一个 `Stateful widget`

> `Stateless widgets` 是不可变的，这意味着它们的属性不能改变 —— 所有的值都是 `final`。<br/>
> `Stateful widgets` 持有的状态可能在 `widget` 生命周期中发生变化，实现一个 `stateful widget` 至少需要两个类： <br/>
> 1）一个 `StatefulWidget` 类；<br/>
> 2）一个 `State` 类，`StatefulWidget` 类本身是不变的，但是 `State` 类在 `widget` 生命周期中始终存在。

* 创建一个类`RandomWords` 继承 `StatefulWidget`

```dart
// 这个类的作用基本就是，实现 createState 接口， 创建一个`State`类
class RandomWords extends StatefulWidget{
  @override
  State<StatefulWidget> createState() { 
    return null;
  }
}
```

* 创建一个`State`类

```dart
// 创建一个State类。应用的大部分逻辑和状态都在这里实现。
class RandomWordsState extends State<RandomWords> {
  @override
  Widget build(BuildContext context) {
    return null;
  }
  
}
```

* 在`RandomWords`中，把`State`类`RandomWordsState`给创建出来。

```dart
class RandomWords extends StatefulWidget{
  @override
  RandomWordsState createState() { // 这个方法可以替换成简写方式：RandomWordsState createState() => RandomWordsState();
    return RandomWordsState();
  }
}
```

* 实现功能：在`RandomWordsState`类的`build`方法中生成随机单词对【单词对从`english_words`依赖包中实现】

```dart
class RandomWordsState extends State<RandomWords> {
  @override
  Widget build(BuildContext context) {
    final wordPair = WordPair.random();
    return Text(wordPair.asPascalCase);
  }
}
```

* 在项目中运行

```dart
void main() => runApp(MyApp());

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
          child: RandomWords(), // 主要是这一句。
        ),
      ),
    );
  }
}
```

## [`State<T extends StatefulWidget>`](https://api.flutter.dev/flutter/widgets/State-class.html)  讲解

```
Widget build(BuildContext context);
void deactivate() {} // 当对象从tree中移除的时候会调用
void dispose() {} // 当对象从tree中永久移除的时候会调用
void initState() {} // 当对象插入到tree中会调用
```

```dart
import 'package:flutter/material.dart';
void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Code Sample',
      home: StateFullExample(),
    );
  }
}

class StateFullExample extends StatefulWidget {
  @override
  StateFullExampleState createState() {
    return StateFullExampleState();
  }
}
class StateFullExampleState extends State<StateFullExample>{
  int _count;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('appBar'),),
      body: Center(child: Text(_count.toString()),),
      floatingActionButton: FloatingActionButton(child: Text('Click'),onPressed: () {
        setState(() {
          _count += 1;
        },);
      },),
    );
  }
  @override
  void deactivate() { 
    super.deactivate();
  }
  @override
  void initState(){
    super.initState();
    _count = 5;
  }
}
```