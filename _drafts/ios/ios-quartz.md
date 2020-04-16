---
title: Quartz 2D 学习记录
layout: post
categories:
 - ios
---

## Graphics Contexts

通过重写`UIView`中的`- (void)drawRect:(CGRect)rect {}`方法来进行绘制图形。通过`UIGraphicsGetCurrentContext()`方法来获取当前`UIView`的图形上下文。

```objc
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
}
```

在`UIView`中的坐标系为: 原点在左上角，正x向右，正y向下。而在`Quartz`的坐标系中，看下图：

<img src="/assets/images/coretext/09.gif" width = "50%" height = "50%"/>

可以通过转换矩阵或者CTM将图形上下文旋转45度时，可以将原点转移到左上角。

<img src="/assets/images/coretext/10.jpg" width = "50%" height = "50%"/>

### 创建PDF图形上下文
创建PDF图形上下文的两种方式:`CGPDFContextCreateWithURL`、`CGPDFContextCreate`。

```objc
// mediaBox: 是PDF图形上下文的边界边框
CGContextRef myPDFContextCreateWithURL(const CGRect *mediaBox,CFStringRef filePath) {
    CGContextRef pdfContext = NULL;
    CFURLRef url;
    
    url = CFURLCreateWithFileSystemPath(NULL, filePath, kCFURLPOSIXPathStyle, false);
    if (url != NULL) {
        pdfContext = CGPDFContextCreateWithURL(url, mediaBox, NULL);
        CFRelease(url);
    }
    return pdfContext;
}

CGContextRef myCGPDFContextCreate(const CGRect *mediaBox,CFStringRef filePath) {
    CGContextRef pdfContext = NULL;
    CFURLRef url;
    CGDataConsumerRef consumer;
    
    url = CFURLCreateWithFileSystemPath(NULL, filePath, kCFURLPOSIXPathStyle, false);
    if (url != NULL) {
        consumer = CGDataConsumerCreateWithURL(url);
        if (consumer != NULL) {
            pdfContext = CGPDFContextCreate(consumer, mediaBox, NULL);
            CGDataConsumerRelease (consumer);
        }
        CFRelease(url);
    }
    return pdfContext;
}

- (void)drawRect:(CGRect)rect {
    CGRect mediaBox;
    CGContextRef pdfContext;
    
    mediaBox = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    pdfContext = myPDFContextCreateWithURL(&mediaBox, CFSTR("test.pdf"));
    CGContextRelease(pdfContext);
}
```

### 创建位图(Bitmap)图形上下文
当绘制位图图形上下文时，会将位图图形上下文存储到`内存缓存区`中，当更新绘制时缓存区也会更新。

> 位图图形上下文可用于屏幕外绘制。可以参考资料`Core Graphics Layer Drawing`。<br>

`UIGraphicsBeginImageContextWithOptions` 需要详细了解

```objc
// data: 如果不是NULL，则指针指向的内存块必须大于(bytesPerRow*height)。如果是NULL，则图形上下文会被自动创建，在 deallocated 时会被释放。
// width: 位图图形上下文宽，像素
// height: 位图图形上下文高，像素
// bitsPerComponent: 内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8。
// bytesPerRow: 每一行要使用的内存字节数得大于:width * bytes per pixel
// colorspace: 颜色颜色空间
// bitmapInfo: 
CGContextRef CGBitmapContextCreate(void * data,size_t width, size_t height, size_t bitsPerComponent, size_t bytesPerRow,CGColorSpaceRef space, uint32_t bitmapInfo);
```

```objc
CGContextRef myCGBitmapContextCreate(int pixelsWidth,int pixelsHight) {
    CGContextRef bitmapContext = NULL;
    void * data;
    int bitsPerComponent = 8;
    int bytesPerRow;
    CGColorSpaceRef space;
    
    bytesPerRow = pixelsWidth * 4;//4:位图中的每个像素都由4个字节表示；红色，绿色，蓝色和Alpha分别为8位。
    data = calloc( bytesPerRow, sizeof(uint8_t) );
    space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    
    if (data == NULL) {
        fprintf (stderr, "Memory not allocated!");
        return NULL;
    }
    bitmapContext = CGBitmapContextCreate(data, pixelsWidth, pixelsHight, bitsPerComponent, bytesPerRow, space, kCGImageAlphaPremultipliedLast);
    if (bitmapContext == NULL) {
        free (data);
        fprintf (stderr, "Context not created!");
        return NULL;
    }
    CGColorSpaceRelease(space);
    return bitmapContext;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGRect myBoundingBox;
    CGContextRef myBitmapContext;
    CGImageRef myImage;
    
    myBoundingBox = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    myBitmapContext = myCGBitmapContextCreate(myBoundingBox.size.width,myBoundingBox.size.height);
    
    myImage = CGBitmapContextCreateImage (myBitmapContext);// 5
    CGContextDrawImage(myContext, myBoundingBox, myImage);// 6
    CGImageRelease(myImage);
}
```

### 支持的像素格式

* `CS` : 关联的色彩空间。`CGColorSpaceRef`
* `bpp` : bits per pixel
* `bpc` : bits per component
* 像素格式关联的位图信息常量。

<img src="/assets/images/coretext/03.png" width = "100%" height = "100%"/>

### 抗锯齿
```objc
void CGContextSetShouldAntialias(CGContextRef c,bool shouldAntialias);
void CGContextSetAllowsAntialiasing(CGContextRef c,bool allowsAntialiasing);
```
<img src="/assets/images/coretext/08.jpg" width = "50%" height = "50%"/>

### 保存、重新保定图形上下文状态

```objc
void CGContextSaveGState(CGContextRef c);
void CGContextRestoreGState(CGContextRef c);
```

## [路径(Paths)](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_paths/dq_paths.html#//apple_ref/doc/uid/TP30001066-CH211-TPXREF101)

### 点
点是x和y坐标，它们指定用户空间中的位置。

```objc
// 指定新路径的起始位置。
CGContextMoveToPoint(CGContextRef c,CGFloat x, CGFloat y);
```

