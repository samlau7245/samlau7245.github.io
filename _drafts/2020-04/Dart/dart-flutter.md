---
title: Flutter 实战
layout: post
categories:
 - dart
---

## 环境搭建

1.从[SDK版本列表](https://flutter.cn/docs/development/tools/sdk/archive)下载版本。<br>
2.解压到路径，例如：`/Users/shanliu/`。<br>
3.配置PATH 环境变量：<br>

```sh
export PATH="$PATH:/Users/shanliu/flutter/bin"
```

4.更新环境变量，在`.bash_profile`文件中添加

```sh
export PUB_HOSTED_URL=https://pub.flutter-io.cn # 国内用户需要设置
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn # 国内用户需要设置 
export PATH=/Users/shanliu/flutter/bin:$PATH # 直接指定 flutter 的 bin
```

5.查看环境依赖：

```sh
source $HOME/.bash_profile
flutter doctor
```

### 设置iOS开发环境
1.安装[Xcode](https://itunes.apple.com/us/app/xcode/id497799835) <br>
2.配置 Xcode command-line tools:<br>

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
# 运行模拟器
open -a Simulator
```

3.创建Flutter应用

```sh
flutter create my_app
cd my_app
flutter run
```

### VSCode 开发Flutter
* 安装：查看 -> 命令面板 -> 输入`install` -> 选择`扩展：安装扩展` -> 搜索框输入：`flutter`并安装 -> 重新启动VSCode。
* 检查：查看 -> 命令面板 -> 输入`doctor` -> 选择`Flutter: Run Flutter Doctor`。
* 创建应用：查看 -> 命令面板 -> 输入`flutter` -> 选择`Flutter: New Project`。

### Flutter for MacOS 

```sh
flutter channel master
flutter upgrade
flutter config --enable-macos-desktop # --enable-web --enable-linux-desktop --enable-windows-desktop --enable-android-embedding-v2
export ENABLE_FLUTTER_DESKTOP=true
flutter doctor
flutter devices
# run
flutter run -d macos
# build
flutter build macos
```

* [Desktop support for Flutter](https://flutter.dev/desktop)





















<!-------------------------------------------------------------- chapter -------------------------------------------------------------->
## 开发基础

### 无状态组件、有状态组件
* 无状态组件(`StatelessWidget`)： 不可变，意味着它们属性不能改变，所有的值都是最终的。
* 有状态组件(`StatefulWidget`)： 持有的状态可能在Widget周期中发生变化。

要实现`StatefulWidget`需要两个类：

* `StatefulWidget`类。
* `State`类。`StatefulWidget`类本身是不变的，但是`State`类在`Widget`声明周期中始终存在。

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

// MyApp 不做状态处理，所以继承 StatelessWidget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new LoginPage(title: 'This is title!',),
    );
  }
}
// 主体需要做状态处理，继承 StatefulWidget
class LoginPage extends StatefulWidget {
  LoginPage({Key key,this.title}) : super(key:key);
  final String title;

  @override
  _LoginPageState createState() => new _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(widget.title),
      ),
      body: new Center(
        child: new Text('data'),
      ),
    );
  }
}
```

#### State(状态管理)

生命周期：`initState` -> `build` -> `setState` -> `didUpdateWidget` -> `build` --->`移除`

<img src="/assets/images/flutter/66.png" width = "25%" height = "25%"/>

### 使用包资源

示例：现在需要使用包`url_launcher`：

1.打开[https://pub.dev](https://pub.dev)搜索`url_launcher`，找到需要依赖的版本号:

```yaml
ependencies:
  url_launcher: ^5.4.2
```

2.项目打开`url_launcher`库，添加依赖配置：

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^0.1.2
  url_launcher: ^5.4.2
```

3.安装：`flutter pub get`<br>
4.使用：

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Use third package',
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("Use third package"),
        ),
        body: new Center(
          child: new RaisedButton(onPressed: _launch,
          child: new Text("Open Baidu"),),
        ),
      ),
    );
  }
}

_launch() async {
  const url = 'https://flutter.dev';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }  
}
```

### 网络请求
方法一：`Http请求`：[https://pub.dev](https://pub.dev)搜索`http`。<br>
方法二：`HttpClient请求`

使用HttpClient请求，需要导入依赖包：

```dart
import 'dart:convert';
import 'dart:io';

_requestClient() async {
  try {
    HttpClient httpClient = new HttpClient();
    // 发起请求
    HttpClientRequest request = await httpClient.getUrl(Uri.parse('https://www.uhomecp.com/cms-api/isShowAdvert'));
    // 等待响应
    HttpClientResponse response = await request.close();
    var result = response.transform(utf8.decoder).join();
    print(result);
    httpClient.close();
  } catch (e) {
    print(e);
  }
}
```






















<!-------------------------------------------------------------- chapter -------------------------------------------------------------->
## 常用组件
Flutter 中一种非常重要的概念：一切皆组件，Flutter 中所有的元素都是有组件组成。

### 图片组件(Image)

可以参考[Flutter中文网-加载图片](https://flutterchina.club/assets-and-images/#加载-images)。

构造函数：

```dart
Image() // 从ImageProvider获取图片
Image.network() //网络图片
Image.file() //本地图片文件
Image.asset() // 加载资源图片
Image.memory() //Unit8List资源图片
```

| 属性 | 类型 | 说明 |
| --- | --- | --- |
|image|ImageProvider||
|width/height|double||
|fit|BoxFit||
|color|||
|colorBlendModel|||
|alignment|||
|repeat|||
|centerSlice|||
|matchTextDirection|||
|gaplessPlayback|||

| 属性 |  说明 |
| --- | --- | 
|BoxFit.fill||
|BoxFit.contain||
|BoxFit.cover||
|BoxFit.fitWidth||
|BoxFit.fitHeight||
|BoxFit.none||
|BoxFit.scalDown||


```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new ImageDemo(),
    );
  }
}

class ImageDemo extends  StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new Image.network('https://www.baidu.com/img/bd_logo1.png',fit: BoxFit.fitWidth);
  }
}
```

<img src="/assets/images/flutter/03.png" width = "25%" height = "25%"/>

#### 依赖包中的资源

```
.
├── android
├── build
├── icons
│   ├── 1.png
│   └── code.png
├── ios
├── lib
│   └── main.dart
├── pubspec.lock
└── pubspec.yaml
```

应用依赖于`icons`包中的资源，如果要加载图片需要修改`pubspec.yaml`文件：

```yaml
flutter:
  assets:
   - icons/1.png
   - icons/code.png
```

使用:

```dart
AssetImage('icons/1.png');
Image.asset('icons/code.png');
```
	
### 文本组件(Text)

| 属性 | 类型 | 说明 |
| --- | --- | --- |
|data|||
|maxLines|||
|style|||
|textAlign|||
|textDirection|||
|textScaleFactor|||
|textSpan|||

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new TextDemo(),
    );
  }
}

class TextDemo extends  StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Text('data',
      style: new TextStyle(
        color: Colors.red
      ),
      ),
    );
  }
}
```

### 图标及按钮组件
#### 图标组件(Icon)
> 该组件不可进行交互，想要交互使用`IconButton`

* `IconButton`: 可交互Icon
* `Icons`: 框架自带Icon集合
* `IconTheme`: Icon主题
* `ImageIcon`: 通过AssetImages或者其他的图片显示Icon

| 属性 | 类型 | 说明 |
| --- | --- | --- |
|color|||
|icon|||
|style|||
|size|||
|textDirection|||

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Bar title'),
        ),
        body: new Center(
          child: new Icon(Icons.phone, size:80.0),
        ),
      ),
    );
  }
}
```

