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

### 使用包资源

示例：现在需要使用包`pubspec.yaml`：

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

## 常用组件
Flutter 中一种非常重要的概念：一切皆组件，Flutter 中所有的元素都是有组件组成。

### 容器组件(Container)

| 属性 | 类型 | 说明 |
| --- | --- | --- |
|key | Key|Container 唯一标识符，用于查找更新|
|alignment | AlignmentGeometry|控制 child 的对齐方式，如果 Container或者 Container父节点尺寸大于 child 的尺寸，这个属性设置会起作用，有很多种对齐方式|
|padding | EdgelnsetsGeometry|Decoration内部的空白区域，如果有 child的话，child位于padding 内部|
|color | Color|用来设置 Container背景色，如果 foregroundDecoration设置的话，可能会遮盖 color效果|
|decoration | Decoration|绘制在 child后丽的装饰，设置了 Decoration 的话，就不能设置 color属性，否则会报错，此时应该在 Decoration 中进行颜色的设置|
|foregroundDecoration | Decoration |绘制在 child前面的装饰|
|width | double|Container 的宽度，设置为 double.infinity可以强制在宽度上撑满，不设置，撑满则根据 child 和父节点两者一起布局|
|height | double|Container的高度，设置为 double.infin即可以 强制在高度上撑满|
|constraints | BoxConstraints |添加到 child上额外的约束条件|
|margin  | EdgelnsetsGeometry |围绕在 Decoration 和 child 之外的空白区域，不属于内容区域|
|transform  | Matrix4|设置 Container 的变换矩阵，类型为 Matrix4|
|child | Widget|Container 中的内容 Widget|

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("AppBar Title"),
        ),
        body: new Center(
          child: new Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.red
            ),
            child: new Center(
              child: new Text('Container Text'),
            ),
          ),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/02.png" width = "25%" height = "25%"/>

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

#### 水平列表组件
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

#### 长列表组件
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

#### 网格列表组件(GridView)
网格列表组件(GridView)：克实现多行多列的应用场景。

* `GridView.count`： 通过单行展示个数来创建。
* `GridView.extent`： 通过最大宽度创建。

| 属性 | 类型 | 默认值 | 说明 |
| --- | --- | --- | --- |
|scrollDirection|||
|reverse|||
|controller|||
|primary|bool||是否是与父节点的PrimaryScrollController所关联的主滚动视图|
|physics|||
|shrinkWrap|||
|padding|||
|gridDelegate|SliverGridDelegate||控制GridView中节点布局的delegate|
|cacheExtent|||

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = new List<Widget>.generate(20, (i) => new Text('data'));
    return MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Bar title'),
        ),
        body: new GridView.count(
          crossAxisCount: 3,// 一行上放三列数据
          primary: false,
          padding: const EdgeInsets.all(20.0),
          crossAxisSpacing: 30.0,
          children: widgets,
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/08.png" width = "25%" height = "25%"/>

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

## Material Design 风格组件
`Material Design` 是由Google推出的全新设计语言。

### App结构和导航组件
#### MaterialApp(应用组件)
`MaterialApp`代表使用纸墨设计风格的应用，里面包含了及其所需要的基本控件。一个完整的Flutter项目就是从`MaterialApp`这个组件开始的。

|属性|类型|说明|
| --- | --- | --- |
|title|String|应用程序的标题：iOS->程序切换管理器中，Android->任务管理器的程序快照上|
|theme|ThemeData|应用使用的主题色，可以全局也可以局部设置|
|color|Color|应用的主题色：`primary color`|
|home|Widget|Widget对象，用来定义当前应用打开时所显示的界面|
|routes|Map<String,WidgetBuilder>|应用中页面跳转规则|
|initialRoute|String|初始化路由|
|onGenerateRoute|RouteFactory|路由回调函数。当通过`Navigator.of(context).pushNamed`跳转路由时，在`routes`查找不到时，会调用该方法|
|onLocalChanged||当系统修改语言的时候,会触发这个回调|
|navigatorObservers|List<NavigatorObserver>|航观察器|
|debugShowMaterialGrid|bool|是否显示纸墨设计基础布局网格,用来调试UI的工具|
|showPerformanceOverlay|bool|显示性能标签|

##### 设置主页面

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // 应用程序的主组件
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'title',
      home: new MyHomePage(),
    );
  }
}