### 线
```objc
void CGContextAddLineToPoint(CGContextRef c, CGFloat x, CGFloat y);

// 第一点必须是第一条线的起点；其余点是端点。
// points: 一个值数组，指定要绘制的线段的起点和终点。
// count: points数组中元素的数量。
void CGContextAddLines(CGContextRef c, const CGPoint *points, size_t count);
```

```objc
- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextSetStrokeColorWithColor(c, UIColor.redColor.CGColor);
    
    CGContextMoveToPoint(c, 10, 10);
    CGContextAddLineToPoint(c, 10, 100);

    CGContextMoveToPoint(c, 20, 20);
    CGContextAddLineToPoint(c, 20, 200);
    
    CGContextStrokePath(c);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextSetStrokeColorWithColor(c, UIColor.redColor.CGColor);
    
    CGPoint points[] = {
        CGPointMake(10.0, 90.0),
        CGPointMake(70.0, 60.0),
        CGPointMake(130.0, 90.0),
        CGPointMake(190.0, 60.0),
        CGPointMake(250.0, 90.0),
        CGPointMake(310.0, 60.0),
    };
    
    CGContextAddLines(c, points, sizeof(points)/sizeof(points[0]));
    CGContextStrokePath(c);
}
```

<img src="/assets/images/coretext/11.png"/>

### 弧线
```objc
// x: 中心点。
// y: 中心点。
// radius: 圆弧半径。
// startAngle: 与弧起点的夹角，以弧度为单位，从x轴正方向开始。
// endAngle: 与弧的终点之间的角度，以弧度为单位，从正x轴开始以弧度为单位。
// clockwise: 0 顺时针圆弧, 1 逆时针圆弧
void CGContextAddArc(CGContextRef c, CGFloat x, CGFloat y, CGFloat radius, CGFloat startAngle, CGFloat endAngle, int clockwise);
```
<img src="/assets/images/coretext/12.png"/>

```
M_PI   : 3.14159265358979323846264338327950288   --> pi      
M_PI_2 : 1.57079632679489661923132169163975144   --> pi/2    
M_PI_4 : 0.785398163397448309615660845819875721  --> pi/4    
M_1_PI : 0.318309886183790671537767526745028724  --> 1/pi    
M_2_PI : 0.636619772367581343075535053490057448  --> 2/pi    
```

```objc
// x1: 用户空间坐标中第一条切线终点的x值。从当前点到（x1，y1）绘制第一条切线。
// y1: 用户空间坐标中第一条切线终点的y值。从当前点到（x1，y1）绘制第一条切线。
// x2: 用户空间坐标中第二条切线终点的x值。第二条切线从（x1，y1）绘制到（x2，y2）。
// y2: 用户空间坐标中第二条切线终点的y值。第二条切线从（x1，y1）绘制到（x2，y2）。
// radius: 用户空间坐标中的圆弧半径
void CGContextAddArcToPoint(CGContextRef c, CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2, CGFloat radius);
```

<img src="/assets/images/coretext/13.png"/>

其中`P1`是起始点。

```objc
- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextSetStrokeColorWithColor(c, UIColor.redColor.CGColor);

    CGContextAddArc(c, rect.size.width*0.5, rect.size.height*0.5, 50, 0, M_PI*1.5, 0);
    
    CGContextStrokePath(c);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextSetStrokeColorWithColor(c, UIColor.redColor.CGColor);
    
    CGPoint P1 = CGPointMake(rect.size.width*0.25, rect.size.height*0.25);
    CGPoint X1 = CGPointMake(P1.x+200, P1.y);
    CGPoint X2 = CGPointMake(P1.x+200, P1.y+300);
    
    CGContextMoveToPoint(c, P1.x, P1.y);
    CGContextAddArcToPoint(c, X1.x, X1.y, X2.x, X2.y, 30);
    CGContextStrokePath(c);
    
    // 测试画线
    CGContextSetLineWidth(c, 0.8);
    CGContextSetStrokeColorWithColor(c, UIColor.blueColor.CGColor);
    CGContextMoveToPoint(c, P1.x, P1.y);
    CGContextAddLineToPoint(c, X1.x, X1.y);
    
    CGContextMoveToPoint(c, X1.x, X1.y);
    CGContextAddLineToPoint(c, X2.x, X2.y);
    
    CGContextStrokePath(c);
}
```

<img src="/assets/images/coretext/14.png"/>

### 曲线
```objc
// 从当前点附加三次贝塞尔曲线
void CGContextAddCurveToPoint(CGContextRef c, CGFloat cp1x, CGFloat cp1y, CGFloat cp2x, CGFloat cp2y, CGFloat x, CGFloat y);

// 指定一个控制点和一个端点，从当前点附加一个二次贝塞尔曲线。 
void CGContextAddQuadCurveToPoint(CGContextRef c, CGFloat cpx, CGFloat cpy, CGFloat x, CGFloat y);
```

<img src="/assets/images/coretext/15.png"/>

