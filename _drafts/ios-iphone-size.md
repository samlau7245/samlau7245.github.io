---
title: iPhone界面适配
layout: post
categories:
 - ios
---

## 机型展示图示

> 表格标题带颜色表明该机型是齐刘海导航栏。

|<font color="red">iPhone11Pro</font>|<font color="red">iPhone11ProMax</font>|<font color="red">iPhone11</font>|<font color="red">iPhoneXS</font>|
|---|---|---|---|
|<img src="/assets/images/iphone-size/compare_iphone11_pro_midnightgreen__e5s9iz63a526_large_2x.jpg" width = "100%" height = "100%"/>|<img src="/assets/images/iphone-size/compare_iphone11_pro_max_midnightgreen__djurwwoo8nwy_large_2x.jpg" width = "100%" height = "100%"/>|<img src="/assets/images/iphone-size/compare_iphone11_purple__4y0j9oox0jmy_large_2x.jpg" width = "100%" height = "100%"/>|<img src="/assets/images/iphone-size/compare_iphoneXS_silver__b74bo85qkmc2_large_2x.jpg" width = "100%" height = "100%"/>|

|<font color="red">iPhoneXSMax</font>|<font color="red">iPhoneXR</font>|<font color="red">iPhoneX</font>|iPhone8Plus|
|---|---|---|---|
|<img src="/assets/images/iphone-size/compare_iphoneXSmax_silver__ei8uke6evnu6_large_2x.jpg" width = "100%" height = "100%"/>|<img src="/assets/images/iphone-size/compare_iphoneXR_blue__f9ewbjbskzm2_large_2x.jpg" width = "100%" height = "100%"/>|<img src="/assets/images/iphone-size/compare_iphoneX_silver__bi4qq4wvktci_large_2x.jpg" width = "100%" height = "100%"/>|<img src="/assets/images/iphone-size/compare_iphone8plus_silver__cdn1v2todnpy_large_2x.jpg" width = "100%" height = "100%"/>|

|iPhone8|iPhone7Plus|iPhone7|iPhone6sPlus|
|---|---|---|---|
|<img src="/assets/images/iphone-size/compare_iphone8_silver__hpu5ikdq5cia_large_2x.jpg" width = "100%" height = "100%"/>|<img src="/assets/images/iphone-size/compare_iphone7plus_black__2200fgodyoym_large_2x.jpg" width = "100%" height = "100%"/>|<img src="/assets/images/iphone-size/compare_iphone7_black__hb3m5bpouju6_large_2x.jpg" width = "100%" height = "100%"/>|<img src="/assets/images/iphone-size/compare_iphone6splus_spacegray__fnl0a4fz1qa2_large_2x.jpg" width = "100%" height = "100%"/>|

|iPhone6s|iPhone6Plus|iPhone6|iPhoneSE|
|---|---|---|---|
|<img src="/assets/images/iphone-size/compare_iphone6s_spacegray__guisiap390ia_large_2x.jpg" width = "100%" height = "100%"/>|<img src="/assets/images/iphone-size/compare_iphone6plus_spacegray__c83z9zsqa526_large_2x.jpg" width = "100%" height = "100%"/>|<img src="/assets/images/iphone-size/compare_iphone6_spacegray__fn7o5djm5iem_large_2x.jpg" width = "100%" height = "100%"/>|<img src="/assets/images/iphone-size/compare_iphoneSE_spacegray__da5crua2qbo2_large_2x.jpg" width = "100%" height = "100%"/>|

## 机型展示数据

