---
title: Material Design 风格组件
layout: post
categories:
 - dart
---

* [Material Design 风格组件](https://api.flutter.dev/flutter/material/MaterialApp-class.html)

`Material Design` 是由Google推出的全新设计语言。

## MaterialApp(应用组件)
`MaterialApp`代表使用纸墨设计风格的应用，里面包含了及其所需要的基本控件。一个完整的Flutter项目就是从`MaterialApp`这个组件开始的。

|属性|类型|说明|
| --- | --- | --- |
|title|String|应用程序的标题：iOS->程序切换管理器中，Android->任务管理器的程序快照上|
|theme|[ThemeData](https://api.flutter.dev/flutter/material/ThemeData-class.html)|应用使用的主题色，可以全局也可以局部设置|
|color|Color|应用的主题色：`primary color`|
|home|Widget|Widget对象，用来定义当前应用打开时所显示的界面|
|routes|Map<String,WidgetBuilder>|应用中页面跳转规则|
|initialRoute|String|初始化路由|
|onGenerateRoute|RouteFactory|路由回调函数。当通过`Navigator.of(context).pushNamed`跳转路由时，在`routes`查找不到时，会调用该方法|
|onLocalChanged||当系统修改语言的时候,会触发这个回调|
|navigatorObservers|List<NavigatorObserver>|航观察器|
|debugShowMaterialGrid|bool|是否显示纸墨设计基础布局网格,用来调试UI的工具|
|showPerformanceOverlay|bool|显示性能标签|

### 设置主页面

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

### 处理路由
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

### 自定义主题
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

## ThemeData(主题)

|属性|类型|说明|
| --- | --- | --- |
|primaryColor|Color|主题色|

## Scaffold(脚手架组件)
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

## AppBar(应用按钮组件)
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

## BtoomNavigationBar(底部导航栏组件)
`BtoomNavigationBar` 显示在应用页面的底部的工具栏。

|属性|类型|说明|
| --- | --- | --- |
|currentIndex|int|当前索引|
|fixedColor|||
|iconColor|||
|items|`List<BtoomNavigationBarItem>`|底部导航栏按钮集合|
|onTap|`ValueChanged<int>`|按下其中某个按钮的回调事件。需要根据返回的索引设置当前索引|

<img src="/assets/images/flutter/16.png" width = "25%" height = "25%"/>

## TabBar(水平选项卡及视图组件)
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

## Drawer(抽屉组件)

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
## FloatingActionButton(悬停按钮组件)

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

## FlatButton(扁平按钮组件)
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

## PopupMenuButton(弹出菜单组件)

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

## SimpleDialog(简单对话框组件)

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

## AlertDialog(提示对话框组件)

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

## SnackBar(轻量提示组件)

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

## TextField(文本框组件)

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

## Card(卡片组件)
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
