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