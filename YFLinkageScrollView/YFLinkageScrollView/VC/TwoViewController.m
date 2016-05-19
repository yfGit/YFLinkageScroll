//
//  TwoViewController.m
//  YFLinkageScrollView
//
//  Created by Wolf on 16/3/25.
//  Copyright © 2016年 许毓方. All rights reserved.
//

#import "TwoViewController.h"

static int count = 0;
@interface TwoViewController ()

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    self.label.text = [NSString stringWithFormat:@"%@ - %d",[self class], count];
    count++;

    self.view.backgroundColor = [UIColor colorWithRed:255/255.0 green:128/255.0 blue:0/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
//    NSLog(@"%s",__func__);
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    NSLog(@"%s",__func__);
}

- (void)dealloc
{
//    NSLog(@"%s",__func__);
}
- (void)load
{
    NSLog(@"%@-加载动画,刷新数据",[self class]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
