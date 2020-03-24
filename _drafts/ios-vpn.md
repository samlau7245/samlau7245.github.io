---
title: iOS端VPN逻辑
layout: post
categories:
 - ios
---

为了实现满足设备对VPN的要求，苹果公司创建了一套[NetworkExtension网络框架](https://developer.apple.com/documentation/networkextension?language=objc)以允许开发人员轻松创建VPN应用程序。

## `NetworkExtension`iOS网络扩展库学习

* 更改系统的Wi-Fi配置
* 将您的应用程序与热点网络子系统集成（“热点助手”）
* 使用内置VPN协议（个人VPN）或自定义VPN协议创建和管理VPN配置
* 实施设备上的内容过滤器
* 实施设备上的DNS代理

API支持的协议：

* 使用[个人VPN](https://developer.apple.com/documentation/networkextension/personal_vpn?language=objc)创建和管理使用内置VPN协议（IPsec或IKEv2）之一的VPN配置。
* 创建一个[数据包隧道提供程序](https://developer.apple.com/documentation/networkextension/packet_tunnel_provider?language=objc)以为面向数据包的自定义VPN协议实现VPN客户端
* 创建一个[应用程序代理提供程序](https://developer.apple.com/documentation/networkextension/app_proxy_provider?language=objc)，以为面向流的自定义VPN协议实现VPN客户端。
* iOS 提供[永远在线VPN](https://support.apple.com/zh-cn/guide/deployment-reference-ios/iore8b083096/1/web/1)，以确保所有IP流量都通过隧道传输回组织。

### Wi-Fi管理

#### Wi-Fi配置

使用`NEHotspotConfigurationManager`类，创建两种不同方式的Wi-Fi管理方式，用户必须明确授权这两个操作。

* 永久配置，等同于用户使用“设置”应用加入Wi-Fi网络
* 一次加入配置，可将设备暂时移至特定的Wi-Fi网络

`NEHotspotConfigurationManager`支持多种身份验证模型：

* 没有身份验证的SSID
* 具有基于密码的身份验证的SSID（WEP，WPA和WPA2）
* 具有EAP身份验证的SSID
* 具有EAP身份验证的Hotspot 2.0

```objc
@interface NEHotspotConfigurationManager : NSObject
@property (class, readonly, strong) NEHotspotConfigurationManager *sharedManager;

- (void)applyConfiguration:(NEHotspotConfiguration *)configuration completionHandler:(void (^)(NSError * error))completionHandler;
@end
```

```objc
@interface NEHotspotConfiguration : NSObject <NSCopying,NSSecureCoding>
@property (readonly) NSString * SSID; // >=iOS11
@property (readonly) NSString * SSIDPrefix; // >=iOS11
@property BOOL joinOnce; // >=iOS11，默认NO。如果设置为YES则Wi-Fi为长久连接。
// 配置的生命周期，以天为单位。 配置将存储此属性指定的天数。 最小值为1天，最大值为365天。 如果未设置此属性或将其设置为无效值，则不会自动删除配置。 此属性不适用于企业和HS2.0网络。
@property (copy) NSNumber * lifeTimeInDays; // >=iOS11
// 如果设置为YES，则系统将对SSID执行主动扫描。 默认为“否”。
@property BOOL hidden; // >=iOS11

// 为开放的Wi-Fi网络创建一个由SSID标识的新热点配置。
-(instancetype)initWithSSID:(NSString*)SSID; // >=iOS11
// 为受保护的WEP或WPA / WPA2个人Wi-Fi网络创建一个由SSID标识的新热点配置。
// passphraseis：密码短语凭证。Static WEP(64bit):10 HexDigits Static WEP(128bit):26HexDigits
// YES:指定WEP Wi-Fi网络。NO：指定WPA/WPA2个人Wi-Fi网络
-(instancetype)initWithSSID:(NSString*)SSID passphrase:(NSString*)passphraseis WEP:(BOOL)isWEP; // >=iOS11
// 为具有EAP设置的WPA / WPA2企业Wi-Fi网络创建一个由SSID标识的新热点配置。
-(instancetype)initWithSSID:(NSString*)SSID eapSettings:(NEHotspotEAPSettings*)eapSettings; // >=iOS11
// 为受保护的WEP或WPA / WPA2个人Wi-Fi网络创建一个新的热点配置，由SSID前缀字符串标识。
-(instancetype)initWithSSIDPrefix:(NSString*)SSID Prefixpassphrase:(NSString*)passphraseis WEP:(BOOL)isWEP; // >=iOS11

// 为具有HS 2.0和EAP设置的Hotspot 2.0 Wi-Fi网络创建一个新的热点配置，该配置由域名标识。
-(instancetype)initWithHS20Settings:(NEHotspotHS20Settings*)hs20Settings eapSettings:(NEHotspotEAPSettings*)eapSettings; // >=iOS13
// 为开放的Wi-Fi网络创建由SSID前缀字符串标识的新热点配置。
-(instancetype)initWithSSIDPrefix:(NSString*)SSIDPrefix; // >=iOS13
@end
```

#### 热点助手
`NEHotspotHelper`允许您的应用参与热点网络。

```objc
@interface NEHotspotHelper : NSObject
// 将应用程序注册为热点助手
+ (BOOL)registerWithOptions:(nullable NSDictionary<NSString *,NSObject *> *)options queue:(dispatch_queue_t)queue handler:(NEHotspotHelperHandler)handler;
// 终止Hotspot网络的身份验证会话
+ (BOOL)logoff:(NEHotspotNetwork *)network;
// 获取热点网络状态
+ (NSArray *_Nullable)supportedNetworkInterfaces;
@end
```

### 虚拟私人网络

#### 个人VPN(Personal VPN)

个人VPN可以创建和管理使用内置VPN协议(IPsec、IKEv2)的VPN协议。用户必须在首次保存VPN配置时明确授权你的应用。

> 个人VPN仅支持推荐的VPN协议；它不支持传统的VPN协议，例如PPTP和L2TP。

##### NEVPNManager

`NEVPNManager`：创建和管理个人VPN配置。

```objc
@interface NEVPNManager : NSObject
@property (copy, nullable) NSArray<NEOnDemandRule *> *onDemandRules;
@property (getter=isOnDemandEnabled) BOOL onDemandEnabled;
@property (copy, nullable) NSString *localizedDescription;
@property (strong, nullable) NEVPNProtocol *protoco;
@property (strong, nullable) NEVPNProtocol *protocolConfiguration;
@property (readonly) NEVPNConnection *connectio;
@property (getter=isEnabled) BOOL enabled;

+ (NEVPNManager *)sharedManager;
// 从网络扩展首选项中加载VPN配置。
- (void)loadFromPreferencesWithCompletionHandler:(void (^)(NSError *  error))completionHandler;
// 从网络扩展首选项中删除VPN配置。
- (void)removeFromPreferencesWithCompletionHandler:(nullable void (^)(NSError *  error))completionHandler;
// 将VPN配置保存在“网络扩展”首选项中。
- (void)saveToPreferencesWithCompletionHandler:(nullable void (^)(NSError *  error))completionHandler;

// TARGET_OS_OSX
- (void)setAuthorization:(AuthorizationRef)authorization
@end
```

##### NEVPNConnection

`NEVPNConnection` 用于启动或者停止个人VPN的连接、获取连接状态。

```objc
@interface NEVPNConnection : NSObject
// 系统通知
NEVPN_EXPORT NSString * const NEVPNStatusDidChangeNotification;// VPN状态改变时会触发此通知
NEVPN_EXPORT NSString * const NEVPNConnectionStartOptionUsername;
NEVPN_EXPORT NSString * const NEVPNConnectionStartOptionPassword;

// VPN连接的当前状态
/*
	NEVPNStatusInvalid = 0,
	NEVPNStatusDisconnected = 1,
	NEVPNStatusConnecting = 2,
	NEVPNStatusConnected = 3,
	NEVPNStatusReasserting = 4,
	NEVPNStatusDisconnecting = 5,
*/
@property (readonly) NEVPNStatus status;
// 连接状态更改为的日期和时间。N
@property (readonly, nullable) NSDate *connectedDate;
// 获取VPN连接状态
@property (readonly) NEVPNManager *manager;

// 开始连接VPN的过程
- (BOOL)startVPNTunnelAndReturnError:(NSError **)error;
// 开始连接VPN的过程
// options：
// error： 可能的错误包括：NEVPNErrorConfigurationInvalid 、 NEVPNErrorConfigurationDisabled
- (BOOL)startVPNTunnelWithOptions:(nullable NSDictionary<NSString *,NSObject *> *)options andReturnError:(NSError **)error;
// 开始断开VPN连接的过程。
- (void)stopVPNTunnel;
@end
```

##### 整体流程

```objc
-(void)personal_vpn{
    // 加载VPN配置
    [[NEVPNManager sharedManager] loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        // 如果以前没有保存过VPN配置，会返回一个nil的配置。
        if (!error) {
            // 根据需求修改配置，然后保存VPN配置
            [[NEVPNManager sharedManager] saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                // 开始连接VPN
                [[NEVPNManager sharedManager].connection startVPNTunnelAndReturnError:nil];
            }];
        }
    }];
}
```

#### 分组隧道提供商(Packet Tunnel Provider)
`虚拟专用网络(VPN)`是一种网络隧道，其中VPN客户端使用公共Internet创建与VPN服务器的连接，然后通过该连接传递专用网络流量。要构建实现面向数据包的自定义VPN协议的VPN客户端，需要创建一个数据包隧道提供程序应用程序扩展(a packet tunnel provider app extension)。

##### 添加网络扩展
* key：`com.apple.developer.networking.networkextension`
* value是字符串数组：
	* `dns-proxy`: 用于代理DNS查询的API。
	* `app-proxy-provider`: 用于代理TCP和UDP连接的API。
	* `content-filter-provider`: 您用于允许或拒绝系统上其他应用程序创建的网络连接的筛选器API。
	* `packet-tunnel-provider`: 使用任何自定义隧道协议将IP数据包隧道到远程网络的API。
	* `dns-proxy-systemextension`: 与开发人员ID配置文件签名后，用于代理DNS查询的API。
	* `app-proxy-provider-systemextension`: 与开发人员ID配置文件签名后，用于代理TCP和UDP连接的API。
	* `content-filter-provider-systemextension`: 使用开发人员ID配置文件签名时，用于允许或拒绝系统上其他应用程序创建的网络连接的筛选器API。
	* `packet-tunnel-provider-systemextension`: 与开发人员ID配置文件签名后，可使用任何自定义隧道协议将IP数据包隧道传输到远程网络的API。

要将上面的权限元素添加到项目配置中，并且在Xcode中添加网络扩展。

* 在开发人员站点的“证书，标识符和配置文件”部分中，为开发人员ID签名的应用程序启用网络扩展功能。生成一个新的配置文件并下载。
* 在Mac上，将下载的配置文件拖动到Xcode进行安装。
* 在您的Xcode项目中，启用手动签名并选择先前下载的配置文件及其关联的证书。
* 更新项目以包括密钥和权利的值。`entitlements.plistcom.apple.developer.networking.networkextension`

##### 分组隧道提供商(Packet Tunnel Provider)

`NEPacketTunnelProvider`允许其子类通过`packetFlow`属性来访问虚拟网络接口。使用`NETunnelProvider`的`setTunnelNetworkSettings:`方法来指定以下网络设置与虚拟接口相关联：

* 虚拟的IP地址。(Virtual IP address)
* DNS解析器配置(DNS resolver configuration)
* HTTP代理配置(HTTP proxy configuration)
* IP目的网络将通过隧道进行路由(IP destination networks to be routed through the tunnel)
* IP目标网络将在隧道外进行路由(IP destination networks to be routed outside the tunnel)
* MTU接口(Interface MTU)

通过指定IP目标网络，分组隧道提供商(Packet Tunnel Provider)可以决定将哪些目标IP会被路由到虚拟接口。匹配了目标地址的IP数据包将被转移到数据包隧道提供(Packet Tunnel Provider)程序，可以使用`packetFlow`属性读取。<br>
分组隧道提供商(Packet Tunnel Provider)可以按照自定义隧道协议(custom tunneling protocol)封装IP数据包，并将其发送到隧道服务器(tunnel server)。解封装从隧道服务器(tunnel server)收到的IP数据包。可以使用`packetFlow`属性将数据包注入网络堆栈。

> 要想使用`NEPacketTunnelProvider`类，必须先添加`com.apple.developer.networking.networkextension`。在程序员开发应用程序ID时，启动这个权限。


[SimpleTunnel：使用NetworkExtension框架的自定义网络](https://developer.apple.com/library/archive/samplecode/SimpleTunnel/Introduction/Intro.html#//apple_ref/doc/uid/TP40016140)

[NEPacketTunnelProvider](https://developer.apple.com/documentation/networkextension/nepackettunnelprovider?language=objc)

```objc
// 类的继承关系：`NSObject->NEProvider->NETunnelProvider->NEPacketTunnelProvider`。

@interface NEPacketTunnelProvider : NETunnelProvider
// 用于接收路由到隧道的虚拟接口的IP数据包，并将IP数据包通过隧道的虚拟接口注入到网络堆栈中
@property (readonly) NEPacketTunnelFlow *packetFlow;
//===管理隧道生命周期===
// 启动网络隧道。创建新隧道时，框架会调用此函数。 子类必须重写此方法以执行建立隧道所需的任何步骤。
- (void)startTunnelWithOptions:(nullable NSDictionary<NSString *,NSObject *> *)options completionHandler:(void (^)(NSError * error))completionHandler;
// 停止网络隧道。销毁隧道时，框架会调用此函数。 子类必须重写此方法，以执行拆除隧道所需的任何步骤。
- (void)stopTunnelWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler;
// 停止从数据包隧道提供程序的网络隧道。遇到网络错误使隧道不再可用时，隧道提供程序实现会调用此函数以启动隧道销毁。 子类不应覆盖此方法。
- (void)cancelTunnelWithError:(nullable NSError *)error;

// ===通过隧道创建网络连接===
// 通过当前隧道创建TCP连接
- (NWTCPConnection *)createTCPConnectionThroughTunnelToEndpoint:(NWEndpoint *)remoteEndpoint enableTLS:(BOOL)enableTLS TLSParameters:(nullable NWTLSParameters *)TLSParameters delegate:(nullable id)delegate;
// 通过当前隧道创建UDP会话
- (NWUDPSession *)createUDPSessionThroughTunnelToEndpoint:(NWEndpoint *)remoteEndpoint fromEndpoint:(nullable NWHostEndpoint *)localEndpoint;
@end

@interface NETunnelProvider : NEProvider
// 指定当前隧道会话的网络设置。
// tunnelNetworkSettings :用于隧道的网络设置。传递nil清除当前隧道会话的网络设置。
- (void)setTunnelNetworkSettings:(nullable NETunnelNetworkSettings *)tunnelNetworkSettings completionHandler:(nullable void (^)( NSError * error))completionHandler;
@end

// 隧道会话的网络设置
@interface NETunnelNetworkSettings : NSObject <NSSecureCoding,NSCopying>
// 初始化隧道网络设置
- (instancetype)initWithTunnelRemoteAddress:(NSString *)address;
// 隧道服务器的IP地址
@property (readonly) NSString *tunnelRemoteAddress;
// 隧道DNS设置
@property (copy, nullable) NEDNSSettings *DNSSettings;
// 隧道HTTP代理设置
@property (copy, nullable) NEProxySettings *proxySettings;
@end

// 网络隧道的DNS解析器设置
@interface NEDNSSettings : NSObject <NSSecureCoding,NSCopying>
- (instancetype)initWithServers:(NSArray<NSString *> *)servers;
// DNS服务器IP地址
@property (readonly) NSArray<NSString *> *servers;
// 域字符串列表，用于完全限定单标签主机名。
@property (copy, nullable) NSArray<NSString *> *searchDomains;
// 隧道的主域。
@property (copy, nullable) NSString *domainName;
// 域字符串列表，用于确定哪些DNS查询将使用此对象中包含的DNS解析器设置。
@property (copy, nullable) NSArray<NSString *> *matchDomains;
// 指定列表中的域是否不应附加到解析程序的搜索域列表中。
@property BOOL matchDomainsNoSearch;
@end

// HTTP代理设置
@interface NEProxySettings : NSObject <NSSecureCoding,NSCopying>
// ====访问自动代理属性====
// 指示是否启用了代理自动配置
@property BOOL autoProxyConfigurationEnabled;
// 它指定从中应下载代理服务器自动配置（PAC）脚本的位置。
@property (copy, nullable) NSURL *proxyAutoConfigurationURL;
// 包含代理自动配置（PAC）JavaScript源代码的字符串
@property (copy, nullable) NSString *proxyAutoConfigurationJavaScript;

// ====访问手动代理属性====
// 指示是否使用静态HTTP代理
@property BOOL HTTPEnabled;
// 包含静态HTTP代理服务器设置的对象
@property (copy, nullable) NEProxyServer *HTTPServer;
// 指示是否将使用静态HTTPS代理
@property BOOL HTTPSEnabled;
// 包含静态HTTPS代理服务器设置的对象
@property (copy, nullable) NEProxyServer *HTTPSServer;

// ====访问常规代理属性====
// 指示是否应将使用单标签主机名的HTTP请求排除在代理设置之外
@property BOOL excludeSimpleHostnames;
// 域名模式数组。如果HTTP连接的目标主机名与这些模式之一匹配，则代理设置将不用于连接。
@property (copy, nullable) NSArray<NSString *> *exceptionList;
// 域字符串数组。如果HTTP连接的目标主机名与这些字符串之一共享后缀，则代理设置将用于HTTP连接。否则将不使用代理设置。
@property (copy, nullable) NSArray<NSString *> *matchDomains;
@end

// 代理服务器的设置
@interface NEProxyServer : NSObject <NSSecureCoding,NSCopying>
// 初始化
- (instancetype)initWithAddress:(NSString *)address port:(NSInteger)port;
// 代理服务器的地址。
@property (readonly) NSString *address;
// 代理服务器正在侦听连接的TCP端口。
@property (readonly) NSInteger port;
// 一个布尔值，指示服务器是否需要身份验证凭据。
@property BOOL authenticationRequired;
// 身份验证凭据的用户名部分，用于与代理服务器进行身份验证。
@property (copy, nullable) NSString *username;
// 身份验证凭据的密码部分，用于与代理服务器进行身份验证。
@property (copy, nullable) NSString *password;
@end

// 用于在隧道的虚拟接口之间读取和写入数据包的对象。
@interface NEPacketTunnelFlow : NSObject
- (void)readPacketsWithCompletionHandler:(void (^)(NSArray<NSData *> *packets, NSArray<NSNumber *> *protocols))completionHandler;
- (BOOL)writePackets:(NSArray<NSData *> *)packets withProtocols:(NSArray<NSNumber *> *)protocols;
- (void)readPacketObjectsWithCompletionHandler:(void (^)(NSArray<NEPacket *> *packets))completionHandler;
- (BOOL)writePacketObjects:(NSArray<NEPacket *> *)packets;
@end
```

##### 封包处理(Packet Handling)
https://developer.apple.com/documentation/networkextension?language=objc

##### VPN配置(VPN Configuration)
##### VPN控制(VPN Control)

#### 应用代理提供商(App Proxy Provider)

### 内容过滤器
### DNS代理

## 参考资料
* [Apple-NetworkExtension](https://developer.apple.com/documentation/networkextension?language=objc)
* [Personal VPN](https://developer.apple.com/documentation/networkextension/personal_vpn?language=objc)
* [How To Build an OpenVPN Client on iOS](https://medium.com/better-programming/how-to-build-an-openvpn-client-on-ios-c8f927c11e80)
* [Apple Developer Forums-want to build my own vpn app](https://forums.developer.apple.com/thread/74786)
* [iPhone 和 iPad 部署参考](https://support.apple.com/zh-cn/guide/deployment-reference-ios/welcome/web)
* [Mac的网络框架-Core WLAN](https://developer.apple.com/documentation/corewlan?language=objc)



































