//
//  ViewController.m
//  YFLinkageScrollView
//
//  Created by Wolf on 16/3/23.
//  Copyright © 2016年 许毓方. All rights reserved.
//

#import "ViewController.h"
#import "OneViewController.h"
#import "TwoViewController.h"
#import "ThreeViewController.h"
#import "FourViewController.h"
#import "FiveViewController.h"
#import "SixViewController.h"
#import "SevenViewController.h"
#import "YFLinkageScrollView.h"


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,YFLinkageScrollViewDelegate>


@property (weak, nonatomic) IBOutlet YFLinkageScrollView *yfScrollView;

@property (nonatomic, strong) NSMutableArray *tagArr;
@property (nonatomic, strong) NSMutableArray *viewCtrls;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.automaticallyAdjustsScrollViewInsets = NO;


    [self config];

}

- (void)config
{
    OneViewController *one = [[OneViewController alloc] init];
    TwoViewController *two = [[TwoViewController alloc] init];
    ThreeViewController *three = [[ThreeViewController alloc] init];

    self.tagArr = [NSMutableArray arrayWithArray:@[@"头条", @"萌傻宠", @"美女的脸"]];

    self.viewCtrls = [NSMutableArray arrayWithArray:@[one, two, three]];



//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.yfScrollView configWithScrolltagArray:self.tagArr visibleCount:3 sliderType:YFSliderTypeBottomAlone contentScrollItem:self.viewCtrls];
//    });


    self.yfScrollView.rotateVisibleCount = 5;
    self.yfScrollView.tagScroll.backgroundColor = [UIColor greenColor];
//    self.yfScrollView.isMoveToVisible = YES;
    self.yfScrollView.sliderWidthScale = .3;
    self.yfScrollView.delegate = self;
    self.yfScrollView.sliderColor = [UIColor whiteColor];
}


- (IBAction)jumpAction:(UIButton *)sender {

    int dom = arc4random()%7;
//    NSLog(@"随机数:%d",dom);

    static  int b = 5;
    [self.yfScrollView setCurrentIndex:dom animated:YES TagAnimated:NO];
    b = 6;
}

#pragma mark - CRUD

// 调用之前self.viewCtrls 先操作, CRUD方法会调用代理
- (IBAction)add:(UIButton *)sender {
    static int a = 0;

    TwoViewController *two = [[TwoViewController alloc] init];
    [self.viewCtrls addObject:two];
    [self.tagArr addObject:[NSString stringWithFormat:@"New-%d",a]];
    [self.yfScrollView addTagTitle:[NSString stringWithFormat:@"New-%d",a] contentItem:two];
    a++;
}
- (IBAction)addInsert:(UIButton *)sender {
    static int b = 0;

    UIView *five = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    five.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 80, 30)];
    label.text = @"UIView";
    [five addSubview:label];
    label.backgroundColor = [UIColor cyanColor];

    int idx = arc4random()%self.viewCtrls.count;
    [self.tagArr insertObject:[NSString stringWithFormat:@"Insert-%d",b] atIndex:idx];
    [self.viewCtrls insertObject:five atIndex:idx]; // 要写在前面, 后面一条会调代理
    [self.yfScrollView addTagTitle:[NSString stringWithFormat:@"Insert-%d",b] contentItem:five atIndex:idx];

    b++;
}


- (IBAction)del:(UIButton *)sender {
    if (self.viewCtrls.count < 2) return;

    NSInteger idx = arc4random()%self.viewCtrls.count;
    [self.viewCtrls removeObjectAtIndex:idx];
    [self.tagArr removeObjectAtIndex:idx];
    self.yfScrollView.animDuration = 0;     // 取消渐变
    [self.yfScrollView removeContentAtIndex:idx];
    self.yfScrollView.animDuration = 0.5;   // 全局属性恢复def 0.5
}

- (IBAction)multipleDel:(UIButton *)sender {

    if (self.viewCtrls.count < 4) return;

    NSInteger idx = arc4random()%self.viewCtrls.count;
    NSInteger idx2;
    do {
        idx2 = arc4random()%self.viewCtrls.count;
    } while (idx2 == idx);

    NSInteger idx3;
    do {
        idx3 = arc4random()%self.viewCtrls.count;
    } while (idx3 == idx2 || idx3 == idx);


    NSArray *indexs = @[@(idx), @(idx2), @(idx3)];

    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];

    for (NSInteger i = 0; i < indexs.count; i++) {
        NSInteger index = [indexs[i] unsignedIntegerValue];
        [indexSet addIndex:index];
    }

    [self.viewCtrls removeObjectsAtIndexes:indexSet];
    [self.tagArr removeObjectsAtIndexes:indexSet];

    [self.yfScrollView removeContentAtIndexs:indexs];
}

- (IBAction)change:(UIButton *)sender {

    if (self.viewCtrls.count < 3) return;
    [self.viewCtrls exchangeObjectAtIndex:0 withObjectAtIndex:1];
    [self.tagArr exchangeObjectAtIndex:0 withObjectAtIndex:1];
    [self.yfScrollView exchangeAtIndex:1 withIndex:2];
}

- (IBAction)updataSource:(UIButton *)sender {
    static int num = 0;

    FourViewController *four = [[FourViewController alloc] init];
    FiveViewController *five = [[FiveViewController alloc] init];
    SixViewController *six = [[SixViewController alloc] init];
    SevenViewController *seven = [[SevenViewController alloc] init];

//    [self.tagArr removeAllObjects];
    [self.tagArr addObject:[NSString stringWithFormat:@"上海的风景-%d",num]];
    [self.tagArr addObject:[NSString stringWithFormat:@"海外-%d",num]];
    [self.tagArr addObject:[NSString stringWithFormat:@"轻松一刻-%d",num]];
    [self.tagArr addObject:[NSString stringWithFormat:@"科技-%d",num]];

//    [self.viewCtrls removeAllObjects];
    [self.viewCtrls addObject:four];
    [self.viewCtrls addObject:five];
    [self.viewCtrls addObject:six];
    [self.viewCtrls addObject:seven];

    [self.yfScrollView updateTagArr:self.tagArr contentArr:self.viewCtrls];

    num++;
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
    NSLog(@"%ld",currentIndex);
    if ([item isKindOfClass:[UIViewController class]]) {
        BasicViewController *vc = (BasicViewController *)self.viewCtrls[currentIndex];
        [vc load];
    }
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)tableView.tag];
    return cell;
}





@end
