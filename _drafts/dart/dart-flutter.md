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

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Container> _buildGridTitleList(int count) {
      return new List<Container>.generate(count, (int index) {
        return new Container(
          child: new Image.asset('icons/code.png',),
        );
      });
    }

    Widget buildGrid() {
      return new GridView.extent(
        maxCrossAxisExtent: 150.0, // 次轴最大宽度
        padding: const EdgeInsets.all(4.0),
        mainAxisSpacing: 4.0, // 主轴间隙
        crossAxisSpacing: 4.0, // 次轴间隙
        children: _buildGridTitleList(9),
      );
    }

    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('data'),
        ),
        body: new Center(
          child: buildGrid(),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/53.png" width = "25%" height = "25%"/>

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

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

// MyApp 不做状态处理，所以继承 StatelessWidget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 添加文本编辑器，监听文本输入内容变化
    final TextEditingController controller = TextEditingController();
    controller.addListener(() {
      print('输入的内容为：${controller.text}');
    });
    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('Title'),
        ),
        body: new Center(
          child: TextField(
            controller: controller,
            maxLength: 30,// 最大长度
            maxLines: 1,//最大行数
            autocorrect: true, //是否自动更正
            autofocus: true,//是否自动对焦
            obscureText: false,//是否加密
            textAlign: TextAlign.center,//文本对齐方式
            style: TextStyle(
              fontSize: 26.0,color: Colors.green
            ),
            onChanged: (text){ // 文本改变时的回调
            },
            onSubmitted: (text){ // 内容提交时的回调
            },
            enabled: true, //是否禁用
            decoration: InputDecoration(
              fillColor: Colors.grey.shade200,
              filled: true,
              helperText: '用户名',
              prefixIcon: Icon(Icons.person),
              suffixText: '用户名'
            ),
          ),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/26.png" width = "25%" height = "25%"/>

#### Card(卡片组件)
Card(卡片组件)内容可以由大多数类型的`Widget`构成，但通常与`ListTitle`搭配使用。`Card`有一个`child`属性，可以支持多个`child`的列、行、列表、网格或者其他小部件。默认情况下`Card`将其大小缩放为`0`像素。你可以使用`SizeBox`组件来限制`Card`的大小。

| 属性|类型|说明|
| --- | --- | --- |
|child|Widget||
|margin|||
|shape|ShapeBorder||

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var card = new SizedBox(
      height: 250.0,
      child: new Card(
        child: new Column(
          children: <Widget>[
            new ListTile(
              title: Text('data1'),
              subtitle: Text('2020动画《真人快打传奇：蝎子的复仇》1080p.HD中英双字[04-14]2019动画《红鞋子和七个小矮人》1080p.HD中英双字'),
              leading: Icon(Icons.home),
            ),
            new Divider(),
            new ListTile(
              title: Text('data2'),
              subtitle: Text('2020动画《真人快打传奇：蝎子的复仇》1080p.HD中英双字[04-14]2019动画《红鞋子和七个小矮人》1080p.HD中英双字'),
              leading: Icon(Icons.school),
            ),
          ],
        ),
      ),
    );

    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('Title'),
        ),
        body: new Center(
          child: card,
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/27.png"/>

## 页面布局

| 组件名称 | 中文名称 | 描述 |
| --- | --- | --- |
| Align | 对齐布局 | 指定child的对齐方式 |
| AspectRatio |调整宽高比|根据设置的宽高比调整child|
|Baseline|基准线布局|所有child底部所在的同一条水平线|
|Center|居中布局|child处于水平和垂直向的中间位置|
|Column|垂直布局|对child在垂直方向进行排列|
|ConstrainedBox|限定宽高|限定child的最大值|
|Container|容器布局|容器布局是一个组合的Widget,包含定位和尺寸|
|FittedBox|缩放布局|缩放以及位置调整|
|FrationallySizedBox|百分比布局|根据现有空间按照百分比调整child的尺寸|
|Gridview|网格布局|对多行多列同时进行操作|
|IndexedStack|栈索引布局|Indexedstack继承自Stack,显示第index个child,其他child都是不可见的|
|LimitedBox|限定宽高布局|对最大宽高进行限制|
|ListView|列表布局|用列表方式进行布局,比如多项数据的场景|
|Offstage|开关布局|控制是否显示组件|
|OverflowBox|溢出父容器显示|允许child超出父容器的范围显示|
| Padding | 填充布局 | 处理容器与其child之间的间距 |
| Row | 水平布局 | 对chid在水平方向进行排列 |
| SizedBox | 设置具体尺寸 | 一个特定大小的盒子来限定child宽度和高度 |
| Stack/Alignment | Alignment 栈布局 | 根据Alignment组件的属性将child定位在Stack组件上 |
| Stack/Positioned | Positioned 栈布局 | 根据Positioned组件的属性将child定位在Stack组件上 |
| Table |表格布局 | 使用表格的行和列进行布局 |
| Transform | 矩阵转换 | 做矩阵变换,对child做平移、旋转、缩放等操作。|
| Wrap | 按宽高自动换行 | 按宽度或者高度,让child自动换行布局 |

### 基础布局

#### Container(基础布局)
Container(基础布局)是一个组合的Widget，具体的属性可以参考前面章节**常用组件-容器组件**。

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget container = new Container(
      // 添加装饰效果
      decoration: new BoxDecoration(
        color: Colors.grey,
      ),
      // 子元素指定为一个垂直水平嵌套布局的组件
      child: new Column(
        children: <Widget>[
          // 第一行
          new Row(
            children: <Widget>[
              new Expanded(
                child: new Container(
                width: 150.0,
                height: 150.0,
                // 添加边框样式
                decoration: new BoxDecoration(
                    border: new Border.all(
                      width: 10.0,
                      color: Colors.blueGrey,
                    ),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(8.0),
                    )),
                margin: const EdgeInsets.all(4.0),
                child: new Image.asset('icons/code.png'),
              )),
              new Expanded(
                child: new Container(
                width: 150.0,
                height: 150.0,
                decoration: new BoxDecoration(
                    border: new Border.all(
                      width: 10.0,
                      color: Colors.blueGrey,
                    ),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(8.0),
                    )),
                margin: const EdgeInsets.all(4.0),
                child: new Image.asset('icons/code.png'),
              )),
            ],
          ),
          // 第二行
          new Row(
            children: <Widget>[
              new Expanded(
                  child: new Container(
                width: 150.0,
                height: 150.0,
                decoration: new BoxDecoration(
                    border: new Border.all(
                      width: 10.0,
                      color: Colors.blueGrey,
                    ),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(8.0),
                    )),
                margin: const EdgeInsets.all(4.0),
                child: new Image.asset('icons/code.png'),
              )),
              new Expanded(
                  child: new Container(
                width: 150.0,
                height: 150.0,
                decoration: new BoxDecoration(
                    border: new Border.all(
                      width: 10.0,
                      color: Colors.blueGrey,
                    ),
                    borderRadius: const BorderRadius.all(
                      const Radius.circular(8.0),
                    )),
                margin: const EdgeInsets.all(4.0),
                child: new Image.asset('icons/code.png'),
              )),
            ],
          )
        ],
      ),
    );

    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('Title'),
        ),
        body: container,
      ),
    );
  }
}
```

<img src="/assets/images/flutter/28.png"/>

#### Center(居中布局)
Center(居中布局)： 子元素处于水平和垂直方向的中间位置。

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
          title: Text('Title'),
        ),
        body: new Center(
          child: new Text('Center Layout'),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/29.png" width = "25%" height = "25%"/>

#### Padding(填充布局)
Padding(填充布局)： 用于处理容器与其子元素之间的间距，与`padding`对应的属性是 `margin` 属性，`margin`是处理容器与其他组件之间的间距。

| 属性|类型|说明|
| --- | --- | --- |
|padding|EdgeInsetsGeometry|填充的值可以用`EdgeInsets`方法，例如：`EdgeInsets.all(6.0)`将容器的上下左右填充设置为6.0|

##### 构造函数

```dart
// 所有方向
const EdgeInsets.all(double value)
// 分别定义各个方向的边框
const EdgeInsets.only({double left: 0.0,double top: 0.0,double right: 0.0,double bottom: 0.0})
// 自定义垂直、水平方向
const EdgeInsets.symmetric({double vertical: 0.0,double horizontal: 0.0})
// 根据机型屏幕尺寸定义
EdgeInsets.fromWindowPadding(ui.WindowPadding padding, double devicePixelRatio)
```

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: PaddingDemo(),
    );
  }
}

class PaddingDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Padding Demo'),
      ),
      body: new Center(
        child: new Container(
          width: 300.0,
          height: 300.0,
          // 容器的上下左右填充设置为60.0
          padding: new EdgeInsets.all(30.0),
          decoration: new BoxDecoration(
            color: Colors.red,
            border: new Border.all(
              color: Colors.green,
              width: 8.0,
            ),
          ),
          child: new Container(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/30.png" /> <!-- width = "25%" height = "25%" -->

#### Align(对齐布局)
Align(对齐布局)： 将子组件按照指定的方式对齐，并且根据子组件的大小调整自己的大小。

|属性|值|描述|
| --- | --- | --- | --- |
|bottomCenter|(0.5,1.0)|底部中心|
|bottomLeft|(0.0,1.0)|左下角|
|bottomRight|(1.0,1.0)|右下角|
|center|(0.5,0.5)|水平垂直居中|
|centerLeft|(0.0,0.5)|坐边缘中心|
|centerRight|(1.0,0.5)|右边缘中心|
|topCenter|(0.5,0.0)|顶部中心|
|topLeft|(0.0,0.0)|左上角|
|topRight|(1.0,0.0)|右上角|

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: PaddingDemo(),
    );
  }
}

class PaddingDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Align Demo'),
      ),
      body: new Stack(
        children: <Widget>[
          // 左上角
          new Align(
            alignment: new FractionalOffset(0.0, 0.0),
            child: new Image.asset('icons/code.png',width: 128.0,height: 128.0,),
          ),
          // 右上角
          new Align(
            alignment: FractionalOffset(1.0, 0.0),
            child: new Image.asset('icons/code.png',width: 128.0,height: 128.0,),
          ),
          // 水平垂直居中
          new Align(
            alignment: FractionalOffset.center,
            child: new Image.asset('icons/code.png',width: 128.0,height: 128.0,),
          ),
          // 左下角
          new Align(
            alignment: FractionalOffset.bottomLeft,
            child: new Image.asset('icons/code.png',width: 128.0,height: 128.0,),
          ),
          // 右下角
          new Align(
            alignment: FractionalOffset.bottomRight,
            child: new Image.asset('icons/code.png',width: 128.0,height: 128.0,),
          ),
        ],
      ),
    );
  }
}
```

