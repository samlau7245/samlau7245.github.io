---
title: iOS Foundation
layout: post
categories:
 - ios
---

## NSAttributedString

```objc
NSFontAttributeName               //设置字体属性，默认值：字体：Helvetica(Neue) 字号：12
NSForegroundColorAttributeNam     //设置字体颜色，取值为 UIColor对象，默认值为黑色
NSBackgroundColorAttributeName    //设置字体所在区域背景颜色，取值为 UIColor对象，默认值为nil, 透明色
NSLigatureAttributeName           //设置连体属性，取值为NSNumber 对象(整数)，0 表示没有连体字符，1 表示使用默认的连体字符
NSKernAttributeName               //设定字符间距，取值为 NSNumber 对象（整数），正值间距加宽，负值间距变窄
NSStrikethroughStyleAttributeName //设置删除线，取值为 NSNumber 对象（整数）
NSStrikethroughColorAttributeName //设置删除线颜色，取值为 UIColor 对象，默认值为黑色
NSUnderlineStyleAttributeName     //设置下划线，取值为 NSNumber 对象（整数），枚举常量 NSUnderlineStyle中的值，与删除线类似
NSUnderlineColorAttributeName     //设置下划线颜色，取值为 UIColor 对象，默认值为黑色
NSStrokeWidthAttributeName        //设置笔画宽度，取值为 NSNumber 对象（整数），负值填充效果，正值中空效果
NSStrokeColorAttributeName        //填充部分颜色，不是字体颜色，取值为 UIColor 对象
NSShadowAttributeName             //设置阴影属性，取值为 NSShadow 对象
NSTextEffectAttributeName         //设置文本特殊效果，取值为 NSString 对象，目前只有图版印刷效果可用：
NSBaselineOffsetAttributeName     //设置基线偏移值，取值为 NSNumber （float）,正值上偏，负值下偏
NSObliquenessAttributeName        //设置字形倾斜度，取值为 NSNumber （float）,正值右倾，负值左倾
NSExpansionAttributeName          //设置文本横向拉伸属性，取值为 NSNumber （float）,正值横向拉伸文本，负值横向压缩文本
NSWritingDirectionAttributeName   //设置文字书写方向，从左向右书写或者从右向左书写
NSVerticalGlyphFormAttributeName  //设置文字排版方向，取值为 NSNumber 对象(整数)，0 表示横排文本，1 表示竖排文本
NSLinkAttributeName               //设置链接属性，点击后调用浏览器打开指定URL地址
NSAttachmentAttributeName         //设置文本附件,取值为NSTextAttachment对象,常用于文字图片混排
NSParagraphStyleAttributeName     //设置文本段落排版格式，取值为 NSParagraphStyle 对象
```

## NSParagraphStyle 段落设置

```objc
typedef NS_ENUM(NSInteger, NSLineBreakMode) {
    NSLineBreakByWordWrapping = 0,         // Wrap at word boundaries, default
    NSLineBreakByCharWrapping,        // Wrap at character boundaries
    NSLineBreakByClipping,        // Simply clip
    NSLineBreakByTruncatingHead,    // Truncate at head of line: "...wxyz"
    NSLineBreakByTruncatingTail,    // Truncate at tail of line: "abcd..."
    NSLineBreakByTruncatingMiddle    // Truncate middle of line:  "ab...yz"
};
typedef NS_ENUM(NSInteger, NSWritingDirection) {
    NSWritingDirectionNatural       = -1,   // Determines direction using the Unicode Bidi Algorithm rules P2 and P3
    NSWritingDirectionLeftToRight   = 0,    // Left to right writing direction
    NSWritingDirectionRightToLeft   = 1     // Right to left writing direction
};

@interface NSMutableParagraphStyle : NSParagraphStyle
@property (nonatomic) CGFloat lineSpacing;// 行间距
@property (nonatomic) CGFloat paragraphSpacing;// 段落间距
@property (nonatomic) NSTextAlignment alignment;// 对齐方式
@property (nonatomic) CGFloat firstLineHeadIndent;//首行缩进
@property (nonatomic) CGFloat headIndent;
@property (nonatomic) CGFloat tailIndent;
@property (nonatomic) NSLineBreakMode lineBreakMode;// 分割模式
@property (nonatomic) CGFloat minimumLineHeight;//最小行高
@property (nonatomic) CGFloat maximumLineHeight;//最大行高(会影响字体)
@property (nonatomic) NSWritingDirection baseWritingDirection;// 段落方向
@property (nonatomic) CGFloat lineHeightMultiple;// 行高倍数
@property (nonatomic) CGFloat paragraphSpacingBefore;
@property (nonatomic) float hyphenationFactor;// 连字符属性 0~1.0

@property (copy, nonatomic) NSArray<NSTextTab *> *tabStops;// 制表符
@property (nonatomic) CGFloat defaultTabInterval;
@property (nonatomic) BOOL allowsDefaultTighteningForTruncation;//收缩字符间距允许截断

- (void)addTabStop:(NSTextTab *)anObject;
- (void)removeTabStop:(NSTextTab *)anObject;
- (void)setParagraphStyle:(NSParagraphStyle *)obj;
@end
```