// 创建可改变的Widget
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}
class _MyHomePageState extends State<StatefulWidget>{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('MaterialApp Demo'),
      ),
      body: new Center(
        child: new Text('body'),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/10.png" width = "25%" height = "25%"/>

##### 处理路由
`routes`对象是一个`Map<String,WidgetBuilder>`类型。当使用`Navigator.of(context).pushNamed`来路由时，会在`routes`查找路由的名字。然后使用对应的`WidgetBuilder`来构建一个待遇页面切换动画的`MaterailPageRoute`。

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // 应用程序的主组件
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'title',
      home: new MyHomePage(),
      routes: {
        '/first': (BuildContext context) => MyFirstPage(),
        '/second': (BuildContext context) => MySecondPage()
      },
      initialRoute: '/first', // 设置初始化路由
    );
  }
}

// 创建可改变的Widget
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}
class _MyHomePageState extends State<StatefulWidget>{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('MaterialApp Demo'),
      ),
      body: new Center(
        child: new RaisedButton(onPressed: (){
          Navigator.pushNamed(context, '/second');
        }, child: new Text('Push To Second'),),
      ),
    );
  }
}

class MyFirstPage extends StatefulWidget {
  @override
  _MyFirstPageState createState() => new _MyFirstPageState();
}
class _MyFirstPageState extends State<StatefulWidget>{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('First Page'),
      ),
      body: new Center(
        child: new RaisedButton(onPressed: (){
          Navigator.pushNamed(context, '/second');
        },child: new Text('Push To Second'),)
      ),
    );
  }
}

class MySecondPage extends StatefulWidget {
  @override
  _MySecondPageState createState() => new _MySecondPageState();
}
class _MySecondPageState extends State<StatefulWidget>{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Second Page'),
      ),
      body: new Center(
        child: new RaisedButton(onPressed: (){
          Navigator.pushNamed(context, '/first');
        },child: new Text('Push To Second'),),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/11.png" width = "50%" height = "50%"/>

##### 自定义主题
```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // 应用程序的主组件
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(
        primarySwatch: Colors.red
      ),
      title: 'title',
      home: new MyHomePage(),
    );
  }
}
```

<img src="/assets/images/flutter/12.png" width = "25%" height = "25%"/>

#### Scaffold(脚手架组件)
`Scaffold`：实现了基本的`Materail Design`布局。

|属性|类型|说明|
| --- | --- | --- |
|appBar|AppBar|显示在界面顶部的一个AppBar|
|body|Widget|当前界面所显示的主要内容|
|floatingActionButton|Widget|Material Design中定义的一个功能按钮|
|persistentFooterButtons|List<Widget>|固定在下方显示的按钮|
|drawer|Widget|侧边栏组件|
|botlomNavigationBar|Widget|显示在底部的导航栏按钮栏|
|backgroundcolor|Color|背景颜色|
|resizeToAvoidBottomPadding| bool|控制界面内容`body`是否重新布局来避免底部被覆盖,比如当键盘显示时,重新布局避免被键盘盖住内容。默认值为`true`|

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // 应用程序的主组件
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'title',
      home: new MyHomePage(),
    );
  }
}