#### 图标按钮组件(IconButton)

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
|alignment||||
|icon||||
|color||||
|disabledColor||||
|iconSize|double|||
|onPressed|voidCallback|null||
|tooltip|String|""|当按钮按下时的提示语句|

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Bar title'),
        ),
        body: new Center(
          child: new IconButton(icon: new Icon( Icons.phone),tooltip: 'tip message', onPressed: (){
          })
        ),
      ),
    );
  }
}
```

#### 凸起按钮组件(RaisedButton)

一个凸起的材质矩形按钮。

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
|color||||
|disabledColor||||
|onPressed||||
|child|Widget||child通常为一个Text文本，用来展示按钮的文本|
|enable||||

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Bar title'),
        ),
        body: new Center(
          child: new RaisedButton(onPressed: (){}, child: new Text('RaisedButton'),
          )
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/04.png" width = "25%" height = "25%"/>

### 列表组件
#### 基础列表组件(ListView)

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
|scrollDirection|Axis|Axis.vertical|列表排序方向，默认垂直|
|padding|EdgeInsetsGeometry|||
|reverse|bool|||
|children|List<Widget>||列表元素|

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Bar title'),
        ),
        body: new ListView(
          children: <Widget>[
            ListTile(title: Text('data'),leading: Icon(Icons.phone),),
            ListTile(title: Text('data'),leading: Icon(Icons.phone),),
            ListTile(title: Text('data'),leading: Icon(Icons.phone),),
          ],
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/05.png" width = "25%" height = "25%"/>

#### 水平列表组件(ListView)
就是把`ListView`的`scrollDirection`属性改为`Axis.horizontal`。

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Bar title'),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(vertical: 20.0),
          height: 200,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Container( width: 100.0, color: Colors.red,),
              Container( width: 200.0, color: Colors.blue,),
              Container( width: 300.0, color: Colors.green,),
            ],
          ),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/06.png" width = "25%" height = "25%"/>

#### 长列表组件(ListView)
当数据非常多的时候，需要用到长列表。用法：以`ListView`为基础组建，再为列表添加`itemBuilder`构造器。

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> items = new List<String>.generate(500, (i) => 'Item $i');

    return MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Bar title'),
        ),
        body: new ListView.builder(
          itemCount: items.length, // 列表长度
          itemBuilder: (context,index) {
            return new ListTile(title: new Text('data -> ${items[index]}'),leading: new Icon(Icons.phone),);
          },
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/07.png" width = "25%" height = "25%"/>


### 表单组件()

两个重要的组件`Form`用于整个表单提交、`TextFormField`用于用户输入。

`Form`的属性：

| 属性 | 类型 | 说明 |
| --- | --- | --- |
|key|||
|autovalidate|bool||
|child|Widget||
|onChanged|VoidCallback||

`TextFormField`的属性：

| 属性 | 类型 | 说明 |
| --- | --- | --- |
|autovalidate|||
|initialValue|||
|onSaved|||
|validator|||

```dart
import 'package:flutter/material.dart';

void main() => runApp(new LoginPage());

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> loginKey = new GlobalKey<FormState>();
  String password, userName;

  login() {
    var loginForm = loginKey.currentState;
    if (loginForm == null) {
      return;
    }
    if (loginForm.validate()) {
      loginForm.save();
      print('userName:$userName passWord: $password');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Form',
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Form'),
        ),
        body: new Column(
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(16.0),
              child: new Form(
                key: loginKey,
                child: new Column(
                  children: <Widget>[
                    new TextFormField(
                      decoration: new InputDecoration(
                        labelText: '请输入用户名：',
                      ),
                      onSaved: (value) {
                        userName = value;
                      },
                      onFieldSubmitted: (value) {},
                    ),
                    new TextFormField(
                      decoration: new InputDecoration(
                        labelText: '请输入密码：',
                      ),
                      onSaved: (value) {
                        password = value;
                      },
                      obscureText: true,
                      validator: (value) {
                        return value.length < 6 ? "密码长度不够6位" : null;
                      },
                    )
                  ],
                ),
              ),
            ),
            new SizedBox(
              width: 340.0,
              height: 42.0,
              child: new RaisedButton(
                onPressed: login(),
                child: new Text('Login', style: TextStyle(fontSize: 18.0)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/09.png" width = "25%" height = "25%"/>

### IgnorePointer
组件内部的子组件都不可以响应用户点击。

<img src="/assets/images/flutter/69.png" width = "25%" height = "25%"/>

### Divider(分割线)

<img src="/assets/images/flutter/70.gif"/>

* DividerThemeData
* `ListView.separated`
* `ListTile.divideTiles(tiles: null)`














<!-------------------------------------------------------------- chapter -------------------------------------------------------------->
## 手势

Flutter中的手势系统分为两层：

* `PointerDownEvent` : 用户与屏幕接触产生了联系。
* `PointerMoveEvent` : 手指已经从屏幕上的一个位置移动到另外一个位置。
* `PointerUpEvent` : 用户已经停止接触屏幕。
* `PointerCancelEvent` : 不再指向此应用程序。

### 用GestureDetector进行手势检测

|事件名|描述|
| --- | --- |
|onTapDown||
|onTapUp||
|onTap||
|onTapCancel|此次点击事件结束,onTapDown不会在产生点击事件|
|onDoubleTap|用户快速连两次在同一位置点击屏幕|
|onLongTap|长时间保持与相同位置的屏幕接触|
|onVerticalDragStart|与屏幕接触,可能会开始垂直移动|
|onVerticalDragUpdate|与屏幕接触并垂直移动的指针在垂直方向上移动
|onVerticalDragEnd|之前与屏幕接触并垂直移动的指针不再与屏幕接触,并且在停止接触屏幕时以特定速度移动垂直拖动|
|onHorizontalDragStart|与屏幕接触,可能开始水平移动|
|onHorizontalDragUpdate|与屏接触并水平移动的指针在水平方向上移动|
|onHorizontalDragEnd|先前与屏幕接触并且水平移动的指针不再与屏幕接触,并且当它停止接触屏幕时以特定速度移动水平抱动|

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

// 宽度300的Container上添加一个约束最大最小宽高的ConstrainedBox。
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
          appBar: new AppBar(
            title: Text('data'),
          ),
          body: new Center(
            child: new MyButton(),
          )),
    );
  }
}

class MyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 一定要把被触摸的组件放到GestureDetector里
    return new GestureDetector(
      onTap: () {
        final snackBar = new SnackBar(content: new Text('data'));
        Scaffold.of(context).showSnackBar(snackBar);
      },
      child: new Container(
        padding: new EdgeInsets.all(12.0),
        decoration: new BoxDecoration(
          color: Theme.of(context).buttonColor,
          borderRadius: new BorderRadius.circular(10.0),
        ),
        child: new Text('测试按钮'),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/58.png" width = "25%" height = "25%"/>


### 用Dismissible实现滑动删除

滑动删除，就是cell侧滑删除功能。

|属性|类型|描述|
| --- | --- | --- |
|onDimissed|DismissDirectionCallback|当包裹的组件消失后回调的函数|
|movementDurantion|Duration|定义组件消息的时长|
|onResize|voidCallback|组件大小改变时回调的函数|
|resizeDuration|Duration|组件大小改变时长|
|child|Widget|组件包裹的子元素，即被隐藏的对象|


```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

// 宽度300的Container上添加一个约束最大最小宽高的ConstrainedBox。
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> items = new List<String>.generate(30, (i) => "列表项 ${i + 1}");

    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('滑动删除示例'),
        ),
        body: new ListView.builder(
            itemCount: items.length, //列表长度
            itemBuilder: (context, index) {
              final item = items[index]; // 提取出被删除项
              return new Dismissible(
                  key: new Key(item),
                  // 删除回调函数
                  onDismissed: (DismissDirection direction) {
                    items.removeAt(index);
                    final snackbar = new SnackBar(content: new Text('data'));
                    Scaffold.of(context).showSnackBar(snackbar);
                  },
                  child: new ListTile(
                    title: new Text('$item'),
                  ));
            }),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/59.png" width = "25%" height = "25%"/>

## 资源和图片

### 添加资源和图片

#### 指定 assets

```
.
├── android
├── build
├── icons
│   ├── config.json
│   ├── 1.png
│   └── code.png
├── ios
├── lib
│   └── main.dart
├── pubspec.lock
└── pubspec.yaml
```

应用依赖于`icons`包中的资源，如果要加载图片需要修改`pubspec.yaml`文件：

```yaml
flutter:
  assets:
   - icons/config.json
   - icons/1.png
   - icons/code.png
```

#### 加载 assets

##### 加载文本配置文件

每个Flutter程序都有一个`rootBundle`对象，可以轻松访问主资源包。可以直接用`package:flutter/services.dart`中全局静态的`rootBundle`对象来加载资源。

```dart
import 'package:flutter/services.dart' show rootBundle;

Future<String> loadAsset() async {
  return await rootBundle.loadString('icons/config.json');
}
```

##### 加载图片

```dart
new AssetImage('icons/1.png');
new Image.asset('icons/code.png');
```

##### 依赖包中国呢的资源图片

要加载依赖包中的图像，必须给`AssetImage`提供`package`参数。


```
包(resource)中的目录结构
.
├── android
├── build
├── assets
│   ├── wifi.json
│   └── add.png
├── ios
├── lib
│   └── main.dart
├── pubspec.lock
└── pubspec.yaml
```

```dart
new AssetImage('assets/wifi.png',package: 'resource');
```

#### 平台 assets

##### 更新应用图标
##### 更新启动页

安卓在`/android/app/src/main/res/drawable/launch_background.xml`文件中，自定义`drawable`来实现自定义启动界面:

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- Modify this file to customize your launch splash screen -->
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />

    <!-- You can insert your own image assets here -->
    <!-- <item>
        <bitmap
            android:gravity="center"
            android:src="@mipmap/launch_image" />
    </item> -->
</layer-list>
```

ios在`/ios/Runner/Assets.xcassets/LaunchImage.imageset`文件夹中，拖入三个命名为`LaunchImage.png`、`LaunchImage@2x.png`、`LaunchImage@3x.png`的启动图片。

### 自定义字体

要在应用程序中实现自定义字体的需求：

* 在项目的根目录下创建`fonts`文件夹，并且存放一种字体文件`xindexingcao57.ttf`。
* 设置配置文件：`pubspec.yaml`。

```yaml
flutter:
  fonts:
    - family: xindexingcao57
    - fonts:
      - asset: fonts/xindexingcao57.ttf
```

```dart
var font = new Text(
  'data',
  style: new TextStyle(
    fontFamily: 'xindexingcao57',
    fontSize: 36.0,
  ),
);
```

整体的项目目录：

```
.
├── README.md
├── android
├── build
├── flutter_demo_01.iml
├── fonts
│   └── xindexingcao57.ttf
├── icons
│   └── config.json
├── ios
├── lib
├── pubspec.lock
└── pubspec.yaml
```

## 路由及导航

### 页面跳转基本使用

移动应用通常通过`屏幕`或者`页面`的全屏元素显示其内容，在Flutter中，这些元素被称为**路由**。他们由导航器[Navigator](https://api.flutter.dev/flutter/widgets/Navigator-class.html)组件管理。`Navigator`管理一组路由`Route`对象，并且提供了管理堆栈的方法。

* `push(BuildContext context, Route<T> route)`
* `pop(BuildContext context, [ T result ])`

```
pushReplacementNamed(BuildContext context,String routeName, {TO result,Object arguments,}));

page1 -push-> page2 -push-> page3 如果这样push的话，栈结构就是: page1-page2-page3
page1 -push-> page2 -pushReplacementNamed-> page3 如果把第二个push换成pushReplacementNamed，那么栈结构就是：page1-page3, page2 将会被销毁。
```

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new FirstScreen(),
    );
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('导航页面示例'),
      ),
      body: new Center(
        child: new RaisedButton(
          onPressed: () {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new SecondScreen()));
          },
          child: new Text('查看商品详情页'),
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('导航页面示例'),
      ),
      body: new Center(
        child: new RaisedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: new Text('返回页面'),
        ),
      ),
    );
  }
}
```

### 页面跳转发送数据

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new ProductList(
        products: new List<Product>.generate(
            20, (i) => new Product('商品 $i', '商品详情 $i')),
      ),
    );
  }
}

class Product {
  final String title;
  final String description;
  Product(this.title, this.description);
}

class ProductList extends StatelessWidget {
  final List<Product> products;
  ProductList({Key key, @required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('商品列表'),
      ),
      body: new ListView.builder(itemBuilder: (context, index) {
        return new ListTile(
          title: new Text(products[index].title),
          onTap: () {
            Navigator.push(
                context,
                new MaterialPageRoute(
                    builder: (context) => new ProductDetail(
                          product: products[index],
                        )));
          },
        );
      }),
    );
  }
}

class ProductDetail extends StatelessWidget {
  final Product product;
  ProductDetail({Key key, @required this.product}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('${product.title}'),
      ),
      body: new Center(
        child: new Text('${product.description}'),
      ),
    );
  }
}
```

