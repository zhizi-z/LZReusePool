//
//  ViewController.m
//  LZObjcKit
//
//  Created by zhizi on 2019/6/3.
//  Copyright © 2019 zlh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIButton *btn2ReusePoolTest;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _scrollView = [UIScrollView new];
    [self.view addSubview:_scrollView];
    _btn2ReusePoolTest = [UIButton new];
    [_btn2ReusePoolTest setTitle:@"重用池测试" forState:UIControlStateNormal];
    _btn2ReusePoolTest.backgroundColor = [UIColor redColor];
    [_btn2ReusePoolTest addTarget:self action:@selector(didClick2ReusePoolTest) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:_btn2ReusePoolTest];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _scrollView.frame = self.view.bounds;
    _btn2ReusePoolTest.frame = CGRectMake(10, 80, 100, 40);
}

- (void)didClick2ReusePoolTest
{
    [self.navigationController pushViewController:[NSClassFromString(@"LZReusePoolTestController") new] animated:YES];
}
@end