// 创建可改变的Widget
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}
class _MyHomePageState extends State<StatefulWidget>{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // 头部元素：左侧返回按钮、中间标题、右侧菜单
      appBar: new AppBar(
        title: new Text('MaterialApp Demo'),
      ),
      // 视图内容
      body: new Center(
        child: new Text('Body'),
      ),
      // 底部导航栏
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 49.0,
        ),
      ),
      // 悬浮按钮
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        tooltip: 'button tip',
        child: Icon(Icons.add),
      ),
      // 悬浮按钮居中展示
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
```

<img src="/assets/images/flutter/13.png" width = "25%" height = "25%"/>

#### AppBar(应用按钮组件)
应用按钮组件有`AppBar`、`SliverAppBar`，都是继承子`StatefulWidget`类。区别在于`AppBar`固定在顶部，`SliverAppBar`可以跟着内容进行滚动。

|属性|类型|默认值|说明|
| --- | --- | --- |--- |
|leading||||
|title||||
|actions|List<Widget>|null|一个`Widget`列表。代表Toolbar中所展示的菜单。对于常用的菜单，通常使用`IconButton`来表示，对于不常用的菜单使用`PopupMenuButton`来显示为三个点，点击后弹出二级菜单|
|bottom|PreferredSizeWidget|null|通常是`TabBar`。用来在ToolBar标题下展示菜单|
|elevation||||
|flexibleSpace||||
|backgroundColor||||
|brightness||||
|iconTheme||||
|textTheme||||
|centerTitle||||

<img src="/assets/images/flutter/14.png"/>

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // 应用程序的主组件
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'title',
      home: new MyHomePage(),
    );
  }
}

// 创建可改变的Widget
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}
class _MyHomePageState extends State<StatefulWidget>{
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      // 头部元素：左侧返回按钮、中间标题、右侧菜单
      appBar: new AppBar(
        title: new Text('MaterialApp Demo'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.search), onPressed: (){}),
          IconButton(icon: Icon(Icons.add), onPressed: (){}),
        ],
      ),
      // 视图内容
      body: new Center(
        child: new Text('Body'),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/15.png" width = "25%" height = "25%"/>

#### BtoomNavigationBar(底部导航栏组件)
`BtoomNavigationBar` 显示在应用页面的底部的工具栏。

|属性|类型|说明|
| --- | --- | --- |
|currentIndex|int|当前索引|
|fixedColor|||
|iconColor|||
|items|`List<BtoomNavigationBarItem>`|底部导航栏按钮集合|
|onTap|`ValueChanged<int>`|按下其中某个按钮的回调事件。需要根据返回的索引设置当前索引|

<img src="/assets/images/flutter/16.png" width = "25%" height = "25%"/>

#### TabBar(水平选项卡及视图组件)
`TabBar`通常需要配套Tab选项组件以及`TabBarView`页面视图组件一起使用。

|TabBar属性|类型|说明|
| --- | --- | --- |
|isScrollable|bool|是否可以水平移动|
|tabs|`List<Widget>`|Tab选项列表，建议不要放太多项，否则用户操作起来不方便|

|Tab属性|类型|说明|
| --- | --- | --- |
|icon|Widget|Tab图标|
|text|String|Tab文本|

|TabBarView属性|类型|说明|
| --- | --- | --- |
|controller|TabController|指定视图的控制器|
|children|`List<Widget>`|视图组件的child为一个列表，一个选项卡对应一个视图|

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // 选项卡 数据源
  final List<Tab> tabs = [
    Tab(text: '选项卡 1',),
    Tab(text: '选项卡 2',),
    Tab(text: '选项卡 3',),
  ];

  // 应用程序的主组件
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: DefaultTabController(
        child: new Scaffold(
          appBar: new AppBar(
            // 添加导航栏
            bottom: TabBar(tabs: tabs),
          ),
          body: TabBarView(children: tabs.map((Tab tab){
            return Center(
              child: Text(tab.text),
            );
          }).toList()),
        ), 
        length: tabs.length,),
    );
  }
}
```

<img src="/assets/images/flutter/17.png" width = "25%" height = "25%"/>

实现一个完整示例：

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      // DefaultTabController：关联 TabBar 和 TabBarView
      home: DefaultTabController(
        child: new Scaffold(
          appBar: new AppBar(
            bottom: TabBar(
              // 设置可滚动
              isScrollable: true,
              tabs: items.map((ItemView item) {
                return Tab(
                  text: item.title,
                  icon: new Icon(item.icon),
                );
              }).toList(),
            ),
          ),
          body: new TabBarView(
              children: items.map((ItemView item) {
            return new Padding(
              padding: const EdgeInsets.all(16.0),
              child: new SelectedView(item: item),
            );
          }).toList()),
        ),
        length: items.length,
      ),
    );
  }
}

// 选项卡数据结构
class ItemView {
  // 构造函数
  const ItemView({this.title, this.icon});
  final String title;
  final IconData icon;
}

// 选项卡数据源
const List<ItemView> items = [
  const ItemView(title: '自驾', icon: Icons.directions_car),
  const ItemView(title: '自行车', icon: Icons.directions_bike),
  const ItemView(title: '轮船', icon: Icons.directions_boat),
  const ItemView(title: '公交车', icon: Icons.directions_bus),
  const ItemView(title: '火车', icon: Icons.directions_railway),
  const ItemView(title: '步行', icon: Icons.directions_walk),
];

// 被选中的视图->被装载在 TabBarView 里面
class SelectedView extends StatelessWidget {
  const SelectedView({Key key, this.item}) : super(key: key);
  final ItemView item;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;