### 页面跳转返回数据

## 组件装饰和视觉效果

### Opacity(透明度处理)

`Opacity`组件里油一个`opacity`属性，用来调整组件的不透明度，使子控件部分透明。

|属性|类型|描述|
| --- | --- | --- |
|opacity|double||
|child|Widget||

### DecoratedBox(装饰盒子)

`DecoratedBox`组件可以从多方面进行装饰处理。比如颜色、形状、阴影、渐变以及背景图片等等。主要属性为`decoration`，类型为`BoxDecoration`。

|属性|类型|默认值|描述|
| --- | --- | --- | --- |
|shape|BoxShape|BoxShape.rectangle|形状取值|
|corlor|Corlor||用来渲染容器的背影色|
|boxShadow|`List<BoxShadow>`||阴影效果|
|gradient|Gradient||渐色取值有:线性渐变、环形渐变|
|image|DecoralionImage||背景图片
|border| BoxBorder||边框样式|
|borderRadius|BorderRadiusGeometry||边框的弧度|

#### 背景图效果

```dart
decoration: new BoxDecoration(
    image: new DecorationImage(image: ExactAssetImage(''),fit: BoxFit.cover,),
),
```

#### 边框圆角处理

```dart
decoration: new BoxDecoration(
  border: Border.all(
    color: Colors.red,
    width: 4.0,
  ),
  borderRadius: BorderRadius.circular(36.0),
),
```

#### 边框阴影处理

`BoxShadow`几个属性：

* `color` : 阴影颜色
* `blurRadius` : 模糊值
* `spreadRadius` : 扩展阴影半径
* `offset` : x、y 方向偏移量

```dart
decoration: new BoxDecoration(
  boxShadow: <BoxShadow>[
    new BoxShadow(
      color: Colors.red,
      blurRadius: 8.0,
      offset: Offset(-1.0, 1.0),
      spreadRadius: 8.0,
    ),
  ],
),
```

#### 渐变处理

渐变`gradient`有两种形式：

* `LinearGradient`：线性渐变
  * `begin`: 起始偏移量
  * `end`: 终止偏移量
  * `colors`: 渐变颜色数据集
* `RadialGradient`：环形渐变
  * `center`: 中心点偏移量，即x、y方向偏移量
  * `radius`: 圆形半径
  * `colors`: 渐变颜色数据集

```dart
gradient: new LinearGradient(
  begin: const FractionalOffset(0.5, 0.6),
  end: const FractionalOffset(1.0, 1.0),
  colors: <Color>[
    Colors.red,
    Colors.green,
  ],
),
```

### RotatedBox(旋转盒子)

`RotatedBox` 组件即为旋转组件，可以使`child`发生旋转。旋转的度数是90度的整数倍。每次旋转只能是90度。当`quarterTurns`属性为3时，表示旋转了270度。`RotatedBox`通常用于图片的旋转，比如在相册里，用户想把照片横着看或者竖着看，那么`RotatedBox`使得使用起来就非常方便。

```dart
child: new RotatedBox(quarterTurns: 3,),
```

### [Clip(剪裁处理)](https://www.youtube.com/watch?v=vzWWDO6whIM&t=28s)

`Clip`作用把一个组件剪掉一部分。

* `ClipOval`: 圆角剪裁
* `ClipRRect`: 圆角矩形剪裁
* `ClipRect`: 矩形剪裁
* `ClipPath`: 路径剪裁

|属性|类型|描述|
| --- | --- | --- |
|clipper|`CustomClipper<Path>`|剪裁路径，比如椭圆，矩形等等|
|clipBehavior|Clip|裁剪方式|

