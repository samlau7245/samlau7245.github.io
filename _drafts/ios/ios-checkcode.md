---
title: UIKit-表格相关
layout: post
categories:
 - ios
---

性能调优

## Instruments

* `Time Profiler` : CPU分析工具分析代码的执行时间。
* `Core Animation` : 离屏渲染，图层混合等GPU耗时。
* `Leaks` : 内存检测，内存泄漏检测工具。
* `Energy Log` : 耗电检测工具。
* `Network` : 流量检测工具。

### Leaks


Run、Test、Profile、Analyse

Call Trees

* Separate by State
* Separate by Thread : 线程分离,只有这样才能在调用路径中能够清晰看到占用CPU最大的线程.
* Invert Call Tree : 从上到下跟踪堆栈信息.这个选项可以快捷的看到方法调用路径最深方法占用CPU耗时,比如FuncA{FunB{FunC}},勾选后堆栈以C->B->A把调用层级最深的C显示最外面. 
* Hide System Libraries : 个就更有用了,勾选后耗时调用路径只会显示app耗时的代码,性能分析普遍我们都比较关系自己代码的耗时而不是系统的.基本是必选项.注意有些代码耗时也会纳入系统层级，可以进行勾选前后前后对执行路径进行比对会非常有用.
* Flatten Recursion
* Top Functions