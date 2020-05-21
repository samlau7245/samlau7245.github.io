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

<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## [理解布局约束](https://flutter.cn/docs/development/ui/layout/constraints)

* [理解布局约束的29个Demo](https://codepen.io/samlau7245/pen/NWGzExa)

<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## Align(对齐布局)
Align(对齐布局)： 将子组件按照指定的方式对齐，并且根据子组件的大小调整自己的大小。

* [Align (Flutter Widget of the Week)](https://www.youtube.com/watch?v=g2E7yl3MwMk)

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
<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## AspectRatio(调整宽高比)

`AspectRatio` 作用是根据设置调整子元素child的宽高比，适合用于需要固定宽高比的场景。

* [AspectRatio Class](https://api.flutter.dev/flutter/widgets/AspectRatio-class.html)

使用`AspectRatio`进行布局的情况：

* `AspectRatio` 会在布局条件允许的范围内尽可能的扩展。Widget的高度是由宽度和比率决定的，类似于`BoxFit.contain`，按照固定比率去尽可能的沾满区域。
* 如果在满足所欲呕限制条件后依然无法找到可行的尺寸，`AspectRatio`会优先适应布局限制条件，而忽略所设置的比率。

|属性|类型|描述|
| --- | --- | --- |
|aspectRatio|double|设置child组件的宽高比，`aspectRatio:3/2`:宽高比例为`3:2`|
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
<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## Baseline(基准线布局)

`Baseline` 将左右元素底部放到同一条水平线上。

* [Baseline Class](https://api.flutter.dev/flutter/widgets/Baseline-class.html)

<img src="/assets/images/flutter/54.png"/>

|属性|类型|描述|
| --- | --- | --- |
|baseline|double||
|baselineType|TextBaseLine|baseline类型：<br> `alphabetic`：对齐字符底部的水平线。<br> `ideographic`：对齐表意字符串的水平线。|

<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## Center(居中布局)
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
<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## ConstrainedBox(限定最大最小宽度布局)
`ConstrainedBox`的作用就是限定子元素child的最大宽度、最大高度、最小宽度和最小高度。例如：通过`ConstrainedBox`来限制文本 Widget 的最大宽度，使其跨越多行。

* [ConstrainedBox (Flutter Widget of the Week)](https://www.youtube.com/watch?v=o2KveVr7adg)
* [CodePen-ConstrainedBox,搭配视频讲解看](https://codepen.io/samlau7245/pen/pojaGdO)
* [ConstrainedBox class](https://api.flutter.dev/flutter/widgets/ConstrainedBox-class.html)

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
<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## Container(基础布局)

Container(基础布局)是一个组合的 Widget 。类似于HTML中的`<span>`标签，用于组合其他的 Widget 。

* [Container (Flutter Widget of the Week)](https://www.youtube.com/watch?v=c1xLMaTUWCY)
* [CodePen-ContainerExample,搭配视频讲解看](https://codepen.io/samlau7245/pen/xxwYMwN)
* [Container class](https://api.flutter.dev/flutter/widgets/Container-class.html)

| 属性 | 类型 | 说明 |
| --- | --- | --- |
|key | Key|Container 唯一标识符，用于查找更新|
|alignment | AlignmentGeometry|控制 child 的对齐方式，如果 Container或者 Container父节点尺寸大于 child 的尺寸，这个属性设置会起作用，有很多种对齐方式|
|padding | EdgelnsetsGeometry|填充， Decoration **内部**的空白区域，如果有 child的话，child位于padding 内部|
|margin  | EdgelnsetsGeometry |边距属性，围绕在 Decoration 和 child 之外的空白区域，不属于内容区域|
|color | Color|用来设置 Container背景色，如果 foregroundDecoration设置的话，可能会遮盖 color效果|
|decoration | Decoration|给Container添加一些装饰，比如形状、颜色...，设置了 Decoration 的话，就不能设置 color属性，否则会报错，此时应该在 Decoration 中进行颜色的设置|
|foregroundDecoration | Decoration |绘制在 child前面的装饰|
|width | double|Container 的宽度，设置为 double.infinity可以强制在宽度上撑满，不设置，撑满则根据 child 和父节点两者一起布局|
|height | double|Container的高度，设置为 double.infinity即可以 强制在高度上撑满|
|constraints | [BoxConstraints](https://api.flutter.dev/flutter/widgets/Container-class.html) |添加到 child上额外的约束条件|
|transform  | [Matrix4](https://api.flutter.dev/flutter/vector_math_64/Matrix4-class.html)|设置 Container 的变换矩阵，类型为 Matrix4|
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

<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## CustomSingleChildLayout

* [CustomSingleChildLayout Class](https://api.flutter.dev/flutter/widgets/CustomSingleChildLayout-class.html)


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## Expanded(填充布局)

* [Expanded (Flutter Widget of the Week)](https://www.youtube.com/watch?v=_rnZaagadyo)
* [Expanded Class](https://api.flutter.dev/flutter/widgets/Expanded-class.html)

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
      home: new Scaffold(
        appBar: AppBar(
          title: Text('Flutter Demo'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    color: Colors.blue,
                    width: 100.0,
                    height: 100.0,
                    margin: EdgeInsets.all(2.0),
                    child: Center(
                      child: Text('Container'),
                    ),
                  ),
                  Container(
                    color: Colors.blue,
                    width: 100.0,
                    height: 100.0,
                    margin: EdgeInsets.all(2.0),
                    child: Center(
                      child: Text('Container'),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    color: Colors.blue,
                    width: 100.0,
                    height: 100.0,
                    margin: EdgeInsets.all(2.0),
                    child: Center(
                      child: Text('Container'),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.amber,
                      height: 100.0,
                      child: Center(
                        child: Text('Expanded'),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.blue,
                    width: 100.0,
                    height: 100.0,
                    margin: EdgeInsets.all(2.0),
                    child: Center(
                      child: Text('Container'),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: Colors.amber,
                      height: 100.0,
                      child: Center(
                        child: Text(
                          'Expanded \nflex: 2',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.blue,
                    width: 100.0,
                    height: 100.0,
                    margin: EdgeInsets.all(2.0),
                    child: Center(
                      child: Text('Container'),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.amber,
                      height: 100.0,
                      child: Center(
                        child: Text(
                          'Expanded \nflex: 1',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

<img src="/assets/images/flutter/73.png" width = "25%" height = "25%"/>


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## FittedBox(缩放布局)

* [FittedBox (Flutter Widget of the Week)](https://youtu.be/T4Uehk3_wlY)
* [FittedBox-官方文档](https://api.flutter.dev/flutter/widgets/FittedBox-class.html)

FittedBox(缩放布局) 组件主要做两件事，`缩放(Scale)`和`位置调整(Position)`。

FittedBox会在自己的尺寸范围内缩放并且调整child的位置。使child适合其尺寸。有点像`ImageView`组件，`ImageView`会将图片在其范围内按照规则进行缩放位置调整。

布局行为分为两种情况:

* 如果外部有约束的话，按照外部约束调整自身尺寸，然后缩放调整child，按照指定的条件进行布局。
* 如果没有外部约束条件，则跟着child尺寸一致，指定的缩放以及位置属性将不起作用。

属性：

* 属性`alignment`：设置对齐方式，默认是`Alignment.center`，居中展示child。
* 属性`fit`：缩放方式。

|`fit`缩放属性|图解|描述|
| --- | --- | --- |
|contain|<img src="/assets/images/flutter/36.png"/>|`child`在`FittedBox`范围内尽可能大，但是不能超出其尺寸。【`contain`是在保持着`child`宽高比不变的大前提下尽可能的填满，一般是宽度或者高度达到最大值时就会停止缩放。】|
|cover|<img src="/assets/images/flutter/37.png"/>|按照原始尺寸填充整个容器，内容可能会超过容器范围|
|fill|<img src="/assets/images/flutter/38.png"/>|不按照宽高比填充，直接填满但是不会超过容器范围|
|fitHeight|<img src="/assets/images/flutter/39.png"/>|按照高度填充整个容器|
|fitWidth|<img src="/assets/images/flutter/40.png"/>|按照宽度填充整个容器|
|none|<img src="/assets/images/flutter/41.png"/>|没有任何填充|
|scaleDown|<img src="/assets/images/flutter/42.png"/>|根据情况缩小范围，内容不会超过容器范围，有时和`contain`一样有时和`none`一样|

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


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## FractionallySizedBox(百分比布局)

`FractionallySizedBox` 组件会根据现有空间来调整child的尺寸，所以就算为child设置了尺寸数值，也不起作用。

* 设置了具体的宽高因子，`具体的宽高=现有的空间宽高X因子`。
* 没有设置宽高因子，则填满可用区域。

|属性|类型|描述|
| --- | --- | --- |
|alignment|AlignmentGeometry|对齐方式，不能为null|
|widthFactor|double|宽度因子|
|heightFactor|double|高度因子|

* [FractionallySizedBox (Flutter Widget of the Week)](https://www.youtube.com/watch?v=PEsY654EGZ0)
* [FractionallySizedBox Class](https://api.flutter.dev/flutter/widgets/FractionallySizedBox-class.html)

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

<img src="/assets/images/flutter/51.png" width = "50%" height = "50%"/>


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## LimitedBox(限定最大宽高布局)

`LimitedBox`和`ConstrainedBox`组件类似。只不过`LimitedBox`没有最小宽高限制。

|属性|类型|描述|
| --- | --- | --- |
|maxWidth|double|最大宽度|
|maxHeight|double|最大高度|

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


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## Offstage(控制是否显示组件)

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


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## OverflowBox 溢出父容器显示
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


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## Padding(填充布局)
Padding(填充布局)： 用于处理容器与其子元素之间的间距，与`padding`对应的属性是 `margin` 属性，`margin`是处理容器与其他组件之间的间距。

* [Padding (Flutter Widget of the Week)](https://www.youtube.com/watch?v=oD5RtLhhubg)
* [Padding Class](https://api.flutter.dev/flutter/widgets/Padding-class.html)
* [Padding Demo](https://dartpad.dartlang.org/8f4870b99659769303f31d3036fea79a)

<img src="/assets/images/flutter/72.png" width = "25%" height = "25%"/>

| 属性|类型|说明|
| --- | --- | --- |
|padding|EdgeInsetsGeometry|填充的值可以用`EdgeInsets`方法，例如：`EdgeInsets.all(6.0)`将容器的上下左右填充设置为6.0|

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


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## SizedBox(设置具体尺寸)

`SizedBox`组件是一个特定大小的盒子，这个组件强制他的child有特定的宽度和高度。

|属性|类型|描述|
| --- | --- | --- |
|width|double|如果具体设置了宽度，则强制child宽度为此值； 如果没有设置，则根据child宽度调整自身宽度|
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


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## Transform(矩阵转换)

* [Transform (Flutter Widget of the Week)](https://www.youtube.com/watch?v=9z_YNlRlWfA)

`Transform` 主要作用就是做矩阵转换。对组件进行平移、旋转和缩放的等操作。

|属性|类型|描述|
| --- | --- | --- |
|transform|Matrix4|一个4x4的矩阵。|
|origin|Offset|旋转点，相对于左上角顶点的偏移。默认旋转点是在左上角顶点|
|alignment|AlignmentGeometry|对齐方式|
|transformHitTests|bool|点击区域石佛业做相应的改变|

```dart
Transform.translate({Key key,@required Offset offset,this.transformHitTests = true,Widget child,});
```


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## Column(垂直布局)
Column(垂直布局) 用来完成对子组件纵向的排列。主轴是垂直方向，次轴是水平方向。

|属性|值|描述|
| --- | --- | --- | --- |
|mainAxisAlignment|MainAxisAlignment|主轴的排列方式|
|crossAxisAlignment|CrossAxisAlignment|次轴的排列方式|
|mainAxisSize|MainAxisSize|主轴应该占据多少空间。取值max为最大，min为最小。|
|children|`List<Widget>`||

<img src="/assets/images/flutter/77.png" width = "50%" height = "50%"/>

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


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## GridView(网格列表布局)

网格列表组件(GridView)：克实现多行多列的应用场景。

* `GridView.count`： 允许你制定列的数量。
* `GridView.extent`： 允许你制定单元格的最大宽度。

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


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## [IndexedStack](https://www.youtube.com/watch?v=_O0PPD1Xfbk)

<img src="/assets/images/flutter/68.gif"/>

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


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## LayoutBuilder(布局构造器)

`LayoutBuilder`可以通过判断设备尺寸来布局界面。与其类似的用法还有`MediaQuery.of(context).orientation == Orientation.portrait`

* [LayoutBuilder Class](https://api.flutter.dev/flutter/widgets/LayoutBuilder-class.html)

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
      home: new Scaffold(
        appBar: AppBar(
          title: Text('FittedBox Demo'),
        ),
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // 通过 constraints 来判断屏幕的尺寸，从而进行界面适配。
            if (constraints.maxWidth < 100) {
            } else {}
            return Center();
          },
        ),
      ),
    );
  }
}
```


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## ListView

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


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## Row(水平布局)
Row(水平布局) 用来完成子组件在水平方向的排列。

<img src="/assets/images/flutter/74.png" width = "50%" height = "50%"/>

<img src="/assets/images/flutter/75.png" width = "50%" height = "50%"/>

|属性|值|描述|
| --- | --- | --- | --- |
|mainAxisAlignment|MainAxisAlignment|主轴的排列方式|
|crossAxisAlignment|CrossAxisAlignment|次轴的排列方式|
|mainAxisSize|MainAxisSize|主轴应该占据多少空间。取值max为最大，min为最小。|
|children|`List<Widget>`||

<img src="/assets/images/flutter/76.png" width = "50%" height = "50%"/>

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var stars = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: Colors.green[500]),
        Icon(Icons.star, color: Colors.green[500]),
        Icon(Icons.star, color: Colors.green[500]),
        Icon(Icons.star, color: Colors.black),
        Icon(Icons.star, color: Colors.black),
      ],
    );
    final ratings = Container(
      color: Colors.blue,
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, //空间均分
        children: [
          stars,
          Text(
            '170 Reviews',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
              letterSpacing: 0.5,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );

    return MaterialApp(
      title: 'Flutter Demo',
      home: new Scaffold(
        appBar: AppBar(
          title: Text('FittedBox Demo'),
        ),
        body: Center(
          child: ratings,
        ),
      ),
    );
  }
}

```

<img src="/assets/images/flutter/32.png" width = "25%" height = "25%"/>


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## Stack(栈布局-将Widget覆盖在另一个的上面)

### Alignment

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

### Overflow

```dart
enum Overflow {
  visible,/// Overflowing children will be visible.
  clip,/// Overflowing children will be clipped to the bounds of their parent.
}
```

<img src="/assets/images/flutter/67.gif"/>

### Positioned

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


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## Table

* [Table (Flutter Widget of the Week)](https://www.youtube.com/watch?v=_lbE0wsVZSw)
* [Table Class](https://api.flutter.dev/flutter/widgets/Table-class.html)

### DataTable 

* [DataTable (Flutter Widget of the Week)](https://www.youtube.com/watch?v=ktTajqbhIcY)
* [CodePen-DataTable,搭配视频讲解看](https://codepen.io/samlau7245/pen/pojVMdj)

### SingleChildScrollView
* [SingleChildScrollView-DataTable](https://codepen.io/samlau7245/pen/oNjdKqd)

### [PaginatedDataTable]()


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## Wrap(按宽高自动换行布局)

`Wrap` 使用了`Flex`中的一些概念，某种意义上和`Row`、`Column`更加相似。单行的`Wrap`和`Row`表现几乎一致，单列的`Wrap`和`Column`表现几乎一致。`Wrap`是在主轴上空间不足时，则向次轴上去扩展显示。

* [Wrap Class](https://api.flutter.dev/flutter/widgets/Wrap-class.html)

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


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## Flexible(自适应组件)

* [Flexible (Flutter Widget of the Week)](https://www.youtube.com/watch?v=CI7x0mAZiY0)
* [CodePen-Flexible,搭配视频讲解看](https://codepen.io/samlau7245/pen/RwWyzXQ)
* [Flexible Class](https://api.flutter.dev/flutter/widgets/Flexible-class.html)


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->



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
* [Flutter关于布局的示例](https://github.com/cfug/flutter.cn/tree/master/examples/layout)
* [Flutter Gallery 应用](https://flutter.github.io/gallery/#/)
* [布局构造](https://flutter.cn/docs/development/ui/layout#sidenav-3-1-2)

## TODO
* [响应式应用的学习](https://flutter.cn/docs/development/ui/layout/responsive)











## constraints

**Constraints go down. Sizes go up. Parent sets position.**










