```objc
- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextSetStrokeColorWithColor(c, UIColor.redColor.CGColor);
    
    CGPoint currentP = CGPointMake(100, 200);
    CGPoint cp1 = CGPointMake(200, 100);
    CGPoint cp2 = CGPointMake(300, 300);
    CGPoint cp3 = CGPointMake(400, 200);
    
    CGContextMoveToPoint(c, currentP.x, currentP.y);
    CGContextAddCurveToPoint(c, cp1.x, cp1.y, cp2.x, cp2.y, cp3.x, cp3.y);
    CGContextStrokePath(c);
    
    [self gridWithContext:c];
    
    CGContextMoveToPoint(c, currentP.x, currentP.y);
    CGContextAddLineToPoint(c, cp1.x, cp1.y);
    
    CGContextMoveToPoint(c, cp1.x, cp1.y);
    CGContextAddLineToPoint(c, cp2.x, cp2.y);
    
    CGContextMoveToPoint(c, cp2.x, cp2.y);
    CGContextAddLineToPoint(c, cp3.x, cp3.y);
    CGContextStrokePath(c);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextSetStrokeColorWithColor(c, UIColor.redColor.CGColor);
    
    CGPoint currentP = CGPointMake(100, 200);
    CGPoint cp1 = CGPointMake(200, 100);
    CGPoint cp2 = CGPointMake(300, 300);
    CGPoint cp3 = CGPointMake(400, 200);
    
    CGContextMoveToPoint(c, currentP.x, currentP.y);
    //CGContextAddCurveToPoint(c, cp1.x, cp1.y, cp2.x, cp2.y, cp3.x, cp3.y);
    CGContextAddQuadCurveToPoint(c, cp1.x, cp1.y, cp2.x, cp2.y);
    CGContextStrokePath(c);
    
    [self gridWithContext:c];
    
    CGContextMoveToPoint(c, currentP.x, currentP.y);
    CGContextAddLineToPoint(c, cp1.x, cp1.y);
    
    CGContextMoveToPoint(c, cp1.x, cp1.y);
    CGContextAddLineToPoint(c, cp2.x, cp2.y);
    
    CGContextMoveToPoint(c, cp2.x, cp2.y);
    CGContextAddLineToPoint(c, cp3.x, cp3.y);
    CGContextStrokePath(c);
}

-(void)gridWithContext:(CGContextRef)c{
    CGContextSetLineWidth(c, 1);
    CGContextSetStrokeColorWithColor(c, UIColor.blueColor.CGColor);
    CGFloat lengths = 3;
    CGContextSetLineDash(c, 0, &lengths,1);
    
    // 网格
    CGPoint minPoint = CGPointMake(0, 0);
    CGPoint maxPoint = CGPointMake(400, 400);
    CGFloat margin = 100;
    for (NSInteger i = 0; i <= maxPoint.y/margin; i ++) {
        // 纵向
        CGContextMoveToPoint(c, margin*i, minPoint.y);
        CGContextAddLineToPoint(c, margin*i, maxPoint.y);
        //横向
        CGContextMoveToPoint(c, minPoint.x, margin*i);
        CGContextAddLineToPoint(c, maxPoint.x, margin*i);
    }
    
    CGContextStrokePath(c);
}
```

<img src="/assets/images/coretext/16.png"/>

### 关闭子路径

弧线、曲线在绘制的时候并没有关闭子路径，需要调用`CGContextClosePath`来关闭子路径。

```objc
void CGContextClosePath(CGContextRef c);
```

```objc
- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextSetStrokeColorWithColor(c, UIColor.redColor.CGColor);
    
    CGPoint currentP = CGPointMake(100, 200);
    CGPoint cp1 = CGPointMake(200, 100);
    CGPoint cp2 = CGPointMake(300, 300);
    CGPoint cp3 = CGPointMake(400, 200);
    
    CGContextMoveToPoint(c, currentP.x, currentP.y);
    CGContextAddQuadCurveToPoint(c, cp1.x, cp1.y, cp2.x, cp2.y);
    //CGContextClosePath(c);
    CGContextAddLineToPoint(c, 400, 400);
    
    CGContextStrokePath(c);
}
```

下面展示执行`CGContextClosePath(c)`区别：左图不执行关闭路径函数，右图执行关闭路径函数(关闭路径后再继续向该路径添加直线、圆弧或曲线时，Quartz从您刚刚关闭的子路径的起点开始一个新的子路径)。

<img src="/assets/images/coretext/17.png"/>

### 椭圆形
```objc
// rect: rect是正方形，则椭圆是圆形
void CGContextAddEllipseInRect(CGContextRef c, CGRect rect);
```

```objc
- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextSetStrokeColorWithColor(c, UIColor.redColor.CGColor);
    CGContextAddEllipseInRect(c, CGRectMake(100, 100, 100, 100));
    CGContextStrokePath(c);
    [self gridWithContext:c];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextSetStrokeColorWithColor(c, UIColor.redColor.CGColor);
    CGContextAddEllipseInRect(c, CGRectMake(100, 100, 200, 100));
    CGContextStrokePath(c);
    [self gridWithContext:c];
}

-(void)gridWithContext:(CGContextRef)c{
    CGContextSetLineWidth(c, 1);
    CGContextSetStrokeColorWithColor(c, UIColor.blueColor.CGColor);
    CGFloat lengths = 3;
    CGContextSetLineDash(c, 0, &lengths,1);
    
    // 网格
    CGPoint minPoint = CGPointMake(0, 0);
    CGPoint maxPoint = CGPointMake(400, 400);
    CGFloat margin = 100;
    for (NSInteger i = 0; i <= maxPoint.y/margin; i ++) {
        // 纵向
        CGContextMoveToPoint(c, margin*i, minPoint.y);
        CGContextAddLineToPoint(c, margin*i, maxPoint.y);
        //横向
        CGContextMoveToPoint(c, minPoint.x, margin*i);
        CGContextAddLineToPoint(c, maxPoint.x, margin*i);
    }
    
    CGContextStrokePath(c);
}
```

<img src="/assets/images/coretext/18.png"/>

### 长方形

```objc
// 创建单个长方形
void CGContextAddRect(CGContextRef c, CGRect rect);
// 创建多个长方形
void CGContextAddRects(CGContextRef c, const CGRect *rects, size_t count);
```

```objc
- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextSetStrokeColorWithColor(c, UIColor.redColor.CGColor);
    CGContextAddRect(c, CGRectMake(300, 300, 50, 100));
    
    CGRect rects[] = {
        CGRectMake(0, 0, 100, 100),
        CGRectMake(0, 200, 200, 100)
    };
    CGContextAddRects(c, rects, sizeof(rects)/sizeof(rects[0]));
    CGContextStrokePath(c);
    [self gridWithContext:c];
}
```

<img src="/assets/images/coretext/19.png"/>

### 创建子路径

```objc
void CGContextBeginPath(CGContextRef c);
```

* 在开始新路径之前，请调用函数`CGContextBeginPath`。
* 从当前点开始绘制直线，圆弧和曲线。空路径没有当前点。您必须调用`CGContextMoveToPoint`来设置第一个子路径的起点，或调用一个为您隐式执行此操作的便捷函数。
* 当您要关闭路径中的当前子路径时，请调用该函数`CGContextClosePath`以将线段连接到子路径的起点。即使您未明确设置新的起点，后续的路径调用也会开始新的子路径。
* 您必须调用绘画功能来填充或描边路径，因为创建路径不会绘制路径。

