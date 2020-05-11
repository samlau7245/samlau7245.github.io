---
title: Flutter 动画
layout: post
categories:
 - dart
---

## AnimatedPadding

* [AnimatedPadding (Flutter Widget of the Week)](https://www.youtube.com/watch?v=PY2m0fhGNz4)
* [CodePen-AnimatedPadding,搭配视频讲解看](https://codepen.io/samlau7245/pen/oNjEmPL)

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: MyWidget(),
    ),
  );
}
class MyWidget extends StatefulWidget {
  @override
  _MyWidget createState() => new _MyWidget();
}

class _MyWidget extends State<MyWidget> {
  double paddingValue = 0; // 当值改变时，触发动画
  _updatePadding(double value) {
    setState(() {
      paddingValue = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: Center(
        child: AnimatedPadding(
          padding: EdgeInsets.all(paddingValue),
          child: Container(
            color: Colors.blue,
            height: 200.0,
          ),
          duration: const Duration(seconds: 1), // 设置动画持续时间
          curve: Curves.easeInOut, // 指定动画的曲线，以实现不同的动画效果
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Text('更新'),
          onPressed: () {
            double tmp = paddingValue == 100.0 ? 0.0 : 100.0;
            _updatePadding(tmp);
          }),
    );
  }
}
```

## AnimatedOpacity 实现渐变效果

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

## 用Hero实现页面切换动画

如果页面切换时有时需要增加点动画，这样可以增加应用的体验。在页面元素中添加`Hero`组件，就会自带一种过渡的动画效果。
