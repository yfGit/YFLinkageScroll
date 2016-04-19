//
//  YFViewController.m
//  YFLinkageScrollView
//
//  Created by Wolf on 16/4/8.
//  Copyright © 2016年 许毓方. All rights reserved.
//

#import "YFViewController.h"
#import "YFLinkageScrollView.h"
#import "OneViewController.h"
#import "TwoViewController.h"
#import "ThreeViewController.h"
#import "FourViewController.h"
#import "FiveViewController.h"
#import "SixViewController.h"
#import "SevenViewController.h"


#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

@interface YFViewController ()<UITableViewDelegate,UITableViewDataSource,YFLinkageScrollViewDelegate>
{}
@property (nonatomic, strong) NSArray *ctrlArr;
@property (nonatomic, strong) NSArray *tbViewArr;
@property (nonatomic, strong) NSArray *tagArr;

@property (nonatomic, strong) YFLinkageScrollView *mainView;

@property (weak, nonatomic) IBOutlet YFLinkageScrollView *one;

@property (weak, nonatomic) IBOutlet YFLinkageScrollView *two;

@property (weak, nonatomic) IBOutlet YFLinkageScrollView *three;

@property (nonatomic, strong) NSMutableArray *statusArr;

@property (nonatomic, assign) BOOL isLoading;

@end

@implementation YFViewController

- (IBAction)switchCurrent:(id)sender {

    int dom = arc4random()%7;
    
    [_mainView setCurrentIndex:dom animated:NO TagAnimated:NO];
    [_one setCurrentIndex:dom animated:NO TagAnimated:NO];
    [_two setCurrentIndex:dom animated:YES TagAnimated:NO];
    [_three setCurrentIndex:dom animated:YES TagAnimated:NO];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isLoading = YES;
    self.navigationController.navigationBar.backgroundColor = [UIColor blueColor];

    _statusArr = [NSMutableArray arrayWithArray:@[@0,@0,@0,@0,@0,@0,@0]];

    [self setupData];

    [self configUI];
                                                        
//    [self configXib];
//    [self configXibTwo];
//    [self configXibThree];
}

- (void)setupData
{
    _tagArr = @[@"头  条", @"萌傻宠", @"美女的脸", @"上海夜景", @"海  外", @"轻松一刻",@"科技"];

    OneViewController *one = [[OneViewController alloc] init];
    TwoViewController *two = [[TwoViewController alloc] init];
    ThreeViewController *three = [[ThreeViewController alloc] init];
    FourViewController *four = [[FourViewController alloc] init];
    FiveViewController *five = [[FiveViewController alloc] init];
    SixViewController *six = [[SixViewController alloc] init];
    SevenViewController *seven = [[SevenViewController alloc] init];

    _ctrlArr = @[one, two, three, four, five, six, seven];


    NSMutableArray *viewArr = [NSMutableArray array];
    for (int i = 0; i < 7; i++) {
        UITableView *tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200, 200) style:UITableViewStylePlain];
        tb.delegate =self;
        tb.dataSource = self;
        [tb registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
        [viewArr addObject:tb];
    }
    _tbViewArr = [NSArray arrayWithArray:viewArr];
}


- (void)configUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;

    _mainView = [[YFLinkageScrollView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, 160)];
    [self.view addSubview:_mainView];

    [_mainView configWithScrolltagArray:_tagArr visibleCount:3.5 sliderType:YFSliderTypeMid contentScrollItem:_ctrlArr];

    _mainView.sliderWidthScale = 0.6;

    UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    tip.text = @"init, 居中, ViewControllers";
    tip.center = _mainView.center;
    [self.view addSubview:tip];
}

- (void)configXib
{
    YFTagItemConfigration block = ^UIButton *(UIButton *itemBtn, NSUInteger index){
        if (index == 0) {  // 选中状态
            [itemBtn setTitleColor:[UIColor colorWithRed:0.4 green:0.0 blue:1.0 alpha:0.3] forState:UIControlStateNormal];
        }else {            // 默认状态
            [itemBtn setTitleColor:[UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        }
        itemBtn.titleLabel.font = [UIFont systemFontOfSize:15]; // 大小按缩放比例
        return itemBtn;
    };

    UIView *sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 4)];
    sliderView.layer.cornerRadius = 2;
    sliderView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];

    NSMutableArray *viewArr = [NSMutableArray array];
    for (int i = 0; i < 7; i++) {
        UITableView *tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200, 200) style:UITableViewStylePlain];
        tb.delegate =self;
        tb.dataSource = self;
        [tb registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
        [viewArr addObject:tb];
    }

    [_one configWithScrolltagArray:_tagArr tagScrollEdgeInset:UIEdgeInsetsZero tagScale:1.1 configTagItemBlock:block visibleCount:5 sliderType:YFSliderTypeTop customSlider:sliderView contentScrollItem:_tbViewArr];

    _one.isMoveToVisible = YES;

}

