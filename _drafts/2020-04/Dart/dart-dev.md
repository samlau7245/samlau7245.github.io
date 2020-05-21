---
title: Flutter 开发笔记
layout: post
categories:
 - dart
---

## 快捷键
* `cmd+.` : Flutter OoutLine 快捷键

## 开发该要
* 为了避免多层Widget，可以把Widget给拆出来，放在`Components`文件中。

```
.
├── Screen
│   ├── Components
│   │   ├── app_bar.dart
│   │   ├── body.dart
│   │   ├── defalult_button.dart
│   │   └── menu_item.dart
│   └── Home
│       └── home_screen.dart
├── constrant.dart
└── main.dart
```

## 如何保持底部导航栏页中子页面状态

> 当点击底部item切换到另一页面, 再返回此页面时会重走它的initState方法（我们一般在initState中发起网络请求），导致不必要的开销。

```dart
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  //1. 声明PageController
  PageController _pageController;
  List<Widget> _pages = [MessagePage(), ContactsPage(), PersonalPage()];

  @override
  void initState() {
    super.initState();
    //2. 初始化PageController
    _pageController = PageController(
      initialPage: _currentIndex,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
    //4. 释放
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      //3. 使用PageView
      body: PageView(
        controller: _pageController,
        children: _pages,
        // physics: NeverScrollableScrollPhysics(), //PageView 可以设置禁止滑动 如果 pagview 嵌套 pagview 会因为滑动冲突导致父pageView无法滑动
        onPageChanged: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.jumpToPage(_currentIndex);
          // _pageController.animateToPage(index, duration: Duration(seconds: 1), curve: ElasticInOutCurve());
        },
        items: <BottomNavigationBarItem>[
          buildBottomNavigationBarItem("聊天","images/message_nor.png","images/message_pre.png",0,),
          buildBottomNavigationBarItem("好友","images/home_nor.png","images/home_pre.png",1,),
          buildBottomNavigationBarItem("我的","images/me_nor.png","images/me_pre.png",2,),
        ],
      ),
    );
  }
}
```

子页面中实现`AutomaticKeepAliveClientMixin`:

```dart
class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold();
  }

  @override
  bool get wantKeepAlive => true;
}
```