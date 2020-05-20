---
title: Flutter(3)： Material Design 风格组件
layout: post
categories:
 - dart
---

## 参考资料
* [Material Design guidelines](https://material.io/guidelines/material-design/introduction.html)










<!-- ==================================================================================================== -->










## [MaterialApp(应用组件)](https://api.flutter.dev/flutter/material/MaterialApp-class.html)

|属性|类型|说明|
| --- | --- | --- |
|title|String|应用程序的标题：<br>iOS->程序切换管理器中<br>Android->任务管理器的程序快照上|
|theme|[ThemeData](https://api.flutter.dev/flutter/material/ThemeData-class.html)|应用使用的主题色，可以全局也可以局部设置|
|color|[Color](https://api.flutter.dev/flutter/dart-ui/Color-class.html)|应用的主题色：`primary color`|
|home|Widget|用来定义当前应用打开时,所显示的界面|
|routes|Map<String,WidgetBuilder>|应用中页面跳转规则|
|initialRoute|String|初始化路由|
|onGenerateRoute|[RouteFactory](https://api.flutter.dev/flutter/widgets/RouteFactory.html)|路由回调函数。当通过`Navigator.of(context).pushNamed`跳转路由时，在`routes`查找不到时，会调用该方法|
|onLocalChanged||当系统修改语言的时候,会触发这个回调|
|navigatorObservers|`List<NavigatorObserver>`|导航观察器|
|debugShowMaterialGrid|bool|是否显示纸墨设计基础布局网格,用来调试UI的工具|
|showPerformanceOverlay|bool|显示性能标签|

`MaterialApp`中`Navigator`寻找页面的顺序:

* For the `/` route, the `home` property, if non-null, is used.
* Otherwise, the `routes` table is used, if it has an entry for the route.
* Otherwise, `onGenerateRoute` is called, if provided. It should return a non-null value for any valid route not handled by home and routes.
* Finally if all else fails `onUnknownRoute` is called.

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MaterialApp Demo",
      theme: ThemeData(primaryColor: Colors.blue),
      color: Colors.orange,
      home: HomePage(),
      routes: {
        "/first": (_) => FirstPage(),
        "/second": (_) => SecondPage(),
        "/thirs": (_) => ThirdPage(),
      },
    );
  }
}

// 等效于：

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MaterialApp Demo",
      theme: ThemeData(primaryColor: Colors.blue),
      color: Colors.orange,
      routes: {
        "/": (_) => HomePage(),
        "/first": (_) => FirstPage(),
        "/second": (_) => SecondPage(),
        "/thirs": (_) => ThirdPage(),
      },
      initialRoute: '/',
    );
  }
}
```

下面是示例，具体效果查看[CodePen](https://codepen.io/samlau7245/pen/jObpgKo)

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MaterialApp Demo",
      theme: ThemeData(primaryColor: Colors.blue),
      color: Colors.orange,
      home: HomePage(),
      routes: {
        "/first": (_) => FirstPage(),
        "/second": (_) => SecondPage(),
        "/thirs": (_) => ThirdPage(),
      },
      onGenerateRoute: (RouteSettings settings) {
        // 路由回调函数。当通过`Navigator.of(context).pushNamed`跳转路由时，在`routes`查找不到时，会调用该方法
        print(settings.name + settings.arguments);
        return null;
      },
    );
  }
}

////////////////////////////////////////////////////////////////////////

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Center(child: Text('Home')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/first');
        },
        child: Text('Push'),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////

class FirstPage extends StatefulWidget {
  @override
  _FirstPage createState() => new _FirstPage();
}

class _FirstPage extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("First Page"),
      ),
      body: Center(child: Text('First')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.popAndPushNamed(context, '/second');
          }
        },
        child: Text('Pop'),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////

class SecondPage extends StatefulWidget {
  @override
  _SecondPage createState() => new _SecondPage();
}

class _SecondPage extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Second Page"),
      ),
      body: Center(child: Text('Second')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute<void>(builder: (_) {
            return Scaffold(
              appBar: AppBar(
                title: Text('MaterialPageRoute Demo'),
              ),
              body: Center(
                child: Text("MaterialPageRoute Demo"),
              ),
            );
          }));
        },
        child: Text('Push'),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////

class ThirdPage extends StatefulWidget {
  @override
  _ThirdPage createState() => new _ThirdPage();
}

class _ThirdPage extends State<ThirdPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Third Page"),
      ),
      body: Center(child: Text('Third')),
    );
  }
}
```










<!-- ==================================================================================================== -->










## [Scaffold(脚手架组件)](https://api.flutter.dev/flutter/material/Scaffold-class.html)

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

示例代码：[codePen](https://codepen.io/samlau7245/pen/XWmPrZe)

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MaterialApp Demo",
      theme: ThemeData(primaryColor: Color(0xFF37966F)),
      color: Colors.orange,
      home: HomePage(),
    );
  }
}

////////////////////////////////////////////////////////////////////////

