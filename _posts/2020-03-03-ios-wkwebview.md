---
title: WKWebView替换
description: WKWebView 替换。
layout: post
categories:
 - ios
---

建议新增：刷新按钮。

https://github.com/ShingoFukuyama/WKWebViewTips

# `WKWebView`

```objc
// 是否允许手势左滑返回上一级, 类似导航控制的左滑返回
@property (nonatomic) BOOL allowsBackForwardNavigationGestures;
```

# `WKPreferences` 偏好设置类

```objc
// 最小字体大小 当将javaScriptEnabled属性设置为NO时，可以看到明显的效果
@property (nonatomic) CGFloat minimumFontSize;
// 设置是否支持javaScript 默认是支持的
@property (nonatomic) BOOL javaScriptEnabled;
// 在iOS上默认为NO，表示是否允许不经过用户交互由javaScript自动打开窗口
@property (nonatomic) BOOL javaScriptCanOpenWindowsAutomatically;
```

# `WKWebViewConfiguration` WKWebView配置类

对象级别配置：

```objc 
@property (nonatomic, strong) WKProcessPool *processPool;
@property (nonatomic, strong) WKPreferences *preferences;
@property (nonatomic, strong) WKUserContentController *userContentController;
@property (nonatomic, strong) WKWebsiteDataStore *websiteDataStore API_AVAILABLE(ios(9.0));
```

普通属性：

```objc
// 是使用h5的视频播放器在线播放(YES), 还是使用原生播放器全屏播放(NO),默认值：NO
@property (nonatomic) BOOL allowsInlineMediaPlayback;
// 设置视频是否需要用户手动播放  设置为NO则会允许自动播放。
@property (nonatomic) BOOL requiresUserActionForMediaPlayback API_DEPRECATED_WITH_REPLACEMENT("mediaTypesRequiringUserActionForPlayback", ios(9.0, 10.0));
//设置是否允许画中画技术 在特定设备上有效，默人YES。
@property (nonatomic) BOOL allowsPictureInPictureMediaPlayback API_AVAILABLE(ios(9_0));
// 设置请求的User-Agent信息中应用程序名称
@property (nullable, nonatomic, copy) NSString *applicationNameForUserAgent API_AVAILABLE(ios(9.0));
```

# `WKUserContentController`

# `WKBackForwardList`

可返回的页面列表, 存储已打开过的网页。

## 在多个`WKWebView`之间共享cookie

原理就是所有的`WKWebView`使用同一个`WKProcessPool`。

```objc
//1. 创建一个process pool
processPool = [[WKProcessPool alloc] init];

//2. 必须在init method中进行设置
WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
config.processPool = processPool;
webview = [[WKWebView alloc] initWithFrame:frame configuration:config];
```

## 页面滚动速率

```objc
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
     scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
     //UIScrollViewDecelerationRateFast
}
```

## 视频自动播放

设置是否允许自动播放，要在 WKWebView 初始化之前设置，在 WKWebView 初始化之后设置无效。

```objc
WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
config.mediaPlaybackRequiresUserAction = NO; // 默认YES
```

## WKWebView 页面样式问题
在 WKWebView 适配过程中，我们发现部分H5页面元素位置向下偏移或被拉伸变形：

```html
Use shrink-to-fit meta-tag 
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no, maximum-scale=1, shrink-to-fit=no">
```

## 白屏问题

`WKWebView`是一个多进程组件,Network Loading 以及 UI Rendering 在其它进程中执行。<br>打开 WKWebView 后，App 进程内存消耗下降，Other Process 的内存占用会增加。<br>总体的内存占用（App Process Memory + Other Process Memory）不见得比 UIWebView 少很多。

在 UIWebView 上当内存占用太大的时候，App Process 会 crash；而在 WKWebView 上当总体的内存占用比较大的时候，WebContent Process 会 crash，从而出现白屏现象。这个时候 WKWebView.URL 会变为 nil, 简单的 reload 刷新操作已经失效，对于一些长驻的H5页面影响比较大。

