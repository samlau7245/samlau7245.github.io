---
title: iOS Foundation
layout: post
categories:
 - ios
---

## NSAttributedString

```objc
NSAttributedStringKey const NSFontAttributeName;
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

Protocol NSTextAttachmentContainer

```objc
- (nullable UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(nullable NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex
- (CGRect)attachmentBoundsForTextContainer:(nullable NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex
```

## NSTextContainer

NSAttributedStringKey const NSFontAttributeName;// UIFont, default Helvetica(Neue) 12
NSAttributedStringKey const NSParagraphStyleAttributeName; // 段落样式 NSParagraphStyle, default defaultParagraphStyle
NSAttributedStringKey const NSForegroundColorAttributeName; // 文字颜色 UIColor, default blackColor
NSAttributedStringKey const NSBackgroundColorAttributeName; // 背景色 UIColor, default nil: no background
NSAttributedStringKey const NSLigatureAttributeName; // 连体字符，iOS只能设置1.
NSAttributedStringKey const NSKernAttributeName; // 设置字符间距 0 禁用，>0 间距变大[hello -> h e l l o] <0 间距变小
NSAttributedStringKey const NSStrikethroughStyleAttributeName; //删除线
NSAttributedStringKey const NSUnderlineStyleAttributeName; //下划线 NSNumber
NSAttributedStringKey const NSStrokeColorAttributeName; // 字符描边色UIColor
NSAttributedStringKey const NSStrokeWidthAttributeName; // 字符描边宽度 NSNumber
NSAttributedStringKey const NSShadowAttributeName; // 阴影 NSShadow
NSAttributedStringKey const NSTextEffectAttributeName; // 文本特殊效果，取值为 NSString 对象，目前只有图版印刷效果可用

NSAttributedStringKey const NSAttachmentAttributeName; // 获取文字附件，常用于图文混排 NSTextAttachment, default nil
NSAttributedStringKey const NSLinkAttributeName;                // NSURL (preferred) or NSString
NSAttributedStringKey const NSBaselineOffsetAttributeName;      // NSNumber containing floating point value, in points; offset from baseline, default 0
NSAttributedStringKey const NSUnderlineColorAttributeName;      // UIColor, default nil: same as foreground color
NSAttributedStringKey const NSStrikethroughColorAttributeName;  // UIColor, default nil: same as foreground color
NSAttributedStringKey const NSObliquenessAttributeName;         // NSNumber containing floating point value; skew to be applied to glyphs, default 0: no skew
NSAttributedStringKey const NSExpansionAttributeName;           // NSNumber containing floating point value; log of expansion factor to be applied to glyphs, default 0: no expansion

NSAttributedStringKey const NSWritingDirectionAttributeName;    
NSAttributedStringKey const NSVerticalGlyphFormAttributeName;  



NSFontAttributeName; //字体，value是UIFont对象
NSParagraphStyleAttributeName;//绘图的风格（居中，换行模式，间距等诸多风格），value是NSParagraphStyle对象
NSForegroundColorAttributeName;// 文字颜色，value是UIFont对象
NSBackgroundColorAttributeName;// 背景色，value是UIFont
NSLigatureAttributeName; //  字符连体，value是NSNumber
NSKernAttributeName; // 字符间隔
NSStrikethroughStyleAttributeName;//删除线，value是NSNumber
NSUnderlineStyleAttributeName;//下划线，value是NSNumber
NSStrokeColorAttributeName; //描绘边颜色，value是UIColor
NSStrokeWidthAttributeName; //描边宽度，value是NSNumber
NSShadowAttributeName; //阴影，value是NSShadow对象
NSTextEffectAttributeName; //文字效果，value是NSString
NSAttachmentAttributeName;//附属，value是NSTextAttachment 对象
NSLinkAttributeName;//链接，value是NSURL or NSString
NSBaselineOffsetAttributeName;//基础偏移量，value是NSNumber对象
NSUnderlineColorAttributeName;//下划线颜色，value是UIColor对象
NSStrikethroughColorAttributeName;//删除线颜色，value是UIColor
NSObliquenessAttributeName; //字体倾斜
NSExpansionAttributeName; //字体扁平化
NSVerticalGlyphFormAttributeName;//垂直或者水平，value是 NSNumber，0表示水平，1垂直