class HomePage extends StatefulWidget {
  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 头部元素
      appBar: AppBar(title: Text("Home Page")),
      // 视图部份
      body: Center(child: Text('Home')),
      // 抽屉
      drawer: Drawer(),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: Color(0xFF37966F),
        child: Container(
          height: 50.0,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Color(0xFF37966F),
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
```

* [关于`Scaffold.of() called with a context that does not contain a Scaffold.`的报错解决方案](https://stackoverflow.com/questions/51304568/scaffold-of-called-with-a-context-that-does-not-contain-a-scaffold)










<!-- ==================================================================================================== -->










## [AppBar(应用按钮组件)](https://api.flutter.dev/flutter/material/AppBar-class.html)

* [Appbar(应用按钮组件)](https://api.flutter.dev/flutter/material/AppBar-class.html)
* [SliverAppBar(应用按钮组件)](https://api.flutter.dev/flutter/material/SliverAppBar-class.html)

应用按钮组件有`AppBar`、`SliverAppBar`，都是继承子`StatefulWidget`类。区别在于`AppBar`固定在顶部，`SliverAppBar`可以跟着内容进行滚动。

```dart
class AppBar extends StatefulWidget implements PreferredSizeWidget{}
class SliverAppBar extends StatefulWidget{}
```

<img src="/assets/images/flutter/14.png"/>

|AppBar 属性|类型|默认值|说明|
| --- | --- | --- |--- |
|leading|Widget|null|在标题前显示的一个组件，在首页通常显示为应用的logo，在其他页面通常显示为返回按钮|
|title|Widget|null|标题|
|actions|List<Widget>|null|一个`Widget`列表。代表Toolbar中所展示的菜单。对于常用的菜单，通常使用`IconButton`来表示，对于不常用的菜单使用`PopupMenuButton`来显示为三个点，点击后弹出二级菜单|
|bottom|PreferredSizeWidget|null|通常是`TabBar`。用来在ToolBar标题下展示菜单|
|elevation|double|4|z坐标顺序，对于可滚动的`SliverAppBar`，当`SliverAppBar`和内容同级的时候，改值为0，当内容滚动`SliverAppBar`变为`ToolBar`的时候，修改elevation的值|
|flexibleSpace|Widget|null|一个显示在`AppBar`下方的组件，高度和`AppBar`高度一样，可以实现一些特殊效果，通常在`SliverAppBar`中使用|
|backgroundColor|Color|ThemeData.primaryColor|背景色|
|brightness|Brightness|ThemeData.primaryColorBrightness|`AppBar`的亮度，有白色、黑色两种主题|
|iconTheme|IconTheme|ThemeData.primaryIconTheme|`AppBar`上图标的颜色、透明度、尺寸信息|
|textTheme|TextTheme|ThemeData.primaryTextTheme|`AppBar`上文字样式|
|centerTitle|bool|true|标题是否居中显示|
|automaticallyImplyLeading| bool |
|shape| ShapeBorder |
|actionsIconTheme| IconThemeData |
|primary| bool |
|excludeHeaderSemantics| bool |
|titleSpacing| double |
|toolbarOpacity| double |
|bottomOpacity| double |

<!--  -->

|SliverAppBar属性|默认值|类型|
| --- | --- | --- |
|leading|| Widget |
|automaticallyImplyLeading| true | bool |
|title|| Widget |
|actions|| List<Widget>|
|flexibleSpace|| Widget |
|bottom|| PreferredSizeWidget |
|elevation|| double |
|forceElevated| false | bool |
|backgroundColor|| Color |
|brightness|| Brightness |
|iconTheme|| IconThemeData |
|actionsIconTheme|| IconThemeData |
|textTheme|| TextTheme |
|primary| true | bool |
|centerTitle|| bool |
|excludeHeaderSemantics| false | bool |
|titleSpacing| NavigationToolbar.kMiddleSpacing | double |
|expandedHeight|| double |
|floating| false | bool |
|pinned| false | bool |
|snap| false | bool |
|stretch| false | bool |
|stretchTriggerOffset| 100.0 | double |
|onStretchTrigger|| AsyncCallback |
|shape|| ShapeBorder |

[AppBar、SliverAppBar 代码示例](https://codepen.io/samlau7245/pen/jObvOGY)

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MaterialApp Demo",
      theme: ThemeData(primaryColor: Color(0xFF37966F)),
      color: Colors.orange,
      home: FirstPage(),
      routes: {
        "/first": (_) => FirstPage(),
        "/second": (_) => SecondPage(),
      },
    );
  }
}

////////////////////////////////////////////////////////////////////////

class FirstPage extends StatefulWidget {
  FirstPage({Key key}) : super(key: key);

  @override
  _FirstPage createState() => new _FirstPage();
}

class _FirstPage extends State<FirstPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("First Page"),
        leading: Icon(Icons.ac_unit),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), onPressed: null),
          IconButton(icon: Icon(Icons.search), onPressed: null)
        ],
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/second');
        },
        child: Text('Push'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////

class SecondPage extends StatefulWidget {
  SecondPage({Key key}) : super(key: key);
  @override
  _SecondPage createState() => new _SecondPage();
}

class _SecondPage extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(
            pinned: true,
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('SliverAppBar Demo'),
            ),
          ),
          SliverFixedExtentList(
            itemExtent: 50.0,
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  alignment: Alignment.center,
                  color: Colors.lightBlue[100 * (index % 9)],
                  child: Text('List Item $index'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```










<!-- ==================================================================================================== -->










## [BottomNavigationBar(底部导航栏组件)](https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html)

可以参考官方的设计理念：[Bottom navigation](https://material.io/components/bottom-navigation/)

|属性|类型|说明|
| --- | --- | --- |
|currentIndex|int|当前索引|
|fixedColor|||
|iconColor|||
|items|`List<BtoomNavigationBarItem>`|底部导航栏按钮集合|
|onTap|`ValueChanged<int>`|按下其中某个按钮的回调事件。需要根据返回的索引设置当前索引|

> `type`控制项目的显示方式，如果没有指定，那么它会自动设置为`BottomNavigationBarType.fixed`. <br>
> `BottomNavigationBarType.fixed` : 当Items少于4个时，则会通过`selectedItemColor`显示选中Item的颜色，如果`selectedItemColor`为`null`，则使用`ThemeData.primaryColor`。如果`backgroundColor`为`null`，则使用`ThemeData.canvasColor`（本质上是不透明的白色）。<br>
> `BottomNavigationBarType.shifting` : 当Items大于等于4个时， 如果`selectedItemColor`为`null`，则所有项目均以白色呈现。背景颜色与所选项目的`BottomNavigationBarItem.backgroundColor`相同 。

* [代码示例1](https://codepen.io/samlau7245/pen/xxwabbb)
* [代码示例2,切换body为Scaffold](https://codepen.io/samlau7245/pen/JjYaGGY)

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MaterialApp Demo",
      theme: ThemeData(primaryColor: Color(0xFF37966F)),
      color: Colors.orange,
      home: HomePage(),
    );
  }
}

////////////////////////////////////////////////////////////////////////

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text('Index 0: Home', style: optionStyle),
    Text('Index 1: Business', style: optionStyle),
    Text('Index 2: School', style: optionStyle),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('BottomNavigationBar Demo')),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
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
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
```

<img src="/assets/images/flutter/16.png" width = "25%" height = "25%"/>










<!-- ==================================================================================================== -->











## [TabBar(水平选项卡及视图组件)](https://api.flutter.dev/flutter/material/TabBar-class.html)
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










<!-- ==================================================================================================== -->










## [Drawer(抽屉组件)](https://api.flutter.dev/flutter/material/Drawer-class.html)

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










<!-- ==================================================================================================== -->










## [WidgetsApp()](https://api.flutter.dev/flutter/material/WidgetsApp-class.html)










<!-- ==================================================================================================== -->










## [FloatingActionButton(悬停按钮组件)](https://api.flutter.dev/flutter/material/FloatingActionButton-class.html)

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

这个组件构造方法：

```dart
FloatingActionButton();
FloatingActionButton.extended();
```

[示例代码](https://codepen.io/samlau7245/pen/oNjPbwB)

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FloatingActionButton Demo",
      home: HomePage(),
    );
  }
}

//////////////////////////////首页//////////////////////////////////

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FloatingActionButton Demo"),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.navigation),
        backgroundColor: Colors.green,
      ),*/
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: Text('Approve'),
        icon: Icon(Icons.thumb_up),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
```

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











<!-- ==================================================================================================== -->










## [FlatButton(扁平按钮组件)](https://api.flutter.dev/flutter/material/FlatButton-class.html)
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











<!-- ==================================================================================================== -->










## PopupMenuButton(弹出菜单组件)

| 属性|类型|说明|
| --- | --- | --- |
|child|Widget||
|icon|Icon||
|itemBuilder|`PopupMenuItembuilder<T>`|菜单构造器，菜单项为任意类型，文本、图标都行|
|onSelected|`PopupMenuItembuilder<T>`|菜单被选中的回调方法|

[示例代码](https://codepen.io/samlau7245/pen/xxwaZYO)

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FloatingActionButton Demo",
      home: HomePage(),
    );
  }
}

