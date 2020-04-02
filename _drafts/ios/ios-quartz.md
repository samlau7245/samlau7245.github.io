---
title: Quartz 2D 学习记录
layout: post
categories:
 - ios
---

## Graphics Contexts[$]
## Paths[$$]
## Color and Color Spaces[$]
## Transforms[$]
## Patterns[$]
## Shadows[$]
## Gradients[$$]
## Transparency Layers[$]
## Data Management in Quartz 2D[$]
## Bitmap Images and Image Masks[$$]
## Core Graphics Layer Drawing[$]
## PDF Document Creation, Viewing, and Transforming[$]
## PDF Document Parsing[$]
## PostScript Conversion[$]



<!-- ## Quartz 2D 编程指导

### Quartz 2D概述
`Quartz 2D`是一个二维的绘图引擎。可以使用所有的绘图和动画的技术(`Core Animation`, `OpenGL ES`,`UIKit`)。

#### 绘图目标：图形上下文(The Graphics Context)
图形上下文(The Graphics Context)(CGContextRef)封装了`Quartz`用于将图像绘制到输出设备的信息:`PDF `、`bitmap`、`window`。

<img src="/assets/images/coretext/02.gif" width = "50%" height = "50%"/>

### 图形上下文

#### 在iOS上获取图形上下文

```objc
- (void)drawRect:(CGRect)rect {
	// context 为当前UIView环境创建的图形上下文。
    CGContextRef context = UIGraphicsGetCurrentContext();
}
```

