---
title: CoreText
layout: post
categories:
 - ios
---

## Quartz 2D 编程指导

### Quartz 2D概述
`Quartz 2D`是一个二维的绘图引擎。可以使用所有的绘图和动画的技术(`Core Animation`, `OpenGL ES`,`UIKit`)。

#### 绘图目标：图形上下文(The Graphics Context)
图形上下文(The Graphics Context)(CGContextRef)封装了`Quartz`用于将图像绘制到输出设备的信息:`PDF `、`bitmap`、`window`。

<img src="/assets/images/coretext/02.png" width = "50%" height = "50%"/>

### 图形上下文

#### 在iOS上获取图形上下文

```objc
- (void)drawRect:(CGRect)rect {
	// context 为当前UIView环境创建的图形上下文。
    CGContextRef context = UIGraphicsGetCurrentContext();
}
```

#### 创建PDF图形上下文

API提供两种创建PDF图形上下文的函数:

```objc
- (void)drawRect:(CGRect)rect {
    CGSize size = [UIScreen mainScreen].bounds.size;
    // CGPDFContextCreateWithURL
    {
        CGRect mediaBox = CGRectMake (0, 0, size.width, size.height);
        CFURLRef url = CFURLCreateWithFileSystemPath(NULL, CFSTR("test.pdf"), kCFURLPOSIXPathStyle, false);
        if (url != NULL) {
            CGContextRef context = CGPDFContextCreateWithURL(url, &mediaBox, NULL);
            CFRelease(url);
            CGContextRelease(context);
        }
    }
    // CGPDFContextCreate
    {
        CGRect mediaBox = CGRectMake (0, 0, size.width, size.height);
        CFURLRef url = CFURLCreateWithFileSystemPath(NULL, CFSTR("test.pdf"), kCFURLPOSIXPathStyle, false);
        if (url != NULL) {
            CGDataConsumerRef dataConsumer = CGDataConsumerCreateWithURL(url);
            if (dataConsumer != NULL) {
                CGContextRef context = CGPDFContextCreate(dataConsumer, &mediaBox, NULL);
                CGDataConsumerRelease(dataConsumer);
                CGContextRelease(context);
            }
            CFRelease(url);
        }
    }
}
```

#### 创建位图图形上下文(Bitmap Graphics Context)


* glyph - 字体、字形。
* glyph run - 是一系列共享相同 attributes 和 direction 的连贯的字形的集合。

## Core Text Design

Core Text是一种高级的底层技术，用于布置文本和处理字体。Core Text直接与Core Graphics（CG）（也称为Quartz）一起使用，它是高速图形渲染引擎，可在OS X和iOS的最低层处理二维图像。

`Core Text`布局引擎通常与属性字符串(`CFAttributedStringRef`)和图形路径(`CGPathRef`)一起使用。属性字符串对象封装了支持显示的字符串，并包含了字符串中字符样式相关的属性(字体和颜色)。`Core Text`中的排版机制使用属性字符串中的信息来执行字符到字形的转换。

`CGPathRef`可以是非矩形的。

`CFAttributedString`的引用类型`CFAttributedStringRef`，是和`Foundation`中的`NSAttributedString`完全桥接的。这意味着`Core Foundation`类型可以在函数或者方法中与`Foundation`互相转换。因此可以看到方法的参数为`NSAttributedString *`时，你可以直接传入一个`CFAttributedStringRef`类型的值，反之亦然。

`Core Text`对象在`runtime`时候的结构树如下图：

<img src="/assets/images/coretext/01.png" width = "50%" height = "50%"/>

在此层次结构的最顶部为 framesetter 对象(`CTFramesetterRef`)。在framesetter中以属性字符串(attributed string)和字形路径(graphics path)作为参数可以生成一个或多个文本框(text frame)(`CTFrameRef`),每一个`CTFrame`对象都代表一个段落(paragraph)。

为了生成文本框(text frame)，framesetter需要调用typesetter对象(`CTTypesetterRef`),typesetter在frame内部对文本进行布局，framesetter会提供段落的样式(paragraph styles)包括对齐方式，制表位，行距，缩进和换行模式等属性。typesetter会把属性字符串(attributed string)中的字符(characters)转换成字形(graphics)，并且把字形(graphics)填充到文本框(text frame)中的lines(`CTLine`)里。

每一个`CTFrame`对象中都包含了一个或多个段落的行对象(paragraph’s line)(`CTLine`)，每一个行对象(line object)中都有一行文字。

每个`CTLine`对象都包含了一组字形运行(glyph run)对象(CTRun)的数组。字形运行(glyph run)是一组共享相同属性和方向的连续字形(glyph)。排字机(typesetter)在从属性字符串(attributed string)，属性和字体对象生成线条(line)时创建字形运行(glyph run)。


## Core Text
`Core Text`是一个文本布局的框架。

```
.
├── CTDefines.h
├── CTFont.h 字体的对象
├── CTFontCollection.h 字体的集合
├── CTFontDescriptor.h 字体的描述
├── CTFontManager.h
├── CTFontManagerErrors.h
├── CTFontTraits.h
├── CTFrame.h 
├── CTFramesetter.h 生成 text的 frames
├── CTGlyphInfo.h 从 Unicode 到 glyph ID 的字体映射
├── CTLine.h
├── CTParagraphStyle.h
├── CTRubyAnnotation.h
├── CTRun.h
├── CTRunDelegate.h
├── CTStringAttributes.h
├── CTTextTab.h
├── CTTypesetter.h
├── CoreText.apinotes
├── CoreText.h
├── SFNTLayoutTypes.h
└── SFNTTypes.h
```

## CTFont

`CTFont`在`Core Text`中表示一种不透明的字体对象。`Core Text`中的所有函数都是线程安全的，包括字体对象(`CTFont`, `CTFontDescriptor`,及其关联类)可以被用于多种操作(多线程、队列中)；然而布局对象(`CTTypesetter`, `CTFramesetter`, `CTRun`, `CTLine`, `CTFrame`,及其关联类)在单线程、单队列中进行操作。

### 创建字体

```objc
// 通过传值的字体名称，返回一个CTFontRef对象的字体
// 注意：只能返回已经注册的字体，通过 CTFontManager 类查看更多信息。
// name: 必填。
// size: 选填。字体的点数。如果size为0.0，那么将使用默认字体12.0
// matrix: 选填。字体的转换矩阵。默认：NULL
CTFontRef CTFontCreateWithName(CFStringRef name, CGFloat size, const CGAffineTransform *matrix);
```

## CTFontRef

`CTFontRef`是结构题，是`Core Text`的字体对象。

```objc
typedef struct __CTFont CTFontRef;
```

## 参考资料
* [Apple Developer - About Text Handling in iOS](https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/Introduction/Introduction.html)
* [Apple Developer - Core Text Programming Guide](https://developer.apple.com/library/archive/documentation/StringsTextFonts/Conceptual/CoreText_Programming/Introduction/Introduction.html?language=objc#//apple_ref/doc/uid/TP40005533)
* [Apple Developer - Quartz 2D](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/Introduction/Introduction.html?language=objc#//apple_ref/doc/uid/TP30001066)