**1. 使用`WKNavigtionDelegate`代理方法重新加载：**

当 WKWebView 总体内存占用过大，页面即将白屏的时候，系统会调用上面的回调函数，我们在该函数里执行[webView reload](这个时候 webView.URL 取值尚不为 nil）解决白屏问题。在一些高内存消耗的页面可能会频繁刷新当前页面，H5侧也要做相应的适配操作。

```objc
//进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    [webView reload];
}
```

**2. 检测 webView.title 是否为空**

在WKWebView白屏的时候，另一种现象是 webView.titile 会被置空, 因此，可以在 viewWillAppear 的时候检测 webView.title 是否为空来 reload 页面。



## 适配网页文本大小

|适配前|适配后｜
| --- | --- |
|![./images/01-1.png](./images/01-1.png)|![./images/01-1.png](./images/01-2.png)|

```objc
//适配网页文本大小
WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
//用于进行JavaScript注入
WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
[config.userContentController addUserScript:wkUScript];
```

## 网页进度条

`WKWebView`系统属性：

```objc
// 0.0~1.0
@property (nonatomic, readonly) double estimatedProgress;
```

通过KVO去监听进度值:

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.progressView];
    [self.webView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:nil];
}
- (void)dealloc{
    [_webView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == _webView){
        NSLog(@"网页加载进度 = %f",_webView.estimatedProgress);
        self.progressView.progress = _webView.estimatedProgress;
        if (_webView.estimatedProgress >= 1.0f) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.progress = 0;
            });
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
```

## `WKNavigationDelegate`

`WKNavigationDelegate`主要用于处理一些跳转、加载处理操作。

```objc

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setProgress:0.0f animated:NO];
} 
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
}
//提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.progressView setProgress:0.0f animated:NO];
}  
// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
}
// 根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // iTunes: App Store link
    if ([urlString isMatch:RX(@"\\/\\/itunes\\.apple\\.com\\/")]) {
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
// 根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSString * urlStr = navigationResponse.response.URL.absoluteString;
    NSLog(@"当前跳转地址：%@",urlStr);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
} 
//需要响应身份验证时调用 同样在block中需要传入用户身份凭证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))completionHandler{
    //用户身份信息
    NSURLCredential * newCred = [[NSURLCredential alloc] initWithUser:@"user123" password:@"123" persistence:NSURLCredentialPersistenceNone];
    //为 challenge 的发送方提供 credential
    [challenge.sender useCredential:newCred forAuthenticationChallenge:challenge];
    completionHandler(NSURLSessionAuthChallengeUseCredential,newCred);
}
//进程被终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
}
```

## `WKUIDelegate` 涉及UI的原生实现

主要处理JS脚本，确认框，警告框等

```objc
// web界面中有弹出警告框时调用,JS中调用alert方法
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Title" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
// web界面中有确认框时调用,JS中调用confirm方法
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
// web界面中有输入框时调用,JS中调用prompt方法
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}
```

|alert|confirm|prompt|
| --- | --- | --- |
|![](/assets/images/wkwebview/02-1.png)|![](/assets/images/wkwebview/02-2.png)|![](/assets/images/wkwebview/02-3.png)|
|`alert("被OC截获到了");`|`confirm("被OC截获到了");`|`prompt("A","B");`|

### 解决`WKWebView`不能打开任何有`target="_blank"`（`开一个新的窗口`）属性的网页

```objc
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
```

## JS调用OC的方法

### 方式1:`window.webkit.messageHandlers`

项目中兼容以前的OCR接入。

当JS调用OC方法时：其中`jsToOcNoPrams`、`jsToOcWithPrams`两个名称是两端统一的。

```js
function jsToOcFunction1(){
    window.webkit.messageHandlers.jsToOcNoPrams.postMessage({});
}
function jsToOcFunction2(){
    window.webkit.messageHandlers.jsToOcWithPrams.postMessage({"params":"我是参数"});
}
```

原生实现方式：

```objc
@interface SEGWebViewViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@end