<img src="/assets/images/flutter/31.png" width = "25%" height = "25%"/>

#### Row(水平布局)
Row(水平布局) 用来完成子组件在水平方向的排列。

|属性|值|描述|
| --- | --- | --- | --- |
|mainAxisAlignment|MainAxisAlignment|主轴的排列方式|
|crossAxisAlignment|CrossAxisAlignment|次轴的排列方式|
|mainAxisSize|MainAxisSize|主轴应该占据多少空间。取值max为最大，min为最小。|
|children|`List<Widget>`||

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: PaddingDemo(),
    );
  }
}

class PaddingDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Align Demo'),
      ),
      body: Row(
        children: <Widget>[
          new Expanded(
            child: new Text('data', textAlign: TextAlign.center,),
          ),
          new Expanded(
            child: new Text('data', textAlign: TextAlign.center,),
          ),
          new Expanded(
            child: new FittedBox(
              fit: BoxFit.contain,
              child: const FlutterLogo(),
            )
          ),
        ],
      ),
    );
  }
}
```

<img src="/assets/images/flutter/32.png" width = "25%" height = "25%"/>

#### Column(垂直布局)
Column(垂直布局) 用来完成对子组件纵向的排列。主轴是垂直方向，次轴是水平方向。

|属性|值|描述|
| --- | --- | --- | --- |
|mainAxisAlignment|MainAxisAlignment|主轴的排列方式|
|crossAxisAlignment|CrossAxisAlignment|次轴的排列方式|
|mainAxisSize|MainAxisSize|主轴应该占据多少空间。取值max为最大，min为最小。|
|children|`List<Widget>`||

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: PaddingDemo(),
    );
  }
}

class PaddingDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Align Demo'),
      ),
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new Text('data', textAlign: TextAlign.center,),
          ),
          new Expanded(
            child: new Text('data', textAlign: TextAlign.center,),
          ),
          new Expanded(
            child: new FittedBox(
              fit: BoxFit.contain,
              child: const FlutterLogo(),
            )
          ),
        ],
      ),
    );
  }
}
```