```objc
- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextSetStrokeColorWithColor(c, UIColor.redColor.CGColor);
    
    //子路径1
    CGContextMoveToPoint(c, 100, 100);
    CGContextAddLineToPoint(c, 300, 300);
    CGContextStrokePath(c);// 下左图效果是注释掉这句
    
    //新建一个子路径2
    CGContextBeginPath(c);//开始一个新的子路径2
    CGContextMoveToPoint(c, 300, 100);//新的子路径2需要设置一个起点。
    CGContextAddLineToPoint(c, 200, 400);
    CGContextClosePath(c);// 关闭路径中的当前子路径2
    
    //子路径3,自动开始一个新的路径
    
    CGContextStrokePath(c);
    [self gridWithContext:c];
}
```

<img src="/assets/images/coretext/20.png"/>

* 绘制圆弧时，Quartz会在圆弧的当前点和起点之间绘制一条直线。

```objc
- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 2);
    CGContextSetStrokeColorWithColor(c, UIColor.redColor.CGColor);
    
    //子路径1-直线
    CGContextMoveToPoint(c, 100, 100);
    CGContextAddLineToPoint(c, 300, 300);
    CGContextStrokePath(c);
    
    //子路径2-圆弧
    CGContextBeginPath(c);//开始一个新的子路径2，下左图效果是注释掉这句
    CGContextAddArc(c, rect.size.width*0.5, rect.size.height*0.5, 50, 0, M_PI*1.5, 0);
    CGContextClosePath(c);// 关闭路径中的当前子路径2，下左图效果是注释掉这句
    
    //子路径3,自动开始一个新的路径
    
    CGContextStrokePath(c);
    [self gridWithContext:c];
}
```

<img src="/assets/images/coretext/21.png"/>

绘制路径后，将从图形上下文中**清除该路径**，Quartz提供了两种数据类型来创建可重用的路径：

```objc
// 路径
typedef const struct CGPath *CGPathRef;
typedef struct CGPath CGMutablePathRef;

// 创建可变的CGPath对象，并向其中添加直线，圆弧，曲线和矩形。
CGMutablePathRef CGPathCreateMutable(void);
```

|可变路径函数|被替代函数|
|---|---|
|`CGPathCreateMutable`|`CGContextBeginPath`|
|`CGPathMoveToPoint`|`CGContextMoveToPoint`|
|`CGPathAddLineToPoint`|`CGContextAddLineToPoint`|
|`CGPathAddCurveToPoint`|`CGContextAddCurveToPoint`|
|`CGPathAddEllipseInRect`|`CGContextAddEllipseInRect`|
|`CGPathAddArc`|`CGContextAddArc`|
|`CGPathAddRect`|`CGContextAddRect`|
|`CGPathCloseSubpath`|`CGContextClosePath`|

```objc
CGMutablePathRef CGPathCreateMutable(void);
void CGPathMoveToPoint(CGMutablePathRef path, const CGAffineTransform *m, CGFloat x, CGFloat y);
void CGPathAddLineToPoint(CGMutablePathRef path, const CGAffineTransform *m, CGFloat x, CGFloat y);
void CGPathAddCurveToPoint(CGMutablePathRef path, const CGAffineTransform *m, CGFloat cp1x, CGFloat cp1y, CGFloat cp2x, CGFloat cp2y, CGFloat x, CGFloat y);
void CGPathAddEllipseInRect(CGMutablePathRef path, const CGAffineTransform *m, CGRect rect);
void CGPathAddArc(CGMutablePathRef path, const CGAffineTransform *m, CGFloat x, CGFloat y, CGFloat radius, CGFloat startAngle, CGFloat endAngle, bool clockwise);
void CGPathAddRect(CGMutablePathRef path, const CGAffineTransform *m, CGRect rect);
void CGPathCloseSubpath(CGMutablePathRef path);
```

调用`CGContextAddPath`函数将路径追加到图形上下文中。该路径将保留在图形上下文中，直到Quartz绘制它为止。可以通过调用`CGContextAddPath`函数再次添加路径。

```objc
void CGContextAddPath(CGContextRef c, CGPathRef path);
```

可以通过调用函数将图形上下文中的路径替换为路径的描边版本:

```objc
void CGContextReplacePathWithStrokedPath(CGContextRef c);
```

### 绘制路径

#### 影响路径的参数

绘制路径有两种方式`描边`、`填充`。

设置线宽：

```objc
// 线宽度
void CGContextSetLineWidth(CGContextRef c, CGFloat width);
// limit：当 CGContextSetLineJoin函数设置 join 为 kCGLineJoinMiter，limit的数值为锐角的长度
void CGContextSetMiterLimit(CGContextRef c, CGFloat limit);
// 描边色彩空间
void CGContextSetStrokeColorSpace(CGContextRef c,CGColorSpaceRef space);
// 描边的颜色
void CGContextSetStrokeColor(CGContextRef c,const CGFloat * components);
void CGContextSetStrokeColorWithColor(CGContextRef c,CGColorRef color);

// 描边模式
void CGContextSetStrokePattern(CGContextRef c,CGPatternRef pattern, const CGFloat * components);
```

线连接的展示样式:

```objc
// kCGLineJoinMiter
// kCGLineJoinRound
// kCGLineJoinBevel
void CGContextSetLineJoin(CGContextRef c, CGLineJoin join);
```

|样式|展示|
|---|---|
|kCGLineJoinMiter|<img src="/assets/images/coretext/22.gif"/>|
|kCGLineJoinRound|<img src="/assets/images/coretext/23.gif"/>|
|kCGLineJoinBevel|<img src="/assets/images/coretext/24.gif"/>|

线两端的展示样式:

```objc

// kCGLineCapButt
// kCGLineCapRound
// kCGLineCapSquare
void CGContextSetLineCap(CGContextRef c, CGLineCap cap);
```

|样式|展示|
|---|---|
|kCGLineCapButt|<img src="/assets/images/coretext/25.gif"/>|
|kCGLineCapRound|<img src="/assets/images/coretext/26.gif"/>|
|kCGLineCapSquare|<img src="/assets/images/coretext/27.gif"/>|

