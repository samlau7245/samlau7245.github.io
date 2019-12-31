---
title: Shell基础 building...
description: building...
layout: post
date: 2019-12-21 05:20:00
categories:
 - shell
---

## Shell 环境

```
#!/bin/bash

echo "Hello World !"
```

`#!` 是一个约定的标记，它告诉系统这个脚本需要什么解释器来执行，即使用哪一种 Shell。

### shell作为可执行程序执行

```sh
cd #test.sh对应的目录
chmod +x ./test.sh #使脚本具有执行权限
./test.sh  #执行脚本
```

### shell作为解释器参数执行

直接运行解释器，其参数就是 shell 脚本的文件名。

```sh
/bin/sh test.sh
```

## Shell echo命令

用于字符串的输出。

```sh
#!/bin/sh

# 普通字符
echo "It is a test"
# It is a test 

# 转义字符
echo "\"It is a test\""
# "It is a test"

# 把界面输入的值展示出来。
read name 
echo "$name It is a test"
# ok				#标准输入
# ok It is a test	#输出

# 原样输出字符串，不进行转义或取变量(用单引号)
echo '$name\"'
# $name\"

# 显示换行
echo -e "OK! \n"
echo "It is a test"
# -e OK! 
#
# It is a test

# 显示不换行
echo -e "OK! \c" # -e 开启转义 \c 不换行
echo "It is a test"
# -e OK! It is a test

# 创建文件myfile，把echo结果输入到里面。
echo "It is a test" > myfile

# 显示命令执行结果
echo `date` 		#是反引号 `, 而不是单引号 '
# 2019年12月21日 星期六 18时05分12秒 CST
```

## Shell 变量

定义和使用变量：

```sh
#!/bin/sh

your_name="qinjx"					# 定义
echo $your_name						# 使用
echo ${your_name}					# 使用
echo "$your_name It is a test"		# 使用
```

只读变量：

```sh
#!/bin/sh

myUrl="http://www.google.com"
readonly myUrl
myUrl="http://www.runoob.com"

# 输出==> ./test.sh: line 4: myUrl: readonly variable
```

删除变量：`unset 命令不能删除只读变量`

```sh
#!/bin/sh

myUrl="http://www.runoob.com"
unset myUrl
echo $myUrl
```

| 变量类型 | 描述 |
| --- | --- |
| `局部变量` |在脚本或命令中定义，仅在当前shell实例中有效，其他shell启动的程序不能访问|
| `环境变量` |所有的程序，包括shell启动的程序，都能访问|
| `shell变量` |shell变量是由shell程序设置的特殊变量。shell变量中有一部分是环境变量，有一部分是局部变量，这些变量保证了shell的正常运行|

### 字符串

```sh
#!/bin/sh

your_name='runoob'
str="Hello, I know you are \"$your_name\"! \n"
echo -e $str
# -e Hello, I know you are "runoob"! 

your_name="runoob"
greeting="hello, "$your_name" !"
echo $greeting
greeting="hello, $your_name !"
echo $greeting
# hello, runoob !
# hello, runoob !
```

---

```sh
#!/bin/sh

# 获取字符串长度
string="abcd"
echo ${#string} 
# 4

# 提取子字符串:从字符串第 2 个字符开始截取 4 个字符
string="runoob is a great site"
echo ${string:1:4} 
# unoo
```

### 数组

`Shell`只支持一维数组。

* 创建数组：数组元素用"空格"符号分割开。

```sh
array_name=(value0 value1 value2 value3)
# 或者
array_name[0]=value0
array_name[1]=value1
array_name[n]=valuen
```

* 读取数组：
	* 通过数组下标显示每个元素。
	* 使用`@`或`*`可以获取数组中的所有元素。

```sh
my_array=(A B "C" D)
echo ${my_array[1]}
echo "数组的元素为: ${my_array[@]}"
```

* 获取数组长度

```sh
my_array=(A B "C" D)
echo "数组元素个数为: ${#my_array[@]}"
```

* 数组新增元素

```sh
#!/bin/sh
my_array=(A B "C" D)
my_array[${#my_array[*]}]=E
```

### 运算符