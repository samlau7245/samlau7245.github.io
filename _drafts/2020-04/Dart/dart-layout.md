---
title: Flutter：布局
layout: post
categories:
 - dart
---

Flutter 布局的核心机制是 widgets。在 Flutter 中，几乎所有东西都是 widget —— 甚至布局模型都是 widgets。具体的布局widgets官方文档：[Layout widgets](https://flutter.cn/docs/development/ui/widgets/layout)。

* Single-child layout widgets -> `Widget child`
* Multi-child layout widgets -> `List<Widget> children = const <Widget>[]`

| child类型| 组件名称 | 中文名称 | 描述 |
| ---| --- | --- | --- |
| Single | [Align](https://api.flutter.dev/flutter/widgets/Align-class.html) | 对齐布局 | 指定child的对齐方式 | 
| Single | [AspectRatio](https://api.flutter.dev/flutter/widgets/AspectRatio-class.html) | 调整宽高比 | 根据设置的宽高比调整child | 
| Single | [Baseline](https://api.flutter.dev/flutter/widgets/Baseline-class.html) | 基准线布局 | 所有child底部所在的同一条水平线 | 
| Single | [Center](https://api.flutter.dev/flutter/widgets/Center-class.html) | 居中布局 | child处于水平和垂直向的中间位置 | 
| Single | [ConstrainedBox](https://api.flutter.dev/flutter/widgets/ConstrainedBox-class.html) | 限定宽高 | 限定child的最大值 | 
| Single | [Container](https://api.flutter.dev/flutter/widgets/Container-class.html) | 容器布局 | 容器布局是一个组合的Widget,包含定位和尺寸 | 
| Single | [CustomSingleChildLayout](https://api.flutter.dev/flutter/widgets/CustomSingleChildLayout-class.html) |  |  | 
| Single | [Expanded](https://api.flutter.dev/flutter/widgets/Expanded-class.html) | 填充布局 |  | 
| Single | [FittedBox](https://api.flutter.dev/flutter/widgets/FittedBox-class.html) | 缩放布局 | 缩放以及位置调整 | 
| Single | [FractionallySizedBox](https://api.flutter.dev/flutter/widgets/FractionallySizedBox-class.html) | 百分比布局 | 根据现有空间按照百分比调整child的尺寸 | 
| Single | [IntrinsicHeight](https://api.flutter.dev/flutter/widgets/IntrinsicHeight-class.html) |  |  | 
| Single | [IntrinsicWidth](https://api.flutter.dev/flutter/widgets/IntrinsicWidth-class.html) |  |  | 
| Single | [LimitedBox](https://api.flutter.dev/flutter/widgets/LimitedBox-class.html) | 限定宽高布局 | 对最大宽高进行限制 | 
| Single | [Offstage](https://api.flutter.dev/flutter/widgets/Offstage-class.html) | 开关布局 | 控制是否显示组件 | 
| Single | [OverflowBox](https://api.flutter.dev/flutter/widgets/OverflowBox-class.html) | 溢出父容器显示 | 允许child超出父容器的范围显示 | 
| Single | [Padding](https://api.flutter.dev/flutter/widgets/Padding-class.html) | 填充布局 | 处理容器与其child之间的间距 | 
| Single | [SizedBox](https://api.flutter.dev/flutter/widgets/SizedBox-class.html) | 设置具体尺寸 | 一个特定大小的盒子来限定child宽度和高度 | 
| Single | [SizedOverflowBox](https://api.flutter.dev/flutter/widgets/SizedOverflowBox-class.html) |  |  | 
| Single | [Transform](https://api.flutter.dev/flutter/widgets/Transform-class.html) | 矩阵转换 | 做矩阵变换,对child做平移、旋转、缩放等操作。 | 
| Multi  | [Column](https://api.flutter.dev/flutter/widgets/Column-class.html) | 垂直布局 | 对child在垂直方向进行排列 | 
| Multi  | [CustomMultiChildLayout](https://api.flutter.dev/flutter/widgets/CustomMultiChildLayout-class.html) | | | 
| Multi  | [Flow](https://api.flutter.dev/flutter/widgets/Flow-class.html) | |[示例](https://codepen.io/samlau7245/pen/OJyEZrY) | 
| Multi  | [Gridview](https://api.flutter.dev/flutter/widgets/Gridview-class.html) | 网格布局 | 对多行多列同时进行操作 | 
| Multi  | [IndexedStack](https://api.flutter.dev/flutter/widgets/IndexedStack-class.html) | 栈索引布局 | Indexedstack继承自Stack,显示第index个child,其他child都是不可见的 | 
| Multi  | [LayoutBuilder](https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html) | 布局构造器 |  | 
| Multi  | [ListBody](https://api.flutter.dev/flutter/widgets/ListBody-class.html) | | | 
| Multi  | [ListView](https://api.flutter.dev/flutter/widgets/ListView-class.html) | 列表布局 | 用列表方式进行布局,比如多项数据的场景 | 
| Multi  | [Row](https://api.flutter.dev/flutter/widgets/Row-class.html) | 水平布局 | 对chid在水平方向进行排列 | 
| Multi  | [Stack](https://api.flutter.dev/flutter/widgets/Stack-class.html) | 栈布局 | 根据Alignment、Positioned 组件的属性将child定位在Stack组件上 | 
| Multi  | [Table](https://api.flutter.dev/flutter/widgets/Table-class.html) | 表格布局 | 使用表格的行和列进行布局 | 
| Multi  | [Wrap](https://api.flutter.dev/flutter/widgets/Wrap-class.html) | 按宽高自动换行 | 按宽度或者高度,让child自动换行布局 | 


## 布局综合示例

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

## 参考资料


## TODO
* [响应式应用的学习](https://flutter.cn/docs/development/ui/layout/responsive)

