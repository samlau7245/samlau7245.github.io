---
title: 给 iOS 开发者的 Flutter 指南 
description: building...
layout: post
categories:
 - flutter
---

* [flutter example](https://gitee.com/BackEndLearning/flutter_example)
* [Material核心widget](https://flutter.cn/docs/development/ui/widgets/material)

# [APP 结构和导航](https://flutter.cn/docs/development/ui/widgets/material#App%20structure%20and%20navigation)

## [MaterialApp](https://api.flutter.dev/flutter/material/MaterialApp-class.html)

* [Flutter之MaterialApp使用详解](https://www.jianshu.com/p/1d44ae246652)

### 基础属性

```dart
final String title; // 设备用于为用户识别应用程序的单行描述
final Color color; // 在操作系统界面中应用程序使用的主色。
final ThemeData theme; // 应用程序小部件(`Widget`)使用的颜色。
final GenerateAppTitle onGenerateTitle; // 如果非空，则调用此回调函数来生成应用程序的标题字符串，否则使用标题。

final Locale locale; // 此应用程序本地化小部件(`Widget`)的初始区域设置基于此值。
final Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates; // 这个应用程序本地化小部件(`Widget`)的委托
final LocaleListResolutionCallback localeListResolutionCallback; // 这个回调负责在应用程序启动时以及用户更改设备的区域设置时选择应用程序的区域设置。
final LocaleResolutionCallback localeResolutionCallback;
final Iterable<Locale> supportedLocales; // 此应用程序已本地化的地区列表 
```

* `theme`

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(title: Text('data'),),
        body: Center(child: Text('data'),),
      ),
      theme: ThemeData(primaryColor: Colors.red),
    );
  }
}
```


### 导航栏相关

```dart
final TransitionBuilder builder; // 用于在导航器上面插入小部件(`Widget`)，但在由WidgetsApp小部件(`Widget`)创建的其他小部件(`Widget`)下面插入小部件(`Widget`)，或用于完全替换导航器
final GlobalKey<NavigatorState> navigatorKey; // 在构建导航器时使用的键。
final List<NavigatorObserver> navigatorObservers; // 为该应用程序创建的导航器的观察者列表
```

### 页面路径

* `MaterialApp`中同时指定了`home`、`routes`，则在`routes`中不能包含`'/'`。

```dart
final Widget home; // 应用默认所显示的界面 Widget
final Map<String, WidgetBuilder> routes; // 应用的顶级导航表格，这个是多页面应用用来控制页面跳转的，类似于网页的网址
final String initialRoute; // 第一个显示的路由名字，默认值为 Window.defaultRouteName
inal RouteFactory onGenerateRoute; // 应用程序导航到指定路由时使用的路由生成器回调
final RouteFactory onUnknownRoute;  // 当 onGenerateRoute 无法生成路由(initialRoute除外)时调用
```

* `home`示例

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: SecondScreen(),
    );
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("First Bar"),
      ),
      body: Center(child: Text("First Body"),),
    );
  }
}

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SecondScreen Bar"),
      ),
      body: Center(child: Text("SecondScreen Body"),),
    );
  }
}
```

* `onGenerateRoute`


[查看代码](https://gitee.com/BackEndLearning/flutter_example/commit/1d44740e16ba21dbbda8d7f225a959c6428a8470)

* 使用`initialRoute`、`routes`来代替`home`

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      routes: <String, WidgetBuilder> {
        'first': (BuildContext context){
          return FirstScreen();
        },
        'second': (BuildContext context){
          return SecondScreen();
        }
      },
      initialRoute: 'second',
    );
  }
}
```

[查看代码](https://gitee.com/BackEndLearning/flutter_example/commit/c7b12b9979001737527711ed8d2c188d2ad5eed4)

### 代码调试属性

```dart
final bool debugShowMaterialGrid; // 打开绘制基线网格材质应用程序的网格纸覆盖
final bool showPerformanceOverlay; // 打开性能叠加
final bool checkerboardRasterCacheImages; // 打开栅格缓存图像的棋盘格
final bool checkerboardOffscreenLayers; // 打开渲染到屏幕外位图的图层的棋盘格
final bool showSemanticsDebugger; // 打开显示框架报告的可访问性信息的覆盖
final bool debugShowCheckedModeBanner; // 在选中模式下打开一个小的“DEBUG”横幅，表示应用程序处于选中模式
```

## [WidgetsApp](https://api.flutter.dev/flutter/widgets/WidgetsApp-class.html)

`MaterialApp`和`WidgetsApp`对比，各自特有的字段：

```dart
WidgetsApp({
    this.pageRouteBuilder,
    this.textStyle, // 应用中的文本使用的默认样式
    this.debugShowWidgetInspector = false, // 调试小部件检测
    this.inspectorSelectButtonBuilder, // 审查员选择按钮生成器
})

