//
//  SevenViewController.m
//  YFLinkageScrollView
//
//  Created by Wolf on 16/3/25.
//  Copyright © 2016年 许毓方. All rights reserved.
//

#import "SevenViewController.h"

@interface SevenViewController ()

@end
static int count = 0;
@implementation SevenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:128/255.0 green:0/255.0 blue:255/255.0 alpha:1.0];

    self.label.text = [NSString stringWithFormat:@"%@ - %d",[self class], count];
    count++;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
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

@end
