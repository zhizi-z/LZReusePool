//
//  LZHorizontalTableView.m
//  LZObjcKit
//
//  Created by zhizi on 2019/6/6.
//  Copyright © 2019 zlh. All rights reserved.
//

#import "LZHorizontalTableView.h"
#import "LZReusePool.h"

static NSString * const kContentOffset = @"contentOffset";

@implementation LZIndexPath

@end

@interface LZHorizontalTableView()
{
    CGFloat _lastOffsetX;
    NSInteger _sectionCount;
    NSMutableArray<NSNumber *> *_sectionColumns;
    CGFloat _shownRight;
    CGFloat _shownLeft;
}

@property (nonatomic, strong) NSMutableArray<NSMutableArray<NSNumber *> *> *columnWidths;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *sectionHeaderWidths;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *sectionFooterWidths;
@property (nonatomic, strong) LZReusePool *reusePool;
@property (nonatomic, strong) NSMutableArray *visibleViews;

@property (nonatomic, assign) BOOL scrollLeft;
@end

@implementation LZHorizontalTableView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _sectionColumns = [NSMutableArray new];
        self.columnWidths = [NSMutableArray new];
        self.sectionHeaderWidths = [NSMutableArray new];
        self.sectionFooterWidths = [NSMutableArray new];
        self.reusePool = [LZReusePool smallPool];
        self.visibleViews = [NSMutableArray new];
        [self addObserver:self forKeyPath:kContentOffset options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:kContentOffset];
}

- (void)resetData
{
    _lastOffsetX = 0.0;
    _sectionCount = 1;
    _shownRight = 0.0;
    _shownLeft = 0.0;
    [_sectionColumns removeAllObjects];
    [self.columnWidths removeAllObjects];
    [self.sectionHeaderWidths removeAllObjects];
    [self.sectionFooterWidths removeAllObjects];
    [self.visibleViews removeAllObjects];
    
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)])
    {
        _sectionCount = [self.dataSource numberOfSectionsInTableView:self];
    }
    for (NSInteger index = 0; index < _sectionCount; index++)
    {
        NSInteger columnCount = [self.dataSource tableView:self numberOfColumnsInSection:index];
        [_sectionColumns addObject:@(columnCount)];
    }
    CGFloat contentWidth = 0.0;
    if (self.tableHeaderView)
    {
        contentWidth += self.tableHeaderView.frame.size.width;
    }
    for (NSInteger section = 0; section < _sectionCount; section++)
    {
        if ([self.delegate respondsToSelector:@selector(tableView:widthForHeaderInSection:)])
        {
            CGFloat headerWidth = [self.delegate tableView:self widthForHeaderInSection:section];
            [self.sectionHeaderWidths addObject:@(headerWidth)];
            contentWidth += headerWidth;
        }
        else {
            contentWidth += self.sectionHeaderWidth;
        }
        NSInteger columnCount = _sectionColumns[section].integerValue;
        if ([self.delegate respondsToSelector:@selector(tableView:widthForColumnAtIndexPath:)])
        {
            NSMutableArray *columns = [NSMutableArray new];
            [self.columnWidths addObject:columns];
            for (NSInteger column = 0; column < columnCount; column++)
            {
                LZIndexPath *indexPath = [LZIndexPath indexPathForRow:column inSection:section];
                indexPath.column = column;
                CGFloat columnWidth = [self.delegate tableView:self widthForColumnAtIndexPath:indexPath];
                [columns addObject:@(columnWidth)];
                contentWidth += columnWidth;
            }
        }
        else {
            contentWidth += self.columnWidth * columnCount;
        }
        if ([self.delegate respondsToSelector:@selector(tableView:widthForFooterInSection:)])
        {
            CGFloat footerWidth = [self.delegate tableView:self widthForFooterInSection:section];
            [self.sectionFooterWidths addObject:@(footerWidth)];
            contentWidth += footerWidth;
        }
        else {
            contentWidth += self.sectionFooterWidth;
        }
    }
    if (self.tableFooterView)
    {
        contentWidth += self.tableFooterView.frame.size.width;
    }
    self.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
}