|机型|屏幕尺寸(inch)|物理分辨率(pixel)|逻辑分辨率(point)|缩放因子|屏幕密度(ppi)|Status高度|Navi高度|Tab高度|底部安全距离|
|---|---|---|---|---|---|---|---|---|
|<font color="red">11 Pro</font>|5.8|1125*2436|375*812|@3x|458|44|44|83|34|
|<font color="red">XS</font>|5.8|1125*2436|375*812|@3x|458|44|44|83|34|
|<font color="red">X</font>|5.8|1125*2436|375*812|@3x|458|44|44|83|34|
|<font color="red">11 Pro Max</font>|6.5|1242*2688|414*896|@3x|458|44|44|83|34|
|<font color="red">XS Max</font>|6.5|1242*2688|414*896|@3x|458|44|44|83|34|
|<font color="red">11</font>|6.1|828*1792|414*896|@2x|326|44|44|83|34|
|<font color="red">XR</font>|6.1|828*1792|414*896|@2x|326|44|44|83|34|
|`8 Plus`|5.5|1080*1920<br><mark>1242*2208</mark>|414*736|@3x|401|20|44|49|-|
|`7 Plus`|5.5|1080*1920<br><mark>1242*2208</mark>|414*736|@3x|401|20|44|49|-|
|`6s Plus`|5.5|1080*1920<br><mark>1242*2208</mark>|414*736|@3x|401|20|44|49|-|
|`6 Plus`|5.5|1080*1920<br><mark>1242*2208</mark>|414*736|@3x|401|20|44|49|-|
|`8`|4.7|750*1334|375*667|@2x|326|20|44|49|-|
|`7`|4.7|750*1334|375*667|@2x|326|20|44|49|-|
|`6s`|4.7|750*1334|375*667|@2x|326|20|44|49|-|
|`6`|4.7|750*1334|375*667|@2x|326|20|44|49|-|
|`SE`|4|640*1136|320*568|@2x|326|20|44|49|-|



1inch = 2.54cm = 25.4mm

1pt = 2px

屏幕密度(Pixel Per Inch by diagonal):沿着对角线每英寸所拥有放入像素总数。

例如`iPhone6`的PPI：326，屏幕尺寸为：4.7，物理分辨率：`750*1334`。

## 代码适配

```objc
// ???
self.extendedLayoutIncludesOpaqueBars = YES;

// ???
@property(nonatomic) UIScrollViewContentInsetAdjustmentBehavior contentInsetAdjustmentBehavior API_AVAILABLE(ios(11.0),tvos(11.0));
```

## 齐刘海适配

safeAreaLayoutGuide

<img src="/assets/images/iphone-size/safe-area-01.jpg" width = "50%" height = "50%"/>

## TODO

**`iPhone11`、`iPhoneXR`为什么是`@2x`？**

`屏幕密度(ppi)`为`326`使用`@2x`,比之大的用`@3x`。

* `iPhone8Plus`、`iPhone7Plus`、`iPhone6sPlus` 为什么要将`@3x`渲染的`2208*1242`分辨率缩小到`1080*1920`屏幕上？
* 缩放因子的计算方式？

## 参考资料

* [iOS所有设备的分辨率、尺寸和缩放因子，放大模式区别和6P实际分辨率](https://www.jianshu.com/p/bef2d20a7e77)
* [苹果手机各种尺寸详细表以及iPhoneX、iPhoneXS、iPhoneXR、iPhoneXSMax、iPhone 11、iPhone 11 Pro、iPhone 11 Pro Max、屏幕适配](https://blog.csdn.net/a18339063397/article/details/81482073)
* [为什么 iPhone 6 Plus 要将 3x 渲染的 2208x1242 分辨率缩小到 1080p 屏幕上？](https://www.zhihu.com/question/25288571)
* [iPhone Plus手机的分辨率到底是多少，是1080×1920还是1242×2208？](https://blog.csdn.net/weixin_30446197/article/details/94781726)
* [IOS设计尺寸规范](http://www.xueui.cn/design/142395.html)
* [iPhoneX页面安全区域与内容重叠问题](https://www.cnblogs.com/theWayToAce/p/7942360.html)
* [The iPhone wiki-Model](https://www.theiphonewiki.com/wiki/Models)
* [关于iOS 11 SafeArea 总结](https://www.jianshu.com/p/23ed2e771007)