## NSShadow

```objc
@interface NSShadow : NSObject <NSCopying, NSSecureCoding>
- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
@property (nonatomic, assign) CGSize shadowOffset;      // offset in user space of the shadow from the original drawing
@property (nonatomic, assign) CGFloat shadowBlurRadius; // blur radius of the shadow in default user space units
@property (nullable, nonatomic, strong) id shadowColor;           // color used for the shadow (default is black with an alpha value of 1/3)
@end
```

## NSTextAttachment

```objc
/*=== Initializing a Text Attachment ===*/
- (instancetype)initWithData:(nullable NSData *)contentData ofType:(nullable NSString *)uti;
+ (NSTextAttachment *)textAttachmentWithImage:(UIImage *)image API_AVAILABLE(ios(13.0),tvos(13.0));

/*=== Defining the Contents ===*/
@property (nullable, copy, nonatomic) NSData *contents;
@property (nullable, copy, nonatomic) NSString *fileType;
@property (nullable, strong, nonatomic) UIImage *image;
@property (nonatomic) CGRect bounds;
@property (nullable, strong, nonatomic) NSFileWrapper *fileWrapper;

+ (NSAttributedString *)attributedStringWithAttachment:(NSTextAttachment *)attachment;
```

### NSTextAttachmentContainer

如果想要自己控制图片尺寸，可以自定义 NSTextAttachment ，然后实现 NSTextAttachmentContainer 协议的方法

```objc
- (nullable UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(nullable NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex
- (CGRect)attachmentBoundsForTextContainer:(nullable NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
```

```objc
@interface SamTextAttachment01 : NSTextAttachment
@end

@implementation SamTextAttachment01
-(CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex{
    return CGRectMake(0 ,0 ,lineFrag.size.height,lineFrag.size.height);
}
-(UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex{
    return self.image;
}
@end
```

## NSTextContainer(暂定)

* `NSTextContainer` 只要保证其原子访问，就可以用多线程环境。
* `NSTextContainer` 所做的所有工作都是在为 `NSLayoutManager` 提供布局信息或者说是布局建议。`NSTextContainer` 所做的仅仅是指明文本显示的区域，并且不接受任何超出区域的文本。

```objc
/*=== Creating a Text Container ===*/
- (instancetype)initWithSize:(CGSize)size;
- (instancetype)initWithCoder:(NSCoder *)coder;

/*=== Managing Text Components ===*/ 
@property (nullable, assign, NS_NONATOMIC_IOSONLY) NSLayoutManager *layoutManager;
- (void)replaceLayoutManager:(NSLayoutManager *)newLayoutManager;

/*=== Defining the Container Shape ===*/
// Default: CGSizeZero,Defines the maximum size for the layout area
@property (NS_NONATOMIC_IOSONLY) CGSize size;
// Default: empty array, 代表文本不可渲染的区域的集合。
@property (copy, NS_NONATOMIC_IOSONLY) NSArray<UIBezierPath *> *exclusionPaths;
@property (NS_NONATOMIC_IOSONLY) NSLineBreakMode lineBreakMode;
@property (NS_NONATOMIC_IOSONLY) BOOL widthTracksTextView;
@property (NS_NONATOMIC_IOSONLY) BOOL heightTracksTextView;

/*=== Constraining Text Layout ===*/ 
// 最大行数
@property (NS_NONATOMIC_IOSONLY) NSUInteger maximumNumberOfLines;
// 行片段内边距
@property (NS_NONATOMIC_IOSONLY) CGFloat lineFragmentPadding;
- (CGRect)lineFragmentRectForProposedRect:(CGRect)proposedRect atIndex:(NSUInteger)characterIndex writingDirection:(NSWritingDirection)baseWritingDirection remainingRect:(nullable CGRect *)remainingRect;
@property (getter=isSimpleRectangularTextContainer, readonly, NS_NONATOMIC_IOSONLY) BOOL simpleRectangularTextContainer;
```
## NSStringDrawing

```objc
@interface NSString (NSExtendedStringDrawing)
- (void)drawWithRect:(CGRect)rect options:(NSStringDrawingOptions)options attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes context:(nullable NSStringDrawingContext *)context;
- (CGRect)boundingRectWithSize:(CGSize)size options:(NSStringDrawingOptions)options attributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attributes context:(nullable NSStringDrawingContext *)context;
@end
```


## NSTextStorage(暂定)
### NSTextStorageDelegate(暂定)
## NSLayoutManager(暂定)