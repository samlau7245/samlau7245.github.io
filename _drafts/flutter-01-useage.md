---
title: Flutter入门 building...
description: building...
layout: post
date: 2019-12-23 03:00:00
categories:
 - flutter
---

[Flutter 中文社区](https://flutter.cn/docs)

### 安装Flutter【macOS 环境】

* [下载开发包](https://flutter.cn/docs/get-started/install/macos#update-your-path)

* 把开发包移动到`/Users/shanliu/`。【根据自己的喜好】所以完整的路径：`/Users/shanliu/flutter/`
 
* 更新 PATH 环境变量

```sh
$ /Users/shanliu/flutter/
$ echo ~ # /Users/shanliu
$ export PATH="$PATH:/Users/shanliu/flutter/bin"
$ source $HOME/.bashrc # 刷新当前命令行
$ echo $PATH # 查看flutter/bin 文件夹是否已经添加到 PATH 环境变量中
$ which flutter # 验证 flutter 命令是否可用
```

* 查看当前环境是否需要安装其他的依赖

```sh
$ flutter doctor		# 查看当前环境是否需要安装其他的依赖(如果想查看更详细的输出，增加一个 -v 参数即可)

[✓] Flutter (Channel stable, v1.12.13+hotfix.5, on Mac OS X 10.14.4 18E227, locale zh-Hans-CN)
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK.
      Install Android Studio from: https://developer.android.com/studio/index.html
      On first launch it will assist you in installing the Android SDK components.
      (or visit https://flutter.dev/setup/#android-setup for detailed instructions).
      If the Android SDK has been installed to a custom location, set ANDROID_HOME to that location.
      You may also want to add it to your PATH environment variable.

[✓] Xcode - develop for iOS and macOS (Xcode 11.2.1)
[!] Android Studio (not installed)
[!] IntelliJ IDEA Ultimate Edition (version 2019.1.1)
    ✗ Flutter plugin not installed; this adds Flutter specific functionality.
    ✗ Dart plugin not installed; this adds Dart specific functionality.
[✓] VS Code (version 1.39.2)
[✓] Connected device (1 available)
```

* [更新Flutter版本](https://flutter.cn/docs/development/tools/sdk/upgrading)

### 通过命令创建一个简单的Flutter应用【iOS平台】

* 在桌面创建文件夹`FlutterDir`，用于测试Flutter项目。

```sh
$ cd /Users/shanliu/Desktop/FlutterDir
$ flutter create first_app # 创建名为first_app的flutter应用
$ cd first_app # 进到first_app应用根目录
```

* 在虚拟机上运行

```sh
$ open -a Simulator # 打开虚拟机
$ flutter run		# 运行Flutter应用。
```

* 在真机上运行

```sh
$ open ios/Runner.xcworkspace #打开 Xcode 工程，在工程中选真机对应的证书
$ flutter run		# 运行Flutter应用。这样真机中就会安装first_app应用
```

### 安装开发工具`VS Code`

* [VS Code](https://code.visualstudio.com/)，选择最新稳定版本

* `查看` > `命令面板` > `输入 "install"` > 选择`安装扩展` > 搜索`flutter`并安装 > 安装好以后，重新启动VS。

* 通过 doctor命令查看是否安装成功：`查看` > `命令面板` > `输入 "doctor"` > 选择`Flutter: Run Flutter Doctor`

### 通过`VS Code`创建Flutter应用

* `查看` > `命令面板` > `输入 "flutter"` > 选择`Flutter: New Project` > 输入项目名称 > 选择项目文件夹

* 热加载：`Hot Reload`  <img src="/assets/images/offline_bolt.png">
