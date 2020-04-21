---
title: iOS 知识碎片记录
layout: post
categories:
 - ios
---

## UIKit

## UIView

### UIView刷新

```objc
// 异步执行方法，执行改方法时会自动调用 drawRect 方法，可以拿到 UIGraphicsGetCurrentContext 。
- (void)setNeedsDisplay;
// 异步执行方法，执行改方法时会自动调用 layoutSubViews ， 可以处理子视图中的一些数据。
- (void)setNeedsLayout;
- (void)layoutIfNeeded;
```

### UITableView

#### 系统API

#### 滚动tableview

```objc
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void)scrollToNearestSelectedRowAtScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
```

#### 编辑Cell

```objc
// Allows multiple insert/delete/reload/move calls to be animated simultaneously. Nestable.
- (void)performBatchUpdates:(void (NS_NOESCAPE ^ _Nullable)(void))updates completion:(void (^ _Nullable)(BOOL finished))completion API_AVAILABLE(ios(11.0), tvos(11.0));
// Use -performBatchUpdates:completion: instead of these methods, which will be deprecated in a future release.
- (void)beginUpdates;
- (void)endUpdates;

// Editing. When set, rows show insert/delete/reorder controls based on data source queries
@property (nonatomic, getter=isEditing) BOOL editing;// default is NO. setting is not animated.
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;

// delete
- (void)deleteSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)deleteRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;

// insert
- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;
- (void)insertRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
```

```objc
@interface APLMasterViewController () <UIActionSheetDelegate>
// A simple array of strings for the data model.
@property (nonatomic, strong) NSMutableArray *dataArray;
@end
@implementation APLMasterViewController
- (IBAction)editAction:(id)sender{
    [self.tableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}
- (void)updateButtonsToMatchTableState {
    if (self.tableView.editing)
    {}else{}
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// The user tapped one of the OK/Cancel buttons.
	if (buttonIndex == 0)
	{
		// Delete what the user selected.
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        BOOL deleteSpecificRows = selectedRows.count > 0;
        if (deleteSpecificRows) {
            // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
            NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedRows) {
                [indicesOfItemsToDelete addIndex:selectionIndex.row];
            }
            // 删除数据源
            // Delete the objects from our data model.
            [self.dataArray removeObjectsAtIndexes:indicesOfItemsToDelete];
            // 删除单元格
            // Tell the tableView that we deleted the objects
            [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            // Delete everything, delete the objects from our data model.
            [self.dataArray removeAllObjects];
            // Tell the tableView that we deleted the objects.
            // Because we are deleting all the rows, just reload the current table section
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }

        // Exit editing mode after the deletion.
        [self.tableView setEditing:NO animated:YES];
        [self updateButtonsToMatchTableState];
	}
}
// 新增cell
- (IBAction)addAction:(id)sender {
	/*if (@available(iOS 11.0, *)) {
        [self.tableView performBatchUpdates:^{
        } completion:^(BOOL finished) {
        }];
    } else {
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }*/

    // Tell the tableView we're going to add (or remove) items.
    [self.tableView beginUpdates];

    // Add an item to the array.
    [self.dataArray addObject:@"New Item"];

    // Tell the tableView about the item that was added.
    NSIndexPath *indexPathOfNewItem = [NSIndexPath indexPathForRow:(self.dataArray.count - 1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPathOfNewItem]
                          withRowAnimation:UITableViewRowAnimationAutomatic];

    // Tell the tableView we have finished adding or removing items.
    [self.tableView endUpdates];

    // Scroll the tableView so the new item is visible
    [self.tableView scrollToRowAtIndexPath:indexPathOfNewItem atScrollPosition:UITableViewScrollPositionBottom animated:YES];

    // Update the buttons if we need to.
    [self updateButtonsToMatchTableState];
}
@end
```

#### cell动态高度-SelfSizing

```objc
@interface APLTableViewController ()
@end
@implementation APLTableViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    //  Must set the following properties
    self.tableView.estimatedRowHeight = 85.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    APLTimeZoneCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCellReuseIdentifierSelfSizingCell];
    [self configureCell:cell forIndexPath:indexPath];
    return cell;
}
@end
```

#### Cell固定高度

