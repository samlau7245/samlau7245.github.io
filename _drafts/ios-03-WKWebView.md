---
title: WKWebView building...
description: WKWebView building...
layout: post
categories:
 - ios
---

**类**

* `WKBackForwardList`: 之前访问过的 web 页面的列表，可以通过后退和前进动作来访问到。
* `WKBackForwardListItem`: webview 中后退列表里的某一个网页。
* `WKFrameInfo`: 包含一个网页的布局信息。
* `WKNavigation`: 包含一个网页的加载进度信息。
* `WKNavigationAction`: 包含可能让网页导航变化的信息，用于判断是否做出导航变化。
* `WKNavigationResponse`: 包含可能让网页导航变化的返回内容信息，用于判断是否做出导航变化。
* `WKPreferences`: 概括一个 webview 的偏好设置。
* `WKProcessPool`: 表示一个 web 内容加载池。
* `WKUserContentController`: 提供使用 JavaScript post 信息和注射 script 的方法。
* `WKScriptMessage`: 包含网页发出的信息。
* `WKUserScript`: 表示可以被网页接受的用户脚本。
* `WKWebViewConfiguration`: 初始化 webview 的设置。
* `WKWindowFeatures`: 指定加载新网页时的窗口属性。

**协议**

* `WKNavigationDelegate`: 提供了追踪主窗口网页加载过程和判断主窗口和子窗口是否进行页面加载新页面的相关方法。
* `WKUIDelegate`: 提供用原生控件显示网页的方法回调。
* `WKScriptMessageHandler`: 提供从网页中收消息的回调方法。


## [WKNavigationDelegate](https://developer.apple.com/documentation/webkit/wknavigationdelegate?language=objc)

### 初始化导航栏

```objc
// Called when the web view begins to receive web content.
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;

// Called when web content begins to load in a web view.
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;
```

### 响应服务器的行为

```objc
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation;
// Called when a web view receives a server redirect
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation;
```

### 错误处理

```objc
// Called when an error occurs during navigation
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error;

// Called when an error occurs while the web view is loading content.
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error;
```

### 跟踪加载进度

```objc
// Called when an error occurs during navigation
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error;

// Called when an error occurs while the web view is loading content.
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error;
```

## [WKUIDelegate](https://developer.apple.com/documentation/webkit/wkuidelegate?language=objc)

用于展示本地化UI的协议。









































