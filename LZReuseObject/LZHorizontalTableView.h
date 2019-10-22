//
//  LZHorizontalTableView.h
//  LZObjcKit
//
//  Created by zhizi on 2019/6/6.
//  Copyright © 2019 zlh. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZIndexPath : NSIndexPath

@property (nonatomic) NSInteger column;
@end

@class LZHorizontalTableView;

@protocol LZHorizontalTableViewDataSource<NSObject>

@required
- (NSInteger)tableView:(LZHorizontalTableView *)tableView numberOfColumnsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(LZHorizontalTableView *)tableView cellForColumnAtIndexPath:(LZIndexPath *)indexPath;

@optional
- (NSInteger)numberOfSectionsInTableView:(LZHorizontalTableView *)tableView;              // Default is 1 if not implemented
//- (void)tableView:(LZHorizontalTableView *)tableView moveColumnAtIndexPath:(LZIndexPath *)sourceIndexPath toIndexPath:(LZIndexPath *)destinationIndexPath;
@end

@protocol LZHorizontalTableViewDelegate<UIScrollViewDelegate>

@optional
- (CGFloat)tableView:(LZHorizontalTableView *)tableView widthForColumnAtIndexPath:(LZIndexPath *)indexPath;
- (CGFloat)tableView:(LZHorizontalTableView *)tableView widthForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(LZHorizontalTableView *)tableView widthForFooterInSection:(NSInteger)section;
- (nullable UIView *)tableView:(LZHorizontalTableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (nullable UIView *)tableView:(LZHorizontalTableView *)tableView viewForFooterInSection:(NSInteger)section;
//- (nullable LZIndexPath *)tableView:(LZHorizontalTableView *)tableView willSelectColumnAtIndexPath:(LZIndexPath *)indexPath;
//- (void)tableView:(LZHorizontalTableView *)tableView didSelectColumnAtIndexPath:(LZIndexPath *)indexPath;
@end

@interface LZHorizontalTableView : UIScrollView

@property (nonatomic, weak, nullable) id <LZHorizontalTableViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id <LZHorizontalTableViewDelegate> delegate;

@property (nonatomic) CGFloat columnWidth;
@property (nonatomic) CGFloat sectionHeaderWidth;
@property (nonatomic) CGFloat sectionFooterWidth;
@property (nonatomic, readonly) NSInteger numberOfSections;
- (NSInteger)numberOfColumnsInSection:(NSInteger)section;

//- (nullable __kindof UITableViewCell *)cellForColumnAtIndexPath:(LZIndexPath *)indexPath;
//@property (nonatomic, readonly) NSArray<__kindof UITableViewCell *> *visibleCells;
//@property (nonatomic, readonly, nullable) NSArray<LZIndexPath *> *indexPathsForVisibleColumns;
//
//@property (nonatomic, readonly, nullable) LZIndexPath *indexPathForSelectedColumn;
//
//- (void)deselectColumnAtIndexPath:(LZIndexPath *)indexPath;

@property (nonatomic, strong, nullable) UIView *tableHeaderView;
@property (nonatomic, strong, nullable) UIView *tableFooterView;

- (nullable __kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier objectType:(Class)type;
- (nullable __kindof UIView *)dequeueReusableViewWithIdentifier:(NSString *)identifier objectType:(Class)type;
- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
