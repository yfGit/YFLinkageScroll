//
//  BasicViewController.m
//  YFLinkageScrollView
//
//  Created by Wolf on 16/4/19.
//  Copyright © 2016年 许毓方. All rights reserved.
//

#import "BasicViewController.h"

@interface BasicViewController ()

@end

@implementation BasicViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _label = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 200, 30)];
    _label.backgroundColor = [UIColor whiteColor];
    _label.textColor = [UIColor blackColor];
    [self.view addSubview:_label];
}





@end
