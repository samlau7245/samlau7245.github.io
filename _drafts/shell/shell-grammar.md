---
title: Shell 基础语法
layout: post
categories:
 - shell
---

## 变量

```sh
# 定义变量
your_name="runoob.com"

# 使用变量
echo $your_name
echo ${your_name}

# 在字符串中使用变量
echo "I am good at ${your_name} Script"
```

示例

```sh
#!/bin/bash
your_name="AAA"
echo your_name
echo $your_name
your_name="BBB"
echo "I am good at ${your_name} Script"

# your_name
# AAA
# I am good at BBB Script
```

### 只读变量

```sh
#!/bin/bash
myUrl="https://www.google.com"
readonly myUrl
```

### 删除变量

> 变量被删除后不能再次使用。unset 命令不能删除只读变量。

```sh
#!/bin/sh
myUrl="https://www.runoob.com"
unset myUrl
echo $myUrl # 没有输出
```

### 变量类型

* `局部变量` 局部变量在脚本或命令中定义，仅在当前shell实例中有效，其他shell启动的程序不能访问局部变量。
* `环境变量` 所有的程序，包括shell启动的程序，都能访问环境变量，有些程序需要环境变量来保证其正常运行。必要的时候shell脚本也可以定义环境变量。
* `shell变量` shell变量是由shell程序设置的特殊变量。shell变量中有一部分是环境变量，有一部分是局部变量，这些变量保证了shell的正常运行。

### 传递参数

* 在执行脚本时，向脚本传递参数，脚本内获取参数的格式为：**$n**。**n** 代表一个数字，1 为执行脚本的第一个参数，2 为执行脚本的第二个参数……
* **$0** 为执行的文件名。

```sh
#!/bin/bash
echo "Shell 传递参数实例！";
echo "执行的文件名：$0";
echo "第一个参数为：$1";
echo "第二个参数为：$2";
echo "第三个参数为：$3";

# % sh example.sh
# --------------
# Shell 传递参数实例！
# 执行的文件名：example.sh
# 第一个参数为：
# 第二个参数为：
# 第三个参数为：
# --------------

# % sh example.sh 1 2 3
# --------------
# Shell 传递参数实例！
# 执行的文件名：example.sh
# 第一个参数为：1
# 第二个参数为：2
# 第三个参数为：3
# --------------
```

几个特殊的处理参数：

```sh
#!/bin/bash
# 脚本运行的当前进程ID号
echo $$; # 78002

# 传递到脚本的参数个数
echo $#; 
# $ sh example.sh 1 2 3
# 3

# 显示最后命令的退出状态。0表示没有错误，其他任何值表明有错误。
echo $?; # 0

# 以一个单字符串显示所有向脚本传递的参数。
echo $*;
# $ sh example.sh 1 2 3
# 1 2 3

echo $@;
# $ sh example.sh 1 2 3
# 1 2 3

echo "-- \$* 演示 ---"
for i in "$*"; do
	echo $i;
done
# $ sh example.sh 1 2 3
# -- $* 演示 ---
# 1 2 3

echo "-- \$@ 演示 ---"
for i in "$@"; do
    echo $i
done
# $ sh example.sh 1 2 3
#-- $@ 演示 ---
#1
#2
#3
```

`$*` 与`$@` 区别：

* 相同点：都是引用所有参数。
* 不同点：只有在双引号中体现出来。假设在脚本运行时写了三个参数 1、2、3，，则`*`等价于 "1 2 3"（传递了一个参数），而`@`等价于 "1" "2" "3"（传递了三个参数）。

#### 设置权限

* 执行`chmod +x`，可以为脚本设置可执行权限，并执行脚本。

```sh
$ chmod +x test.sh 
$ ./test.sh 1 2 3
```

<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## 类型

### 字符串

#### 定义

* 通过`\"`可以在字符串中展示`"`。

```sh
#!/bin/bash
echo "I am good at \"Script\""
# I am good at "Script"
```

#### 长度