//////////////////////////////首页//////////////////////////////////

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePage createState() => new _HomePage();
}

enum ConferenceItem { AddMember, LockConference, ModifyLayout, TurnoffAll }

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FloatingActionButton Demo"),
        actions: <Widget>[
          PopupMenuButton<ConferenceItem>(itemBuilder: (_) {
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
          })
        ],
      ),
    );
  }
}
```

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











<!-- ==================================================================================================== -->










## [SimpleDialog(简单对话框组件)](https://api.flutter.dev/flutter/material/SimpleDialog-class.html)

| 属性|类型|说明|
| --- | --- | --- |
|children|`List<Widget>`||
|title|||
|contentPadding|||
|titlePadding|||

[示例代码](https://codepen.io/samlau7245/pen/OJyoMBo)

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FloatingActionButton Demo",
      home: HomePage(),
    );
  }
}

//////////////////////////////首页//////////////////////////////////

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    
    Future<void> _showDialog() async {
      await showDialog(
          context: context,
          builder: (_) {
            return SimpleDialog(
              title: Text('This is a SimpleDialog!'),
              children: <Widget>[
                SimpleDialogOption(child: Text("data")),
                SimpleDialogOption(child: Text("data")),
              ],
            );
          });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("FloatingActionButton Demo"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showDialog();
        },
      ),
    );
  }
}
```

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











<!-- ==================================================================================================== -->










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











<!-- ==================================================================================================== -->










## [TextField(输入框)](https://api.flutter.dev/flutter/material/TextField-class.html)

