



//
//  FiveViewController.m
//  YFLinkageScrollView
//
//  Created by Wolf on 16/3/25.
//  Copyright © 2016年 许毓方. All rights reserved.
//

#import "FiveViewController.h"

@interface FiveViewController ()

@end
static int count = 0;
@implementation FiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];

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
    NSLog(@"%s",__func__);
}
- (void)load
{
    NSLog(@"%@-加载动画,刷新数据",[self class]);
}



@end