```objc
// c: 
// phase: 表示在第一个虚线绘制的时候跳过多少个点。
// lengths: 虚线的宽度，在线条的上色和未上色的线段之间交替
// count: lengths
void CGContextSetLineDash(CGContextRef c, CGFloat phase, const CGFloat *lengths, size_t count);
```

<img src="/assets/images/coretext/28.gif"/>

```objc
float lengths[] = {10,10}; // 表示先绘制10个点，再跳过10个点，如此反复
CGContextSetLineDash(context, 0, lengths,2);
```

<img src="/assets/images/coretext/29.png"/>

```objc
float lengths[] = {10,20,10}; // 表示先绘制10个点，跳过20个点，绘制10个点，跳过10个点，再绘制20个点，如此反复
CGContextSetLineDash(context, 0, lengths,2);
```

<img src="/assets/images/coretext/30.png"/>

```objc
float lengths[] = {10,5};  
CGContextSetLineDash(context, 0, lengths, 2);
CGContextSetLineDash(context, 5, lengths, 2);
CGContextSetLineDash(context, 8, lengths, 2);
```

<img src="/assets/images/coretext/31.png"/>

#### 描边(Stroke)路径
```objc
// 对当前路径进行描边
void CGContextStrokePath(CGContextRef c);
// 对rect范围进行描边
void CGContextStrokeRect(CGContextRef c, CGRect rect);
// 对rect范围进行描边,并且加上宽度为width的边界线
void CGContextStrokeRectWithWidth(CGContextRef c,CGRect rect, CGFloat width);
void CGContextStrokeEllipseInRect(CGContextRef c,CGRect rect);
// 绘制多条线
// points: 数组如果为偶数，则偶数坐标为线的起点和终点，如果为奇数那么线的起点默认为 (0,0)到(x,y)的连线。
void CGContextStrokeLineSegments(CGContextRef c,const CGPoint * points, size_t count);
void CGContextDrawPath(CGContextRef c,CGPathDrawingMode mode);
```

```objc
- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 3);
    
    CGContextSetStrokeColorWithColor(c, UIColor.redColor.CGColor);
    CGContextStrokeRectWithWidth(c, CGRectMake(100, 100, 100, 100), 5);
    
    CGContextSetStrokeColorWithColor(c, UIColor.greenColor.CGColor);
    CGContextStrokeEllipseInRect(c, CGRectMake(0, 0, 300, 300));
    
    CGContextSetStrokeColorWithColor(c, UIColor.orangeColor.CGColor);
    CGPoint points[] = {CGPointMake(100, 200),CGPointMake(200, 100),CGPointMake(300, 300),CGPointMake(400, 400)};
    CGContextStrokeLineSegments(c, points, sizeof(points)/sizeof(points[0]));
    
    [self gridWithContext:c];
}
```

<img src="/assets/images/coretext/32.png"/>

#### 填充(Fill)路径

```objc
// 使用奇偶填充当前路径
void CGContextEOFillPath(CGContextRef c);
// 使用非零绕数填充当前路径。
void CGContextFillPath(CGContextRef c);
// 填充适合指定矩形的区域
void CGContextFillRect(CGContextRef c, CGRect rect);
// 填充适合指定矩形的区域
void CGContextFillRects(CGContextRef c,const CGRect * rects, size_t count);
// 填充适合指定矩形的椭圆
void CGContextFillEllipseInRect(CGContextRef c,CGRect rect);

// 通过mode来指定填充规则。
// kCGPathFill 非零绕数
// kCGPathEOFill 奇数
// kCGPathStroke 
// kCGPathFillStroke 
// kCGPathEOFillStroke 
void CGContextDrawPath(CGContextRef c,CGPathDrawingMode mode);
```

* `奇偶填充(even-odd)`：
* `非零绕数(the nonzero winding number)`：

<img src="/assets/images/coretext/34.gif"/>


```objc
// 奇偶填充(even-odd)示例：
- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextAddEllipseInRect(c, CGRectMake(100, 100, 200, 200));
    CGContextAddEllipseInRect(c, CGRectMake(150, 150, 100, 100));
    CGContextAddEllipseInRect(c, CGRectMake(175, 175, 50, 50));
    CGContextAddEllipseInRect(c, CGRectMake(187.5, 187.5, 25, 25));
    CGContextEOFillPath(c);
    
    [self gridWithContext:c];
}
```

<img src="/assets/images/coretext/35.png"/>

```objc
- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 3);
    
    CGContextSetFillColorWithColor(c, UIColor.redColor.CGColor);
    CGContextFillRect(c, CGRectMake(0, 0, 50, 50));
    
    CGContextSetFillColorWithColor(c, UIColor.greenColor.CGColor);
    CGRect rects[] = {
        CGRectMake(100, 0, 50, 50),
        CGRectMake(100, 60, 50, 50),
        CGRectMake(100, 120, 50, 50)
    };
    CGContextFillRects(c, rects, sizeof(rects)/sizeof(rects[0]));
    
    CGContextSetFillColorWithColor(c, UIColor.orangeColor.CGColor);
    CGContextFillEllipseInRect(c, CGRectMake(200, 0, 100, 100));

    [self gridWithContext:c];
}
```

<img src="/assets/images/coretext/33.png"/>

#### [设置混合模式(Blend Modes)](https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_paths/dq_paths.html#//apple_ref/doc/uid/TP30001066-CH211-TPXREF101)

混合模式指定Quartz如何在背景上应用绘画。

```objc
// 设置混合模式
// kCGBlendModeNormal,普通混合模式
// kCGBlendModeMultiply,乘法混合模式
// kCGBlendModeScreen,屏幕混合模式
// kCGBlendModeOverlay,叠加混合模式
// kCGBlendModeDarken,调暗混合模式
// kCGBlendModeLighten,减轻混合模式
// kCGBlendModeColorDodge,道奇混合模式
// kCGBlendModeColorBurn,混色混合模式
// kCGBlendModeSoftLight,柔光混合模式
// kCGBlendModeHardLight,硬光混合模式
// kCGBlendModeDifference,差异混合模式
// kCGBlendModeExclusion,排除混合模式
// kCGBlendModeHue,色相混合模式
// kCGBlendModeSaturation,饱和混合模式
// kCGBlendModeColor,色彩混合模式
void CGContextSetBlendMode(CGContextRef c, CGBlendMode mode);
void CGContextSaveGState(CGContextRef c);
void CGContextRestoreGState(CGContextRef c);
```

