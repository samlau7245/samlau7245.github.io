---
title: iOS自动化打包
layout: post
categories:
 - ios
---

## 报错

```sh
$ xcodebuild -help
xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance

# 解决：
$ sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer/
```

## 参考资料
* [Linux 构建/编译IOS/Mac程序](https://heroims.github.io/2017/09/10/Linux%20%E6%9E%84%E5%BB%BA:%E7%BC%96%E8%AF%91IOS:Mac%E7%A8%8B%E5%BA%8F/)
* [GitHub Actions 实现编译打包 Golang 到 Docker 镜像](https://github.red/github-actions-beginning/)
* [IOS自动化打包介绍](https://yq.aliyun.com/articles/426176)