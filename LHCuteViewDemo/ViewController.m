//
//  ViewController.m
//  RYCuteViewDemo
//
//  Created by Codeliu on 17/7/15.
//  Copyright © 2015年 Resory. All rights reserved.
//

#import "ViewController.h"
#import "LHCuteView.h"
#import "MyTableView.h"

@interface ViewController ()<CuteViewDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    MyTableView *tableView;
    LHCuteView *cuteView;
    UIView *subView;
    BOOL isCute;
}
@end
#define KWIDTH    ([[UIScreen mainScreen] bounds].size.width)                  // 屏幕宽度
#define KHEIGHT   ([[UIScreen mainScreen] bounds].size.height)                 // 屏幕长度
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [self methodTwo];
}

- (void)methodOne{
    
    cuteView = [[LHCuteView alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, KHEIGHT)];
    cuteView.backgroundColor = [UIColor whiteColor];
    cuteView.cuteDelegate = self;
    [self.view addSubview:cuteView];
    
    
    cuteView.headerImage.image = [UIImage imageNamed:@"cute.jpg"];
    
    subView = [[UIView alloc]initWithFrame:CGRectMake(0, 170, KWIDTH, KHEIGHT - 170)];
    [cuteView addSubview:subView];
    
    [self creatSubView];
    
}

- (void)methodTwo
{
    cuteView = [[LHCuteView alloc] initWithFrame:CGRectMake(0, 0, KWIDTH, 170)];
    cuteView.backgroundColor = [UIColor whiteColor];
    cuteView.cuteDelegate = self;
    [self.view addSubview:cuteView];
    
    isCute = YES;
    cuteView.headerImage.image = [UIImage imageNamed:@"cute.jpg"];
    
    tableView = [[MyTableView alloc]initWithFrame:CGRectMake(0, 0, KWIDTH, KHEIGHT) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.bounces = NO;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    tableView.tableHeaderView = cuteView;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanAction:)];
    [tableView addGestureRecognizer:pan];
}

- (void)handlePanAction:(UIPanGestureRecognizer *)pan
{
    CGPoint point = [pan translationInView:tableView];
    if (point.y > 0) {
        if (isCute == YES) {
            [cuteView handlePanAction:pan];
        }
    }
}

- (void)creatSubView
{
    for (int i = 0; i < 5; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, i * 44, 100, 44)];
        label.text = [NSString stringWithFormat:@"个人中心%d",i];
        label.textAlignment = NSTextAlignmentLeft;
        [subView addSubview:label];
    }
}

- (void)backMeWithHeaderCenterY:(CGFloat)centerY
{
//    tableView.frame = CGRectMake(0, centerY + 30 + 50, KWIDTH, KHEIGHT - 170);
//    subView.frame = CGRectMake(0, centerY + 80, KWIDTH, KHEIGHT - 170);
    

    if (centerY == 1000) {
        cuteView.frame = CGRectMake(0, 0, KWIDTH, 170);
        tableView.tableHeaderView = cuteView;
        [tableView reloadData];
    }
    else
    {
        cuteView.frame = CGRectMake(0, 0, KWIDTH, centerY + 65);
        tableView.tableHeaderView = cuteView;
        
    }

}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"个人中心%ld",(long)indexPath.row];
    
    
    return cell;
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%f",tableView.contentOffset.y);
    if (tableView.contentOffset.y > 0) {
        isCute = NO;
    }
    if (tableView.contentOffset.y == 0) {
        [self performSelector:@selector(canCute) withObject:nil afterDelay:0.1];
    }
}

- (void)canCute
{
    isCute = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