#### 剪切路径

```objc
// 使用非零绕数规则来计算当前路径与当前剪切路径的交集。
void CGContextClip(CGContextRef c);
// 使用奇偶规则计算当前路径与当前剪切路径的交集。
void CGContextEOClip(CGContextRef c);
// 
void CGContextClipToRect(CGContextRef c, CGRect rect);
// 
void CGContextClipToRects(CGContextRef c,const CGRect *  rects, size_t count);
// 
void CGContextClipToMask(CGContextRef c, CGRect rect,CGImageRef mask);
```

```objc
- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();

    CGContextClipToRect(c, CGRectMake(100, 100, 100, 100)); //左图是加了这句代码的效果
    CGContextAddEllipseInRect(c, CGRectMake(100, 100, 200, 200));
    CGContextAddEllipseInRect(c, CGRectMake(100, 100, 50, 50));
    CGContextFillPath(c);
    [self gridWithContext:c];
}
```

<img src="/assets/images/coretext/36.png"/>

## Color and Color Spaces

### 色彩空间的值

|值|色彩空间|组件|
|---|---|---|
|240 degrees, 100%, 100%|HSB|Hue, saturation, brightness|
|0, 0, 1|RGB|Red, green, blue|
|1, 1, 0, 0|CMYK|Cyan, magenta, yellow, black|
|1, 0, 0|BGR|Blue, green, red|

### 透明度(Alpha)

不同的`Alpha`值展示的控件样式：

<img src="/assets/images/coretext/37.gif"/>

通过在绘制之前在图形上下文中设置全局的`Alpha`值，使的页面上的对象和页面本身透明。

<img src="/assets/images/coretext/38.gif"/>

```objc
// 设置全局的Alpha
void CGContextSetAlpha(CGContextRef c, CGFloat alpha);
// 通过清除图形上下文中的Alpha值来达到页面本身透明。
void CGContextClearRect(CGContextRef c, CGRect rect);
```

### 创建色彩空间
设备（显示器，打印机，扫描仪，照相机）的颜色处理方式不同。每种都有其自己的颜色范围。色彩空间用于管理这些不同设备的颜色。

```objc
// 创建色彩空间
CGColorSpaceRef CGColorSpaceCreateWithName(CFStringRef name);
// 通过传入色彩空间来创建CGColor对象。数组中的最后一个组件指定alpha值
CGColorRef CGColorCreate(CGColorSpaceRef space,const CGFloat * components);
```

```objc
CGFloat components[] = {
    255.F/255.F, //R
    255.F/255.F, //G
    255.F/255.F, //B
    1.0 // Alpha
};
CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
CGColorRef color = CGColorCreate(space, components);
```

色彩空间的值：

* 备无关的色彩空间:
    * `CGColorSpaceCreateLab` : 
    * `CGColorSpaceCreateICCBased` : 
    * `CGColorSpaceCreateCalibratedRGB` : 
    * `CGColorSpaceCreateCalibratedGray` : 
* 通用色彩空间:
    * `kCGColorSpaceGenericGray` :通用灰色，是一种单色空间，允许从绝对黑(0.0)到绝对白(1.0)的单值。
    * `kCGColorSpaceGenericRGB` : 通用RGB，由三部分组成的色彩空间(Red, green, blue)。
    * `kCGColorSpaceGenericCMYK` : 通用CMYK，组成的色彩空间(Cyan, magenta, yellow, black)，模拟打印机墨水的堆积方式。
* 设备色彩空间:
    * `CGColorSpaceCreateDeviceGray` : 
    * `CGColorSpaceCreateDeviceRGB` : 
    * `CGColorSpaceCreateDeviceCMYK` : 
* 索引和图案颜色空间:
    * `CGColorSpaceCreateIndexed` : 
    * `CGColorSpaceCreatePattern` :

### 设置和创建颜色
* Quartz提供了一组用于设置填充(Fill)颜色，描边(Stroke)颜色，颜色空间和Alpha的功能。
* 颜色必须关联到色彩空间，不然Quartz不知道如何解释颜色值。

设置颜色:

```objc
//设备RGB
void CGContextSetRGBStrokeColor(CGContextRef c,CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha);
void CGContextSetRGBFillColor(CGContextRef c, CGFloat red,CGFloat green, CGFloat blue, CGFloat alpha);

// 设备CMYK
void CGContextSetCMYKStrokeColor(CGContextRef c,CGFloat cyan, CGFloat magenta, CGFloat yellow, CGFloat black, CGFloat alpha);
void CGContextSetCMYKFillColor(CGContextRef c,CGFloat cyan, CGFloat magenta, CGFloat yellow, CGFloat black, CGFloat alpha);

// 设备灰色
void CGContextSetGrayStrokeColor(CGContextRef c,CGFloat gray, CGFloat alpha);
void CGContextSetGrayFillColor(CGContextRef c,CGFloat gray, CGFloat alpha);

// 任何色彩空间
void CGContextSetStrokeColorWithColor(CGContextRef c,CGColorRef color);
void CGContextSetFillColorWithColor(CGContextRef c,CGColorRef color);

// 当前的色彩空间。不建议
void CGContextSetStrokeColor(CGContextRef c,const CGFloat * components);
void CGContextSetFillColor(CGContextRef c,const CGFloat * components);
```

### 设置渲染

```objc
// kCGRenderingIntentDefault,
// kCGRenderingIntentAbsoluteColorimetric,
// kCGRenderingIntentRelativeColorimetric,
// kCGRenderingIntentPerceptual,
// kCGRenderingIntentSaturation
void CGContextSetRenderingIntent(CGContextRef c,CGColorRenderingIntent intent);
```

## Transforms
### 修改CTM(Current Transformation Matrix)
可以对CTM进行平移，旋转，缩放和连接。在转换前需要保存图形上下文的状态，以便在绘制后恢复。

