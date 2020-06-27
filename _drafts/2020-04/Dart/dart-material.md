---
title: Flutter： Material Design 风格组件
layout: post
categories:
 - dart
---


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