const MaterialApp({
    this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
    this.debugShowMaterialGrid = false,
})
```

## [Scaffold](https://api.flutter.dev/flutter/material/Scaffold-class.html)

`Scaffold` 翻译过就是脚手架的意思，它实现了`Material Design`可视化布局结构。

```dart
  const Scaffold({
    Key key,
    this.appBar, // 标题栏
    this.body, // 用于显示当前界面主要内容的Widget
    this.floatingActionButton, // 一个悬浮在body上的按钮，默认显示在右下角
    this.floatingActionButtonLocation, // 用于设置floatingActionButton显示的位置
    this.floatingActionButtonAnimator, // floatingActionButton移动到一个新的位置时的动画
    this.persistentFooterButtons, // 多状态按钮
    this.drawer, // 左侧的抽屉菜单
    this.endDrawer, //  右侧的抽屉菜单
    this.bottomNavigationBar, // 底部导航栏
    this.bottomSheet, // 显示在底部的工具栏
    this.backgroundColor, // 内容的背景颜色
    this.resizeToAvoidBottomPadding, // 控制界面内容 body 是否重新布局来避免底部被覆盖，比如当键盘显示的时候，重新布局避免被键盘盖住内容。
    this.resizeToAvoidBottomInset, 
    this.primary = true, // Scaffold是否显示在页面的顶部
    this.drawerDragStartBehavior = DragStartBehavior.start,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.drawerScrimColor,
    this.drawerEdgeDragWidth,
  })
```

简单的示例，具体属性的使用会单独说明：

```dart
void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('data'),
        ),
        body: Center(
          child: Text('data'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Text('点击'),
          tooltip: 'test',
        ),
        drawer: Drawer(
          child: Text('data'),
        ),
        endDrawer: Drawer(
          child: Text('data'),
        ),
      ),
    );
  }
}
```

## BottomNavigationBar. 

`MaterialApp`中要实现底部导航栏的功能，需要了解的类[BottomNavigationBar](https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html#instance-properties)、[BottomNavigationBarItem](https://api.flutter.dev/flutter/widgets/BottomNavigationBarItem-class.html#instance-properties)。其中`BottomNavigationBar`类是和`Scaffold`结合使用。

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: MyStatefulWidget(),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  @override
  _MyStatefulWidgetState createState() {
    return _MyStatefulWidgetState();
  }
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  // items 数组，设置底部Tab
  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      title: Text('Home'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.business),
      title: Text('Business'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.school),
      title: Text('School'),
    ),
  ];

  // onTap
  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index; // 点击不用Tab时，更新下标
    });
  }

  // 当前tab下标
  int _currentIndex = 0;

  // 点击不同的Tab时，在街面上展示不同的文本
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BottomNavigationBar Sample'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_currentIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: items,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        currentIndex: _currentIndex,
      ),
    );
  }
}
```

