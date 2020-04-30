---
title: Flutter Platform Channel
layout: post
categories:
 - dart
---

## Platform Channel 工作原理

Flutter有三种不同类型的Channel：

* `BasicMessageChannel`：用于传递字符串和半结构化的信息。
* `MethodChannel`：用于传递方法调用（method invocation）。
* `EventChannel`: 用于数据流（event streams）的通信。

每种Channel都有三种不同的变量：

* `name`:  String类型，代表Channel的名字，也是其唯一标识符。
* `messager`：BinaryMessenger类型，代表消息信使，是消息的发送与接收的工具。
* `codec`: MessageCodec类型或MethodCodec类型，代表消息的编解码器。

一个Flutter应用中可能存在多个Channel，每个Channel在创建时必须指定一个独一无二的name，Channel之间使用name来区分彼此。当有消息从Flutter端发送到Platform端时，会根据其传递过来的channel name找到该Channel对应的Handler（消息处理器）。

## 参考资料

* [深入理解Flutter Platform Channel-闲鱼技术](https://juejin.im/post/5b84ff6a6fb9a019f47d1cc9)