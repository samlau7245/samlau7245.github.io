---
title: Flutter(2)： 动画
layout: post
categories:
 - dart
---

* [How to choose which Flutter Animation Widget is right for you? - Flutter in Focus](https://flutter.cn/docs/development/ui/animations)
* [How to Choose Which Flutter Animation Widget is Right for You?](https://medium.com/flutter/how-to-choose-which-flutter-animation-widget-is-right-for-you-79ecfb7e72b5)

* Code-based Animation : 更趋向于Widget的扩展效果，修改颜色、形状、位置...
  * 隐式动画(Implicit animations) ： 像修改颜色、形状、位置...，一般使用隐式动画，如果内置的隐式动画不满足要求，可以使用`TweenAnimationBuilder(补间动画生成器)`来创建自定义隐式动画。
  * 显式动画(Explicit animations) ： 显式动画需要使用到`AnimationController`。
* Draw-based Animation : 用户绘制的动画

* Does it repeat “forever” ？ 比如播放音乐。
* Is it “discontinuous”？比如模拟水波纹，圆圈是从小到大有规律执行，而不是无序的。
* Do multiple widgets animate together?

上面三个问题中出现任意一种，推荐使用显示动画。

<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## 如何选择哪种动画

* [YouTube-如何在 Flutter 中选择合适的动画 Widget](https://www.youtube.com/watch?v=GXIJJkq_H8g)
* [How to Choose Which Flutter Animation Widget is Right for You?](https://medium.com/flutter/how-to-choose-which-flutter-animation-widget-is-right-for-you-79ecfb7e72b5)


<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## [隐式动画(Implicit animations)](https://api.flutter.dev/flutter/widgets/ImplicitlyAnimatedWidget-class.html)

* [YouTube-Animation basics with implicit animations](https://www.youtube.com/watch?v=IVTjpW3W33s&list=PLjxrf2q8roU2v6UqYlt_KPaXlnjbYySua&index=1)
* [Medium-Animation basics with implicit animations](https://medium.com/flutter/flutter-animation-basics-with-implicit-animations-95db481c5916)
* [Curves Class](https://api.flutter.dev/flutter/animation/Curves-class.html)

| 动画组件 | 描述 | 示例 |
| --- | --- | --- |
| [AnimatedAlign](https://api.flutter.dev/flutter/widgets/AnimatedAlign-class.html) | which is an implicitly animated version of Align.|  [示例](https://codepen.io/samlau7245/pen/zYvLopR) |
| [AnimatedContainer](https://api.flutter.dev/flutter/widgets/AnimatedContainer-class.html) | which is an implicitly animated version of Container.|  [示例](https://codepen.io/samlau7245/pen/VwvBmZB) |
| [AnimatedDefaultTextStyle](https://api.flutter.dev/flutter/widgets/AnimatedDefaultTextStyle-class.html) | which is an implicitly animated version of DefaultTextStyle.|  [示例](https://codepen.io/samlau7245/pen/KKdBNeW) |
| [AnimatedOpacity](https://api.flutter.dev/flutter/widgets/AnimatedOpacity-class.html) | which is an implicitly animated version of Opacity.|  [示例](https://codepen.io/samlau7245/pen/rNOrWZJ) |
| [AnimatedPadding](https://api.flutter.dev/flutter/widgets/AnimatedPadding-class.html) | which is an implicitly animated version of Padding.|  [示例](https://codepen.io/samlau7245/pen/MWaBbPE) |
| [AnimatedPhysicalModel](https://api.flutter.dev/flutter/widgets/AnimatedPhysicalModel-class.html) | which is an implicitly animated version of PhysicalModel.|   |
| [AnimatedPositioned](https://api.flutter.dev/flutter/widgets/AnimatedPositioned-class.html) | which is an implicitly animated version of Positioned.|  [示例](https://codepen.io/samlau7245/pen/mdejOoy) |
| [AnimatedPositionedDirectional](https://api.flutter.dev/flutter/widgets/AnimatedPositionedDirectional-class.html) | which is an implicitly animated version of PositionedDirectional.|   |
| [AnimatedTheme](https://api.flutter.dev/flutter/widgets/AnimatedTheme-class.html) | which is an implicitly animated version of Theme.|   |
| [AnimatedCrossFade](https://api.flutter.dev/flutter/widgets/AnimatedCrossFade-class.html) | which cross-fades between two given children and animates itself between their sizes.|  [示例](https://codepen.io/samlau7245/pen/OJywbYN) |
| [AnimatedSize](https://api.flutter.dev/flutter/widgets/AnimatedSize-class.html) | which automatically transitions its size over a given duration.|  [示例](https://codepen.io/samlau7245/pen/JjYBbgx) |
| [AnimatedSwitcher](https://api.flutter.dev/flutter/widgets/AnimatedSwitcher-class.html) | which fades from one widget to another.|   |
| [TweenAnimationBuilder](https://api.flutter.dev/flutter/widgets/TweenAnimationBuilder-class.html) | which animates any property expressed by a Tween to a specified target value.|  [示例](https://codepen.io/samlau7245/pen/qBOyREw) |

<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## 自定义隐式动画(TweenAnimationBuilder)

* [YouTube-Creating your own Custom Implicit Animations with TweenAnimationBuilder](https://www.youtube.com/watch?v=6KiPEqzJIKQ&feature=youtu.be)
* [Medium-Creating your own Custom Implicit Animations with TweenAnimationBuilder](https://medium.com/flutter/custom-implicit-animations-in-flutter-with-tweenanimationbuilder-c76540b47185)
* [示例：TweenAnimationBuilder - Transform.rotate](https://codepen.io/samlau7245/pen/WNQKRWK)
* [示例：TweenAnimationBuilder - ColorFilter](https://codepen.io/samlau7245/pen/oNjMZxB)
* [示例：TweenAnimationBuilder - IconButton](https://codepen.io/samlau7245/pen/dyYjvNR)

<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## 显式动画(Explicit animations)
* [YouTube-Making Your First Directional Animations with Built-in Explicit Animations](https://www.youtube.com/watch?v=CunyH6unILQ&list=PLjxrf2q8roU2v6UqYlt_KPaXlnjbYySua&index=3)
* [Medium-Making Your First Directional Animations with Built-in Explicit Animations](https://medium.com/flutter/directional-animations-with-built-in-explicit-animations-3e7c5e6fbbd7)
* [源码-Making Your First Directional Animations with Built-in Explicit Animations](https://codepen.io/samlau7245/pen/WNQKjZw)
* [AnimatedWidget 官方文档](https://api.flutter.dev/flutter/widgets/AnimatedWidget-class.html)
* [AnimationController Class](https://api.flutter.dev/flutter/animation/AnimationController-class.html)

| 转场动画 | 描述 | 示例|
| --- | --- | --- |
|[RotationTransition](https://api.flutter.dev/flutter/widgets/RotationTransition-class.html)|which animates the rotation of a widget.|[示例](https://codepen.io/samlau7245/pen/yLYqbMg)|
|[ScaleTransition](https://api.flutter.dev/flutter/widgets/ScaleTransition-class.html)|which animates the scale of a widget.|[示例](https://codepen.io/samlau7245/pen/XWmBgrB)|
|[SlideTransition](https://api.flutter.dev/flutter/widgets/SlideTransition-class.html)|which animates the position of a widget relative to its normal position.|[示例1](https://codepen.io/samlau7245/pen/mdejwmE)、[示例2](https://codepen.io/samlau7245/pen/dyYjzpW)|
|[FadeTransition](https://api.flutter.dev/flutter/widgets/FadeTransition-class.html)|which is an animated version of Opacity.|[示例](https://codepen.io/samlau7245/pen/BaoPdJG)|
|[SizeTransition](https://api.flutter.dev/flutter/widgets/SizeTransition-class.html)|which animates its own size.|[示例](https://codepen.io/samlau7245/pen/yLYqoGN)|
|[PositionedTransition](https://api.flutter.dev/flutter/widgets/PositionedTransition-class.html)|which is an animated version of Positioned.|[示例](https://codepen.io/samlau7245/pen/JjYBrKp)|
|[DecoratedBoxTransition](https://api.flutter.dev/flutter/widgets/DecoratedBoxTransition-class.html)|which is an animated version of DecoratedBox.|[示例](https://codepen.io/samlau7245/pen/QWjBqVG)|
|[AlignTransition](https://api.flutter.dev/flutter/widgets/AlignTransition-class.html)|which is an animated version of Align.|[示例](https://codepen.io/samlau7245/pen/xxwJXMy)|
|[DefaultTextStyleTransition](https://api.flutter.dev/flutter/widgets/DefaultTextStyleTransition-class.html)|which is an animated version of DefaultTextStyle.|[示例](https://codepen.io/samlau7245/pen/rNOrGgv)|
|[AnimatedBuilder-自定义显式动画](https://api.flutter.dev/flutter/widgets/AnimatedBuilder-class.html)| which is useful for complex animation use cases and a notable exception to the naming scheme of AnimatedWidget subclasses.|[示例](https://codepen.io/samlau7245/pen/OJywOqO)|
|[RelativePositionedTransition](https://api.flutter.dev/flutter/widgets/RelativePositionedTransition-class.html)|  which is an animated version of Positioned.|[示例](https://codepen.io/samlau7245/pen/vYNaWWG)|
|[AnimatedModalBarrier](https://api.flutter.dev/flutter/widgets/AnimatedModalBarrier-class.html)|  which is an animated version of ModalBarrier.||
|ScaleTransition、RotationTransition结合||[示例](https://codepen.io/samlau7245/pen/JjYBJYV)|

* 设置`AnimationController(vsync: this,)`中`vsync`时，注意如果是单动则使用`SingleTickerProviderStateMixin`，如果是多动画则使用`TickerProviderStateMixin`。

```dart
class _AnimatedDemo extends State<AnimatedDemo> with SingleTickerProviderStateMixin {}
```

<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->


## 用Hero实现页面切换动画
* [用Hero实现页面切换动画](https://flutter.cn/docs/development/ui/animations/hero-animations)

## 交织动画(staggered-animations)
* [交织动画](https://flutter.cn/docs/development/ui/animations/staggered-animations)

如果页面切换时有时需要增加点动画，这样可以增加应用的体验。在页面元素中添加`Hero`组件，就会自带一种过渡的动画效果。