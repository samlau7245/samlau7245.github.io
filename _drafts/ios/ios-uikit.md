---
title: iOS UIKit
layout: post
categories:
 - ios
---

## UIView

## UITableView

### 系统API

```objc
/*=== Creating a Table View ===*/
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;

/*=== Providing the Table's Data and Cells ===*/
@property(nonatomic, weak) id<UITableViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id <UITableViewDataSourcePrefetching> prefetchDataSource API_AVAILABLE(ios(10.0));

/*== Recycling Table View Cells 重复利用cells ===*/
- (void)registerNib:(nullable UINib *)nib forCellReuseIdentifier:(NSString *)identifier API_AVAILABLE(ios(5.0));
- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier API_AVAILABLE(ios(6.0));
- (nullable UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;  
- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(6.0));

/*== Recycling Section Headers and Footers ===*/
- (void)registerNib:(nullable UINib *)nib forHeaderFooterViewReuseIdentifier:(NSString *)identifier API_AVAILABLE(ios(6.0));
- (void)registerClass:(nullable Class)aClass forHeaderFooterViewReuseIdentifier:(NSString *)identifier API_AVAILABLE(ios(6.0));
- (nullable UITableViewHeaderFooterView *)dequeueReusableHeaderFooterViewWithIdentifier:(NSString *)identifier API_AVAILABLE(ios(6.0));

/*== Managing Interactions with the Table 管理Table交互 ===*/
@property (nonatomic, weak, nullable) id <UITableViewDelegate> delegate;

/*=== Configuring the Table's Appearance ===*/
@property (nonatomic, readonly) UITableViewStyle style;
@property (nonatomic, strong, nullable) UIView *tableHeaderView; // default is nil
@property (nonatomic, strong, nullable) UIView *tableFooterView; // default is nil
// this will be placed as a subview of the table view behind all cells and headers/footers.
@property (nonatomic, strong, nullable) UIView *backgroundView API_AVAILABLE(ios(3.2));

/*== Configuring Cell Height and Layout ===*/
```

Protocol UITableViewDataSource

```objc
@protocol UITableViewDataSource<NSObject>
/*=== Providing the Number of Rows and Sections ===*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;              
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;

/*=== Providing Cells, Headers, and Footers ===*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    
- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;

/*=== Inserting or Deleting Table Rows ===*/
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

/*=== Reordering Table Rows ===*/
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

/*=== Configuring an Index ===*/
- (nullable NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView;                               
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;  
@end
```

Protocol UITableViewDelegate

```objc
/*=== Configuring Rows for the Table View ====*/
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(UITableView *)tableView shouldSpringLoadRowAtIndexPath:(NSIndexPath *)indexPath withContext:(id<UISpringLoadedInteractionContext>)context API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos, watchos);

/*=== Responding to Row Selections ===*/
- (nullable NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (nullable NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(3.0));
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(3.0));

- (BOOL)tableView:(UITableView *)tableView shouldBeginMultipleSelectionInteractionAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(tvos, watchos);
- (void)tableView:(UITableView *)tableView didBeginMultipleSelectionInteractionAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(tvos, watchos);
- (void)tableViewDidEndMultipleSelectionInteraction:(UITableView *)tableView API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(tvos, watchos);

/*=== Providing Custom Header and Footer Views ===*/
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section API_AVAILABLE(ios(6.0));
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section API_AVAILABLE(ios(6.0));

/*=== Providing Header, Footer, and Row Heights ===*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;

/*=== Estimating Heights for the Table's Content ===*/
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(7.0));
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section API_AVAILABLE(ios(7.0));
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section API_AVAILABLE(ios(7.0));

/*=== Managing Accessory Views ===*/
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;

/*=== Responding to Row Actions ===*/
- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView leadingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos);
- (nullable UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) API_UNAVAILABLE(tvos);

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender;
- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(nullable id)sender;
- (nullable UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point API_AVAILABLE(ios(13.0)) API_UNAVAILABLE(watchos, tvos);
// 替换此方法：tableView:trailingSwipeActionsConfigurationForRowAtIndexPath:
- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath;

/*=== Managing Table View Highlights ===*/
- tableView:shouldHighlightRowAtIndexPath:
- tableView:didHighlightRowAtIndexPath:
- tableView:didUnhighlightRowAtIndexPath:

/*=== Editing Table Rows ===*/
- tableView:willBeginEditingRowAtIndexPath:
- tableView:didEndEditingRowAtIndexPath:
- tableView:editingStyleForRowAtIndexPath:
- tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:
- tableView:shouldIndentWhileEditingRowAtIndexPath:

/*=== Reordering Table Rows ===*/
- tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:

/*=== Tracking the Removal of Views ===*/
- tableView:didEndDisplayingCell:forRowAtIndexPath:
- tableView:didEndDisplayingHeaderView:forSection:
- tableView:didEndDisplayingFooterView:forSection:

/*=== Managing Table View Focus ===*/
- tableView:canFocusRowAtIndexPath:
- tableView:shouldUpdateFocusInContext:
- tableView:didUpdateFocusInContext:withAnimationCoordinator:
- indexPathForPreferredFocusedViewInTableView:

/*=== Instance Methods ===*/
- tableView:contextMenuConfigurationForRowAtIndexPath:point:
- tableView:previewForDismissingContextMenuWithConfiguration:
- tableView:previewForHighlightingContextMenuWithConfiguration:
- tableView:willPerformPreviewActionForMenuWithConfiguration:animator:
```

* [Handling Row Selection in a Table View](https://developer.apple.com/documentation/uikit/uitableviewdelegate/handling_row_selection_in_a_table_view?language=objc)
* [Estimating the Height of a Table's Scrolling Area](https://developer.apple.com/documentation/uikit/views_and_controls/table_views/estimating_the_height_of_a_table_s_scrolling_area?language=objc)

Protocol UITableViewDataSourcePrefetching

```objc
- (void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)tableView:(UITableView *)tableView cancelPrefetchingForRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
```

### 资料
* [Filling a Table with Data](https://developer.apple.com/documentation/uikit/views_and_controls/table_views/filling_a_table_with_data?language=objc)
* [Preserving Your App's UI Across Launches](https://developer.apple.com/documentation/uikit/view_controllers/preserving_your_app_s_ui_across_launches?language=objc)
* [Table Views](https://developer.apple.com/documentation/uikit/views_and_controls/table_views?language=objc#//apple_ref/doc/uid/TP40007451)
* [UITableView](https://developer.apple.com/documentation/uikit/uitableview?language=objc)

## UITableViewCell

## UIStateRestoration

### 资料
* [UIDataSourceModelAssociation](https://developer.apple.com/documentation/uikit/uidatasourcemodelassociation?language=objc)

## UIViewController

### 资料
* [View Controller Programming Guide for iOS](https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/index.html#//apple_ref/doc/uid/TP40007457-CH2-SW1)

## UIObjectRestoration

### 资料
* [UIObjectRestoration](https://developer.apple.com/documentation/uikit/uiobjectrestoration?language=objc)

## UIViewControllerRestoration

### 资料
* [UIViewControllerRestoration](https://developer.apple.com/documentation/uikit/uiviewcontrollerrestoration?language=objc)

## UIResponder