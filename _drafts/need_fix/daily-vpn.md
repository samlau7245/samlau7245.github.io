---
title: 科学上网学习
layout: post
categories:
 - diary
---

科学上网工具：`ShadowSocksR`、`V2Ray`、`WireGuard`、`谷歌云`、`搬瓦工`。


# VPS

* `加密型数据`：就是把数据包加密，让墙看不到包内的数据，但是墙可以通过测量加密包的大小来进行拦截。
* `伪装型数据(HTTPS)`：把数据伪装成主流的HTTPS加密数据，让墙从海量的数据流中也找不到你的数据包。

`Trojan`和`V2Ray`的`WebSockt+TLS`这两种模式非常相似，他们可以模拟出HTTPS来诱骗墙认为你的数据包就是HTTPS，从而不被识别。

## Trojan

[全系统支持，Trojan一键安装脚本，自动续签SSL证书，自动配置伪装网站，支持centos7+/debian9+/ubuntu16+](https://www.v2rayssr.com/trojan-1.html)

## V2Ray

```sh
yum install -y wget && wget https://raw.githubusercontent.com/V2RaySSR/V2RaySSR/master/v2ray_ws_tls_wp.sh && chmod +x v2ray_ws_tls_wp.sh && ./v2ray_ws_tls_wp.sh

# V2RAY 配置信息在以下目录: /etc/v2ray/myconfig.json
# 强制更新 SSL 证书
acme.sh --cron -f
```

## SSR

* [V2Ray一键安装/TG电报代理搭建/BBR开启/SS代理/多合一脚本/FOR/233boy](https://www.v2rayssr.com/233v2ray.html)

## 安装BBR

```sh
wget -N --no-check-certificate "https://raw.githubusercontent.com/chiakge/Linux-NetSpeed/master/tcp.sh"
chmod +x tcp.sh
./tcp.sh
# 最好用的是 BBR Plus
```

## 参考资料

* [Project V](https://v2ray.com/)
* [千影-BBR](https://www.94ish.me/)
* [v2ray综合网](https://www.v2rayssr.com/)
* [检查IP](https://www.vps234.com/ipchecker/)
* [SSL](https://www.v2rayssr.com/v2raywstls.html)

# 软路由
* `刷梅林固件`：
* `软路由`：

# NAS



`Hostwinds`





https://www.namesilo.com samlaunamesilo namesilo/7245
samlau7245@icloud.com

https://github.com/yanue/V2rayU/releases

https://github.com/shadowsocks/shadowsocks-iOS/wiki/Shadowsocks-for-OSX-Help

https://github.com/search?q=Shadowsocks+iOS&type=Repositories