- (void)scrollWithOffsetX:(CGFloat)offsetX
{
    if (offsetX < 0) return;
    if (offsetX == _lastOffsetX) return;
    
    if (offsetX > _lastOffsetX)
    {//往左滑
        for (UIView *singleView in [self.visibleViews copy])
        {
            CGFloat right = singleView.frame.origin.x + singleView.frame.size.width;
            if (right <= offsetX)
            {//从左边滑出去了
                if ([[self.reusePool usableObjects] containsObject:singleView])
                {
                    [self.reusePool moveUsableObject:singleView];
                }
                else {
                    [singleView removeFromSuperview];
                }
                [self.visibleViews removeObject:singleView];
            }
            else{
                _shownLeft = singleView.frame.origin.x;
                break;
            }
        }
        if (_shownRight < offsetX + self.frame.size.width)
        {
            [self loadMoreData:NO];
        }
    }
    else
    {//往右滑
        NSArray *shownObjects = [self.visibleViews copy];
        for (NSInteger index = shownObjects.count - 1; index >= 0; index--)
        {
            UIView *singleView = shownObjects[index];
            CGFloat left = singleView.frame.origin.x;
            if (left >= offsetX + self.frame.size.width)
            {
                if ([[self.reusePool usableObjects] containsObject:singleView])
                {
                    [self.reusePool moveUsableObject:singleView];
                }
                else {
                    [singleView removeFromSuperview];
                }
                [self.visibleViews removeObject:singleView];
            }
            else {
                _shownRight = singleView.frame.origin.x + singleView.frame.size.width;
                break;
            }
        }
        if (_shownLeft > offsetX)
        {
            [self loadOldData];
        }
    }
    _lastOffsetX = offsetX;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([kContentOffset isEqualToString:keyPath]) {
            NSValue *value = change[NSKeyValueChangeNewKey];
            CGFloat offsetX = [value CGPointValue].x;
            [self scrollWithOffsetX:offsetX];
        }
    });
}

- (NSInteger)numberOfSections
{
    return _sectionCount;
}

- (NSInteger)numberOfColumnsInSection:(NSInteger)section
{
    return _sectionColumns[section].integerValue;
}

//- (nullable __kindof UITableViewCell *)cellForColumnAtIndexPath:(LZIndexPath *)indexPath
//{
//    
//}
//
//- (NSArray<UITableViewCell *> *)visibleCells
//{
//    
//}
//
//- (NSArray<LZIndexPath *> *)indexPathsForVisibleColumns
//{
//    
//}
//
//- (LZIndexPath *)indexPathForSelectedColumn
//{
//    
//}
//
//- (void)deselectColumnAtIndexPath:(LZIndexPath *)indexPath
//{
//    
//}

- (nullable __kindof UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier objectType:(Class)type
{
    return [self.reusePool dequeueReusableObjectWithIdentifier:identifier objectType:type isFirst:self.scrollLeft];
}

- (nullable __kindof UIView *)dequeueReusableViewWithIdentifier:(NSString *)identifier objectType:(Class)type
{
    return [self.reusePool dequeueReusableObjectWithIdentifier:identifier objectType:type isFirst:self.scrollLeft];
}

- (void)reloadData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.reusePool moveUsableObjects];
        [self resetData];
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self loadMoreData:YES];
    });
}