@implementation SEGWebViewViewController
//被自定义的WKScriptMessageHandler在回调方法里通过代理回调回来，绕了一圈就是为了解决内存不释放的问题
//通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
    //用message.body获得JS传出的参数体
    NSDictionary * parameter = message.body;
    //JS调用OC
    if([message.name isEqualToString:@"jsToOcNoPrams"]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"js调用到了oc" message:@"不带参数" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }])];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else if([message.name isEqualToString:@"jsToOcWithPrams"]){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"js调用到了oc" message:parameter[@"params"] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }])];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}

- (WKWebView *)webView{
    if(_webView == nil){
        
        //创建网页配置对象
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];

        //这个类主要用来做native与JavaScript的交互管理
        WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        
        //自定义的WKScriptMessageHandler 是为了解决内存不释放的问题
        WeakWebViewScriptMessageDelegate *weakScriptMessageDelegate = [[WeakWebViewScriptMessageDelegate alloc] initWithDelegate:self];
        //注册一个name为jsToOcNoPrams的js方法 设置处理接收JS方法的对象
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"jsToOcNoPrams"];
        [wkUController addScriptMessageHandler:weakScriptMessageDelegate  name:@"jsToOcWithPrams"];
        
        config.userContentController = wkUController;
                
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) configuration:config];
        _webView.UIDelegate = self;// UI代理
        _webView.navigationDelegate = self;// 导航代理
    }
    return _webView;
}