<img src="/assets/images/flutter/33.png" width = "25%" height = "25%"/>

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: PaddingDemo(),
    );
  }
}

class PaddingDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Align Demo'),
      ),
      body: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,// 水平方向靠左对齐
        mainAxisSize: MainAxisSize.min, //主轴方向最小化处理
        children: <Widget>[
          new Text('度权重查询 SEO概况查询 友情链接查询 Google PR查询 Whois信息查询 域名备案查询'),
          new Text('度权重查询 SEO概况查询 友情链接查询 Google PR查询 Whois信息查询 域名备案查询'),
          new Text('度权重查询 SEO概况查询 友情链接查询 Google PR查询 Whois信息查询 域名备案查询'),
          new Text('data1'),
          new Text('度权重查询 SEO概况查询 友情链接查询 Google PR查询 Whois信息查询 域名备案查询'),
          new Text('度权重查询 SEO概况查询 友情链接查询 Google PR查询 Whois信息查询 域名备案查询度权重查询 SEO概况查询 友情链接查询 Google PR查询 Whois信息查询 域名备案查询'),
        ],
      ),
    );
  }
}
```

<img src="/assets/images/flutter/34.png" width = "25%" height = "25%"/>

#### FittedBox(缩放布局)

* [FittedBox-官方视频教程](https://youtu.be/T4Uehk3_wlY)
* [FittedBox-官方文档](https://api.flutter.dev/flutter/widgets/FittedBox-class.html)

FittedBox(缩放布局) 组件主要做两件事，`缩放(Scale)`和`位置调整(Position)`。

FittedBox会在自己的尺寸范围内缩放并且调整child的位置。使child适合其尺寸。有点像`ImageView`组件，`ImageView`会将图片在其范围内按照规则进行缩放位置调整。

布局行为分为两种情况:

* 如果外部有约束的话，按照外部约束调整自身尺寸，然后缩放调整child，按照指定的条件进行布局。
* 如果没有外部约束条件，则跟着child尺寸一致，指定的缩放以及位置属性将不起作用。

属性`alignment`：设置对齐方式，默认是`Alignment.center`，居中展示child。

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(title: Text('data'),),
        body: new Container(
          color: Colors.red,
          width: 200.0,
          height: 200.0,
          child: new FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topLeft,
            child: new Container(
              color: Colors.green,
              child: new Text('Test'),
            ),
          ),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/35.png" width = "25%" height = "25%"/>

|`fit`缩放属性|图解|描述|
| --- | --- | --- |
|contain|<img src="/assets/images/flutter/36.png"/>|`child`在`FittedBox`范围内尽可能大，但是不能超出其尺寸。【`contain`是在保持着`child`宽高比不变的大前提下尽可能的填满，一般是宽度或者高度达到最大值时就会停止缩放。】|
|cover|<img src="/assets/images/flutter/37.png"/>|按照原始尺寸填充整个容器，内容可能会超过容器范围|
|fill|<img src="/assets/images/flutter/38.png"/>|不按照宽高比填充，直接填满但是不会超过容器范围|
|fitHeight|<img src="/assets/images/flutter/39.png"/>|按照高度填充整个容器|
|fitWidth|<img src="/assets/images/flutter/40.png"/>|按照宽度填充整个容器|
|none|<img src="/assets/images/flutter/41.png"/>|没有任何填充|
|scaleDown|<img src="/assets/images/flutter/42.png"/>|根据情况缩小范围，内容不会超过容器范围，有时和`contain`一样有时和`none`一样|

#### Stack/Alignment

`Stack`组件的每个子组件要么定位，要么不定位。定位的子组件用`Positioned`组件包裹。`Stack`组件本身包含所有不定位的子组件，子组件根据`alignment`属性进行定位(默认为左上角)。然后根据定位的子组件的`top`、`right`、`bottom`和`left`属性将它们位置在`Stack`组件上。

|属性|类型|默认值|描述|
| --- | --- | --- | --- |
|alignment|AlignmentGeometry|Alignment.topLeft|定位位置有以下几种：<br>`bottomCenter` : 底部中心 <br>`bottomLeft` : 左下角 <br>`bottomRight` : 右下角 <br>`center` : 水平垂直居中 <br>`centerLeft` : 坐边缘中心 <br>`centerRight` : 右边缘中心 <br>`topCenter` : 顶部中心 <br>`topLeft` : 左上角 <br>`topRight` : 右上角|

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var stack = new Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        new CircleAvatar(
          backgroundImage: new AssetImage('icons/code.png'),
          radius: 100.0,
        ),
        new Container(
          decoration: new BoxDecoration(
            color: Colors.blue,
          ),
          child: new Text(
            'TestTes',
            style: new TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        )
      ],
    );

    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(title: Text('data'),),
        body: new Center(
          child: stack,
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/43.png"/>
<!-- width = "25%" height = "25%" -->

#### Stack/Positioned
`Positioned`组件是用来定位的。`Stack`组件里需要包裹一个定位组件。

|属性|类型|描述|
| --- | --- | --- |
|top|double|子元素相对顶部边界距离|
|bottom|double|子元素相对底部边界距离|
|left|double|子元素相对坐侧边界距离|
|right|double|子元素相对右侧边界距离|

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var stack = new Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        new CircleAvatar(
          backgroundImage: new AssetImage('icons/code.png'),
          radius: 100.0,
        ),
        new Positioned(
            bottom: 50.0,
            right: 50.0,
            child: new Text('data',
                style: new TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red))),
      ],
    );

    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('data'),
        ),
        body: new Center(
          child: stack,
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/44.png"/>

#### IndexedStack

`IndexedStack`继承了`Stack`，它的作用就是显示第`index`个`child`，其他的`child`不可见。所以`IndexStack`的尺寸永远是和最大的子节点尺寸一致的。

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var stack = new IndexedStack(
      index: 1,
      alignment: Alignment.topLeft,
      children: <Widget>[
        new CircleAvatar(
          backgroundImage: new AssetImage('icons/code.png'),
          radius: 100.0,
        ),
        new Positioned(
            bottom: 50.0,
            right: 50.0,
            child: new Text('data',
                style: new TextStyle(
                    fontSize: 36.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red))),
      ],
    );

    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('data'),
        ),
        body: new Center(
          child: stack,
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/45.png" width = "25%" height = "25%"/>

#### OverflowBox 溢出父容器显示
`OverflowBox` 组件运行子元素`child`超出父容器的显示范围。

* 当`OverflowBox`的最大尺寸大于`child`的时候，`child`可以完整显示。
* 当`OverflowBox`的最大尺寸小于`child`的时候，则以最大尺寸为基准，当然这个尺寸是可以突破父节点的。

|属性|类型|描述|
| --- | --- | --- |
|alignment|AlignmentGeometry||
|minWidth|double|允许 child 的最小宽度。如果 child 宽度小于这个值，则按照最小宽度进行显示|
|maxWidth|double|允许 child 的最大宽度。如果 child 宽度大于这个值，则按照最大宽度进行显示|
|minHeight|double|允许 child 的最小高度。如果 child 宽度小于这个值，则按照最小高度进行显示|
|maxHeight|double|允许 child 的最小高度。如果 child 宽度小于这个值，则按照最小高度进行显示|

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
          title: Text('data'),
        ),
        body: new Container(
          color: Colors.red,
          width: 200.0,
          height: 200.0,
          padding: const EdgeInsets.all(10.0),
          child: OverflowBox(
            alignment: Alignment.topLeft,
            maxWidth: 300.0,
            maxHeight: 500.0,
            child: Container(
              color: Colors.green,
              width: 400.0,
              height: 400.0,
            ),
          ),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/46.png" width = "25%" height = "25%"/>

### 宽高尺寸处理

#### SizedBox(设置具体尺寸)

`SizedBox`组件是一个特定大小的盒子，这个组件强制他的child有特定的宽度和高度。

|属性|类型|描述|
| --- | --- | --- |
|width|AlignmentGeomtry|如果具体设置了宽度，则强制child宽度为此值； 如果没有设置，则根据child宽度调整自身宽度|
|height|double|如果具体设置了高度，则强制child高度为此值； 如果没有设置，则根据child高度调整自身宽度|

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
          title: Text('data'),
        ),
        body: SizedBox(
          width: 200.0,
          height: 300.0,
          child: const Card(
            child: Text(
              'data',
              style: TextStyle(fontSize: 36.0),
            ),
          ),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/47.png" width = "25%" height = "25%"/>

#### ConstrainedBox(限定最大最小宽度布局)
`ConstrainedBox`的作用就是限定子元素child的最大宽度、最大高度、最小宽度和最小高度。

| --- | --- | --- |
|constraints|BoxConstraints|添加到child上的额外限制条件，BoxConstraints的作用就是限制各种最大最小宽高|
|child|||

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
        body: new ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 150.0,
            minHeight: 150.0,
            maxWidth: 220.0,
            maxHeight: 220.0,
          ),
          child: new Container(
            width: 300.0,
            height: 300.0,
            color: Colors.red,
          ),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/48.png" width = "25%" height = "25%"/>

#### LimitedBox(限定最大宽度布局)

`LimitedBox`和`ConstrainedBox`组件类似。只不过`LimitedBox`没有最小宽高限制。

|属性|类型|描述|
| --- | --- | --- |
|maxWidth|||
|maxHeight|||

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
        body: Row(
          children: <Widget>[
            Container(
              color: Colors.red,
              width: 100.0,
            ),
            LimitedBox(
              maxWidth: 100.0,
              child: Container(
                color: Colors.blue,
                width: 250.0,// 虽然设置了25.0 但是父容器限制了最大宽度
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/49.png" width = "25%" height = "25%"/>

#### AspectRatio(调整宽高比)

`AspectRatio` 作用是根据设置调整子元素child的宽高比，适合用于需要固定宽高比的场景。

使用`AspectRatio`进行布局的情况：

* `AspectRatio` 会在布局条件允许的范围内尽可能的扩展。Widget的高度是由宽度和比率决定的，类似于`BoxFit.contain`，按照固定比率去尽可能的沾满区域。
* 如果在满足所欲呕限制条件后依然无法找到可行的尺寸，`AspectRatio`会优先适应布局限制条件，而忽略所设置的比率。

|属性|类型|描述|
| --- | --- | --- |
|aspectRatio|double|宽高比|
|child|Widget||

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
        body: new Container(
          height: 200.0,
          child: new AspectRatio(
            aspectRatio: 1.5,// 比率是1.5 => W = H * 1.5,所以AspectRatio组件的尺寸为(300,200)
            child: new Container(
              color: Colors.green,
            ),
          ),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/50.png" width = "25%" height = "25%"/>

#### FractionallySizedBox(百分比布局)

`FractionallySizedBox` 组件会根据现有空间来调整child的尺寸，所以就算为child设置了尺寸数值，也不起作用。

* 设置了具体的宽高因子，`具体的宽高=现有的空间宽高X因子`。
* 没有设置宽高因子，则填满可用区域。

|属性|类型|描述|
| --- | --- | --- |
|alignment|AlignmentGeometry|对齐方式，不能为null|
|widthFactor|double|宽度因子|
|heightFactor|double|高度因子|

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
          title: Text('data'),
        ),
        body: new Container(
          color: Colors.red,
          height: 200.0,
          width: 200.0,
          child: new FractionallySizedBox(
            alignment: Alignment.topCenter,
            widthFactor: 0.5, //宽度因子
            heightFactor: 1.5, //高度因子
            child: new Container(
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/51.png" width = "25%" height = "25%"/>

### 列表及表格处理

#### ListView

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final List<Widget> list = <Widget>[
    new ListTile(
      title: Text('titletitletitletitletitletitletitletitletitletitletitletitletitletitle',style: new TextStyle(fontWeight: FontWeight.w400,fontSize: 18.0),),
      subtitle: Text('Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test Test '),
      leading: Icon(Icons.fastfood,color: Colors.blue,),
    ),
    new ListTile(
      title: Text('data',style: new TextStyle(fontWeight: FontWeight.w400,fontSize: 18.0),),
      subtitle: Text('data'),
      leading: Icon(Icons.fastfood,color: Colors.blue,),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(
          title: Text('data'),
        ),
        body: new Center(
          child: new ListView(
            children: list,
          )
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/52.png" width = "25%" height = "25%"/>

#### GridView
代码参考**常用组件**

#### Table

### 其他布局处理

#### Transform(矩阵转换)

`Transform` 主要作用就是做矩阵转换。对组件进行平移、旋转和缩放的等操作。

|属性|类型|描述|
| --- | --- | --- |
|transform|Matrix4|一个4x4的矩阵。|
|origin|Offset|旋转点，相对于左上角顶点的偏移。默认旋转点是在左上角顶点|
|alignment|AlignmentGeometry|对齐方式|
|transformHitTests|bool|点击区域石佛业做相应的改变|

#### Baseline(基准线布局)

`Baseline` 将左右元素底部放到同一条水平线上。

<img src="/assets/images/flutter/54.png"/>

|属性|类型|描述|
| --- | --- | --- |
|baseline|double||
|baselineType|TextBaseLine|baseline类型：<br> `alphabetic`：对齐字符底部的水平线。<br> `ideographic`：对齐表意字符串的水平线。|

#### Offstage(控制是否显示组件)

`Offstage` 通过参数来控制child是否显示。

|属性|类型|默认值|描述|
| --- | --- | --- |--- |
|offstage|bool|true|true：不显示|

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = "Offstage 控制是否展示组件示例";
    return new MaterialApp(
      title: 'Demo',
      home: new MyHomePage(title: appTitle,),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  _MyHomePage createState() => _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  bool offstage = true;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Offstage(
          offstage: offstage,
          child: new Text(
            'Show Stage',
            style: TextStyle(fontSize: 36.0),
          ),
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          setState(() {
            offstage = !offstage;
          });
        },
        child: new Icon(Icons.flip),
      ),
    );
  }
}
```
<img src="/assets/images/flutter/55.gif"/>