    return new Card(
      color: Colors.white,
      child: new Center(
        child: new Column(
          mainAxisSize: MainAxisSize.min, // 垂直方向最小化处理
          crossAxisAlignment: CrossAxisAlignment.center, //水平方向居中对齐
          children: <Widget>[
            new Icon(
              item.icon,
              size: 128.0,
              color: textStyle.color,
            ),
            new Text(
              item.title,
              style: textStyle,
            )
          ],
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/18.png" width = "25%" height = "25%"/>

#### Drawer(抽屉组件)

|Drawer 属性|类型|默认值|说明|
| --- | --- | --- | --- |
|child|Widget||可显示对象|
|elevation|double|16|组件的`z`坐标顺序|

* `DrawerHeader` : 头部效果，展示基本信息。
* `UserAccountsDrawerHeader` : 头部效果，展示用户头像、用户名、Email等信息。

|DrawerHeader 属性|类型|说明|
| --- | --- | --- |
|decoration|Decoration||
|curve|Curve||
|child|Widget||
|padding|EdgeInsetsGeometry||
|margin|EdgeInsetsGeometry||

|UserAccountsDrawerHeader 属性|类型|说明|
| --- | --- | --- |
|margin|EdgeInsetsGeometry||
|decoration|Decoration||
|CurrentAccountPicture|Widget||
|OtherAccountsPictures|`List<Widget>`||
|accountName|Widget||
|accountEmail|Widget||
|onDetailsPressed|VoidCallback||

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
          appBar: new AppBar(
            title: Text('Demo'),
          ),
          drawer: new Drawer(
            child: ListView(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: new Text('accountName'),
                  accountEmail: new Text('accountEmail'),
                  currentAccountPicture: new CircleAvatar(
                    backgroundImage: new AssetImage('icons/1.png'),
                  ),
                  otherAccountsPictures: <Widget>[
                    new Container(
                      child: Image.asset('icons/code.png'),
                    )
                  ],
                  onDetailsPressed: () {},
                ),
                ListTile(
                  leading: new CircleAvatar(
                    child: Icon(Icons.color_lens),
                  ),
                  title: Text('个性装扮'),
                ),
                ListTile(
                  leading: new CircleAvatar(
                    child: Icon(Icons.photo),
                  ),
                  title: Text('我的相册'),
                ),
                ListTile(
                  leading: new CircleAvatar(
                    child: Icon(Icons.wifi),
                  ),
                  title: Text('免流量权限'),
                ),
              ],
            ),
          )),
    );
  }
}
```

<img src="/assets/images/flutter/19.png" width = "25%" height = "25%"/>

### 按钮和提示组件
#### FloatingActionButton(悬停按钮组件)

| 属性|类型|默认值|说明|
| --- | --- | --- | --- |
|child|Widget|||
|tooltip||||
|foregroundColor||||
|backgroundColor||||
|elevation||||
|hignlightElevation||||
|onPressed||||
|shape||||

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('Demo'),
        ),
        floatingActionButton: new Builder(builder: (BuildContext context){
          return new FloatingActionButton(
            child: const Icon(Icons.add),
            tooltip: 'Click Tip',
            foregroundColor: Colors.red,
            backgroundColor: Colors.blue,
            elevation: 7.0,// 未点击阴影值
            highlightElevation: 14.0,// 点击阴影值
            mini: false,
            shape: new CircleBorder(),
            isExtended: false,
            onPressed: (){
              Scaffold.of(context).showSnackBar(
                new SnackBar(content: new Text('data'))
              );
            },
          );
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,// 居中
      ),
    );
  }
}
```

把`FloatingActionButton`写在`Builder`组件里面为了使`SnackBar`有效果，因为这个类是`StatelessWidget`。也可以通过下面的代码实现，使用`StatefulWidget`：

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
        child: FlatButton(onPressed: (){
          _neverSatisfied(context);
        }, child: new Text('FlatButton'))
      ),
    );
  }
}