```sh
#!/bin/bash
string="abcd"
echo ${#string} #输出 4
```

#### 遍历

> 第一个字符的索引值为**0**。

```sh
#!/bin/bash
string="runoob is a great site"
echo ${string:1:4} # 输出 unoo
```

### 数组

#### 定义

* 用**括号**来表示数组，数组元素用**空格**符号分割开。`数组名=(值1 值2 ... 值n)`
* 支持一维数组。

```sh
#!/bin/bash
array_name=(value0 value1 value2 value3)

# 或者
array_name=(
value0
value1
value2
value3
)

# 还可以单独定义数组的各个分量
array_name[0]=value0
array_name[1]=value1
array_name[n]=valuen
```

#### 读取

* 格式： `数组名[下标]`。
* 使用`数组名[@]`、`数组名[*]`可以获取数组中的所有元素。

```sh
#!/bin/bash
array=(
	1
	2
	"3"
	)
array[3]=4

echo ${array[1]} # 2
echo ${array[@]} # 1 2 3 4
```

#### 长度

* 整个数组长度：`#array_name[@]`、`#array_name[*]`。
* 数组单个元素的长度：`#array_name[n]`。

```sh
#!/bin/bash
array=( 1 2 "AAA" 4)
echo ${#array[@]} # 4
echo ${#array[*]} # 4
echo ${#array[2]} # 3
```

<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## 运算符

### 算数运算符

* `expr` 是一款表达式计算工具，使用它能完成表达式的求值操作。
* 完整的表达式要被**\`\`**包含。
* 表达式和运算符之间要有空格，例如 2+2 是不对的，必须写成 2 + 2。
* 乘号(\*)前边必须加反斜杠(\)才能实现乘法运算
* 算术运算符： `+`、`-`、`*`、`/`、`%`、`=`、`==`、`!=`

<img src="/assets/images/shell/01.png"/>

> 条件表达式要放在方括号之间，并且要有空格，例如: [$a==$b] 是错误的，必须写成 [ $a == $b ]。

```sh
#!/bin/bash
a=10
b=20

val=`expr $a + $b`
echo "a + b : $val"

val=`expr $a - $b`
echo "a - b : $val"

val=`expr $a \* $b`
echo "a * b : $val"

val=`expr $b / $a`
echo "b / a : $val"

val=`expr $b % $a`
echo "b % a : $val"
```

### 关系运算符

* 关系运算符只支持数字，不支持字符串，除非字符串的值是数字。
* 关系运算符： `-eq`、`-ne`、`-gt`、`-lt`、`-ge`、`-le`

<img src="/assets/images/shell/02.png"/>

```sh
#!/bin/bash
a=10
b=20
if [[ $a -eq $b ]]; then echo "\"-eq\":true" ; else echo "\"-eq\":false" ; fi ;
if [[ $a -ne $b ]]; then echo "\"-ne\":true" ; else echo "\"-ne\":false" ; fi ;
if [[ $a -gt $b ]]; then echo "\"-gt\":true" ; else echo "\"-gt\":false" ; fi ;
if [[ $a -lt $b ]]; then echo "\"-lt\":true" ; else echo "\"-lt\":false" ; fi ;
if [[ $a -ge $b ]]; then echo "\"-ge\":true" ; else echo "\"-ge\":false" ; fi ;
if [[ $a -le $b ]]; then echo "\"-le\":true" ; else echo "\"-le\":false" ; fi ;

