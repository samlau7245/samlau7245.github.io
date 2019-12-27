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

打开`IntelliJ Idea` -> `plugins` ->