[查看代码](https://gitee.com/BackEndLearning/flutter_example/commit/6906c7e837e38c5662d9b3e30067d70514549423)

## [AppBar](https://api.flutter.dev/flutter/material/AppBar-class.html)

`AppBar`是一个顶端栏。

![有帮助的截图](/assets/images/flutter/01.png)

```dart
AppBar({
  Key key,
  this.leading, // 在首页通常显示应用的 logo；在其他界面通常显示为返回按钮。
  this.automaticallyImplyLeading = true,
  this.title, // 通常显示为当前界面的标题文字
  this.actions, // 常用的菜单
  this.flexibleSpace, // 一个显示在 AppBar 下方的控件, 该属性通常在 SliverAppBar 中使用
  this.bottom, // 通常是 TabBar,用来在Toolbar标题下面显示一个Tab导航栏。
  this.elevation, // 控件的 z 坐标顺序，默认值为 4
  this.shape,
  this.backgroundColor, // Appbar 的颜色，默认值为 ThemeData.primaryColor
  this.brightness, // Appbar 的亮度 有白色和黑色两种主题，默认值为 ThemeData.primaryColorBrightness
  this.iconTheme, // Appbar 上图标的颜色、透明度、和尺寸信息。默认值为 ThemeData.primaryIconTheme。
  this.actionsIconTheme,
  this.textTheme, // Appbar 上的文字样式
  this.primary = true,
  this.centerTitle, // 标题是否居中显示，默认值根据不同的操作系统，显示方式不一样。
  this.titleSpacing = NavigationToolbar.kMiddleSpacing,
  this.toolbarOpacity = 1.0,
  this.bottomOpacity = 1.0,
})
```

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
          appBar: AppBar(
            title: new Text('data'),
            leading: new Icon(Icons.home),
            backgroundColor: Colors.blue,
            centerTitle: true,
            actions: <Widget>[
              new IconButton(
                icon: new Icon(Icons.add_a_photo),
                onPressed: () {},
              ),
              new IconButton(
                icon: new Icon(Icons.add_alarm),
                onPressed: () {},
              ),
              new PopupMenuButton<String>(
                itemBuilder: (BuildContext context) {
                  return <PopupMenuItem<String>>[
                    this.SelectView(Icons.message, '发起群聊', 'A'),
                    this.SelectView(Icons.group_add, '添加服务', 'B'),
                    this.SelectView(Icons.cast_connected, '扫一扫码', 'C'),
                  ];
                },
                onSelected: (String action) {
                  switch (action) {
                    case 'A':
                      break;
                    case 'B':
                      break;
                    case 'C':
                      break;
                  }
                },
              )
            ],
          ),
          body: Center(
            child: Text('data'),
          )),
    );
  }

  SelectView(IconData icon, String text, String id) {
    return new PopupMenuItem<String>(
        value: id,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Icon(icon, color: Colors.blue),
            new Text(text),
          ],
        ));
  }
}
```

[示例代码1：action：展示隐藏popmenu](https://gitee.com/BackEndLearning/flutter_example/commit/1de918e148ca129d62e03be546a2316b7d7e2791) <br>
[示例代码2：action：push到下一个页面](https://gitee.com/BackEndLearning/flutter_example/commit/73b16fb839ff453fce476fbc92f8bfa35b3a34eb)

## [TabBar](https://api.flutter.dev/flutter/material/TabBar-class.html)、[TabBarView](https://api.flutter.dev/flutter/material/TabBarView-class.html)、[TabController](https://api.flutter.dev/flutter/material/TabController-class.html)

```dart
const TabBar({
  Key key,
  @required this.tabs, //显示的标签内容，一般使用Tab对象,也可以是其他的Widget
  this.controller, //TabController对象
  this.isScrollable = false, //是否可滚动
  this.indicatorColor, //指示器颜色
  this.indicatorWeight = 2.0, //指示器高度
  this.indicatorPadding = EdgeInsets.zero, //底部指示器的Padding
  this.indicator, //指示器decoration，例如边框等
  this.indicatorSize, //指示器大小计算方式，TabBarIndicatorSize.label跟文字等宽,TabBarIndicatorSize.tab跟每个tab等宽
  this.labelColor, //选中label颜色
  this.labelStyle, //选中label的Style
  this.labelPadding, //每个label的padding值
  this.unselectedLabelColor, //未选中label颜色
  this.unselectedLabelStyle, //未选中label的Style
  this.dragStartBehavior = DragStartBehavior.start,
  this.onTap,
})

TabController({ 
  int initialIndex = 0, 
  @required this.length, // tab总数
  @required TickerProvider vsync 
})

const DefaultTabController({
  Key key,
  @required this.length, // tab总数
  this.initialIndex = 0,
  @required this.child,
})

const TabBarView({
  Key key,
  @required this.children,
  this.controller,
  this.physics,
  this.dragStartBehavior = DragStartBehavior.start,
})
```
一个`stateful widget`的`TabBar`或`TabBarView`可以创建一个`TabController`，并且可以直接共享它。

```dart
import 'package:flutter/material.dart';
void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Code Sample',
      home: MyTabbedPage(),
    );
  }
}
//  创建一个 stateful widget
class MyTabbedPage extends StatefulWidget {
  const MyTabbedPage({ Key key }) : super(key: key);
  @override
  _MyTabbedPageState createState() => _MyTabbedPageState();
}