# "-eq":false
# "-ne":true
# "-gt":false
# "-lt":true
# "-ge":false
# "-le":true
```

### 布尔运算符

* 布尔运算符 ： `!`、`-o`、`-a`

<img src="/assets/images/shell/03.png"/>

### 逻辑运算符

* 逻辑运算符 ： `&&`、`||`

<img src="/assets/images/shell/04.png"/>

### 字符串运算符

* 字符串运算符 ： `=`、`!=`、`-z`、`-n`、`$`

<img src="/assets/images/shell/05.png"/>

```sh
#!/bin/bash
a=10
b=20
if [[ $a = $b ]]; then echo "true" ; else echo "false" ; fi ; # false
if [[ $a != $b ]]; then echo "true" ; else echo "false" ; fi ; # true
if [[ -z $a ]]; then echo "true" ; else echo "false" ; fi ; # false
if [[ -n $a ]]; then echo "true" ; else echo "false" ; fi ; # true
if [[ $a ]]; then echo "true" ; else echo "false" ; fi ; # true
```

### 文件测试运算符

* 文件测试运算符 ： `-b`、`-c`、`-d`、`-f`、`-g`、`-k`、`-p`、`-u`、`-r`、`-w`、`-x`、`-s`

<img src="/assets/images/shell/06.png"/>

```sh
#!/bin/bash
file="/var/www/runoob/test.sh"
if [ -r $file ]
then
   echo "文件可读"
else
   echo "文件不可读"
fi
```

<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## 条件语句

### if 条件

```sh
#========if=======
if [ condition ]
then
	#statements
fi

#=======if else========
if [ condition ]; then
	#statements
else
	#statements
fi 
#=========if else-if else======
if [ condition ]; then
	#statements
elif [ condition ]; then
	#statements
else
	#statements
fi
```

```sh
#!/bin/bash
a=10
b=20
# && 逻辑运算符 逻辑的 AND
if [[ $a -eq 10 && $b -eq 20 ]]; then echo "true" ; else echo "false" ; fi ; # true
if [[ $a -eq 20 && $b -eq 20 ]]; then echo "true" ; else echo "false" ; fi ; # false

if [ $a -eq 10 && $b -eq 20 ]; then echo "true" ; else echo "false" ; fi ; # example.sh: line 7: [: missing `]'
if [ $a -eq 20 && $b -eq 20 ]; then echo "true" ; else echo "false" ; fi ; # example.sh: line 8: [: missing `]'

# -a 布尔运算符 与运算，两个表达式都为 true 才返回 true。
if [ $a -eq 10 -a $b -eq 20 ]; then echo "true" ; else echo "false" ; fi ; # true
if [ $a -eq 20 -a $b -eq 20 ]; then echo "true" ; else echo "false" ; fi ; # false

# ============= || VS -o ===============
if [[ $a -eq 10 || $b -eq 20 ]]; then echo "true" ; else echo "false" ; fi ; # true
if [[ $a -eq 20 || $b -eq 20 ]]; then echo "true" ; else echo "false" ; fi ; # true

if [ $a -eq 10 || $b -eq 20 ]; then echo "true" ; else echo "false" ; fi ; # example.sh: line 7: [: missing `]'
if [ $a -eq 20 || $b -eq 20 ]; then echo "true" ; else echo "false" ; fi ; # example.sh: line 8: [: missing `]'

if [ $a -eq 10 -o $b -eq 20 ]; then echo "true" ; else echo "false" ; fi ; # true
if [ $a -eq 20 -o $b -eq 20 ]; then echo "true" ; else echo "false" ; fi ; # true	
```

* 可以知道，逻辑运算符`&&` + `[[`，与之等效果的是：布尔运算符`-a`+`[`。
* 可以知道，逻辑运算符`||` + `[[`，与之等效果的是：布尔运算符`-o`+`[`。

|对比|`[]`|`[[]]`|
| --- | --- | --- |
|文件测试运算符|`-b`、`-c`、`-d`、`-f`、`-g`、`-k`、`-p`、`-u`、`-r`、`-w`、`-x`、`-s`|等同`[]`|
|关系运算符|`-eq`、`-ne`、`-gt`、`-lt`、`-ge`、`-le`|等同`[]`|
|逻辑运/布尔运算符|`!`、`-o`、`-a`|`&&`、`||`|



### case 条件
### for 循环
### while 循环

<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## 函数

<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->

## 参数

<!-- 










 -->
<!-- ==================================================================================================== -->
<!-- 










 -->