#### 创建PDF图形上下文(PDF Graphics Context)

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
            //Coding...
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
                //Coding...
                CGContextRelease(context);
            }
            CFRelease(url);
        }
    }
}
```

#### 创建位图图形上下文(Bitmap Graphics Context)

位图图形上下文(Bitmap Graphics Context)的绘制可以在内存缓冲区(memory buffer)中进行，当进行绘制的时候，内存缓存区将会更新。当绘制超过了屏幕的尺寸也就是在屏幕外进行绘制的时候，可以先参考`CGLayer`，系统对它在屏幕外绘制进行了优化。

<img src="/assets/images/coretext/03.png" width = "50%" height = "50%"/>

```objc
// 生成一个位图图形上下文
CGContextRef MyCreateBitmapContext(int pixelsWide,int pixelsHigh){
    void * bitmapData;
    int bitmapByteCount;
    int bitmapBytePerRow;//表示每行的字节数。
    CGColorSpaceRef colorSpace;
    CGContextRef context = NULL;
    
    bitmapBytePerRow = pixelsWide * 4;//在此示例中，位图中的每个像素都由4个字节表示；红色，绿色，蓝色和Alpha分别为8位。
    bitmapByteCount = bitmapBytePerRow * pixelsHigh;
    
    colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    /*
     创建并清除存储位图数据的内存块。
     本示例创建一个32位RGBA位图（即，每个像素32位的数组，每个像素包含8位红，绿，蓝和alpha信息）。位图中的每个像素占用4个字节的内存。
     如果将其NULL作为位图数据传递，则Quartz会自动为位图分配空间。
     */
    bitmapData = calloc(bitmapByteCount, sizeof(uint8_t));

    if (bitmapData == NULL) {
        fprintf(stderr, "Memory not allocated!");
        return NULL;
    }
    context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8, bitmapBytePerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    if (context == NULL) {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
        return NULL;
    }
    CGColorSpaceRelease(colorSpace);
    return context;
    // data: 需要渲染的图形数据。该存储块的大小至少应为（bytesPerRow* height）字节。
    // width: 指定位图的宽度（以像素为单位）。
    // height: 指定位图的高度（以像素为单位）。
    // bitsPerComponent: 指定要用于内存中像素每个部分的位数。例如，对于32位像素格式和RGB颜色空间，应为每个组件指定8位的值。
    // bytesPerRow: 当 data 和 bytesPerRow 是 16-byte 对其的时候，将获得最佳性能。
    // space: 用于位图上下文的颜色空间。创建位图图形上下文时，可以提供Gray，RGB，CMYK或NULL颜色空间。
    // bitmapInfo: 指定要用于内存中像素每个部分的位数。例如，对于32位像素格式和RGB颜色空间，应为每个组件指定8位的值。
    //CGBitmapContextCreate(void * __nullable data,size_t width, size_t height, size_t bitsPerComponent, size_t bytesPerRow,CGColorSpaceRef cg_nullable space, uint32_t bitmapInfo)
    
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 存储边界框的原点和尺寸
    CGRect myBoundingBox = CGRectMake (10, 10, 400, 300);
    // 创建一个宽度为400像素，高度为300像素的位图上下文
    CGContextRef myBitmapContext = MyCreateBitmapContext(myBoundingBox.size.width, myBoundingBox.size.height);
    
    CGContextSetRGBFillColor (myBitmapContext, 1, 0, 0, 1);// 红色
    CGContextFillRect (myBitmapContext, CGRectMake (0, 0, 200, 100 ));
    
    CGContextSetRGBFillColor (myBitmapContext, 0, 0, 1, .5);// 半透明蓝色
    CGContextFillRect (myBitmapContext, CGRectMake (0, 0, 100, 200 ));
    
    // 创建Quartz 2D图像
    CGImageRef myImage = CGBitmapContextCreateImage (myBitmapContext);
    // 将图像绘制到窗口图形上下文中由边界框指定的位置。
    CGContextDrawImage(context, myBoundingBox, myImage);
    // 获取与位图图形上下文关联的位图数据。
    char *bitmapData = CGBitmapContextGetData(myBitmapContext);
    // 当不再需要时释放位图图形上下文。
    CGContextRelease (myBitmapContext);
    // 释放位图数据（如果存在）。
    if (bitmapData) free(bitmapData);
    CGImageRelease(myImage);
    
    CGContextSetShouldAntialias(<#CGContextRef  _Nullable c#>, <#bool shouldAntialias#>)
}
```

<img src="/assets/images/coretext/07.png" width = "50%" height = "50%"/>

#### 抗锯齿
位图图形上下文支持抗锯齿，使对象在位图中显得平滑。

<img src="/assets/images/coretext/08.jpg" width = "50%" height = "50%"/>

```objc
// 关闭特定位图图形上下文的抗锯齿功能
CGContextSetShouldAntialias(context, true);
// 对特定图形上下文进行抗锯齿: true:允许抗锯齿 false:不允许抗锯齿
CGContextSetAllowsAntialiasing(context, true);
```

### 颜色和色彩空间

为了有效地使用颜色并了解使用颜色空间和颜色的`Quartz 2D`功能可以参考[颜色管理概述](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/csintro/csintro_intro/csintro_intro.html#//apple_ref/doc/uid/TP30001148)。

Quartz中的颜色由一组值表示：(值范围:0.0-1.0)

|值|色彩空间|组件|
| --- | --- |--- |
|240 degrees, 100%, 100%|HSB|色相(Hue)，饱和度(saturation)，亮度(brightness)|
|0, 0, 1|RGB|Red, green, blue|
|1, 1, 0, 0|CMYK|Cyan, magenta, yellow, black|
|1, 0, 0|BGR|Blue, green, red|

下图表示在Quartz中不同透明度的图片展示的样子，这是局部不透明的样式。

<img src="/assets/images/coretext/04.gif" width = "50%" height = "50%"/>

在绘制之前在图形上下文中全局设置alpha值，可以使页面上的对象和页面本身透明。

<img src="/assets/images/coretext/05.gif" width = "50%" height = "50%"/>

```objc
// 通过这个函数可以清除图形上下文中的透明度值
void CGContextClearRect(CGContextRef cg_nullable c, CGRect rect);
```

#### 创建通用的色彩空间

* `kCGColorSpaceGenericGray`: 通用灰色，一种单色颜色空间，允许指定从绝对黑色（值0.0）到绝对白色（值1.0）的单个值。
* `kCGColorSpaceGenericRGB`: 通用RGB，这是一种由三部分组成的颜色空间（红色，绿色和蓝色），用于模拟彩色监视器上单个像素的组成方式。
* `kCGColorSpaceGenericCMYK`: 通用的CMYK，这是一种由四部分组成的颜色空间（青色，品红色，黄色和黑色），用于模拟打印过程中墨水的堆积方式。

```objc
// 创建色彩空间
CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
```

#### 创建设备的色彩空间
设备的色彩空间主要是用于iOS设备。大多数情况下，Mac OS X应用程序应使用通用颜色空间，而不是创建设备颜色空间。
* `CGColorSpaceCreateDeviceGray`: 取决于设备的灰度色彩空间。
* `CGColorSpaceCreateDeviceRGB`: 用于设备相关的RGB颜色空间。
* `CGColorSpaceCreateDeviceCMYK`: 取决于设备的CMYK颜色空间。

#### 创建索引和图案颜色空间
索引颜色空间包含一个最多包含256个条目的颜色表。

```objc
CGColorSpaceRef __nullable CGColorSpaceCreateIndexed(CGColorSpaceRef baseSpace,size_t lastIndex, const unsigned char * cg_nullable colorTable);
```

#### 设置和创建颜色
Quartz提供了一组用于设置 填充色(fill color)、 描边色(stroke color)、颜色空间和Alpha的功能。需要为绘图目标提供适当的色彩空间。下图就是CMYK填充颜色和RGB填充颜色，会发现填充色之间存在很大差异：
<img src="/assets/images/coretext/06.gif" width = "50%" height = "50%"/>

```objc
// 设置填充色空间
CGContextSetFillColorSpace(CGContextRef cg_nullable c,CGColorSpaceRef cg_nullable space);
// 设置描边色空间
CGContextSetStrokeColorSpace(CGContextRef cg_nullable c,CGColorSpaceRef cg_nullable space);
```

|功能|用于设置颜色|
| --- | --- |
|CGContextSetRGBStrokeColor<br>CGContextSetRGBFillColor|设备RGB。在生成PDF时，Quartz会像在相应的通用颜色空间中一样编写颜色。|
|CGContextSetCMYKStrokeColor<br>CGContextSetCMYKStrokeColor|设备CMYK。|
|CGContextSetGrayStrokeColor<br>CGContextSetGrayFillColor|设备灰色。|
|CGContextSetStrokeColorWithColor<br>CGContextSetFillColorWithColor|任何色彩空间。您提供了一个指定颜色空间的CGColor对象|
|CGContextSetStrokeColor<br>CGContextSetFillColor|当前的色彩空间。不建议使用。可以使用`CGContextSetFillColorSpace`、`CGContextSetStrokeColorSpace`函数|

```objc
CGColorRef __nullable CGColorCreate(CGColorSpaceRef cg_nullable space,const CGFloat * cg_nullable components);
```

#### 设置渲染
定Quartz如何将颜色从源颜色空间映射到图形上下文的目标颜色空间的色域内。

```objc
void CGContextSetRenderingIntent(CGContextRef cg_nullable c,CGColorRenderingIntent intent);
```

* `kCGRenderingIntentDefault`: 使用上下文的默认呈现方式。
* `kCGRenderingIntentAbsoluteColorimetric`: 将输出设备色域外的颜色映射到输出设备色域内的最可能匹配的颜色。这会产生剪切效果，其中图形上下文的色域中的两个不同颜色值映射到输出设备色域中的相同颜色值。当图形中使用的颜色在源和目标的色域内时（这是徽标的常见情况或使用专色时），这是最佳选择。
* `kCGRenderingIntentRelativeColorimetric`: 相对色度偏移所有颜色（包括色域内的所有颜色），以解决图形上下文的白点与输出设备的白点之间的差异。
* `kCGRenderingIntentRelativeColorimetric`: 通过压缩图形上下文的色域以适合输出设备的色域，保留颜色之间的视觉关系。感知意图适用于照片和其他复杂，详细的图像。
* `kCGRenderingIntentSaturation`: 当转换为输出设备的色域时，保留颜色的相对饱和度值。结果是图像具有明亮的饱和色彩。饱和度意图适用于再现低细节的图像，例如演示图表和图形。

















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

-->



