---
title: 开发证书管理
layout: post
categories:
 - ios
---

## Identifiers

* Description:
* Bundle ID: 
	* explicit(Check)
* Capabilities:
	* `App Groups` : APP数据共享
	* `Network Extensions` : 网络拓展
	* ` ` : 

## 证书签名请求(Certificate Signing Request(CSR))
[CSR官方教程](https://help.apple.com/developer-account/#/devbfa00fef7)

* 启动位于 /Applications/Utilities 中的“钥匙串访问”。
* 选取“钥匙串访问”>“证书助理”>“从证书颁发机构请求证书”。
* 在“证书助理”对话框中，在“用户电子邮件地址”栏位中输入电子邮件地址。
* 在“常用名称”栏位中，输入密钥的名称 (例如，Gita Kumar Dev Key)。
* 将“CA 电子邮件地址”栏位留空。
* 选取“存储到磁盘”，然后点按“继续”。

## 证书(Certificates)

生成步骤：`+ -> Certificates -> CSR -> Download`。

* Software
	* `Apple Development`:开发证书。平台: iOS、macOS、tvOS、watchOS。用于iOS11系统以上
	* `Apple Distribution`:(App Store、Ad Hoc)发布证书。平台: iOS、macOS、tvOS、watchOS。用于iOS11系统以上
	* `iOS App Development`: 内部开发证书。平台: iOS
	* `iOS Distribution`: (App Store、Ad Hoc)发布证书。平台: iOS
	* `Mac Development`: 内部开发证书。平台: Mac
	* `Mac App Distribution`: 提交给 Mac App Store 的发布证书。
	* `Mac Installer Distribution`: 提交给 Mac App Store 的PKG签名发布证书。
	* `Developer ID Installer`: 在 Mac App Store之外分发的 证书，用于开发者打包+签名。
	* `Developer ID Application`:  在 Mac App Store之外分发的 PKG签名发布证书
* Services
	* `Apple Push Notification service SSL` :  Apple(Sandbox)开发环境推送证书
		* `Platform` : `iOS`、`macOS`
		* `App ID` : 这里的ID是下拉选择，在`Identifiers`模块创建的ID。
	* `Apple Push Notification service SSL` : Apple(Sandbox & Production)生产环境推送证书
	* `macOS Apple Push Notification service SSL (Production)` : macOS(Production)推送证书
	* `Pass Type ID Certificate` : 通过类型ID证书-用于电子钱包
	* `Website Push ID Certificate` : 网站推送ID证书
	* `WatchKit Services Certificate` : WatchKit服务证书
	* `VoIP Services Certificate` : VoIP服务证书
	* `Apple Pay Payment Processing Certificate` : Apple Pay付款处理证书
	* `Apple Pay Merchant Identity Certificate` : Apple Pay商家身份证明

## 配置文件(Profiles)
通过配置文件，可以将应用程序安装到设备上。供应配置文件包括签名证书，设备标识符和应用程序ID。可以通过`测试人员的UDID`+`Profiles`把`IPA`包发给远程的人使用。

## 密钥(Keys)

创建密钥后，您可以为该密钥配置，认证和使用一项或多项Apple服务。与证书不同，密钥不会过期，可以在创建密钥后对其进行修改以访问更多服务。结果会生成一个`.p8`文件。

* `Key Name`: 随便填
* `ENABLE Server`
	* `Apple Push Notifications service (APNs)` : 消息推送服务
	* `DeviceCheck` : 设备检查 - 访问关联服务器可以在其业务逻辑中使用的每个设备，每个开发人员的数据。一键用于所有应用程序。 

## 错误收集

```
Automatic signing is unable to resolve an issue with the "xxx" target's entitlements.
Switch to manual signing and resolve the issue by downloading a matching provisioning profile from the developer website. Alternatively, to continue using automatic signing, remove these entitlements from your entitlements file and their associated functionality from your code.
```

```
Provisioning profile "iOS Team Provisioning Profile: com.xxxxxx" doesn't match the entitlements file's value for the keychain-access-groups entitlement.
```

修改配置中的`Keychain Sharing`中的值。

## 参考资料
* [Apple Store Connection 帮助](https://help.apple.com/app-store-connect/#/devdbefef011)

com.fun.more



