- (void)loadMoreData:(BOOL)isReload
{
    self.scrollLeft = NO;
    
    if (isReload && self.tableHeaderView && ![self.subviews containsObject:self.tableHeaderView])
    {
        self.tableHeaderView.frame = CGRectMake(0, 0, self.tableHeaderView.frame.size.width, self.frame.size.height);
        [self addSubview:self.tableHeaderView];
        _shownRight += self.tableHeaderView.frame.size.width;
        if (_shownRight >= self.frame.size.width + self.contentOffset.x) return;
    }
    
    NSInteger currentSection = 0;
    NSInteger currentColumn = -1;
    if (self.visibleViews.count > 0)
    {
        UIView *lastObj = self.visibleViews.lastObject;
        currentSection = lastObj.lz_section.integerValue;
        currentColumn = lastObj.lz_index.integerValue;
        NSInteger columnCount = _sectionColumns[currentSection].integerValue;
        if (currentColumn == columnCount)
        {
            currentColumn = -1;
            currentSection++;
        }
        else {
            currentColumn++;
        }
    }
 
    for (NSInteger section = currentSection; section < _sectionCount; section++)
    {
        if (currentColumn == -1)
        {
            CGFloat headerWidth = self.sectionHeaderWidth;
            if (self.sectionHeaderWidths.count > section)
            {
                headerWidth = self.sectionHeaderWidths[section].floatValue;
            }
            if (headerWidth > 0.0)
            {
                UIView *headerView = nil;
                if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)])
                {
                    headerView = [self.delegate tableView:self viewForHeaderInSection:section];
                }
                else {
                    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerWidth, self.frame.size.height)];
                }
                headerView.frame = CGRectMake(_shownRight, 0, headerWidth, self.frame.size.height);
                headerView.lz_section = @(section);
                headerView.lz_index = @(currentColumn);
                if (![self.subviews containsObject:headerView])
                {
                    [self addSubview:headerView];
                }
                _shownRight += headerWidth;
                [self.visibleViews addObject:headerView];
            }
            currentColumn++;
            if (_shownRight >= self.frame.size.width + self.contentOffset.x) return;
        }
        
        NSInteger columnCount = _sectionColumns[section].floatValue;
        if (currentColumn > -1 && currentColumn < columnCount)
        {
            for (NSInteger column = currentColumn; column < columnCount; column++)
            {
                CGFloat columnWidth = self.columnWidth;
                if (self.columnWidths.count > section)
                {
                    columnWidth = self.columnWidths[section][column].floatValue;
                }
                if (columnWidth > 0)
                {
                    LZIndexPath *indexPath = [LZIndexPath indexPathForRow:column inSection:section];
                    indexPath.column = column;
                    UITableViewCell *cell = [self.dataSource tableView:self cellForColumnAtIndexPath:indexPath];
                    cell.frame = CGRectMake(_shownRight, 0, columnWidth, self.frame.size.height);
                    cell.lz_section = @(section);
                    cell.lz_index = @(column);
                    if (![self.subviews containsObject:cell])
                    {
                        [self addSubview:cell];
                    }
                    _shownRight += columnWidth;
                    [self.visibleViews addObject:cell];
                }
                currentColumn++;
                if (_shownRight >= self.frame.size.width + self.contentOffset.x) return;
            }
        }
        
        if (currentColumn == columnCount)
        {
            CGFloat footerWidth = self.sectionFooterWidth;
            if (self.sectionFooterWidths.count > section)
            {
                footerWidth = self.sectionFooterWidths[section].floatValue;
            }
            if (footerWidth > 0.0)
            {
                UIView *footerView = nil;
                if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)])
                {
                    footerView = [self.delegate tableView:self viewForFooterInSection:section];
                }
                else {
                    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, footerWidth, self.frame.size.height)];
                }
                footerView.frame = CGRectMake(_shownRight, 0, footerWidth, self.frame.size.height);
                footerView.lz_section = @(section);
                footerView.lz_index = @(currentColumn);
                if (![self.subviews containsObject:footerView])
                {
                    [self addSubview:footerView];
                }
                _shownRight += footerWidth;
                [self.visibleViews addObject:footerView];
            }
            currentColumn = -1;
            if (_shownRight >= self.frame.size.width + self.contentOffset.x) return;
        }
    }
    
    if (self.tableFooterView && ![self.subviews containsObject:self.tableFooterView])
    {
        self.tableFooterView.frame = CGRectMake(_shownRight, 0, self.tableFooterView.frame.size.width, self.frame.size.height);
        [self addSubview:self.tableFooterView];
        _shownRight += self.tableFooterView.frame.size.width;
    }
}