- (void)configXibTwo
{
    YFTagItemConfigration block = ^UIButton *(UIButton *itemBtn, NSUInteger index){
        if (index == 0) {
            [itemBtn setTitleColor:[UIColor colorWithRed:0.6 green:0.4 blue:0.2 alpha:1.0] forState:UIControlStateNormal];
        }else {
            [itemBtn setTitleColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.3] forState:UIControlStateNormal];
        }
        itemBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        return itemBtn;
    };

    UIView *sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
    sliderView.layer.cornerRadius = 2;
    sliderView.backgroundColor = [UIColor redColor];

    NSMutableArray *viewArr = [NSMutableArray array];
    for (int i = 0; i < 7; i++) {
        UITableView *tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200, 200) style:UITableViewStylePlain];
        tb.delegate =self;
        tb.dataSource = self;
        tb.tag = 10+i;
        [tb registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
        [viewArr addObject:tb];
    }

    [_two configWithScrolltagArray:_tagArr tagScrollEdgeInset:UIEdgeInsetsMake(10, 20, 20, 20) tagScale:1.2 configTagItemBlock:block visibleCount:3.5 sliderType:YFSliderTypeBottomAlone customSlider:sliderView contentScrollItem:viewArr];
    _two.tagScroll.backgroundColor = [UIColor whiteColor];

    _two.isMoveToVisible = YES;
    _two.sliderColor = [UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:0.3];
}

- (void)configXibThree
{
    YFTagItemConfigration block = ^UIButton *(UIButton *itemBtn, NSUInteger index){
        if (index == 0) {
            [itemBtn setTitleColor:[UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        }else {
            [itemBtn setTitleColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] forState:UIControlStateNormal];
        }
        itemBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        return itemBtn;
    };

    UIView *sliderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 4)];
    sliderView.layer.cornerRadius = 2;
    sliderView.backgroundColor = [UIColor redColor];

    NSMutableArray *viewArr = [NSMutableArray array];
    for (int i = 0; i < 7; i++) {
        UITableView *tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200, 200) style:UITableViewStylePlain];
        tb.delegate =self;
        tb.tag = 10+i;
        tb.dataSource = self;
        [tb registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
        [viewArr addObject:tb];
    }

    _three.tagScroll.backgroundColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0];
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < 7; i++) {
        YFLinkageScrollView *view = [[YFLinkageScrollView alloc] initWithFrame:_three.bounds];

        NSMutableArray *viewArr = [NSMutableArray array];
        for (int i = 0; i < 4; i++) {
            UITableView *tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200, 200) style:UITableViewStylePlain];
            tb.delegate =self;
            tb.dataSource = self;
            [tb registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
            [viewArr addObject:tb];
        }
        [view configWithScrolltagArray:@[@"上山",@"打嘛呀打",@"老虎",@"拉拉拉"] visibleCount:3 sliderType:YFSliderTypeMid contentScrollItem:viewArr];
        view.delegate = self;
//        view.ctScroll.scrollEnabled = NO;  // 效果: 滚动的是 _three
        [arr addObject:view];
    }

    [_three configWithScrolltagArray:_tagArr tagScrollEdgeInset:UIEdgeInsetsZero tagScale:1.2 configTagItemBlock:block visibleCount:4 sliderType:YFSliderTypeNone customSlider:sliderView contentScrollItem:arr];
    _three.delegate = self;
    _isLoading = NO;
}


#pragma mark - TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)tableView.tag];
    cell.backgroundColor = [UIColor colorWithRed:0.0 green:1 blue:0 alpha:1.0];
    return cell;
}


#pragma mark - YFLinkageScrollViewDelegate

- (void)yfScrollViewOutOfRight:(CGFloat)value
{
    NSLog(@"%f",value);
}

- (void)yfScrollViewOutOfLeft:(CGFloat)value
{
    NSLog(@"%f",value);
}

- (void)yfScrollViewChangeCurrentIndex:(NSInteger)currentIndex item:(id)item
{
    static BOOL isFirst = YES;
    static NSInteger prefix = 0;
    static NSInteger suffix = 0;
    static NSInteger lastPrefix = 0;

    if (isFirst) {
        NSLog(@"%ld - %ld 加载动画,刷新数据, ",(long)prefix, (long)suffix);
        isFirst = NO;
        return;
    }

    if (_isLoading) {
        return;
    }

    if ([item isKindOfClass:[YFLinkageScrollView class]]) {
        prefix = currentIndex;
        if (prefix != lastPrefix) {
            suffix = [_statusArr[prefix] intValue];
        }
    }else {
        suffix = currentIndex;
    }
    [_statusArr removeObjectAtIndex:prefix];
    [_statusArr insertObject:@(suffix) atIndex:prefix];
    lastPrefix = prefix;

    NSLog(@"%ld - %ld 加载动画,刷新数据, ",(long)prefix, (long)suffix);


//    UIViewController *vc = (UIViewController *)_ctrlArr[currentIndex];
//    [vc load];
}


- (void)dealloc
{
    NSLog(@"%s",__func__);
}


@end
