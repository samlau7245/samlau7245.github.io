---
title: Spring Security技术栈开发企业级认证与授权
layout: post
description: Spring Security技术栈开发企业级认证与授权。
categories:
 - spring-security
---

## 前言

* 每一节课创建一个分支(branch)。
* [上每节课程之前先把代码拉下来预热](https://git.imooc.com/coding-134/security-new/branches)

## 环境安装

* JDK、[STS(Spring Tool Suite)](https://spring.io/tools3/sts/all)、MySql

## `Spring-Tool-Suite` 使用

### 快捷键

* `cmd+shift+f`: 格式化代码


`Create a Maven project` ->`[√]Create a simple project ` & [next >]

* `Group Id`:坐标，一般格式为：域[org(非营利)、com(商业组织)...].公司名.项目名
* `Artifact Id`:项目名
* `Version`:设置版本
* `Packaging`:包的形式 `pom` `jar` `war`

## 搭建项目基础架构

### 代码结构

![项目结构](/assets/images/ss_tec/01.png)

* `imooc-security`：主项目，没有具体代码，作用就是把其他模块给统一起来让子模块统一的去执行Maven命令。
* `imooc-security-core`：核心代码。
* `imooc-security-borower`：浏览器安全代码。
* `imooc-security-app`：APP安全代码。
* `imooc-security-demo`：样例。

### 创建`imooc-security`