- (void)dealloc{
    //移除注册的js方法
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"jsToOcNoPrams"];
    [[_webView configuration].userContentController removeScriptMessageHandlerForName:@"jsToOcWithPrams"];
}
@end
```

自定义的消息句柄：

```objc
@interface WeakWebViewScriptMessageDelegate : NSObject<WKScriptMessageHandler>
//WKScriptMessageHandler 这个协议类专门用来处理JavaScript调用原生OC的方法
@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
@end
@implementation WeakWebViewScriptMessageDelegate
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}
#pragma mark - WKScriptMessageHandler
//遵循WKScriptMessageHandler协议，必须实现如下方法，然后把方法向外传递
//通过接收JS传出消息的name进行捕捉的回调方法
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([self.scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}
@end
```

也可以直接使用系统定义的`WKScriptMessageHandler`来实现。

### 方式2:`window.location.href`

当JS调用OC方法时：

```js
function jsToOcFunction3(){
    var query = {
      fn: 'uhomeNativeApi.cameraCb'
    };
    window.location.href = 'uhomeoc://system.camera?params=' + JSON.stringify(query);
}
```

这是直接发起连接跳转，可以通过`WKNavigationDelegate`代理来拦截。

```objc
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSString * scheme = navigationAction.request.URL.scheme;
    NSString * host = navigationAction.request.URL.host;
    NSString * query = [navigationAction.request.URL.query stringByURLDecode];
    if (scheme && host && [scheme rangeOfString:@"uhomeoc"].location != NSNotFound){
        if ([host rangeOfString:@"system.camera"].location != NSNotFound) { // 使用原生系统功能：相机
            [self segJSSystemCameraWithQuery:query request:navigationAction.request.URL];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
```

## OC调用JS的方法

假设JS中存在方法，需要用原生方法去执行：

```js
function changeColor(parameter){
    document.body.style.backgroundColor = randomColor();
    alert(parameter);
}
```

OC原生方法：

```objc
//OC调用JS
- (void)ocToJs{
    //changeColor()是JS方法名，completionHandler是异步回调block
    NSString *jsString = [NSString stringWithFormat:@"changeColor('%@')", @"Js颜色参数"];
    [_webView evaluateJavaScript:jsString completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSLog(@"改变HTML的背景色");
    }];
}
```

# Cookies

JS原生方法可以获取cookie：`document.cookie`

## 获取cookie

1.从`NSHttpCookieStorage`、`WKHttpCookieStore`中获取cookie：

```objc
+ (void)logCookiesFromHTTPCookieStore
{
    if (@available(iOS 11.0, *)) {
        WKWebsiteDataStore *store = [WKWebsiteDataStore defaultDataStore];
        [store.httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * cookies) {
            [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"-->count:%zd; name:%@; value:%@",cookies.count, obj.name, obj.value);
                
            }];
        }];
    }
    else {
        NSArray *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
        for (NSHTTPCookie *cookie in cookieJar) {
            NSLog(@"-->count:%zd; name:%@; value:%@",cookieJar.count, cookie.name, cookie.value);
        }
    }
}
```

2.从请求头中获取cookie：

```objc
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[navigationAction.request allHTTPHeaderFields] forURL:navigationAction.request.URL];
    decisionHandler(WKNavigationActionPolicyAllow);
}
```

3.通过JS方法获取cookie：

```objc
- (void)ocToJs{
    //changeColor()是JS方法名，completionHandler是异步回调block
    NSString *jsString = [NSString stringWithFormat:@"alert(document.cookie)"];
    [_webView evaluateJavaScript:jsString completionHandler:^(id _Nullable data, NSError * _Nullable error) {
    }];
}
```

4.获取响应头中的cookie：

```objc
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSHTTPURLResponse *response = navigationResponse.response;
    // FIXME:获取Cookie!!!
    NSArray *cookies =[NSHTTPCookie cookiesWithResponseHeaderFields:[response allHeaderFields] forURL:response.URL];
    // 读取wkwebview中的cookie 方法1
    for (NSHTTPCookie *cookie in cookies) {
        //[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        NSLog(@"-->wkwebview中的cookie:%@", cookie);
    }
    
    // -------------------- 分割线
    // 读取wkwebview中的cookie 方法2 读取Set-Cookie字段
    NSString *cookieString = [[response allHeaderFields] valueForKey:@"Set-Cookie"];
    NSLog(@"wkwebview中的cookie:%@", cookieString);
    // 看看存入到了NSHTTPCookieStorage了没有
    NSHTTPCookieStorage *cookieJar2 = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieJar2.cookies) {
        NSLog(@"NSHTTPCookieStorage中的cookie%@", cookie);
    }
    
    NSString * urlStr = navigationResponse.response.URL.absoluteString;
    NSLog(@"当前跳转地址：%@",urlStr);
    //允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    //不允许跳转
    //decisionHandler(WKNavigationResponsePolicyCancel);
}
```

## 添加cookie

```objc
- (void)addCookie {
    NSDictionary *mCookProperties = @{
    NSHTTPCookieDomain: @".lilongcnc.cc",
    NSHTTPCookiePath: @"/",
    NSHTTPCookieName: @"laurenKey",
    NSHTTPCookieValue:  @"laurenValue",
    };
    NSHTTPCookie *myCookie = [NSHTTPCookie cookieWithProperties:mCookProperties];
    if (@available(iOS 11.0, *)) {
        WKWebsiteDataStore *store = [WKWebsiteDataStore defaultDataStore];
        [store.httpCookieStore setCookie:myCookie completionHandler:^{
        }];
        
        
    } else {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:myCookie];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
```

## 同步cookie

在iOS11以下的版本中，WKWebView并没有类似UIWebView中NSHTTPCookieStorage这样的可以直接设置和存储Cookie的官方类。但是在各个App的实际开发过程中，给HTML5后台传入Cookie进行身份校验等属于最基本的操作，正是因为不能方便设置Cookie的原因，在本文发布的时候，很多大厂App的核心web业务并没有使用WKWebView，仍然是UIWebView。iOS11开始，苹果意识到了这个问题，做了妥协，新增WKHTTPCookieStorage来帮助开发者解决Cookie问题，虽然方便了，但是API仍然不稳定，比如iOS11.3的时候就出现了一些变动。

在`UIWebView`中，可以通过`NSHttpCookieStorage`来管理Cookie，对Cookie进行增删改查。当把Cookie添加到`NSHttpCookieStorage`中后，webView在发起请求的时候会自动从`NSHttpCookieStorage`中取出Cookie添加到`request Header`中，并且这个操作是**零延迟**的。也就是说，你第一行代码添加Cookie到`NSHttpCookieStorag`e中，第二行代码`loadRequest:`，发起的请求中是带有你设置的Cookie的。

在`WKWebView`中，WKWebView实例也会将 Cookie 存储于 NSHTTPCookieStorage中，但存储时机**有延迟**。

`NSHttpCookieStorage`对`WKWebView`而言，只能管理Cookie，但是没有了零延迟自动同步到`request Header`这一关键特性。

**WKWebView Cookie 问题在于 WKWebView 发起的请求不会自动带上存储于 NSHTTPCookieStorage 容器中的 Cookie。**

|版本|方案|
|---|---|
|`<iOS11`|使用`NSHttpCookieStorage`管理cookie。<br>新页面请求：在`loadRequest`之前把cookie添加到`Request Header`中。<br>|
|`iOS11~iOS12`|`WKHttpCookieStorage`管理，在`loadRequest`之前写入本地cookie|
|`iOS13`|`WKHttpCookieStorage`管理，同步机制变化，不能及时同步。<br>首次请求:在`loadRequest`之前写入本地cookie|

### `<iOS11`

* 使用`NSHttpCookieStorage`管理cookie。
* 请求新WebView页面请求：在`loadRequest`之前把cookie添加到`Request Header`中。
* 页面跳转：JS写入`document.cookie`中【解决后续页面(同域)Ajax、iframe 请求的 Cookie 问题】

> document.cookie()无法跨域设置 cookie

```objc
-(void)loadData {
    if (@available(iOS 13.0, *)) { /*13*/
        
    }else if (@available(iOS 11.0, *)){ /*11~12*/
        
    }else{ /* 8~10:先把cookie添加到`Request Header`中 */
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://h5.qzone.qq.com/mqzone/index"]];
        
        [request addValue:@"skey=skeyValue" forHTTPHeaderField:@"Cookie"];
        [_webView loadRequest:request];
    }
}
```

设置`document.cookie`：

```objc
WKUserContentController* userContentController = [WKUserContentController new] 
WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource: @"document.cookie = 'skey=skeyValue';" injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO]; 
[userContentController addUserScript:cookieScript];
config.userContentController = userContentController;
```

### `iOS11~iOS12`

iOS11.0推出了`WKHTTPCookieStore`，效果和NSHttpCookieStorage一样，是零延迟。在请求发起的时候，我们只需要将Cookie设置到`WKHTTPCookieStore`就可以了。

```objc
- (void)loadData {
    if (@available(iOS 11.0, *)) {
        // 1. 设置Cookie
        NSArray *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
        WKWebsiteDataStore *store = [WKWebsiteDataStore defaultDataStore];
        [store.httpCookieStore setCookie:cookieJar completionHandler:^{
            NSLog(@"cookie添加成功");
        }];
        // 2. 加载请求
        [self.wkwebView loadRequest: request];
    }
}
```

### `iOS13`

在iOS13中可能遇到的问题：`WKHTTPCookieStore`设置Cookie之后，第一次发起请求Cookie会丢失，第二次及以后的请求的Cookie没有问题。

可以在login之后先同步一次cookie：

```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   WKWebsiteDataStore *store = [WKWebsiteDataStore defaultDataStore];
    [store.httpCookieStore setCookie:cookie completionHandler:^{
        NSLog(@"cookie添加成功");
    }];
}
```

# 参考资料

* [WKWebView的使用--API篇](https://www.jianshu.com/p/833448c30d70)
* [WKWebView User Agent、跨域、重定向及其它](https://www.jianshu.com/p/91cfe58c032d)
* [IOS进阶之WKWebView](https://www.jianshu.com/p/4fa8c4eb1316)
* [WKWebView 那些坑](https://mp.weixin.qq.com/s/rhYKLIbXOsUJC_n6dt9UfA?)
* [WBWebViewConsole](https://github.com/Naituw/WBWebViewConsole)