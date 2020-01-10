---
title: Linux building...
description: building...
layout: post
date: 2019-12-21 05:20:00
categories:
 - linux
---

# 硬件·内核·Shell·监测

## [lsof命令](https://man.linuxde.net/lsof)

### 查看端口占用情况

```c
lsof -i:8080
```

## [kill命令](https://man.linuxde.net/kill)

### 强制终止进程

```c
kill -9 PID			# 9：信息编号
```

# 系统管理

## [systemctl命令](https://man.linuxde.net/systemctl)

systemctl命令用于进程和作业管理。

### 查看服务当前状态

```c
// 查看firewalld 防火墙的状态
systemctl status firewalld
```