* [TextFormField](https://api.flutter.dev/flutter/material/TextFormField-class.html)
* [Form](https://api.flutter.dev/flutter/widgets/Form-class.html)
* [可以从flutter 官方测试文件中找到Demo](https://github.com/flutter/flutter/blob/8de07d5527bcdc6b02e43e8efed19219a84bf82e/packages/flutter/test/material/text_field_test.dart)
* [使用TextEditingController](https://flutter.dev/docs/cookbook/forms/text-field-changes#2-use-a-texteditingcontroller)
* [CodePen示例](https://codepen.io/samlau7245/pen/QWjVmqM)

```dart
const TextField({
  Key key,
  this.controller, // 控制器
  this.focusNode,   // 轻按按钮时使文本字段聚焦,@see: https://flutter.dev/docs/cookbook/forms/focus                                             
  this.decoration = const InputDecoration(),//样式                                            
  TextInputType keyboardType,                                            
  this.textInputAction,                                            
  this.textCapitalization = TextCapitalization.none,                                            
  this.style, //类型                                            
  this.strutStyle,                                            
  this.textAlign = TextAlign.start,                                            
  this.textAlignVertical,                                            
  this.textDirection,                                            
  this.readOnly = false,                                            
  ToolbarOptions toolbarOptions,                                            
  this.showCursor,                                          // 光标设置                                            
  this.autofocus = false,     // 立即聚焦文本字段,@see: https://flutter.dev/docs/cookbook/forms/focus                                  
  this.obscureText = false,                                            
  this.autocorrect = true,                                            
  SmartDashesType smartDashesType,                                            
  SmartQuotesType smartQuotesType,                                            
  this.enableSuggestions = true,                                            
  this.maxLines = 1,// 行数限制                                           
  this.minLines,// 行数限制                                           
  this.expands = false,                                            
  this.maxLength,                                            
  this.maxLengthEnforced = true,                                            
  this.onChanged, // 输入监听回调                                            
  this.onEditingComplete, // 输入监听回调                                            
  this.onSubmitted, // 输入监听回调                                            
  this.inputFormatters,                                            
  this.enabled,                                            
  this.cursorWidth = 2.0,                                    // 光标设置
  this.cursorRadius,                                         // 光标设置
  this.cursorColor,                                          // 光标设置
  this.selectionHeightStyle = ui.BoxHeightStyle.tight,                                            
  this.selectionWidthStyle = ui.BoxWidthStyle.tight,                                            
  this.keyboardAppearance,                                            
  this.scrollPadding = const EdgeInsets.all(20.0),                                            
  this.dragStartBehavior = DragStartBehavior.start,                                            
  this.enableInteractiveSelection = true,                                            
  this.onTap,                                            
  this.buildCounter,                                            
  this.scrollController,                                            
  this.scrollPhysics,                                            
});

// 其中 `this.decoration = const InputDecoration()` 控制组件的样式，构造函数为：

const InputDecoration({
  this.icon,
  this.labelText,
  this.labelStyle,
  this.helperText,
  this.helperStyle,
  this.helperMaxLines,
  this.hintText,
  this.hintStyle,
  this.hintMaxLines,
  this.errorText,
  this.errorStyle,
  this.errorMaxLines,
  @Deprecated(
    'Use floatingLabelBehaviour instead. '
    'This feature was deprecated after v1.13.2.'
  )
  this.hasFloatingPlaceholder = true, // ignore: deprecated_member_use_from_same_package
  this.floatingLabelBehavior = FloatingLabelBehavior.auto,
  this.isDense,
  this.contentPadding,
  this.prefixIcon,
  this.prefixIconConstraints,
  this.prefix,
  this.prefixText,
  this.prefixStyle,
  this.suffixIcon,
  this.suffix,
  this.suffixText,
  this.suffixStyle,
  this.suffixIconConstraints,
  this.counter,
  this.counterText,
  this.counterStyle,
  this.filled,
  this.fillColor,
  this.focusColor,
  this.hoverColor,
  this.errorBorder,
  this.focusedBorder,
  this.focusedErrorBorder,
  this.disabledBorder,
  this.enabledBorder,
  this.border,
  this.enabled = true,
  this.semanticCounterText,
  this.alignLabelWithHint,
})
```










<!-- ==================================================================================================== -->










## [Form(表格)](https://api.flutter.dev/flutter/widgets/Form-class.html)

表格类，可以通过[Cookbook-Forms](https://flutter.dev/docs/cookbook/forms)来初步实现Form的创建；其中涉及到的Widget有：[FormField](https://api.flutter.dev/flutter/widgets/FormField-class.html)、[TextFormField](https://api.flutter.dev/flutter/material/TextFormField-class.html)、[DropdownButtonFormField](https://api.flutter.dev/flutter/material/DropdownButtonFormField-class.html)、[EditableText](https://api.flutter.dev/flutter/widgets/EditableText-class.html)、[InputDatePickerFormField](https://api.flutter.dev/flutter/material/InputDatePickerFormField-class.html)。

```dart
class TextFormField extends FormField<String>{}
class DropdownButtonFormField<T> extends FormField<T>{}
class EditableText extends StatefulWidget{}
```

[Form示例](https://codepen.io/samlau7245/pen/bGVxKXE)

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "FloatingActionButton Demo",
      home: HomePage(),
    );
  }
}

//////////////////////////////首页//////////////////////////////////

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  FocusNode _focusNode;
  List<String> _dropList;
  String _dropListSelected;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _dropList = ["One", "Two"];
    _dropListSelected = _dropList.length <= 0 ? "" : _dropList.elementAt(0);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Demo")),
      body: Builder(
        builder: (BuildContext context) => Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            // Add TextFormFields and RaisedButton here.
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  //autofocus: true,
                  //focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                  ),
                  // 校验字段
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    print(value);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0, bottom: 16.0, right: 16.0),
                child: DropdownButtonFormField(
                  hint: const Text('Select Value'),
                  value: _dropListSelected,
                  items: _dropList
                      .map<DropdownMenuItem<String>>((String dropdownMenuItem) {
                    return DropdownMenuItem(
                      child: Text(dropdownMenuItem),
                      value: dropdownMenuItem,
                    );
                  }).toList(),
                  onChanged: (value) {},
                  validator: (String value) =>
                      value == null ? 'Must select value' : null,
                  onSaved: (String value) {
                    setState(() {
                      _dropListSelected = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16.0, bottom: 16.0, right: 16.0),
                child: EditableText(
                  backgroundCursorColor: Colors.grey,
                  controller: _controller,
                  focusNode: _focusNode,
                  style: TextStyle(color: Colors.black),
                  cursorColor: Color.fromARGB(0xFF, 0xFF, 0x00, 0x00),
                ),
              ),
              InputDatePickerFormField(
                firstDate: DateTime(2018),
                lastDate: DateTime(2030),
              ),
              RaisedButton(
                onPressed: () {
                  if (_focusNode.canRequestFocus) {
                    _focusNode.requestFocus();
                  }
                  if (_formKey.currentState.validate()) {
                    Scaffold.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')));
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```










<!-- ==================================================================================================== -->










## [AlertDialog](https://api.flutter.dev/flutter/material/AlertDialog-class.html)

[示例](https://codepen.io/samlau7245/pen/zYvJLpm)

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Demo", home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(),
      floatingActionButton: FloatingActionButton(
          child: Text("Alert"),
          onPressed: () {
            _showDialog(context);
          }),
    );
  }

  void _cupertinoAlertDialogActionDismis(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> _showDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (_) {
        return AlertDialog(
          elevation: 24.0, // 圆角
          backgroundColor: Color(0xFFE8F5E9),
          title: Text("title"),
          //shape: CircleBorder(),
          //content: Text("content"),
          // content: FlutterLogo(size: 80.0),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('This is a demo alert dialog.'),
                Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("NO"),
              onPressed: () {
                _cupertinoAlertDialogActionDismis(context);
              },
            ),
            FlatButton(
              child: Text("YES"),
              onPressed: () {
                _cupertinoAlertDialogActionDismis(context);
              },
            ),
          ],
        );
      },
    );
  }
}
```










<!-- ==================================================================================================== -->










## [SimpleDialog](https://api.flutter.dev/flutter/material/SimpleDialog-class.html)
```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Demo", home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(),
      floatingActionButton: FloatingActionButton(
          child: Text("Alert"),
          onPressed: () {
            _showDialog(context).then((value) => print(value));
          }),
    );
  }

  Future<String> _showDialog(BuildContext context) async {
    Future<String> ret = showDialog<String>(
      context: context,
      builder: (_) {
        return SimpleDialog(
          title: const Text('Select assignment'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, "1");
              },
              child: const Text('Treasury department'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, "2");
              },
              child: const Text('State department'),
            ),
          ],
        );
      },
    );
    return ret;
  }
}
```











<!-- ==================================================================================================== -->










## [BottomSheet](https://api.flutter.dev/flutter/material/BottomSheet-class.html)

BottomSheet有两种设计方式：

* `Persistent` : 这是用过[ScaffoldState.showBottomSheet](https://api.flutter.dev/flutter/material/ScaffoldState/showBottomSheet.html)来展示。
* `Modal` 通过[showModalBottomSheet](https://api.flutter.dev/flutter/material/BottomSheet-class.html)来展示。

[示例代码](https://codepen.io/samlau7245/pen/ZEbMMpP)

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Demo", home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Builder(
        builder: (BuildContext context) => Center(
          child: FlatButton(
            child: Text("Alert"),
            onPressed: () {
              _showBottomSheetDemo(context);
            },
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Text("Alert"),
      //   onPressed: () {
      //     scaffoldKey.currentState.showBottomSheet<void>(
      //       (_) {
      //         return Container(
      //           margin: const EdgeInsets.all(40.0),
      //           child: const Text('BottomSheet'),
      //         );
      //       },
      //     );
      //   },
      // ),
    );
  }

  void _showBottomSheetDemo(BuildContext context) {
    Scaffold.of(context).showBottomSheet((_) {
      return Container(
        height: 200.0,
        color: Color(0xFF37966F),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('BottomSheet'),
            RaisedButton(
              child: const Text('Close BottomSheet'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      );
    });
  }
}
```

[示例代码](https://codepen.io/samlau7245/pen/OJyoovZ)

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Demo", home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) => Center(
          child: FlatButton(
            child: Text("Alert"),
            onPressed: () {
              showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.pink,
                  barrierColor: Colors.red,
                  elevation: 9.0,
                  shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  clipBehavior: Clip.antiAlias,
                  builder: (_) {
                    return Container(
                      child: const Text('BottomSheet'),
                      height: 400.0,
                    );
                  }).then(
                (value) {},
              );
            },
          ),
        ),
      ),
    );
  }
}
```
<img src="/assets/images/flutter/81.png" width = "25%" height = "25%"/>










<!-- ==================================================================================================== -->










## [ExpansionPanel](https://api.flutter.dev/flutter/material/ExpansionPanel-class.html)

```dart
class ExpansionPanel{}

class ExpansionPanelList extends StatefulWidget{
  const ExpansionPanelList({
    Key key,
    this.children = const <ExpansionPanel>[],
    this.expansionCallback,
    this.animationDuration = kThemeAnimationDuration,
    this.expandedHeaderPadding = _kPanelHeaderExpandedDefaultPadding,
  });
}

class ExpansionPanelRadio extends ExpansionPanel{}
```

### [ExpansionPanelList](https://api.flutter.dev/flutter/material/ExpansionPanelList-class.html)

[示例](https://codepen.io/samlau7245/pen/rNOZqOL)

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Demo", home: HomePage());
  }
}

// 数据模型
class Item {
  Item({this.expandedValue, this.headerValue, this.isExpanded = false});

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

List<Item> generateItems(int length) {
  return List.generate(
    length,
    (index) => Item(
        headerValue: 'Panel $index',
        expandedValue: 'This is item number $index'),
  );
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  List<Item> list = generateItems(8);
  Widget _buildPanel() {
    return ExpansionPanelList(
      children: list.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(title: Text(item.headerValue));
          },
          body: ListTile(
            title: Text(item.expandedValue),
            subtitle: Text('To delete this panel, tap the trash can icon'),
            trailing: Icon(Icons.delete),
            onTap: () {},
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          list[index].isExpanded = !isExpanded;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: _buildPanel(),
        ),
      ),
    );
  }
}
```

### [ExpansionPanelList.radio](https://api.flutter.dev/flutter/material/ExpansionPanelList/ExpansionPanelList.radio.html)

[CodePen-ExpansionPanelList.radio](https://codepen.io/samlau7245/pen/VwvGEKX)

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Demo", home: HomePage());
  }
}

// 数据模型
class Item {
  Item({this.expandedValue, this.headerValue, this.id});

  String expandedValue;
  String headerValue;
  int id;
}

List<Item> generateItems(int length) {
  return List.generate(
    length,
    (index) => Item(
        id: index,
        headerValue: 'Panel $index',
        expandedValue: 'This is item number $index'),
  );
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  List<Item> list = generateItems(8);
  Widget _buildPanel() {
    return ExpansionPanelList.radio(
      initialOpenPanelValue: 2,
      children: list.map<ExpansionPanelRadio>((Item item) {
        return ExpansionPanelRadio(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(title: Text(item.headerValue));
          },
          body: ListTile(
            title: Text(item.expandedValue),
            subtitle: Text('To delete this panel, tap the trash can icon'),
            trailing: Icon(Icons.delete),
            onTap: () {},
          ),
          value: item.id,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: _buildPanel(),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/82.gif"/>










<!-- ==================================================================================================== -->










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










<!-- ==================================================================================================== -->










## [Card(卡片组件)](https://api.flutter.dev/flutter/material/Card-class.html)

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










<!-- ==================================================================================================== -->










## [Chip](https://api.flutter.dev/flutter/material/Chip-class.html)

* [InputChip](https://api.flutter.dev/flutter/material/InputChip-class.html)
* [ChoiceChip](https://api.flutter.dev/flutter/material/ChoiceChip-class.html)
* [FilterChip](https://api.flutter.dev/flutter/material/FilterChip-class.html)
* [ActionChip](https://api.flutter.dev/flutter/material/ActionChip-class.html)
* [查看官方测试文件](https://github.com/flutter/flutter/blob/5d5175b0b3d044574eec48a8b9b17095f58fd576/packages/flutter/test/material/chip_test.dart)

<img src="/assets/images/flutter/84.png"/>

```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Demo", home: HomePage());
  }
}

class ActorFilterEntry {
  const ActorFilterEntry(this.name, this.initials);
  final String name;
  final String initials;
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  @override
  _HomePage createState() => new _HomePage();
}

class _HomePage extends State<HomePage> {
  ///////////////////////////////////////////////
  Chip _chip() {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: Colors.grey.shade800,
        child: Text('AB'),
      ),
      deleteButtonTooltipMessage: 'Delete chip A',
      label: Text('Aaron Burr'),
      onDeleted: () {
        print('Chip.');
      },
    );
  }

  ///////////////////////////////////////////////

  bool _inputChipSlected = false;
  InputChip _inputChip() {
    return InputChip(
      avatar: CircleAvatar(
        backgroundColor: Colors.grey.shade800,
        child: Text('AB'),
      ),
      label: Text('Aaron Burr'),
      selected: _inputChipSlected,
      onSelected: (bool value) {
        setState(() {
          _inputChipSlected = value;
        });
      },
    );
  }

  ///////////////////////////////////////////////

  int _value = 1;
  Wrap _choiceChip() {
    return Wrap(
      children: List<Widget>.generate(
        3,
        (int index) {
          return ChoiceChip(
            label: Text('Item $index'),
            selected: _value == index,
            onSelected: (bool selected) {
              setState(() {
                _value = selected ? index : null;
              });
            },
          );
        },
      ).toList(),
    );
  }

  ///////////////////////////////////////////////
  final List<ActorFilterEntry> _cast = <ActorFilterEntry>[
    const ActorFilterEntry('Aaron Burr', 'AB'),
    const ActorFilterEntry('Alexander Hamilton', 'AH'),
    const ActorFilterEntry('Eliza Hamilton', 'EH'),
    const ActorFilterEntry('James Madison', 'JM'),
  ];
  List<String> _filters = <String>[];
  Iterable<Widget> get actorWidgets sync* {
    for (final ActorFilterEntry actor in _cast) {
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: FilterChip(
          avatar: CircleAvatar(child: Text(actor.initials)),
          label: Text(actor.name),
          selected: _filters.contains(actor.name),
          onSelected: (bool value) {
            setState(() {
              if (value) {
                _filters.add(actor.name);
              } else {
                _filters.removeWhere((String name) {
                  return name == actor.name;
                });
              }
            });
          },
        ),
      );
    }
  }

  ///////////////////////////////////////////////
  ActionChip _actionChip() {
    return ActionChip(
        avatar: CircleAvatar(
          backgroundColor: Colors.grey.shade800,
          child: Text('AB'),
        ),
        label: Text('Aaron Burr'),
        onPressed: () {
          print("If you stand for nothing, Burr, what’ll you fall for?");
        });
  }

  ///////////////////////////////////////////////

  Container demo1() {
    return Container(
      width: 75.0,
      height: 25.0,
      child: Chip(
        label: Container(
          width: 100.0,
          height: 50.0,
        ),
        onDeleted: () {},
      ),
    );
  }

  InputChip demo2() {
    return InputChip(
      label: const Text('InputChip'),
      selected: true,
      showCheckmark: true,
      checkmarkColor: Colors.red,
    );
  }

  Widget _selectedFilterChip({Color checkmarkColor}) {
    return FilterChip(
      label: const Text('InputChip'),
      selected: true,
      showCheckmark: true,
      checkmarkColor: checkmarkColor,
      onSelected: (bool _) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          _chip(),
          _inputChip(),
          _choiceChip(),
          Wrap(children: actorWidgets.toList()),
          _actionChip(),
          demo1(),
          demo2(),
          _selectedFilterChip(checkmarkColor: Colors.red),
        ],
      ),
    );
  }
}
```










<!-- ==================================================================================================== -->










##[CircularProgressIndicator(环进度指示器)](https://api.flutter.dev/flutter/material/CircularProgressIndicator-class.html)

* `Determinate` : 值范围(`0.0~1.0`)。
* `Indeterminate` : 非固定值。使用非空`value`属性值。










<!-- ==================================================================================================== -->










## [DataTable](https://api.flutter.dev/flutter/material/DataTable-class.html)

* [DataColumn](https://api.flutter.dev/flutter/material/DataColumn-class.html)
* [DataRow](https://api.flutter.dev/flutter/material/DataRow-class.html)

```dart
DataTable({
  Key key,
  @required this.columns,
  this.sortColumnIndex,
  this.sortAscending = true,
  this.onSelectAll,
  this.dataRowHeight = kMinInteractiveDimension,
  this.headingRowHeight = 56.0,
  this.horizontalMargin = 24.0,
  this.columnSpacing = 56.0,
  this.showCheckboxColumn = true,
  this.dividerThickness = 1.0,
  @required this.rows,
});

const DataColumn({
  @required this.label,
  this.tooltip,
  this.numeric = false,
  this.onSort,
});

const DataRow({
  this.key,
  this.selected = false,
  this.onSelectChanged,
  @required this.cells,
});

const DataCell(
  this.child, {
  this.placeholder = false,//显示缺省
  this.showEditIcon = false,// 显示编辑按钮
  this.onTap,
});

```

[示例](https://codepen.io/samlau7245/pen/WNQgBQB)

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<StatefulWidget> {
  List<DataColumn> columnsTitles = List.generate(3, (index) {
    return DataColumn(
      numeric: true,
      label: Text("COL$index", style: TextStyle(fontStyle: FontStyle.italic)),
    );
  });
  List<DataRow> rows = List.generate(20, (index) {
    return DataRow(
      selected: index == 2 ? true : false,
      onSelectChanged: (bool value){
        print('object-$index');
      },
      cells: <DataCell>[
        DataCell(Text('co1-$index'),showEditIcon: true),
        DataCell(Text('co2-$index'),showEditIcon: true),
        DataCell(Text('co3-$index'),showEditIcon: true),
      ],
    );
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Demo"),
      ),
      body: DataTable(
        columns: <DataColumn>[
          DataColumn(
            // numeric: true,
            label: Text(
              "COL1",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            tooltip: "Column Tips"
          ),
          DataColumn(
            // numeric: true,
            label: Text(
              "COL22",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          DataColumn(
            numeric: true,
            label: Text(
              "COL3",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
        rows: rows,
      ),
    );
  }
}
```

<img src="/assets/images/flutter/85.png" width = "25%" height = "25%"/>

### [PaginatedDataTable](https://api.flutter.dev/flutter/material/PaginatedDataTable-class.html)

```dart
PaginatedDataTable({
  Key key,
  @required this.header,//表头
  this.actions,
  @required this.columns,
  this.sortColumnIndex,
  this.sortAscending = true,
  this.onSelectAll,
  this.dataRowHeight = kMinInteractiveDimension,
  this.headingRowHeight = 56.0,
  this.horizontalMargin = 24.0,
  this.columnSpacing = 56.0,
  this.showCheckboxColumn = true,
  this.initialFirstRowIndex = 0,
  this.onPageChanged,
  this.rowsPerPage = defaultRowsPerPage,
  this.availableRowsPerPage = const <int>[defaultRowsPerPage, defaultRowsPerPage * 2, defaultRowsPerPage * 5, defaultRowsPerPage * 10],
  this.onRowsPerPageChanged,
  this.dragStartBehavior = DragStartBehavior.start,
  @required this.source,
});
```

**PaginatedDataTableState**

<!--  -->










<!-- ==================================================================================================== -->










## [Navigator(导航栏)](https://api.flutter.dev/flutter/widgets/Navigator-class.html)

|方法名|含义|
| --- | --- |  
|[canPop](https://api.flutter.dev/flutter/widgets/Navigator/canPop.html)||
|[pop](https://api.flutter.dev/flutter/widgets/Navigator/pop.html)||
|[popAndPushNamed](https://api.flutter.dev/flutter/widgets/Navigator/popAndPushNamed.html)||
|[popUntil](https://api.flutter.dev/flutter/widgets/Navigator/popUntil.html)||
|[push](https://api.flutter.dev/flutter/widgets/Navigator/push.html)||
|[pushAndRemoveUntil](https://api.flutter.dev/flutter/widgets/Navigator/pushAndRemoveUntil.html)||
|[pushNamed](https://api.flutter.dev/flutter/widgets/Navigator/pushNamed.html)||
|[pushNamedAndRemoveUntil](https://api.flutter.dev/flutter/widgets/Navigator/pushNamedAndRemoveUntil.html)||
|[pushReplacement](https://api.flutter.dev/flutter/widgets/Navigator/pushReplacement.html)||
|[pushReplacementNamed](https://api.flutter.dev/flutter/widgets/Navigator/pushReplacementNamed.html)|替换掉前一个rout|
|[defaultGenerateInitialRoutes](https://api.flutter.dev/flutter/widgets/Navigator/defaultGenerateInitialRoutes.html)||
|[maybePop](https://api.flutter.dev/flutter/widgets/Navigator/maybePop.html)||
|[of](https://api.flutter.dev/flutter/widgets/Navigator/of.html)||
|[removeRoute](https://api.flutter.dev/flutter/widgets/Navigator/removeRoute.html)||
|[removeRouteBelow](https://api.flutter.dev/flutter/widgets/Navigator/removeRouteBelow.html)||
|[replace](https://api.flutter.dev/flutter/widgets/Navigator/replace.html)||
|[replaceRouteBelow](https://api.flutter.dev/flutter/widgets/Navigator/replaceRouteBelow.html)||

```dart
if (Navigator.canPop(context)) {
   Navigator.pop(context);
   Navigator.popAndPushNamed(context, '/second');
}

Navigator.pushNamed(context, '/first');

Navigator.push(context, MaterialPageRoute<void>(builder: (_) {
  return Scaffold(
    appBar: AppBar(
      title: Text('MaterialPageRoute Demo'),
    ),
    body: Center(
      child: Text("MaterialPageRoute Demo"),
    ),
  );
}));
```
<!--










-->
<!-- ==================================================================================================== -->
<!--










-->

## 其他

* [SwitchListTile](https://codepen.io/samlau7245/pen/gOadoxo)


### [ThemeData](https://api.flutter.dev/flutter/material/ThemeData-class.html)

```dart
Theme(
  data: ThemeData(primaryColor: Colors.amber),
  child: Builder(
    builder: (BuildContext context) {
      return Container(
        width: 100,
        height: 100,
        color: Theme.of(context).primaryColor, // 获取到上下文中的主题数据
      );
    },
  ),
)
```

<img src="/assets/images/flutter/80.png" width = "50%" height = "50%"/>

```dart
MaterialApp(
  // 这里设置了全局主题数据
  theme: ThemeData(
    primaryColor: Colors.blue, // 全局主题色
    accentColor: Colors.green, // 全局强调色
    textTheme: TextTheme(bodyText2: TextStyle(color: Colors.purple)), // 全局字体色
  ),
  home: Scaffold(
    appBar: AppBar(
      title: const Text('ThemeData Demo'),
    ),
    floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {},
    ),
    body: Center(
      child: Text(
        'Button pressed 0 times',
      ),
    ),
  ),
)
```

|属性名|类型|描述|
| --- | --- |--- |
| `brightness` | [Brightness](https://api.flutter.dev/flutter/material/Brightness-class.html) | |
| `visualDensity` | [VisualDensity](https://api.flutter.dev/flutter/material/VisualDensity-class.html) | |
| `primarySwatch` | [MaterialColor](https://api.flutter.dev/flutter/material/MaterialColor-class.html) | |
| `primaryColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) |主题色 |
| `primaryColorBrightness` | [Brightness](https://api.flutter.dev/flutter/material/Brightness-class.html) | |
| `primaryColorLight` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `primaryColorDark` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `accentColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) |强调色 |
| `accentColorBrightness` | [Brightness](https://api.flutter.dev/flutter/material/Brightness-class.html) | |
| `canvasColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `scaffoldBackgroundColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `bottomAppBarColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `cardColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `dividerColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `focusColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `hoverColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `highlightColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `splashColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `splashFactory` | [InteractiveInkFeatureFactory](https://api.flutter.dev/flutter/material/InteractiveInkFeatureFactory-class.html) | |
| `selectedRowColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `unselectedWidgetColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `disabledColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `buttonColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `buttonTheme` | [ButtonThemeData](https://api.flutter.dev/flutter/material/ButtonThemeData-class.html) | |
| `toggleButtonsTheme` | [ToggleButtonsThemeData](https://api.flutter.dev/flutter/material/ToggleButtonsThemeData-class.html) | |
| `secondaryHeaderColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `textSelectionColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `cursorColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `textSelectionHandleColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `backgroundColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `dialogBackgroundColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `indicatorColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `hintColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `errorColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `toggleableActiveColor` | [Color](https://api.flutter.dev/flutter/material/Color-class.html) | |
| `fontFamily` | [String](https://api.flutter.dev/flutter/material/String-class.html) | |
| `textTheme` | [TextTheme](https://api.flutter.dev/flutter/material/TextTheme-class.html) | |
| `primaryTextTheme` | [TextTheme](https://api.flutter.dev/flutter/material/TextTheme-class.html) | |
| `accentTextTheme` | [TextTheme](https://api.flutter.dev/flutter/material/TextTheme-class.html) | |
| `inputDecorationTheme` | [InputDecorationTheme](https://api.flutter.dev/flutter/material/InputDecorationTheme-class.html) | |
| `iconTheme` | [IconThemeData](https://api.flutter.dev/flutter/material/IconThemeData-class.html) | |
| `primaryIconTheme` | [IconThemeData](https://api.flutter.dev/flutter/material/IconThemeData-class.html) | |
| `accentIconTheme` | [IconThemeData](https://api.flutter.dev/flutter/material/IconThemeData-class.html) | |
| `sliderTheme` | [SliderThemeData](https://api.flutter.dev/flutter/material/SliderThemeData-class.html) | |
| `tabBarTheme` | [TabBarTheme](https://api.flutter.dev/flutter/material/TabBarTheme-class.html) | |
| `tooltipTheme` | [TooltipThemeData](https://api.flutter.dev/flutter/material/TooltipThemeData-class.html) | |
| `cardTheme` | [CardTheme](https://api.flutter.dev/flutter/material/CardTheme-class.html) | |
| `chipTheme` | [ChipThemeData](https://api.flutter.dev/flutter/material/ChipThemeData-class.html) | |
| `platform` | [TargetPlatform](https://api.flutter.dev/flutter/material/TargetPlatform-class.html) | |
| `materialTapTargetSize` | [MaterialTapTargetSize](https://api.flutter.dev/flutter/material/MaterialTapTargetSize-class.html) | |
| `applyElevationOverlayColor` | [bool](https://api.flutter.dev/flutter/material/bool-class.html) | |
| `pageTransitionsTheme` | [PageTransitionsTheme](https://api.flutter.dev/flutter/material/PageTransitionsTheme-class.html) | |
| `appBarTheme` | [AppBarTheme](https://api.flutter.dev/flutter/material/AppBarTheme-class.html) | |
| `bottomAppBarTheme` | [BottomAppBarTheme](https://api.flutter.dev/flutter/material/BottomAppBarTheme-class.html) | |
| `colorScheme` | [ColorScheme](https://api.flutter.dev/flutter/material/ColorScheme-class.html) | |
| `dialogTheme` | [DialogTheme](https://api.flutter.dev/flutter/material/DialogTheme-class.html) | |
| `floatingActionButtonTheme` | [FloatingActionButtonThemeData](https://api.flutter.dev/flutter/material/FloatingActionButtonThemeData-class.html) | |
| `navigationRailTheme` | [NavigationRailThemeData](https://api.flutter.dev/flutter/material/NavigationRailThemeData-class.html) | |
| `typography` | [Typography](https://api.flutter.dev/flutter/material/Typography-class.html) | |
| `cupertinoOverrideTheme` | [CupertinoThemeData](https://api.flutter.dev/flutter/material/CupertinoThemeData-class.html) | |
| `snackBarTheme` | [SnackBarThemeData](https://api.flutter.dev/flutter/material/SnackBarThemeData-class.html) | |
| `bottomSheetTheme` | [BottomSheetThemeData](https://api.flutter.dev/flutter/material/BottomSheetThemeData-class.html) | |
| `popupMenuTheme` | [PopupMenuThemeData](https://api.flutter.dev/flutter/material/PopupMenuThemeData-class.html) | |
| `bannerTheme` | [MaterialBannerThemeData](https://api.flutter.dev/flutter/material/MaterialBannerThemeData-class.html) | |
| `dividerTheme` | [DividerThemeData](https://api.flutter.dev/flutter/material/DividerThemeData-class.html) | |
| `buttonBarTheme` | [ButtonBarThemeData](https://api.flutter.dev/flutter/material/ButtonBarThemeData-class.html) | |










<!-- ==================================================================================================== -->











## [DefaultTextStyle](https://api.flutter.dev/flutter/widgets/DefaultTextStyle-class.html)

```dart
const DefaultTextStyle({
  Key key,
  @required this.style,
  this.textAlign,
  this.softWrap = true,
  this.overflow = TextOverflow.clip,
  this.maxLines,
  this.textWidthBasis = TextWidthBasis.parent,
  this.textHeightBehavior,
  @required Widget child,
})

const TextStyle({
  this.inherit = true,
  this.color,
  this.backgroundColor,
  this.fontSize,
  this.fontWeight,
  this.fontStyle,
  this.letterSpacing,
  this.wordSpacing,
  this.textBaseline,
  this.height,
  this.locale,
  this.foreground,
  this.background,
  this.shadows,
  this.fontFeatures,
  this.decoration,
  this.decorationColor,
  this.decorationStyle,
  this.decorationThickness,
  this.debugLabel,
  String fontFamily,
  List<String> fontFamilyFallback,
  String package,
})
```