Future _neverSatisfied(BuildContext context) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rewind and remember'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You will never be satisfied.'),
                Text('You\’re like me. I’m never satisfied.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Regret'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
```

<img src="/assets/images/flutter/20.gif"/>

#### FlatButton(扁平按钮组件)
`FlatButton`组件是`Materail Design`风格按钮，点击时会有一个阴影效果。

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('Demo'),
        ),
        body: new Center(
          child: FlatButton(
              onPressed: () {},
              child: Text(
                'FlatButton',
                style: TextStyle(fontSize: 24.0),
              )),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/21.gif"/>

#### PopupMenuButton(弹出菜单组件)

| 属性|类型|说明|
| --- | --- | --- |
|child|Widget||
|icon|Icon||
|itemBuilder|`PopupMenuItembuilder<T>`|菜单构造器，菜单项为任意类型，文本、图标都行|
|onSelected|`PopupMenuItembuilder<T>`|菜单被选中的回调方法|


```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('Demo'),
        ),
        body: new Center(
          child: FlatButton(
            onPressed: () {},
            child: PopupMenuButton<ConferenceItem>(
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<ConferenceItem>>[
                  const PopupMenuItem<ConferenceItem>(
                    child: Text('添加成员'),
                    value: ConferenceItem.AddMember,
                  ),
                  const PopupMenuItem<ConferenceItem>(
                    child: Text('锁定会议'),
                    value: ConferenceItem.LockConference,
                  ),
                  const PopupMenuItem<ConferenceItem>(
                    child: Text('修改布局'),
                    value: ConferenceItem.ModifyLayout,
                  ),
                  const PopupMenuItem<ConferenceItem>(
                    child: Text('挂断所有'),
                    value: ConferenceItem.TurnoffAll,
                  ),
                ];
              },
              onSelected: (ConferenceItem item) {
              },
            ),
          ),
        ),
      ),
    );
  }
}

enum ConferenceItem { AddMember, LockConference, ModifyLayout, TurnoffAll }
```

<img src="/assets/images/flutter/22.gif"/>

#### SimpleDialog(简单对话框组件)

| 属性|类型|说明|
| --- | --- | --- |
|children|`List<Widget>`||
|title|||
|contentPadding|||
|titlePadding|||

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('Demo'),
        ),
        body: new Center(
          child: showDialog(),
        ),
      ),
    );
  }
}
StatelessWidget showDialog() {
  return SimpleDialog(
    title: const Text('SimpleDialog Title'),
    children: <Widget>[
      SimpleDialogOption(
        child: new Text('Line 3'),
        onPressed: () {},
      ),
      SimpleDialogOption(
        child: new Text('Line 3'),
        onPressed: () {},
      ),
      SimpleDialogOption(
        child: new Text('Line 3'),
        onPressed: () {},
      ),
    ],
  );
}
```

<img src="/assets/images/flutter/23.png" width = "25%" height = "25%"/>

> 一般对话框要封装在方法里，通过点击事件弹出。如果这一过程是异步要加上`async/await`处理。

#### AlertDialog(提示对话框组件)

| 属性|类型|说明|
| --- | --- | --- |
|actions|`List<Widget>`||
|title|||
|contentPadding|||
|content|Widget|内容，如果内容比较多可以用`SingleChildScrollView`组件进行包裹|
|titlePadding|||

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('Demo'),
        ),
        body: new Center(
          child: new Builder(builder: (BuildContext context){
            return new FlatButton(onPressed: (){
              _neverSatisfied(context);
            }, child: new Text('data'));
          }),
        ),
      ),
    );
  }
}

Future _neverSatisfied(BuildContext context) async {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rewind and remember'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('You will never be satisfied.'),
                Text('You\’re like me. I’m never satisfied.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Regret'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}

```

<img src="/assets/images/flutter/24.gif"/>

#### SnackBar(轻量提示组件)

| 属性|类型|说明|
| --- | --- | --- |
|action|||
|animation|||
|content|||
|duration|||
|backgroundColor|||

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('Demo'),
        ),
        body: new Center(
          child: new Builder(builder:(BuildContext context) {
            return new FlatButton(onPressed: (){
              Scaffold.of(context).showSnackBar(
                new SnackBar(content: new Text('data'))
              );
            }, child: new Text('data'));
          })
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/25.gif"/>

### 其他组件
#### TextField(文本框组件)

| 属性|类型|说明|
| --- | --- | --- |
|maxLength|||
|maxLines|||
|autoCorrect|||
|autofocus|||
|obscureText|||
|textAlign|||
|style|||
|inputFormatters|||
|onChanged|||
|onSubmitted|||
|enabled|||

#### Card(卡片组件)

## 参考资料
* [Flutter 中文社区](https://flutter.cn/)
* [Dart 编程语言概览](https://www.dartcn.com/guides/language/language-tour)
* [Materail Design 指导](https://material.io)
* [Flutter widget 目录](https://flutterchina.club/widgets/)























