```objc
// 平移
void CGContextTranslateCTM(CGContextRef c,CGFloat tx, CGFloat ty);
// 旋转
void CGContextRotateCTM(CGContextRef c, CGFloat angle);
// 缩放；sx sy 缩放因子
void CGContextScaleCTM(CGContextRef c,CGFloat sx, CGFloat sy);

// 旋转角度的工具方法
#include <math.h>
static inline double radians (double degrees) {return degrees * M_PI/180;}
```

```objc
- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);// 在绘制CTM之前先保存图形上下文状态，为了不影响网格 gridWithContext() 的绘制
    
    //CGContextTranslateCTM(c, 100, 100);
    //CGContextRotateCTM(c, radians(-45.));
    //CGContextScaleCTM(c, 1.5, .75);
    
    UIImage *loadImage = [UIImage imageNamed:@"chiken"];
    [loadImage drawInRect:CGRectMake(0, 0, loadImage.size.width, loadImage.size.height)];
    
    CGContextRestoreGState(c);// 重新保存图形上下文状态，绘制网格
    [self gridWithContext:c];
}
```

<img src="/assets/images/coretext/39.png"/> <!-- width = "25%" height = "25%" -->

### 创建CTM

```objc
// t' = [ 1 0 0 1 tx ty ]
CGAffineTransform CGAffineTransformMakeTranslation(CGFloat tx,CGFloat ty);
// t' = [ 1 0 0 1 tx ty ] * t
CGAffineTransform CGAffineTransformTranslate(CGAffineTransform t,CGFloat tx, CGFloat ty);
// t' = [ cos(angle) sin(angle) -sin(angle) cos(angle) 0 0 ]
CGAffineTransform CGAffineTransformMakeRotation(CGFloat angle);
// t' =  [ cos(angle) sin(angle) -sin(angle) cos(angle) 0 0 ] * t
CGAffineTransform CGAffineTransformRotate(CGAffineTransform t,CGFloat angle);
// t' = [ sx 0 0 sy 0 0 ]
CGAffineTransform CGAffineTransformMakeScale(CGFloat sx, CGFloat sy);
//t' = [ sx 0 0 sy 0 0 ] * t
CGAffineTransform CGAffineTransformScale(CGAffineTransform t,CGFloat sx, CGFloat sy);
```

### CTM 涉及到的数学

`CGAffineTransform`(Core Graphics Affine Transform) 用于CG框架，对二维空间进行平移、缩放和旋转的功能。通过一个仿射变换矩阵（一个3X3的矩阵）实现。它采用的是二维坐标系（ 即向右为x轴正方向,向下为y轴正方向）。

<img src="/assets/images/coretext/40.png" width = "50%" height = "50%"/>

<img src="/assets/images/coretext/41.gif"/>

矩阵中的每一列的元素都和`[x y 1]`做乘法，得出的结果再想加，就得到仿射变换后`x1`或`y1`的值。其中矩阵中的具体`0、1`是为了占位，不具有什么意义。

<img src="/assets/images/coretext/42.png"/>

这样就可以通过修改`tx ty`来实现平移。

<img src="/assets/images/coretext/43.png"/>

这样就可以通过修改`a b`来实现缩放。

## Patterns(图案样式)
Patterns 是一系列绘制操作，重复绘制到图形上下文。

```objc
void CGContextSetFillColor(CGContextRef c,const CGFloat * components);

void CGContextSetFillPattern(CGContextRef c,CGPatternRef pattern, const CGFloat * components);
void CGContextSetStrokePattern(CGContextRef c,CGPatternRef pattern, const CGFloat * components);

typedef void (*CGPatternDrawPatternCallback)(void * info,CGContextRef context);
typedef void (*CGPatternReleaseInfoCallback)(void * info);

struct CGPatternCallbacks {
    unsigned int version; // 设置为0
    CGPatternDrawPatternCallback drawPattern; // 图形回调的指针
    CGPatternReleaseInfoCallback releaseInfo;
};
typedef struct CGPatternCallbacks CGPatternCallbacks;

CGPatternRef CGPatternCreate(void * info,CGRect bounds, CGAffineTransform matrix, CGFloat xStep, CGFloat yStep,CGPatternTiling tiling, bool isColored,const CGPatternCallbacks * callbacks);

CGColorSpaceRef CGColorSpaceCreatePattern(CGColorSpaceRef baseSpace);

void CGContextSetFillColorSpace(CGContextRef c,CGColorSpaceRef space);
void CGContextSetStrokeColorSpace(CGContextRef c,CGColorSpaceRef space);
```

