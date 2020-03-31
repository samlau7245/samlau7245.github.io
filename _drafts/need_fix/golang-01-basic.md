---
title: Golang 基础 building...
description: Golang 基础 building...
layout: post
categories:
 - golang
---

[Go 语言中文网](http://studygolang.com)

## 环境搭建

### 安装、镜像配置

* 安装下载包：[https://studygolang.com/dl](https://studygolang.com/dl)

* 修改镜像路径

```sh
$ go env

GO111MODULE=""
GOARCH="amd64"
GOBIN=""
GOCACHE="/Users/shanliu/Library/Caches/go-build"
GOENV="/Users/shanliu/Library/Application Support/go/env"
GOEXE=""
GOFLAGS=""
GOHOSTARCH="amd64"
GOHOSTOS="darwin"
GONOPROXY=""
GONOSUMDB=""
GOOS="darwin"
GOPATH="/Users/shanliu/go"
GOPRIVATE=""
GOPROXY="https://proxy.golang.org,direct" 
GOROOT="/usr/local/go"
GOSUMDB="sum.golang.org"
GOTMPDIR=""
GOTOOLDIR="/usr/local/go/pkg/tool/darwin_amd64"
GCCGO="gccgo"
AR="ar"
CC="clang"
CXX="clang++"
CGO_ENABLED="1"
GOMOD=""
CGO_CFLAGS="-g -O2"
CGO_CPPFLAGS=""
CGO_CXXFLAGS="-g -O2"
CGO_FFLAGS="-g -O2"
CGO_LDFLAGS="-g -O2"
PKG_CONFIG="pkg-config"
GOGCCFLAGS="-fPIC -m64 -pthread -fno-caret-diagnostics -Qunused-arguments -fmessage-length=0 -fdebug-prefix-map=/var/folders/9d/ddry3pzs7vj7y3qr4tv6wh1h0000gn/T/go-build763466078=/tmp/go-build -gno-record-gcc-switches -fno-common"
```

其中`GOPROXY` 就是是`golang`的国外镜像地址，当我们需要依赖第三方库、`github`上的库的时候默认会从`GOPROXY`里面去拉取。

换成国内的镜像可以访问:[https://goproxy.cn](https://goproxy.cn)

```sh
go env -w GOPROXY=https://goproxy.cn,direct
export GOPROXY=https://goproxy.cn
```

这样`golang`的镜像就换成了国内的环境了。

另外设置下配置`GO111MODULE`：

```sh
go env -w GO111MODULE=on # 其中on必须是小写。不然会有问题:https://github.com/golang/go/issues/34880
```

* 安装[goimports](https://godoc.org/golang.org/x/tools/cmd/goimports)工具:

```sh
$ go get golang.org/x/tools/cmd/goimports
```


### `IntelliJ Idea` 安装和配置

* 安装插件：

打开`IntelliJ Idea` -> `plugins` ->搜索并且安装`go`插件->搜索并且安装`file watcher`插件。

* 创建项目：

`Create New Project` -> `Go Modules` -> 修改参数`Proxy`输入:`https://goproxy.cn,direct` -> `New Go File` -> `Kind`:`Simple Application`

* 设置偏好设置

打开偏好设置搜索：`parameter hint` -> 在`Editor->General->Appearance`中不勾选 `Show Parameter name hints` <br>
偏好设置搜索:`file watcher` -> 在`Tools->File Watcher`中新增(`+`)`goimports`->`OK`


## 基础语法

### 变量

* 变量定义出来之后就存在了初值，不像其他系统一样为空。
* 定义变量是先定义`变量名`，再定义`变量类型`。

```golang
package main

import "fmt"

// 定义类内变量(包内变量)，包内定义变量不能使用 := 进行定义。
var var1 = 1
var var2 = "a"

// 包内变量简易定义
var (
	var3 = 1
	var4 = "2"
	var5 = 6
)

// 定义函数内变量
func variable() {
	var a string
	var b int
	fmt.Printf("%q %d", a, b) // "" 0
}

func variableInitialValue() {
	var a, b int = 1, 2
	var c string = "3"
	println(a, b, c)
}

func variableTypeDedution() {
	var a, b = 1, 2
	var c = "3"
	var d, e, f = 4, "5", 6 // 编译器可以自动识别
	println(a, b, c, d, e, f)
}

func variableShorter() {
	d, e, f := 4, "5", 6 // 使用 := 时，就可以不使用var，但是 := 只适用于定义，只能在函数内使用
	println(d, e, f)
}

func main() {
	fmt.Println("hello")
	variable()
	variableInitialValue()
	variableTypeDedution()
	variableShorter()
	println(var1, var4)
}
```

### 内建变量类型

* `bool`
* `string`
* 浮点数：`float32`、`float64`、`complex64`、`complex128`
	* `complex64`、`complex128`：复数。
* 整数：`(u)int`、`(u)int8`、`(u)int16`、`(u)int32`、`(u)int64`、`uintptr`
	* `u`: 有`u`为无符号整数。
	* 规定长度(位数)整数：`(u)int8`、`(u)int16`、`(u)int32`、`(u)int64`。
	* 不规定长度整数：`(u)int` ==> 它的长度是根据系统来适应，在32位的系统中就是`(u)int32`,在64位的系统中就是`(u)int64`。
	* `uintptr`：`ptr`就是指针，指针的长度就是根据系统来定的。
* `byte`
* `rune`：这是`golang`特有类型：**字符型**,类似于`char`。现有系统中一个英语单词占用1个字节、一个汉字占用2个字节、还有些字是占用3个字节，`char`使用起来很多坑。

|char|rune|
|---|---|
|占1字节，就是8位|占4字节，就是32位|
|2^8|2^32|

**强制类型转换**

<mark>类型的转换是强制的，也就是说没有隐式转换。</mark>

```golang
// 计算直角三角形(a、b 为两个直角)的斜边长度。
func main() {
	var a, b = 3, 4
	var c int
	//c = math.Sqrt(a*a + b*b) // 报错：因为'func Sqrt(x float64) float64' 入参是float64类型，a*a + b*b的结果类型为 int，因为go不会隐式转换所有类型对不上，报错。
	//c = math.Sqrt(float64(a*a + b*b)) // 报错：因为变量'c'的类型为 int，而Sqrt的结果数据的类型为float64，同理报错。
	c = int(math.Sqrt(float64(a*a + b*b))) //运行通过,把Sqrt的入参、结果都进行强制的类型转换。
	println(c)
}

// 扩展：因为浮点类型的数据是不准确的，如果强制转换有可能会出错。比如`math.Sqrt(float64(a*a + b*b))` 的结果为4.999999，强制转int时直接变成了5而不是5。
// 所有的系统关于浮点数类型的计算都是不准确的，应该要注意这点。
```

### 常量与枚举

```golang
package main

import "math"

// 包内常量
const var1 int = 1

// 包内常量
const (
	var2 = 3
	var3 = "4"
)

func main() {
	const file = "a"  // 方法内常量
	const a, b = 3, 4 // 方法内常量，没有指定变量类型
	var c int
	c = int(math.Sqrt(a*a + b*b)) //Sqrt不报错是因为 a, b常量没有定义具体类型，编译器直接把它们作为float来使用。
	println(file, c)
	// 方法内常量
	const (
		var5 = 5
		var6 = "6"
	)
}
```

定义枚举：

> `iota`：自增值，从0开始自增。

```golang
func main() {
	// 定义枚举常量
	const (
		var1 = 1
		var2 = 2
		var3 = 3
	)
}

func main() {
	// 定义枚举常量
	const (
		var1 = iota // iota 为自增值
		var2
		var3
	)
	println(var1, var2, var3) // 0 1 2
}

func main() {
	// 计算一个内存枚举
	const (
		b  = 1 << (10 * iota)
		kb //相当于：1 << (10 * 1)
		mb //相当于：1 << (10 * 2)
		gb //相当于：1 << (10 * 3)
		tb //相当于：1 << (10 * 4)
		pb //相当于：1 << (10 * 5)
	)
	println(b, kb, mb, gb, tb, pb) // 1 1024 1048576 1073741824 1099511627776 1125899906842624
}
```

### 条件语句

#### `if`语句

* `if`条件句里面可以定义变量，这个变量的生命就在这个条件句里面。

```golang
func bounded(v int) int {
	if v > 100 {
		return 100
	} else if v < 0 {
		return 0
	} else {
		return v
	}
}

func main() {
	const filename = "abc.txt"
	// 常规写法
	contents, err := ioutil.ReadFile(filename) // ([]byte, error) 结果返回两个值,定义contents, err这两个变量去承接结果。
	if err != nil {
		println(err)
	} else {
		fmt.Printf("%s", contents)
	}

	// 优化写法
	if contents, err := ioutil.ReadFile(filename); err != nil { // 在条件句里面定义了变量：contents、err
		println(err)
	} else {
		fmt.Printf("%s", contents)
	}
}
```

#### `switch`语句

* `switch`会自动`break`，不用代码编写；除非使用`fullthrough`。
* `switch` 可以不带表达式，后面加多个条件`case`。

```golang
func switchtest(a, b int, c string) int {
	var result int
	switch c {
	case "+":
		result = a + b
	case "-":
		result = a - b
	case "*":
		result = a * b
	case "/":
		result = a / b
	default:
		panic("error" + c)
	}
	return result
}

func switchtest(a int) string {
	var result string
	switch { //switch后不带表达式也可以执行代码
	case a < 0 || a > 100:
		panic(fmt.Sprintf("error inoput:%d", a))
	case a < 60:
		result = "F"
	case a < 80:
		result = "C"
	case a < 90:
		result = "B"
	case a <= 100:
		result = "A"
	default:
		panic(fmt.Sprintf("error inoput:%d", a))
	}
	return result
}
```

### 循环语句

* `golang`中没有`while`语句，这里是通过`for`语句进行了代替。

```golang
func main() {
	sum := 0
	for i := 0; i <= 100; i++ { //条件中没有括号,存在起始条件、结束条件、递增条件
		sum += i
	}
	println(sum)
}

func main() {
	const filename = "abc.txt"
	// 常规写法
	file, err := os.Open(filename)
	if err != nil {
		println(err)
	}
	scanner := bufio.NewScanner(file)
	for scanner.Scan() { //这里只有结束条件，没有起始条件、递增条件
		println(scanner.Text())
	}
}

func main() {
	for { //不存在起始条件、结束条件、递增条件
		println("a")
	}
}

func test(n int) string {
	for ; n > 0; n / 2 = 0 { //这里没有起始条件，只有结束条件、递增条件
	}
	return ""
}
```

### 函数

```golang
// 同类型的入参可以通过','分割
func f1(a, b int, c string) {}

// 多个出参，没有变量名
func f2(a, b int) (int, int) {
	return 1, 2
}

// 多个出参，有变量名
func f3(a, b int) (c, d int) {
	if a == 1 {
		return a, b
	}
	// 这种return方式也是可以的
	c = a + 1
	d = b + 1
	return
}

// 使用
a, b := f3(2, 3) // 获取两个出参数
c, _ := f3(1, 2) // 只想获取一个参数，那可以把不想获取的参数用 '_' 代替。
```

接下来我们把前面的方法优化下：

```golang
func switchtestOld(a, b int, c string) int {
	var result int
	switch c {
	case "+":
		result = a + b
	case "-":
		result = a - b
	case "*":
		result = a * b
	case "/":
		result = a / b
	default:
		panic("error" + c) // 这里直接中断了程序。
	}
	return result
}

func switchtestNew(a, b int, c string) (int, error) { // 错误通过出参来展示，不会中断程序
	switch c {
	case "+":
		return a + b, nil
	case "-":
		return a - b, nil
	case "*":
		return a * b, nil
	case "/":
		return a / b, nil
	default:
		return 1, fmt.Errorf("error")
	}
}
```

### 指针












































