- (void)loadOldData
{
    self.scrollLeft = YES;
    
    NSInteger currentSection = 0;
    NSInteger currentColumn = -1;
    if (self.visibleViews.count > 0)
    {
        UIView *firstObj = self.visibleViews.firstObject;
        currentSection = firstObj.lz_section.integerValue;
        currentColumn = firstObj.lz_index.integerValue;
        if (currentColumn == -1)
        {
            currentSection--;
            if (currentSection < 0) return;
            currentColumn = _sectionColumns[currentSection].integerValue;
        }
        else {
            currentColumn--;
        }
    }
    else {
        return;
    }
    
    for (NSInteger section = currentSection; section > -1; section--)
    {
        NSInteger columnCount = _sectionColumns[section].floatValue;
        if (currentColumn == columnCount)
        {
            CGFloat footerWidth = self.sectionFooterWidth;
            if (self.sectionFooterWidths.count > section)
            {
                footerWidth = self.sectionFooterWidths[section].floatValue;
            }
            if (footerWidth > 0.0)
            {
                UIView *footerView = nil;
                if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)])
                {
                    footerView = [self.delegate tableView:self viewForFooterInSection:section];
                }
                else {
                    footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, footerWidth, self.frame.size.height)];
                }
                footerView.frame = CGRectMake(_shownLeft - footerWidth, 0, footerWidth, self.frame.size.height);
                footerView.lz_section = @(section);
                footerView.lz_index = @(currentColumn);
                if (![self.subviews containsObject:footerView])
                {
                    [self addSubview:footerView];
                }
                _shownLeft -= footerWidth;
                [self.visibleViews insertObject:footerView atIndex:0];
            }
            currentColumn--;
            if (_shownLeft <= self.contentOffset.x) return;
        }
        
        if (currentColumn > -1 && currentColumn < columnCount)
        {
            for (NSInteger column = currentColumn; column > -1; column--)
            {
                CGFloat columnWidth = self.columnWidth;
                if (self.columnWidths.count > section)
                {
                    columnWidth = self.columnWidths[section][column].floatValue;
                }
                if (columnWidth > 0)
                {
                    LZIndexPath *indexPath = [LZIndexPath indexPathForRow:column inSection:section];
                    indexPath.column = column;
                    UITableViewCell *cell = [self.dataSource tableView:self cellForColumnAtIndexPath:indexPath];
                    cell.frame = CGRectMake(_shownLeft - columnWidth, 0, columnWidth, self.frame.size.height);
                    cell.lz_section = @(section);
                    cell.lz_index = @(column);
                    if (![self.subviews containsObject:cell])
                    {
                        [self addSubview:cell];
                    }
                    _shownLeft -= columnWidth;
                    [self.visibleViews insertObject:cell atIndex:0];
                }
                currentColumn--;
                if (_shownLeft <= self.contentOffset.x) return;
            }
        }
        
        if (currentColumn == -1)
        {
            CGFloat headerWidth = self.sectionHeaderWidth;
            if (self.sectionHeaderWidths.count > section)
            {
                headerWidth = self.sectionHeaderWidths[section].floatValue;
            }
            if (headerWidth > 0.0)
            {
                UIView *headerView = nil;
                if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)])
                {
                    headerView = [self.delegate tableView:self viewForHeaderInSection:section];
                }
                else {
                    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerWidth, self.frame.size.height)];
                }
                headerView.frame = CGRectMake(_shownLeft - headerWidth, 0, headerWidth, self.frame.size.height);
                headerView.lz_section = @(section);
                headerView.lz_index = @(-1);
                if (![self.subviews containsObject:headerView])
                {
                    [self addSubview:headerView];
                }
                _shownLeft -= headerWidth;
                [self.visibleViews insertObject:headerView atIndex:0];
            }
            NSInteger lastSection = section - 1;
            if (lastSection < 0) return;
            currentColumn = _sectionColumns[lastSection].integerValue;
            if (_shownLeft <= self.contentOffset.x) return;
        }
    }
}
@end