#### Wrap(按宽高自动换行布局)

`Wrap` 使用了`Flex`中的一些概念，某种意义上和`Row`、`Column`更加相似。单行的`Wrap`和`Row`表现几乎一致，单列的`Wrap`和`Column`表现几乎一致。`Wrap`是在主轴上空间不足时，则向次轴上去扩展显示。

|属性|类型|默认值|描述|
| --- | --- | --- | --- |
|direction|Axis|Axis.horizontal|主轴(mainAxis)的方向,默认为水平|
|alignment|WrapAlignment||主轴方向上的对齐方式,默认为start|
|spacing|double|0.0|主轴方向上的间距|
|runAlignment| WrapAlignment| wrapAlignment.start|run的对齐方式。run可以理解为新的行或者列,如果是水平方向布局的话,run可以理解为新的一行|
|runSpacing|double|0.0|run的间距|
|crossAxisAlignment| WrapCrossAlignment wrapCrossAlignment.start|主轴(crossAxis)方向上的对齐方式|
|textDirecfion|TextDirection||文本方向|
|verticalDirection| VerticalDirection|定义了children摆放顺序,默认是down|

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
          title: new Text('Demo'),
        ),
        body: Wrap(
          spacing: 8.0, //主轴间距
          runSpacing: 4.0, // 行间距【默认水平排序】
          children: <Widget>[
            Chip(
              label: new Text('data'),
              avatar: CircleAvatar(
                backgroundColor: Colors.lightGreen.shade800,
                child: new Text(
                  'data',
                  style: new TextStyle(fontSize: 10.0),
                ),
              ),
            ),
            Chip(
              label: new Text('datadata'),
              avatar: CircleAvatar(
                backgroundColor: Colors.lightGreen.shade800,
                child: new Text(
                  'datadata',
                  style: new TextStyle(fontSize: 10.0),
                ),
              ),
            ),
            Chip(
              label: new Text('datadatadatadata'),
              avatar: CircleAvatar(
                backgroundColor: Colors.lightGreen.shade800,
                child: new Text(
                  'datadatadatadata',
                  style: new TextStyle(fontSize: 10.0),
                ),
              ),
            ),
            Chip(
              label: new Text('datadatadatadataadatadata'),
              avatar: CircleAvatar(
                backgroundColor: Colors.lightGreen.shade800,
                child: new Text(
                  'datadatadatadataadatadata',
                  style: new TextStyle(fontSize: 10.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/56.png" width = "50%" height = "50%"/>

### 布局综合示例

```dart
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 风景区地址部分
    Widget addressContainer = Container(
      padding: EdgeInsets.all(32.0), //容器四周的间距
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // 默认居中，设置 start 让 children 居左
              children: <Widget>[
                Container(
                  child: Text('风景区地址'),
                  padding: const EdgeInsets.only(bottom: 8.0), // 与下面文本间隔8.0
                ),
                Text('地址地址地址地址地址地址地址地址')
              ],
            ),
          ),
          Icon(
            Icons.star,
            color: Colors.red,
          ),
          Text('66'),
        ],
      ),
    );

    // 按钮部分
    // 构建单个按钮
    Column buildButtonCloumn(IconData icon, String label) {
      return Column(
        mainAxisSize: MainAxisSize.min, // 垂直方向大小最小化
        mainAxisAlignment: MainAxisAlignment.center, // 垂直方向居中对齐
        children: <Widget>[
          Icon(
            icon,
            color: Colors.lightGreen[600],
          ),
          Container(
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.lightGreen[600]),
            ),
            margin: const EdgeInsets.only(top: 8.0),
          ),
        ],
      );
    }

    // 按钮数组
    Widget buttonsContainer = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 水平方向居云排列每个元素
        children: <Widget>[
          buildButtonCloumn(Icons.call, '电话'),
          buildButtonCloumn(Icons.near_me, '导航'),
          buildButtonCloumn(Icons.share, '分享'),
        ],
      ),
    );

    // 风景区介绍文字部分
    Widget textContainer = Container(
      padding: const EdgeInsets.all(32.0),
      child: Text(
        '''
        各位好：
        积分商城首页、兑换记录、积分、兑换公告、商品详情页、兑换确认页、配送地址、
        新增收货地址等积分商城相关页面的暗黑模式高保真已输出并上传至蓝湖，请前往查看，如有问题随时沟通，谢谢！
        另外，邀请邻居页面颜色特殊，在高亮模式和暗黑模式下颜色保持一致，故没输出高保真。
        ''',
        softWrap: true,
      ),
    );

    return new MaterialApp(
      title: 'Demo',
      home: new Scaffold(
        appBar: new AppBar(),
        body: ListView(
          children: <Widget>[
            Image.asset(
              'icons/code.png',
              width: 600.0,
              height: 240.0,
              fit: BoxFit.cover,
            ),
            addressContainer,
            buttonsContainer,
            textContainer
          ],
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/57.png"/>

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

移动应用通常通过`屏幕`或者`页面`的全屏元素显示其内容，在Flutter中，这些元素被称为**路由**。他们由导航器`Navigator`组件管理。`Navigator`管理一组路由`Route`对象，并且提供了管理堆栈的方法。

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

### Clip(剪裁处理)

`Clip`作用把一个组件剪掉一部分。

* `ClipOval`: 圆角剪裁
* `ClipRRect`: 圆角矩形剪裁
* `ClipRect`: 矩形剪裁
* `ClipPath`: 路径剪裁

|属性|类型|描述|
| --- | --- | --- |
|clipper|`CustomClipper<Path>`|剪裁路径，比如椭圆，矩形等等|
|clipBehavior|Clip|裁剪方式|

### ClipOval

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

### ClipRRect

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

### ClipRect

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
  Rect getClip(Size size) { // 获取剪裁范围
    return new Rect.fromLTRB(100.0, 100.0, size.width - 100.0, size.height - 100.0);
  }
  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) { //是否重新剪裁
    return true;
  }
}
```

<img src="/assets/images/flutter/62.png" width = "25%" height = "25%"/>

### ClipPath

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

## 动画

### AnimatedOpacity 实现渐变效果

|属性|类型|描述|
| --- | --- | --- |
|opacity|double|透明度|
|child|Widget||

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Demo',
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePage createState() => new _MyHomePage();
}

class _MyHomePage extends State<MyHomePage> {
  bool _visible = true;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('data'),
      ),
      body: new AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.0,
        duration: new Duration(
          milliseconds: 1000,
        ),
        child: new Container(
          width: 300.0,
          height: 300.0,
          color: Colors.red,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _visible = !_visible;
          });
        },
        child: new Icon(Icons.flip),
      ),
    );
  }
}
```

### 用Hero实现页面切换动画

如果页面切换时有时需要增加点动画，这样可以增加应用的体验。在页面元素中添加`Hero`组件，就会自带一种过渡的动画效果。

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


* `flutter_webview_plugin`: 移动端浏览网页的插件
* `date_formate` ： 日期格式化插件

### 项目搭建

[iconfont](https://www.iconfont.cn)






```sh
PUB_HOSTED_URL ===== https://pub.flutter-io.cn
FLUTTER_STORAGE_BASE_URL ===== https://storage.flutter-io.cn
```


