[适用于iOS的UITableView基础知识](https://developer.apple.com/library/archive/samplecode/TableViewSuite/Introduction/Intro.html#//apple_ref/doc/uid/DTS40007318)

```objc
@class APLTimeZoneWrapper;
@interface APLTimeZoneView : UIView
@property (nonatomic) APLTimeZoneWrapper *timeZoneWrapper; // UIView对应的数据包装
@property (nonatomic) NSString *abbreviation;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;
@property (nonatomic, getter=isEditing) BOOL editing;
@end
@implementation APLTimeZoneView
// 数据绑定
- (void)setTimeZoneWrapper:(APLTimeZoneWrapper *)newTimeZoneWrapper {
	// If the time zone wrapper changes, update the date formatter and abbreviation string.
	if (_timeZoneWrapper != newTimeZoneWrapper) {
		_timeZoneWrapper = newTimeZoneWrapper;
		self.dateFormatter.timeZone = _timeZoneWrapper.timeZone;
		self.abbreviation = [[NSString alloc] initWithFormat:@"%@ (%@)", _timeZoneWrapper.abbreviation, _timeZoneWrapper.gmtOffset];
	}
	// May be the same wrapper, but the date may have changed, so mark for redisplay.
	[self setNeedsDisplay];
}
- (void)setHighlighted:(BOOL)lit {
	// If highlighted state changes, need to redisplay.
	if (_highlighted != lit) {
		_highlighted = lit;
		[self setNeedsDisplay];
	}
}
// 直接在UIView上绘制。
- (void)drawRect:(CGRect)rect {
	
#define LEFT_COLUMN_OFFSET 10
#define MIDDLE_COLUMN_OFFSET 170
#define RIGHT_COLUMN_OFFSET 270
	
#define UPPER_ROW_TOP 12
#define LOWER_ROW_TOP 44

	// Color for the main text items (time zone name, time).
	UIColor *mainTextColor;

	// Color for the secondary text items (GMT offset, day).
	UIColor *secondaryTextColor;

	// Choose font color based on highlighted state.
	if (self.highlighted) {
		mainTextColor = [UIColor whiteColor];
		secondaryTextColor = [UIColor whiteColor];
	}
	else {
		mainTextColor = [UIColor blackColor];
		secondaryTextColor = [UIColor darkGrayColor];
	}

    /*
     Font attributes for the main text items (time zone name, time).
     For iOS 7 and later, use text styles instead of system fonts.
     */
    UIFont *mainFont;
    if (DeviceSystemMajorVersion() > 6) {
        mainFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    else {
        mainFont = [UIFont systemFontOfSize:17.0];
    }
    
    NSDictionary *mainTextAttributes = @{ NSFontAttributeName : mainFont, NSForegroundColorAttributeName : mainTextColor };

	// Font attributes for the secondary text items (GMT offset, day).
    UIFont *secondaryFont;
    if (DeviceSystemMajorVersion() > 6) {
        secondaryFont = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    }
    else {
        secondaryFont = [UIFont systemFontOfSize:12.0];
    }
    NSDictionary *secondaryTextAttributes = @{ NSFontAttributeName : secondaryFont, NSForegroundColorAttributeName : secondaryTextColor };
    

	// In this example we will never be editing, but this illustrates the appropriate pattern.
    if (!self.editing) {

		CGPoint point;
		
		/*
		 Draw the locale name top left.
		*/
        NSAttributedString *localeNameAttributedString = [[NSAttributedString alloc] initWithString:self.timeZoneWrapper.timeZoneLocaleName attributes:mainTextAttributes];
		point = CGPointMake(LEFT_COLUMN_OFFSET, UPPER_ROW_TOP);
		[localeNameAttributedString drawAtPoint:point];

		/*
		 Draw the current time in the middle column.
		 */
		NSString *timeString = [self.dateFormatter stringFromDate:[NSDate date]];
        NSAttributedString *timeAttributedString = [[NSAttributedString alloc] initWithString:timeString attributes:mainTextAttributes];
		point = CGPointMake(MIDDLE_COLUMN_OFFSET, UPPER_ROW_TOP);
		[timeAttributedString drawAtPoint:point];
		
		/*
		 Draw the abbreviation botton left.
		 */
        NSAttributedString *abbreviationAttributedString = [[NSAttributedString alloc] initWithString:self.abbreviation attributes:secondaryTextAttributes];
		point = CGPointMake(LEFT_COLUMN_OFFSET, LOWER_ROW_TOP);
		[abbreviationAttributedString drawAtPoint:point];

		/*
		 Draw the whichDay string.
		 */
        APLTimeZoneWrapper *timeZoneWrapper = self.timeZoneWrapper;

        NSAttributedString *whichDayAttributedString = [[NSAttributedString alloc] initWithString:timeZoneWrapper.whichDay attributes:secondaryTextAttributes];
		point = CGPointMake(MIDDLE_COLUMN_OFFSET, LOWER_ROW_TOP);
		[whichDayAttributedString drawAtPoint:point];

		
		// Draw the quarter image.
		CGFloat imageY = (self.bounds.size.height - self.timeZoneWrapper.image.size.height) / 2;
		
		point = CGPointMake(RIGHT_COLUMN_OFFSET, imageY);
		[timeZoneWrapper.image drawAtPoint:point];
	}
}	

@implementation APLViewController
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
	APLTimeZoneCell *timeZoneCell = (APLTimeZoneCell *)[tableView dequeueReusableCellWithIdentifier:@"TimeZoneCell"];
	APLRegion *region = self.displayList[indexPath.section];
	NSArray *regionTimeZones = region.timeZoneWrappers;
	[timeZoneCell setTimeZoneWrapper:regionTimeZones[indexPath.row]];
	return timeZoneCell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}
@end
```

<img src="/assets/images/ios-records/01.png" width = "25%" height = "25%"/>

#### 获取可见屏幕cell数据

> 在cell的外部尺寸不变， 只是改变了内容的情况下，不要去`reload`数据，这需要重新计算单元格的数量和每个cell的高度。

```objc
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;   // returns nil if cell is not visible or index path is out of range
// 获取界面上能显示出来了cell,在当前页面中能看到cells都在这个数组中。
@property (nonatomic, readonly) NSArray<UITableViewCell *> *visibleCells;
@property (nonatomic, readonly, nullable) NSArray<NSIndexPath *> *indexPathsForVisibleRows;
```

```objc
@interface APLViewController ()
@property (nonatomic) NSArray *displayList;
@property (nonatomic, weak) NSTimer *minuteTimer;
@end
@implementation APLViewController
- (void)updateTime:(NSTimer *)timer {
    /*
     To display the current time, redisplay the time labels.
     Don't reload the table view's data as this is unnecessarily expensive -- it recalculates the number of cells and the height of each item to determine the total height of the view etc.  The external dimensions of the cells haven't changed, just their contents.
     */
    NSArray *visibleCells = self.tableView.visibleCells;
    for (APLTimeZoneCell *cell in visibleCells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self configureCell:cell forIndexPath:indexPath];
        [cell setNeedsDisplay];
    }
    /*
    NSArray<NSIndexPath *> *indexPathsForVisibleRows = self.tableView.indexPathsForVisibleRows;
    for (NSIndexPath *idx in indexPathsForVisibleRows) {
        APLTimeZoneCell *cell = [self.tableView cellForRowAtIndexPath:idx];
        [self configureCell:cell forIndexPath:idx];
        [cell setNeedsDisplay];
        NSLog(@"%zd-%zd",idx.section,idx.row);
    }*/
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
	APLTimeZoneCell *cell = (APLTimeZoneCell *)[tableView dequeueReusableCellWithIdentifier:@"TimeZoneCell"];
	[self configureCell:cell forIndexPath:indexPath];
	return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)configureCell:(APLTimeZoneCell *)cell forIndexPath:(NSIndexPath *)indexPath {
	APLRegion *region = self.displayList[indexPath.section];
	NSArray *regionTimeZones = region.timeZoneWrappers;
	APLTimeZoneWrapper *wrapper = regionTimeZones[indexPath.row];
	// Set the locale name.
	cell.nameLabel.text = wrapper.timeZoneLocaleName;
}
@end
```

### UIButton

#### 修改`UIButton`中`imageView`的图片颜色

```objc
UIImage *image = [UIImage imageNamed:@"back"];
image = [image imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];

UIButton *_goBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
[_goBackButton setImage:image forState:UIControlStateNormal];
_goBackButton.tintColor = [UIColor redColor];
```

#### 设置`UIButton`图片居上

```objc
btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
[btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.imageView.frame.size.height ,-btn.imageView.frame.size.width, 0.0,0.0)];
[btn setImageEdgeInsets:UIEdgeInsetsMake(-btn.imageView.frame.size.height, 0.0,0.0, -btn.titleLabel.bounds.size.width)];
```

### UIImageView

#### 修改`imageView`的图片颜色

```objc
UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"back"]];
imgView.image = [imgView.image imageWithRenderingMode:(UIImageRenderingModeAlwaysTemplate)];
imgView.tintColor = [UIColor whiteColor];
```

## Foundation

### 定时器:NSTimer

```objc
@interface APLViewController ()
@property (nonatomic) NSCalendar *calendar;
@property (nonatomic, weak) NSTimer *minuteTimer;
@end
@implementation APLViewController
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.minuteTimer = nil;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDate *date = [NSDate date];
    NSDate *oneMinuteFromNow = [date dateByAddingTimeInterval:60];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *timerDateComponents = [self.calendar components:unitFlags fromDate:oneMinuteFromNow];
    timerDateComponents.second = 1;
    NSDate *minuteTimerDate = [self.calendar dateFromComponents:timerDateComponents];
    
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:minuteTimerDate interval:60 target:self selector:@selector(updateTime:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    self.minuteTimer = timer;
}
#pragma mark - Temporal updates
- (void)updateTime:(NSTimer *)timer {
}
- (void)dealloc {
	[_minuteTimer invalidate];
}

- (void)setMinuteTimer:(NSTimer *)newTimer {
    if (_minuteTimer != newTimer) {
        [_minuteTimer invalidate];
        _minuteTimer = newTimer;
    }
}
@end
```

### NSObject

#### NS_DESIGNATED_INITIALIZER

```objc
@interface APLTimeZoneWrapper : NSObject
- (instancetype)initWithTimeZone:(NSTimeZone *)aTimeZone nameComponents:(NSArray *)nameComponents NS_DESIGNATED_INITIALIZER;
@end
@implementation APLTimeZoneWrapper
+ (void)initialize {
	if (self == [APLTimeZoneWrapper class]) {
		q1Image = [UIImage imageNamed:@"12AM-6AM.png"];
	}
}
- (instancetype)init {
    NSAssert(NO, @"Invalid use of init; use initWithTimeZone:nameComponents: to create APLTimeZoneWrapper");
    return [self init];
}
- (instancetype)initWithTimeZone:(NSTimeZone *)aTimeZone nameComponents:(NSArray *)nameComponents {
	if (self == [super init]) {
		_timeZone = aTimeZone;
	}
	return self;
}
@end
```

#### load、initialize

```objc
+ (void)load;
+ (void)initialize;
```

#### NSNotificationCenter

```objc
// 在 ViewControllerA 中定义了通知
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderPayResult:) name:@"NSNotificationName" object:@"A"]

// 在 ViewControllerB 中定义了通知
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getOrderPayResult:) name:@"NSNotificationName" object:@"B"]

// 在ViewControllerC中发起通知，发起这个通知就只会在 ViewControllerA 的 getOrderPayResult 才会触发
[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NSNotificationName" object:@"A" userInfo:@{}]];

// 在ViewControllerC中发起通知，发起这个通知就只会在 ViewControllerB 的 getOrderPayResult 才会触发
[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NSNotificationName" object:@"B" userInfo:@{}]];

// 在ViewControllerC中发起通知，ViewControllerB ViewControllerA 都收不到通知
[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"NSNotificationName" object:nil userInfo:@{}]];
```

#### NSString

##### NSMutableAttributedString 用H5属性展示

```objc
NSDictionary *options = @{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType };
NSString* htmlString = @"<font color='#DC143C'>订单将会在</font>"; // 展示颜色为#DC143C的字体
NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:options documentAttributes:nil error:nil];
```

#### [iOS NSError HTTP错误码大全](https://www.cnblogs.com/yang-shuai/p/6830142.html)

#### 字典(NSDictionary)和JSON字符串(NSString)之间互转


