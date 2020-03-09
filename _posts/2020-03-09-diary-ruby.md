---
title: Ruby使用记录
layout: post
description: Mac环境下对Ruby的使用[卸载、安装、更新]，涉及到Brew的使用
categories:
 - diary
---

# 安装Brew

因为重新安装`Ruby`会依赖于`Brew`，所以我们先安装`Brew`环境,[Brew官网](https://brew.sh/index_zh-cn.html)。

```sh
# 根据官方的地址，安装环境
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# 如果执行上面的命令失败，可以把：https://raw.githubusercontent.com/Homebrew/install/master/install.sh 保存到本地为：install.sh
$ sh install.sh

# 如果报如下错误：
Already downloaded: /Users/shanliu/Library/Caches/Homebrew/portable-ruby-2.6.3.mavericks.bottle.tar.gz
Error: Checksum mismatch.
Expected: ab81211a2052ccaa6d050741c433b728d0641523d8742eef23a5b450811e5104
  Actual: bce400586f4c3130c46db9519de5b636f089134c7999dc665108979509a41234
 Archive: /Users/shanliu/Library/Caches/Homebrew/portable-ruby-2.6.3.mavericks.bottle.tar.gz
To retry an incomplete download, remove the file above.
Error: Failed to install vendor Ruby.

# 删除：/Users/shanliu/Library/Caches/Homebrew/portable-ruby-2.6.3.mavericks.bottle.tar.gz
# 重新执行Shell脚本
```

## 更换Brew为国内([中科大源](http://mirrors.ustc.edu.cn))镜像

```sh
$ git clone git://mirrors.ustc.edu.cn/homebrew-core.git /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core --depth=1
$ git clone git://mirrors.ustc.edu.cn/homebrew-cask.git /usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask --depth=1

$ cd /usr/local/Homebrew
$ git remote set-url origin https://mirrors.ustc.edu.cn/brew.git

$ cd /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core
$ git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git

$ cd /usr/local/Homebrew/Library/Taps/homebrew/homebrew-cask
$ git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-cask.git

# 更换完镜像后看看有没有问题
$ brew update
$ brew doctor
```

## 如果想要切回原镜像

```sh
$ cd /usr/local/Homebrew
$ git remote set-url origin https://github.com/Homebrew/brew.git

$ cd /usr/local/Homebrew/Library/Taps/homebrew/homebrew-core
$ git remote set-url origin https://github.com/Homebrew/homebrew-core.git

# 更换完镜像后看看有没有问题
$ brew update
$ brew doctor
```
# Ruby

## 卸载、重新安装

```sh
# 查看ruby版本
$ ruby -v

ruby 2.4.1p111 (2017-03-22 revision 58053) [x86_64-darwin17]

# 移除当前版本的ruby
$ rvm uninstall 2.4.1p111
# 彻底移除
$ rvm remove 2.4.1p111
# 查看当前ruby的最新版本
$ rvm list known

# MRI Rubies
[ruby-]1.8.6[-p420]
[ruby-]1.8.7[-head] # security released on head
[ruby-]1.9.1[-p431]
[ruby-]1.9.2[-p330]
[ruby-]1.9.3[-p551]
[ruby-]2.0.0[-p648]
[ruby-]2.1[.10]
[ruby-]2.2[.10]
[ruby-]2.3[.7]
[ruby-]2.4[.4]
[ruby-]2.5[.1]
[ruby-]2.6[.0-preview2]
ruby-head

# for forks use: rvm install ruby-head-<name> --url https://github.com/github/ruby.git --branch 2.2

# JRuby
jruby-1.6[.8]
jruby-1.7[.27]
jruby-9.1[.17.0]
jruby[-9.2.0.0]
jruby-head

# Rubinius
rbx-1[.4.3]
rbx-2.3[.0]
rbx-2.4[.1]
rbx-2[.5.8]
rbx-3[.100]
rbx-head

# TruffleRuby
truffleruby[-1.0.0-rc2]

# Opal
opal

# Minimalistic ruby implementation - ISO 30170:2012
mruby-1.0.0
mruby-1.1.0
mruby-1.2.0
mruby-1.3.0
mruby-1[.4.0]
mruby[-head]

# Ruby Enterprise Edition
ree-1.8.6
ree[-1.8.7][-2012.02]

# Topaz
topaz

# MagLev
maglev-1.0.0
maglev-1.1[RC1]
maglev[-1.2Alpha4]
maglev-head

# Mac OS X Snow Leopard Or Newer
macruby-0.10
macruby-0.11
macruby[-0.12]
macruby-nightly
macruby-head

# IronRuby
ironruby[-1.1.3]
ironruby-head

# 安装
$ rvm install 2.5 --disable-binary

Checking requirements for osx.
Installing requirements for osx.
Updating system............
Installing required packages: autoconf, automake, libtool, pkg-config, coreutils, libyaml, readline, libksba, openssl@1.1..-............
Certificates bundle '/usr/local/etc/openssl@1.1/cert.pem' is already up to date.
Requirements installation successful.
Installing Ruby from source to: /Users/shanliu/.rvm/rubies/ruby-2.5.1, this may take a while depending on your cpu(s)...
ruby-2.5.1 - #downloading ruby-2.5.1, this may take a while depending on your connection...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 13.3M  100 13.3M    0     0  1751k      0  0:00:07  0:00:07 --:--:-- 2922k
ruby-2.5.1 - #extracting ruby-2.5.1 to /Users/shanliu/.rvm/src/ruby-2.5.1.....
ruby-2.5.1 - #configuring...................................................................
ruby-2.5.1 - #post-configuration.
ruby-2.5.1 - #compiling...............................................................
ruby-2.5.1 - #installing.........
ruby-2.5.1 - #making binaries executable..
ruby-2.5.1 - #downloading rubygems-2.7.10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  843k  100  843k    0     0   5247      0  0:02:44  0:02:44 --:--:-- 10129
No checksum for downloaded archive, recording checksum in user configuration.
ruby-2.5.1 - #extracting rubygems-2.7.10.....
ruby-2.5.1 - #removing old rubygems........
ruby-2.5.1 - #installing rubygems-2.7.10.....................................
ruby-2.5.1 - #gemset created /Users/shanliu/.rvm/gems/ruby-2.5.1@global
ruby-2.5.1 - #importing gemset /Users/shanliu/.rvm/gemsets/global.gems...................................................
ruby-2.5.1 - #generating global wrappers.......
ruby-2.5.1 - #gemset created /Users/shanliu/.rvm/gems/ruby-2.5.1
ruby-2.5.1 - #importing gemsetfile /Users/shanliu/.rvm/gemsets/default.gems evaluated to empty gem list
ruby-2.5.1 - #generating default wrappers.......
ruby-2.5.1 - #adjusting #shebangs for (gem irb erb ri rdoc testrb rake).
Install of ruby-2.5.1 - #complete 
Ruby was built without documentation, to build it run: rvm docs generate-ri

# 查看版本
$ ruby -v
ruby 2.5.1p57 (2018-03-29 revision 63029) [x86_64-darwin18]
```

## 其他用法

```sh
# 查询已经安装的 ruby
$ rvm list

# 切换 Ruby 版本
$ rvm use 2.2.0

# 设置默认版本
rvm use 2.2.0 --default

# 如果之前安装过 RVM 想要更新 
$ rvm get stable
```

# 报错日志记录

```sh
$ rvm install 2.5 --disable-binary

Checking requirements for osx.
About to install Homebrew, press `Enter` for default installation in `/usr/local`,
type new path if you wish custom Homebrew installation (the path needs to be writable for user)
# 如果中间停顿，则是 要授权 输入  yes 即可，初次安装要等好久，切记要耐心!
: yes
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   124  100   124    0     0     34      0  0:00:03  0:00:03 --:--:--    34
100   139  100   139    0     0     32      0  0:00:04  0:00:04 --:--:--  135k
100   416    0   416    0     0     68      0 --:--:--  0:00:06 --:--:--   512
chmod: yes/bin/brew: No such file or directory
Something went wrong during Homebrew installation,
can not find 'brew' command, please report a bug: https://bit.ly/rvm-issues
Requirements installation failed with status: 1.
```

> 需要安装`brew`环境。

# 参考资料

* [brew](http://caibaojian.com/a-programmer/software/mac/softwares/brew.html)
* [Mac必备神器Homebrew](https://zhuanlan.zhihu.com/p/59805070)





