class _MyTabbedPageState extends State<MyTabbedPage> with SingleTickerProviderStateMixin {
  // 创建Tab 数组
  final List<Tab> myTabs = <Tab>[Tab(text: 'LEFT'),Tab(text: 'RIGHT',icon: Icon(Icons.add_alert),)];
  TabController _tabController;

  @override
  void initState() { //初始化State
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
  }

 @override
 void dispose() { //从tree中彻底销毁对象时调用
   _tabController.dispose();
   super.dispose();
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar( // 创建TabBar
          controller: _tabController, // 关联TabController
          tabs: myTabs, // 关联Tab
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: myTabs.map((Tab tab) {
          final String label = tab.text.toLowerCase();
          return Center(
            child: Text(
              'This is the $label tab',
              style: const TextStyle(fontSize: 36),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

[查看代码](https://gitee.com/BackEndLearning/flutter_example/commit/f629f06f8dbd7eb9c142ff63546e3b7adabbfc53)，[执行效果](https://flutter.github.io/assets-for-api-docs/assets/material/tabs.mp4)

# [按钮类](https://flutter.cn/docs/development/ui/widgets/material#Buttons)

## [ButtonBar](https://api.flutter.dev/flutter/material/ButtonBar-class.html)

这是个布局组件，可以让Button排列展示。

```dart
const ButtonBar({
  Key key,
  this.alignment,
  this.mainAxisSize,
  this.buttonTextTheme,
  this.buttonMinWidth,
  this.buttonHeight,
  this.buttonPadding,
  this.buttonAlignedDropdown,
  this.layoutBehavior,
  this.children = const <Widget>[], 
})
```

```dart
import 'package:flutter/material.dart';
void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Code Sample',
      home: Scaffold(
        appBar: AppBar(
          title: Text('title'),
        ),
        body: Center(
          child: ButtonBar(children: <Widget>[
            CloseButton(),
            BackButton()
          ],
          alignment: MainAxisAlignment.spaceBetween,)
        ),
      ),
    );
  }
}
```

## [RaisedButton](https://api.flutter.dev/flutter/material/RaisedButton-class.html)

是一个 `Materia` 风格的按钮。

```dart
const RaisedButton({
  Key key,
  @required VoidCallback onPressed,
  VoidCallback onLongPress,
  ValueChanged<bool> onHighlightChanged,
  ButtonTextTheme textTheme,
  Color textColor,
  Color disabledTextColor,
  Color color,
  Color disabledColor,
  Color focusColor,
  Color hoverColor,
  Color highlightColor,
  Color splashColor,
  Brightness colorBrightness,
  double elevation,
  double focusElevation,
  double hoverElevation,
  double highlightElevation,
  double disabledElevation,
  EdgeInsetsGeometry padding,
  ShapeBorder shape,
  Clip clipBehavior = Clip.none,
  FocusNode focusNode,
  bool autofocus = false,
  MaterialTapTargetSize materialTapTargetSize,
  Duration animationDuration,
  Widget child,
})
```

## [DropdownButton](https://api.flutter.dev/flutter/material/DropdownButton-class.html)

```dart
DropdownButton({
  Key key,
  @required this.items,
  this.selectedItemBuilder,
  this.value, // 展示的文本
  this.hint,
  this.disabledHint,
  @required <th></th>is.onChanged,
  this.elevation = 8,
  this.style,
  this.underline, // 控件下划线

  this.icon, // 展示的icon
  this.iconDisabledColor,
  this.iconEnabledColor,
  this.iconSize = 24.0,

  this.isDense = false,
  this.isExpanded = false,
  this.itemHeight = kMinInteractiveDimension,
  this.focusColor,
  this.focusNode,
  this.autofocus = false,
})
```

```dart
void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: Center(
          child: MyStatefulWidget(),
        ),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  MyStatefulWidget({Key key}) : super(key: key);
  @override
  _MyStatefulWidgetState createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  String dropdownValue = 'One';
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue, 
      icon: Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        setState(() { //更新数据状态
          dropdownValue = newValue;
        });
      },
      items: <String>['One', 'Two', 'Free', 'Four']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
```

[示例代码](https://gitee.com/BackEndLearning/flutter_example/commit/6efbe1501b432fc6b368e8a34e8911ed07703116)、[示例效果图](https://flutter.github.io/assets-for-api-docs/assets/material/dropdown_button.png)

## [FlatButton](https://api.flutter.dev/flutter/material/FlatButton-class.html)

`FlatButton`与`MaterialButton`类似，不同的是它是透明背景的。如果一个`Container`想要点击事件时，可以使用`FlatButton`包裹，而不是`MaterialButton`。因为`MaterialButton`默认带背景，而 `FlatButton`默认不带背景。

```dart
import 'package:flutter/material.dart';
void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Flutter Code Sample,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: Center(
          child: FlatButton(child: Text('Click Me'), onPressed: () {},)
        ),
      ),
    );
  }
}
```

## [FloatingActionButton](https://api.flutter.dev/flutter/material/FloatingActionButton-class.html)

`FloatingActionButton`有`regular`, `mini`, `extended`三种类型：`this.mini = false`:`regular`，`this.mini = true`:`mini`，`extended`需要通过`FloatingActionButton.extended()`创建。

```dart
const FloatingActionButton({
  Key key,
  this.child, //按钮显示的内容
  this.tooltip, //长按时显示的提示
  this.foregroundColor, //前景色，影响到文字颜色
  this.backgroundColor, //背景色
  this.focusColor,
  this.hoverColor,
  this.splashColor,
  this.heroTag = const _DefaultHeroTag(),
  this.elevation, //未点击时阴影值
  this.focusElevation,
  this.hoverElevation,
  this.highlightElevation, //点击下阴影值
  this.disabledElevation,
  @required this.onPressed,
  this.mini = false,
  this.shape,
  this.clipBehavior = Clip.none,
  this.focusNode,
  this.autofocus = false,
  this.materialTapTargetSize,
  this.isExtended = false, //是否为”extended”类型
})

// FloatingActionButton.extended 比 FloatingActionButton 多出来的字段：
FloatingActionButton.extended({
  Widget icon,
  @required Widget label,
})
```

在`Scaffold`中可以设置FAB相关的字段:

```dart
const Scaffold({
  Key key,
  this.floatingActionButton, // 一个悬浮在body上的按钮，默认显示在右下角
  this.floatingActionButtonLocation, // 用于设置floatingActionButton显示的位置
  this.floatingActionButtonAnimator, // floatingActionButton移动到一个新的位置时的动画
})

其中floatingActionButtonLocation：
FloatingActionButtonLocation.centerDocked：居中对齐，浮动在Scaffold.bottomNavigationBar上方，会遮住bottomNavigationBar
FloatingActionButtonLocation.centerFloat：居中，浮动在屏幕底部。浮动在Scaffold.bottomNavigationBar上方，不会遮住bottomNavigationBar
FloatingActionButtonLocation.endDocked：右端对齐，浮动在屏幕底部，浮动在Scaffold.bottomNavigationBar上方 会遮住bottomNavigationBar。
FloatingActionButtonLocation.endFloat：右端对齐，浮动在屏幕底部，浮动在Scaffold.bottomNavigationBar上方 不会遮住bottomNavigationBar。
FloatingActionButtonLocation.endTop：右端对齐，浮动在Scaffold.appBar和Scaffold.body之间的过渡上
FloatingActionButtonLocation.miniStartTop：左端对齐，在Scaffold.appBar和Scaffold.body之间的过渡上浮动
FloatingActionButtonLocation.startTop：左端对齐，在Scaffold.appBar和Scaffold.body之间的过渡上浮动

```

```dart
import 'package:flutter/material.dart';
void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'title',
      home: Scaffold(
        appBar: AppBar(title: Text('data')),
        body: Center(
          child: Text('data'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          label: Text('Approve'),
          icon: Icon(Icons.thumb_up),
          backgroundColor: Colors.pink,
          tooltip: 'long press',
        ),
      ),
    );
  }
}
```

[查看代码](https://gitee.com/BackEndLearning/flutter_example/commit/5bbb59f2cd06424af9016fd3963b2479e27bd848)

## [IconButton](https://api.flutter.dev/flutter/material/IconButton-class.html)

[查看所有`icon`的样式](https://api.flutter.dev/flutter/material/Icons-class.html)

## [PopupMenuButton](https://api.flutter.dev/flutter/material/PopupMenuButton-class.html)