* [Quartz 2D编程指南 （八） —— Patterns图案样式（一）](https://www.jianshu.com/p/b300ecd98531)


```objc
//1. Write a Callback Function That Draws a Colored Pattern Cell
void MyDrawColoredPattern (void *info, CGContextRef myContext) {
    CGFloat subunit = 5; // the pattern cell itself is 16 by 18
    
    CGRect  myRect1 = {{0,0}, {subunit, subunit}};
    CGRect myRect2 = {{subunit, subunit}, {subunit, subunit}};
    CGRect myRect3 = {{0,subunit}, {subunit, subunit}};
    CGRect myRect4 = {{subunit,0}, {subunit, subunit}};
    
    CGContextSetRGBFillColor (myContext, 0, 0, 1, 0.5);
    CGContextFillRect (myContext, myRect1);
    CGContextSetRGBFillColor (myContext, 1, 0, 0, 0.5);
    CGContextFillRect (myContext, myRect2);
    CGContextSetRGBFillColor (myContext, 0, 1, 0, 0.5);
    CGContextFillRect (myContext, myRect3);
    CGContextSetRGBFillColor (myContext, .5, 0, .5, 0.5);
    CGContextFillRect (myContext, myRect4);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState (c);
    //2. Set Up the Colored Pattern Color Space
    CGColorSpaceRef patternSpace;
    patternSpace = CGColorSpaceCreatePattern (NULL);//passing NULL as the base color space
    CGContextSetFillColorSpace (c, patternSpace);
    
    //3. Set Up the Anatomy of the Colored Pattern
    static const CGPatternCallbacks callbacks = {0,&MyDrawColoredPattern,NULL};
    CGPatternRef pattern;
    pattern = CGPatternCreate(NULL,
                    CGRectMake(0, 0, rect.size.width, rect.size.height),
                    CGAffineTransformIdentity,
                    H_PATTERN_SIZE,
                    V_PATTERN_SIZE,
                    kCGPatternTilingConstantSpacing,
                    true, &callbacks);
    //4. Specify the Colored Pattern as a Fill or Stroke Pattern
    CGFloat alpha = 1;
    CGContextSetFillPattern(c, pattern, &alpha);
    
    //5. Draw With the Colored Pattern
    CGContextFillPath(c);
    
    CGColorSpaceRelease (patternSpace);
    CGPatternRelease(pattern);
    
    CGContextRestoreGState (c);
}
```

## Shadows[$]
## Gradients[$$]
## Transparency Layers[$]
## Data Management in Quartz 2D[$]
## Bitmap Images and Image Masks[$$]
## Core Graphics Layer Drawing[$]
## PDF Document Creation, Viewing, and Transforming[$]
## PDF Document Parsing[$]
## PostScript Conversion[$]

## 参考资料
* [iOS的View编程指南](https://developer.apple.com/library/archive/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/Introduction/Introduction.html#//apple_ref/doc/uid/TP40009503)



## CGAffineTransform 、 CATransform3D

CGAffineTransform ： CG(CoreGraphics框架) Affine(仿射) Transform(变化) 用于在二维空间做旋转,缩放和平移.

CGAffineTransform是一个可以和二维空间向量（例如CGPoint）做乘法的3X2的矩阵,layer的affineTransform的属性也是CGAffineTransform.


https://www.jianshu.com/p/824822ca4822


## 三角函数

$\sum_{i=0}^N\int_{a}^{b}g(t,i)\text{d}t$




* Painting Colored Patterns
    * Write a Callback Function That Draws a Colored Pattern Cell
    * Set Up the Colored Pattern Color Space
    * Set Up the Anatomy of the Colored Pattern
    * Specify the Colored Pattern as a Fill or Stroke Pattern
    * Draw With the Colored Pattern
    * A Complete Colored Pattern Painting Function
* Painting Stencil Patterns


### Write a Callback Function That Draws a Colored Pattern Cell

```objc
// 这个回调函数用于绘制纯色图案的 单个cell。Draws a Colored Pattern Cell
// info ：  是一个通用指针，用于传递数据到pattern里，如果没有可以传NULL
// context ： pattern cell 需要绘制到的图形上下文
typedef void (*CGPatternDrawPatternCallback)(void * info,CGContextRef context);
```

```objc
void drawPatternCallback(void * info,CGContextRef context){
    // 设置填充色
    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);//red green blue alpha
    CGContextFillRect(context, CGRectMake(0, 0, TILE_SIZE, TILE_SIZE));//需要填充的位置
    CGContextFillRect(context, CGRectMake(TILE_SIZE, TILE_SIZE, TILE_SIZE, TILE_SIZE));//需要填充的位置
}
```

### Set Up the Colored Pattern Color Space
```objc
// Creating a base pattern color space
CGColorSpaceRef patternSpace;
patternSpace = CGColorSpaceCreatePattern (NULL);//passing NULL as the base color space
CGContextSetFillColorSpace (c, patternSpace);
CGColorSpaceRelease (patternSpace);
```

### Set Up the Anatomy of the Colored Pattern

```objc
// info: params `info` will be passing to -> (*CGPatternDrawPatternCallback)(void * info,CGContextRef context);
// bounds: size of the pattern cell
// matrix: trans、rotate、scale the pattern cell
// xStep、yStep: 间距
// isColored: specifies whether the pattern cell is a colored pattern (true) or a stencil pattern (false).
// if isColored is true, need code #Set Up the Colored Pattern Color Space#
CGPatternRef CGPatternCreate(void * info,CGRect bounds, CGAffineTransform matrix, CGFloat xStep, CGFloat yStep,CGPatternTiling tiling, bool isColored,CGPatternCallbacks * callbacks);

struct CGPatternCallbacks{
    unsigned int version; // set the version field to 0
    CGPatternDrawPatternCallback drawPattern;//drawing callback
    CGPatternReleaseInfoCallback releaseInfo;//a callback that’s invoked when the CGPattern object is released, to release storage for the info parameter you passed to your drawing callback. If you didn’t pass any data in this parameter, you set this field to NULL.
};
``` 

```objc
CGRect bounds = CGRectMake(0, 0, 2*TILE_SIZE, 2*TILE_SIZE);// cell 的大小
CGAffineTransform transform = CGAffineTransformIdentity;
CGFloat xStep = 2*TILE_SIZE;// cell 横向间距
CGFloat yStep = 2*TILE_SIZE;// cell 纵向间距
CGPatternTiling tiling = kCGPatternTilingNoDistortion; //cell 摆放的方式
bool isColored = false;//cell 是否已经指定了颜色。
CGPatternCallbacks callback = {0,&drawPatternCallback,&releaseInfoCallback};//绘制回调函数
CGPatternRef pattern = CGPatternCreate(NULL, bounds, transform, xStep, yStep, tiling, isColored, &callback);
```

### Specify the Colored Pattern as a Fill or Stroke Pattern

```objc
/*
components: An array of color components.Although colored patterns supply their own color, you must pass a single alpha value to inform Quartz of the overall opacity of the pattern when it’s drawn. Alpha can vary from 1 (completely opaque) to 0 (completely transparent). These lines of code show an example of how to set opacity for a colored pattern used to fill.
*/
void CGContextSetFillPattern(CGContextRef c,CGPatternRef pattern, const CGFloat * components);
void CGContextSetStrokePattern(CGContextRef c,CGPatternRef pattern, const CGFloat * components);
```

```objc
// set opacity for a colored pattern used to fill.
CGFloat alpha = 1;
CGContextSetFillPattern (myContext, myPattern, &alpha)
```

### Draw With the Colored Pattern
After you’ve completed the previous steps, you can call any Quartz 2D function that paints. Your pattern is used as the “paint.”

```objc
// For example : CGContextStrokePath, CGContextFillPath, CGContextFillRect
```

### A Complete Colored Pattern Painting Function
















































































