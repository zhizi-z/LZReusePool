//
//  LZReusePoolTestController.m
//  LZObjcKit
//
//  Created by zhizi on 2019/6/3.
//  Copyright © 2019 zlh. All rights reserved.
//

#import "LZReusePoolTestController.h"
#import "LZHorizontalTableView.h"

@interface LZReusePoolTestCell : UITableViewCell

@property (nonatomic, strong) UILabel *label;

@end

@implementation LZReusePoolTestCell

- (instancetype)init
{
    if (self = [super init])
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
        [self addSubview:label];
        _label = label;
    }
    return self;
}
@end

@interface LZReusePoolTestController ()<LZHorizontalTableViewDataSource, LZHorizontalTableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) LZHorizontalTableView *scrollView;
@property (nonatomic, strong) UITextField *txtShowCount;
@end

@implementation LZReusePoolTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.txtShowCount = [[UITextField alloc] initWithFrame:CGRectMake(10, 100, self.view.frame.size.width - 20, 40)];
    [self.view addSubview:self.txtShowCount];
    self.txtShowCount.layer.borderColor = [UIColor grayColor].CGColor;
    self.txtShowCount.layer.borderWidth = 1.0;
    self.txtShowCount.placeholder = @"请输入在一下scrollview中显示的label个数";
    [self.txtShowCount addTarget:self action:@selector(didEndEditing:) forControlEvents:UIControlEventEditingDidEnd];
    self.txtShowCount.delegate = self;
    
    self.scrollView = [[LZHorizontalTableView alloc] initWithFrame:CGRectMake(10, 150, self.view.frame.size.width - 20, 50)];
    [self.view addSubview:self.scrollView];
    self.scrollView.layer.borderWidth = 1.0;
    self.scrollView.layer.borderColor = [UIColor grayColor].CGColor;
    self.scrollView.delegate = self;
    self.scrollView.dataSource = self;
    self.scrollView.bounces = YES;
    
    UIView *tableHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, self.scrollView.frame.size.height)];
    tableHeader.backgroundColor = [UIColor grayColor];
    self.scrollView.tableHeaderView = tableHeader;
    UIView *tableFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, self.scrollView.frame.size.height)];
    tableFooter.backgroundColor = [UIColor grayColor];
    self.scrollView.tableFooterView = tableFooter;
}

- (void)dealloc
{
    NSLog(@"dealloc");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didEndEditing:(UITextField *)txtField
{
    [self.scrollView reloadData];
}

- (NSInteger)tableView:(LZHorizontalTableView *)tableView numberOfColumnsInSection:(NSInteger)section
{
    return self.txtShowCount.text.integerValue;
}

- (UITableViewCell *)tableView:(LZHorizontalTableView *)tableView cellForColumnAtIndexPath:(LZIndexPath *)indexPath
{
    LZReusePoolTestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LZReusePoolTestController_TableView_Cell" objectType:[LZReusePoolTestCell class]];
//    LZReusePoolTestCell *cell = [LZReusePoolTestCell new];
    cell.label.text = [NSString stringWithFormat:@"第%ld列", indexPath.column];
    cell.backgroundColor = [UIColor redColor];
    NSLog(@"cell is %p", cell);
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(LZHorizontalTableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(LZHorizontalTableView *)tableView widthForColumnAtIndexPath:(LZIndexPath *)indexPath
{
    return 80.0;
}

- (CGFloat)tableView:(LZHorizontalTableView *)tableView widthForHeaderInSection:(NSInteger)section
{
    return 20.0;
}

- (CGFloat)tableView:(LZHorizontalTableView *)tableView widthForFooterInSection:(NSInteger)section
{
    return 20.0;
}

- (nullable UIView *)tableView:(LZHorizontalTableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20.0, tableView.frame.size.height)];
//    UIView *view = [tableView dequeueReusableCellWithIdentifier:@"LZReusePoolTestController_TableView_Header" objectType:[UIView class]];
//    view.frame = CGRectMake(0, 0, 20.0, tableView.frame.size.height);
    view.backgroundColor = [UIColor yellowColor];
    NSLog(@"headerView is %p", view);
    return view;
}

- (nullable UIView *)tableView:(LZHorizontalTableView *)tableView viewForFooterInSection:(NSInteger)section
{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20.0, tableView.frame.size.height)];
    UIView *view = [tableView dequeueReusableCellWithIdentifier:@"LZReusePoolTestController_TableView_Footer" objectType:[UIView class]];
    view.frame = CGRectMake(0, 0, 10.0, tableView.frame.size.height);
    view.backgroundColor = [UIColor greenColor];
    NSLog(@"footerView is %p", view);
    return view;
}
@end
