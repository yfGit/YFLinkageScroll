//
//  CustomViewController.m
//  YFLinkageScrollView
//
//  Created by Wolf on 16/4/12.
//  Copyright © 2016年 许毓方. All rights reserved.
//

#import "CustomViewController.h"

@interface CustomViewController ()
{}
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UIButton *btnTwo;
@property (weak, nonatomic) IBOutlet UILabel *label;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation CustomViewController

static float a = 1.0;

- (void)viewDidLoad {
    [super viewDidLoad];

    a = 1.0;
    _btn.titleLabel.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.3];
    _btn.titleLabel.adjustsFontSizeToFitWidth = YES;
    _btnTwo.titleLabel.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    _btnTwo.titleLabel.adjustsFontSizeToFitWidth = YES;

    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeSize) userInfo:nil repeats:YES];
}

- (void)changeSize
{
    CGFloat fontSize = _btn.titleLabel.font.pointSize;
    _btn.titleLabel.font = [UIFont systemFontOfSize:fontSize+0.1];

    _label.font = [UIFont systemFontOfSize:fontSize+0.1];

    a += 0.01;
    if (a > 1.9) return;
    _btnTwo.transform = CGAffineTransformMakeScale(a, a);
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_timer invalidate];
    //_btnTwo.transform = CGAffineTransformIdentity;
    _timer = nil;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end
