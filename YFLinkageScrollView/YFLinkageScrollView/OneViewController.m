//
//  OneViewController.m
//  YFLinkageScrollView
//
//  Created by Wolf on 16/3/25.
//  Copyright © 2016年 许毓方. All rights reserved.
//

#import "OneViewController.h"

@interface OneViewController ()

@end

@implementation OneViewController

static int count = 0;

- (void)viewDidLoad {
    [super viewDidLoad];


    self.label.text = [NSString stringWithFormat:@"%@ - %d",[self class], count];
    count++;

    self.view.backgroundColor = [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
}
- (void)load
{
    NSLog(@"%@-加载动画,刷新数据",[self class]);
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
    NSLog(@"%s",__func__);
}


@end