#### ClipOval

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Title'),
        ),
        body: new Center(
          child: new ClipOval(
            child: new SizedBox(
              width: 200.0,
              height: 200.0,
              child: new Image.asset('icons/test.png'),
            ),
          ),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/60.png" width = "25%" height = "25%"/>

#### ClipRRect

`ClipRRect` 组件的属性`borderRadius`参数来控制圆角的位置大小。

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Title'),
        ),
        body: new Center(
          child: new ClipRRect(
            borderRadius: new BorderRadius.all(
              new Radius.circular(30.0),
            ),
            child: new SizedBox(
              width: 200.0,
              height: 200.0,
              child: new Image.asset(
                'icons/test.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/61.png" width = "25%" height = "25%"/>

#### ClipRect

`ClipRect`这个组件需要自定义`clipper`属性才能使用，否则没有效果。自定义`clipper`需要继承`CustomClipper`类。并且需要重写`getClip`和`shouldReclip`两个方法。

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Title'),
        ),
        body: new Center(
          child: new ClipRect(
            clipper: new RectClipper(),//自定义 clipper 
            child: new SizedBox(
              width: 300.0,
              height: 300.0,
              child: new Image.asset(
                'icons/test.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 自定义的clipper，集成了 CustomClipper
class RectClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) { // 获取剪裁范围,100.0, 100.0, 裁剪child的坐标，width、height 裁剪的宽高
    return new Rect.fromLTRB(100.0, 100.0, size.width - 100.0, size.height - 100.0);
  }
  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) { //是否重新剪裁
    return true;
  }
}
```

<img src="/assets/images/flutter/62.png" width = "25%" height = "25%"/>

#### ClipPath

`ClipPath` 组件由于采用了矢量路径`path`，所以可以把组件剪裁为任意类型的形状。比如三角形、矩形、星形以及多边形等等。

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Title'),
        ),
        body: new Center(
          child: new ClipPath(
            clipper: new RectClipper(), //自定义 clipper
            child: new SizedBox(
              width: 300.0,
              height: 300.0,
              child: new Image.asset(
                'icons/test.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 自定义的clipper，集成了 CustomClipper，类型为 Path
class RectClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = new Path();
    path.moveTo(50.0, 50.0); //起始点
    path.lineTo(50.0, 10.0); //点(50.0, 50.0)到(50.0, 10.0)，两点划条直线。
    path.lineTo(100.0, 50.0); //点(50.0, 10.0)到(100.0, 50.0)，两点划条直线。
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
```

<img src="/assets/images/flutter/63.png" width = "25%" height = "25%"/>

## Packages和插件

通过`Packages`可以创建共享的的模块化代码。

* `flutter create`
  * `--template=<type>` : `[app]`、`[module]`、`[package]`、`[plugin]`
  * `--ios-language` : `[objc]`、`[swift](default)`
  * `--android-language` : `[java]`、`[kotlin](default)`

### 开发Dart包

```sh
flutter create --template=package hello
```

项目结构：

```
├── CHANGELOG.md
├── LICENSE
├── README.md
├── hello.iml
├── lib
│   └── hello.dart ==》 包代码
├── pubspec.lock
├── pubspec.yaml
└── test
    └── hello_test.dart ==> 用于 单元测试
```

### 插件开发

`Flutter`插件就是一种`Flutter`的库。这是这个库相对特殊，可以和原生程序打交道。比如调用蓝牙，启动Wi-Fi，打开手电筒等等。`Flutter`的上层Dart语言是无法完成底层操作的，它只能做一些UI相关的事情。所以插件就尤为重要。

插件开发需要涉及两大移动平台的知识，例如：

* iOS：Objective-C和swift语言。
* Android：Java和Kotlin语言。


#### 新建插件

```sh
flutter create --org com.example --template=plugin --ios-language=objc hello
```

* `lib/hello.dart` : 插件包的Dart API。
* `android/src/main/kotlin/com/example/hello/HelloPlugin.kt` : 插件包API的Android实现。
* `ios/Classes/HelloPlugin.m` : 插件包API的iOS实现。
* `example/` : 依赖于插件的Flutter应用程序。

##### 添加iOS平台代码

在iOS的目录结构：

```
ios
├── Assets
├── Classes
│   ├── HelloPlugin.h
│   └── HelloPlugin.m
└── hello.podspec ==> podspec文件
```

构建代码：

```sh
cd hello/example
flutter build ios --no-codesign
```

执行后的代码结构：

```
.
├── Flutter
│   ├── App.framework
│   ├── AppFrameworkInfo.plist
│   ├── Debug.xcconfig
│   ├── Flutter.framework
│   ├── Flutter.podspec
│   ├── Generated.xcconfig
│   ├── Release.xcconfig
│   └── flutter_export_environment.sh
├── Podfile
├── Podfile.lock
├── Pods
├── Runner
│   ├── AppDelegate.h
│   ├── AppDelegate.m
│   ├── Assets.xcassets
│   ├── Base.lproj
│   ├── GeneratedPluginRegistrant.h
│   ├── GeneratedPluginRegistrant.m
│   ├── Info.plist
│   └── main.m
├── Runner.xcodeproj
└── Runner.xcworkspace ==> Xcode执行，打开项目
```

插件的iOS写的位置：`Pods/DevelopmentPods/hello/Classes/`。

### 文档

* `README.md` : 介绍包的文件
* `CHANGELOG.md` : 记录每个版本中的更改
* `LICENSE` : 包含软件包许可条款的文件

### 发布包

完成一个包的开发后可以发布到[pub.dev][https://pub.dev/]中，其他人员可以使用。详细信息可以查看[Pub publishing docs](https://dart.dev/tools/pub/publishing)。

```sh
# 检查包
flutter packages pub publish --dry-run
# 发布
flutter packages pub publish
```

### 使用平台通道编写平台特定的代码

`Flutter`允许您调用特定平台的API，无论在Android上的Java或Kotlin代码中，还是iOS上的ObjectiveC或Swift代码中均可用。

Flutter消息传递的方式：

* 应用的Flutter部分通过平台通道（`platform channel`）将消息发送到其应用程序的所在的宿主（iOS或Android）。
* 宿主监听的平台通道，并接收该消息。然后它会调用特定于该平台的API（使用原生编程语言） - 并将响应发送回客户端，即应用程序的Flutter部分。

<img src="/assets/images/flutter/64.png"/>

消息和响应是异步传递的，以确保用户界面保持响应(不会挂起)。

* 在客户端，[MethodChannel](https://api.flutter.dev/flutter/services/MethodChannel-class.html)可以发送与方法调用相对应的消息。
* 在宿主平台上，Android 的[MethodChannel](https://api.flutter.dev/javadoc/io/flutter/plugin/common/MethodChannel.html)和 iOS的 [FlutterMethodChannel](https://api.flutter.dev/objcdoc/Classes/FlutterMethodChannel.html)可以接收方法调用并返回结果。这些类允许您用很少的“脚手架”代码开发平台插件。
* 如果需要，方法调用也可以反向发送，宿主作为客户端调用Dart中实现的API。 这个[quick_actions](https://pub.dev/packages/quick_actions)插件就是一个具体的例子

#### 插件分析

##### 插件部分

`hello.dart` 是插件用来对外提供接口的文件。

```dart
import 'dart:async';
import 'package:flutter/services.dart';

class Hello {
  // 定义通道：
  // const MethodChannel(name) name参数是一个标识符，通常是一个字符串，这个字符串必须与原生代码保持一致，不然回导致无法正常通信
  // 我们建议在通道名称前加一个唯一的“域名前缀”，例如samples.flutter.io/battery。
  // static const platform = const MethodChannel('samples.flutter.io/battery');
  
  static const MethodChannel _channel = const MethodChannel('hello');

  static Future<String> get platformVersion async {
    // 调用原生程序获取系统版本号
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
```

##### iOS部分

```objc
#import "HelloPlugin.h"

@implementation HelloPlugin
// 插件注册
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    // 定义与上层代码通信的通道，@"hello" 必须与上层的名字统一
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"hello" binaryMessenger:[registrar messenger]];
    HelloPlugin* instance = [[HelloPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  // 调用系统方法
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}
@end
```

##### 测试部分

测试插件分析：

打开`example/pubspec.yaml`文件，添加插件：`hello`标识是放在`dev_dependencies`标签下的。如果路径配置错误会导致插件引用失败。

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  hello:
    path: ../
```

<img src="/assets/images/flutter/65.png"/>

#### 平台类型支持

平台支持的通道类型：[StandardMessageCodec](https://api.flutter.dev/flutter/services/StandardMessageCodec-class.html)

|Dart|  Android |iOS|
| --- | --- | --- |
|null|  null | nil (NSNull when nested)|
|bool|  java.lang.Boolean |NSNumber numberWithBool:|
|int| java.lang.Integer |NSNumber numberWithInt:|
|int|, if 32 bits not enough  java.lang.Long  |NSNumber numberWithLong:|
|int|, if 64 bits not enough  java.math.BigInteger  |FlutterStandardBigInteger|
|double|  java.lang.Double  |NSNumber numberWithDouble:|
|String|  java.lang.String  |NSString|
|Uint8List| byte[]  |FlutterStandardTypedData typedDataWithBytes:|
|Int32List| int[] ||FlutterStandardTypedData typedDataWithInt32:|
|Int64List| long[]  FlutterStandardTypedData typedDataWithInt64:|
|Float64List| double[]  |FlutterStandardTypedData typedDataWithFloat64:|
|List|  java.util.ArrayList |NSArray|
|Map| java.util.HashMap |NSDictionary|





















## 将 Flutter 集成到现有应用

Flutter 可以作为一个库或模块，集成进现有的应用当中。模块引入到 Android 或 iOS 应用中，以使用 Flutter 来渲染一部分的 UI，或者仅运行多平台共享的 Dart 代码逻辑。

### 集成到 iOS 应用

* 支持 Objective-C 和 Swift 为宿主的应用程序。
* Flutter 模块可以通过使用 Flutter plugins 与平台进行交互。
* 支持通过从 IDE 或命令行中使用 `flutter attach` 来实现 Flutter 调试与有状态的热重载。

#### 环境搭建

```sh
cd /Users/shanliu/Documents/Dart/moduleDemo
# 创建模版
flutter create --template module my_flutter
cd my_flutter
# 拉取依赖
flutter pub get
# 运行调试
flutter run --debug
# 打开`.ios/`目录下的项目，这样Xcode和flutter run 跑出的界面就是一样的。
```

在`my_flutter`模块，代码的目录结构：

```
my_flutter/ 
├── .ios/ ==> 用于单独运行 Flutter module，用于调试的iOS空壳项目
│   ├── Runner.xcworkspace
│   └── Flutter/podhelper.rb
├── lib/ ==> Dart代码存放到这里
│   └── main.dart
├── test/
└── pubspec.yaml ==> 用于添加Flutter依赖(Flutter packages、plugins等等)
```

> 注意：iOS 代码要添加到**`既有应用`**或者**`Flutter plugin`**中，而不是 `Flutter module` 的 `.ios/` 目录下。`.ios/` 目录下的代码只是用于调试的空壳项目。

#### 使用 CocoaPods 和 Flutter SDK 集成

先把代码的目录结构展示一下：

```
├── my_flutter/ ==> flutter 模块
│   └── .ios/
│       └── Flutter/
│         └── podhelper.rb ==> podhelper.rb脚本会把 Flutter plugins， Flutter.framework，和 App.framework 集成到项目中。
└── FlutterDemo/ ==> iOS项目
    └── Podfile
```

在`FlutterDemo`的`Podfile`中添加代码：

```rb
platform :ios, '9.0'

flutter_application_path = '../my_flutter'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'FlutterDemo' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FlutterDemo
  install_all_flutter_pods(flutter_application_path)
end
```

然后运行`pod install`。

### 在 iOS 应用中添加 Flutter 页面

要想在iOS中添加Flutter页面，需要先启动`FlutterEngine`和`FlutterViewController`。














## Flutter API

[Flutter API](https://api.flutter-io.cn/objcdoc/index.html)

```
.
├── Flutter.h
├── FlutterAppDelegate.h
├── FlutterBinaryMessenger.h
├── FlutterCallbackCache.h
├── FlutterChannels.h
├── FlutterCodecs.h
├── FlutterDartProject.h
├── FlutterEngine.h ==> 用于启动并持续地为挂载 FlutterViewController 以提供独立的 Flutter 环境
├── FlutterHeadlessDartRunner.h
├── FlutterMacros.h
├── FlutterPlatformViews.h
├── FlutterPlugin.h
├── FlutterPluginAppLifeCycleDelegate.h
├── FlutterTexture.h
└── FlutterViewController.h
```
 






### 资料

* [将 Flutter 集成到现有应用](https://flutter.cn/docs/development/add-to-app)
* [add-to-app GitHub 示例仓库](https://github.com/flutter/samples/tree/master/add_to_app)















## 测试

|类目|单元测试|组件测试|集成测试|
| --- | --- | --- | --- |
|维护成本|低|高|很高|
|依赖|少|多|很多|
|执行速度|快|慢|非常慢|

## 参考资料
* [Flutter 中文社区](https://flutter.cn/)
* [Dart 编程语言概览](https://www.dartcn.com/guides/language/language-tour)
* [Materail Design 指导](https://material.io)
* [Flutter widget 目录](https://flutterchina.club/widgets/)
* [Dart DevTools](http://s0dart0dev.icopy.site/tools/dart-devtools)
* [Flutter CookBook](https://flutter.cn/docs/cookbook)
* [Flutter Codelabs](https://flutter.cn/docs/codelabs)
* [App Brewery在线课程-Google账号](https://www.appbrewery.co/courses/enrolled/851555)

* `flutter_webview_plugin`: 移动端浏览网页的插件
* `date_formate` ： 日期格式化插件

### 项目搭建

[iconfont](https://www.iconfont.cn)


```sh
PUB_HOSTED_URL=https://pub.flutter-io.cn
FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```










<!-- ========================================================================================================================== -->
## Flutter 插件

* [开发Packages和插件](https://flutterchina.club/developing-packages/)
* [youtube](https://www.youtube.com/results?search_query=flutter+plugin+development)

```sh
# --org com.example bundleId
# -t plugin 是简写，可以写成 --template=plugin
# iOS语言选择：默认 swift ， 换成OC: -i objc
flutter create --org com.example -t plugin hello
```

项目的结构和作用：

* `hello/lib/hello.dart` : 插件包的Dart API。
* `hello/android/src/main/kotlin/com/example/hello/HelloPlugin.kt` : 插件包API的Android实现。
* `hello/ios/Classes/HelloPlugin.m` : 插件包API的iOS实现。
* `hello/example/` : 依赖于插件的Flutter示例应用程序。

### Flutter与Native通信机制

<img src="/assets/images/flutter/64.png"/>

Flutter与Native的通信是通过Channel来完成的。Flutter定义了三种不同类型的Channel:

* `FlutterBasicMessageChannel` : 用于传递字符串和半结构化的信息，持续通信，收到消息后可以回复此次消息。例如：Native将遍历到的文件信息陆续传递到Dart；Flutter将服务端获取的数据交给Native加工，Native处理完之后返回。
* `FlutterMethodChannel` : 用于传递方法调用，一次性通信。
* `FlutterEventChannel` : 用于数据流的通信，持续通信，收到消息后无法回复此次消息，通常用于Native向Dart的通信。例如：手机电量变化，网络连接变化，陀螺仪，传感器等。

### FlutterBasicMessageChannel
### FlutterMethodChannel
### FlutterEventChannel

### iOS 插件

```
插件项目根目录 hello/
├── android
├── example
├── hello.iml
├── ios
├── lib
│   └── hello.dart
├── pubspec.lock
├── pubspec.yaml
└── test

iOS插件开发目录 hello/ios/
├── Assets
├── Classes
│   ├── HelloPlugin.h
│   └── HelloPlugin.m
└── hello.podspec

iOS插件测试项目目录 hello/example/ios
├── Flutter
├── Podfile
├── Runner
│   ├── AppDelegate.h
│   ├── AppDelegate.m
│   ├── Assets.xcassets
│   ├── GeneratedPluginRegistrant.h
│   ├── GeneratedPluginRegistrant.m
│   ├── Info.plist
│   └── main.m
├── Runner.xcodeproj
└── Runner.xcworkspace
```

运行iOS插件示例：

```sh
cd hello/example
flutter build ios --no-codesign
```

## Flutter.framework

### Classes

#### FlutterMethodChannel

```objc
@interface FlutterMethodChannel : NSObject
+ (instancetype)methodChannelWithName:(NSString*)name binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
/*+ (instancetype)methodChannelWithName:(NSString*)name binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger codec:(NSObject<FlutterMethodCodec>*)codec;
- (instancetype)initWithName:(NSString*)name binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger codec:(NSObject<FlutterMethodCodec>*)codec;
- (void)invokeMethod:(NSString*)method arguments:(id _Nullable)arguments;
- (void)invokeMethod:(NSString*)method arguments:(id _Nullable)arguments result:(FlutterResult _Nullable)callback;
- (void)setMethodCallHandler:(FlutterMethodCallHandler _Nullable)handler;
- (void)resizeChannelBuffer:(NSInteger)newSize;*/
@end
```

### Protocols

#### FlutterPlugin

```objc
typedef void (*FlutterPluginRegistrantCallback)(NSObject<FlutterPluginRegistry>* registry);

@protocol FlutterPlugin <NSObject, FlutterApplicationLifeCycleDelegate>
@required
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

@optional
+ (void)setPluginRegistrantCallback:(FlutterPluginRegistrantCallback)callback;
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;
@end
```





### 通过 MethodChannel 进行通讯




MethodChannel API：

```dart
Future<T> invokeMethod<T>(String method, [ dynamic arguments ]);

// 返回特殊类型
Future<List<T>> invokeListMethod<T>(String method, [ dynamic arguments ]);
Future<Map<K, V>> invokeMapMethod<K, V>(String method, [ dynamic arguments ])

void setMethodCallHandler(Future<dynamic> handler(MethodCall call));
```

iOS FlutterMethodCall API:

```objc
+ (instancetype)methodCallWithMethodName:(NSString*)method arguments:(id _Nullable)arguments;
@property(readonly, nonatomic) NSString* method;
@property(readonly, nonatomic, nullable) id arguments;
```

Flutter端：

```dart
class Music {
  static const MethodChannel _channel = MethodChannel('music');

  static Future<bool> isLicensed() async {
    return _channel.invokeMethod('isLicensed');
  }

  static Future<List<Song>> songs() async {
    final List<dynamic> songs = await _channel.invokeMethod('getSongs');
    return songs.map(Song.fromJson).toList();
  }
  // 带参数
  static Future<void> play(Song song, double volume) async {
    try {
      return _channel.invokeMethod('play', <String, dynamic>{ 'song': song.id, 'volume': volume, });
    } on PlatformException catch (e) {
      throw 'Unable to play ${song.title}: ${e.message}';
    }
  }
  static void func2(){
    _channel.setMethodCallHandler(handler);
  }
}

Future<dynamic> handler(MethodCall call) async{
  switch (call.method) {
    case 'func_name_1':
      return call.arguments;
    default:
  }
  return call.arguments;
}

class Song {
  Song(this.id, this.title, this.artist);

  final String id;
  final String title;
  final String artist;

  static Song fromJson(dynamic json) {
    return Song(json['id'], json['title'], json['artist']);
  }
}
```

iOS端：

```objectivec
@interface MusicPlugin : NSObject<FlutterPlugin>
@end
@implementation MusicPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"music" binaryMessenger:[registrar messenger]];
    FlutterPlugin* instance = [[FlutterPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];

    /* 这里的作用和 `handleMethodCall:result:` 作用一样。
    [channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        if ([@"getPlatformVersion" isEqualToString:call.method]) {
            result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
        } else if([@"func1" isEqualToString:call.method]){
            NSLog(@"%@",call.arguments);
            result (@"----sss");
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
     */
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  // isLicensed
  if ([@"isLicensed" isEqualToString:call.method]) {
    result([NSNumber numberWithBool:[BWPlayApi isLicensed]]);
  } 
  // getSongs
  else if ([@"getSongs" isEqualToString:call.method]) {
    NSArray* items = [BWPlayApi items];
    NSMutableArray* json = [NSMutableArray arrayWithCapacity:items.count];
    for (BWPlayItem* item in items) {
      [json addObject:@{@"id":item.itemId, @"title":item.name, @"artist":item.artist}];
    }
    result(json);
  } 
  // play
  else if ([@"play" isEqualToString:call.method]) {
    NSString* itemId = call.arguments[@"song"];
    NSNumber* volume = call.arguments[@"volume"];
    NSError* error = nil;
    BOOL success = [BWPlayApi playItem:itemId volume:volume.doubleValue error:&error];
    if (success) {
      result(nil);
    } else {
      result([FlutterError errorWithCode:[NSString stringWithFormat:@"Error %ld", error.code]
                                 message:error.domain
                                 details:error.localizedDescription]);
    }
  } else {
    result(FlutterMethodNotImplemented);
  }
}
@end
```

涉及的API：

```objc
// Protocol FlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;
- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result;

//Interface FlutterMethodChannel
+ (instancetype)methodChannelWithName:(NSString*)name binaryMessenger:(NSObject<FlutterBinaryMessenger>*)messenger;
- (void)setMethodCallHandler:(FlutterMethodCallHandler _Nullable)handler;

// Protocol FlutterPluginRegistrar
- (void)addMethodCallDelegate:(NSObject<FlutterPlugin>*)delegate channel:(FlutterMethodChannel*)channel;
```

* [深入理解Flutter Platform Channel](https://juejin.im/post/5b84ff6a6fb9a019f47d1cc9)

```
├── actions.dart
├── animated_cross_fade.dart
├── animated_list.dart
├── animated_size.dart
├── animated_switcher.dart
├── annotated_region.dart
├── app.dart
├── async.dart
├── autofill.dart
├── automatic_keep_alive.dart
├── banner.dart
├── basic.dart
├── binding.dart
├── bottom_navigation_bar_item.dart
├── color_filter.dart
├── constants.dart
├── container.dart
├── debug.dart
├── dismissible.dart
├── disposable_build_context.dart
├── drag_target.dart
├── draggable_scrollable_sheet.dart
├── editable_text.dart
├── fade_in_image.dart
├── focus_manager.dart
├── focus_scope.dart
├── focus_traversal.dart
├── form.dart
├── framework.dart
├── gesture_detector.dart
├── grid_paper.dart
├── heroes.dart
├── icon.dart
├── icon_data.dart
├── icon_theme.dart
├── icon_theme_data.dart
├── image.dart
├── image_filter.dart
├── image_icon.dart
├── implicit_animations.dart
├── inherited_model.dart
├── inherited_notifier.dart
├── inherited_theme.dart
├── layout_builder.dart
├── list_wheel_scroll_view.dart
├── localizations.dart
├── media_query.dart
├── modal_barrier.dart
├── navigation_toolbar.dart
├── navigator.dart
├── nested_scroll_view.dart
├── notification_listener.dart
├── orientation_builder.dart
├── overlay.dart
├── overscroll_indicator.dart
├── page_storage.dart
├── page_view.dart
├── pages.dart
├── performance_overlay.dart
├── placeholder.dart
├── platform_view.dart
├── preferred_size.dart
├── primary_scroll_controller.dart
├── raw_keyboard_listener.dart
├── route_notification_messages.dart
├── routes.dart
├── safe_area.dart
├── scroll_activity.dart
├── scroll_aware_image_provider.dart
├── scroll_configuration.dart
├── scroll_context.dart
├── scroll_controller.dart
├── scroll_metrics.dart
├── scroll_notification.dart
├── scroll_physics.dart
├── scroll_position.dart
├── scroll_position_with_single_context.dart
├── scroll_simulation.dart
├── scroll_view.dart
├── scrollable.dart
├── scrollbar.dart
├── semantics_debugger.dart
├── shortcuts.dart
├── single_child_scroll_view.dart
├── size_changed_layout_notifier.dart
├── sliver.dart
├── sliver_fill.dart
├── sliver_layout_builder.dart
├── sliver_persistent_header.dart
├── sliver_prototype_extent_list.dart
├── spacer.dart
├── status_transitions.dart
├── table.dart
├── text.dart
├── text_selection.dart
├── texture.dart
├── ticker_provider.dart
├── title.dart
├── transitions.dart
├── tween_animation_builder.dart
├── unique_widget.dart
├── value_listenable_builder.dart
├── viewport.dart
├── visibility.dart
├── widget_inspector.dart
├── widget_span.dart
└── will_pop_scope.dart
```