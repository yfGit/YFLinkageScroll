//
//  YFTagScroll.h
//  YFLinkageScrollView
//
//  Created by Wolf on 16/3/24.
//  Copyright © 2016年 许毓方. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kTagPadding  -100


/** 自定义button,设置颜色时需要旋转用tagScroll */
typedef UIButton *(^YFTagItemConfigration)(UIButton *itemBtn, NSUInteger index);


@interface YFTagScroll : UIScrollView


@property (nonatomic, strong) NSMutableArray *titleArr;
/** tagItem宽度 */
@property (nonatomic, assign) float tagItemWidth;
/** tagItem缩放比 */
@property (nonatomic, assign) CGFloat tagScale;
/** tagItemNorlColorNormal */
@property (nonatomic, strong) UIColor *tagColorNor;
/** tagItemNorlColorSelect */
@property (nonatomic, strong) UIColor *tagColorSelect;

@property (nonatomic, assign) NSInteger currentIdx;


#pragma mark - Init

/** 配置数据 */
@property (nonatomic, copy) void(^infoBlock)(UIColor *tagColorNor, UIColor *tagColorSelect);
/** 标签选择 */
@property (nonatomic, copy) void(^tagSelectBlock)(UIButton *btn, NSInteger idx);



- (NSArray *)configTagArray:(NSArray *)tagArr
              tagScale:(CGFloat)tagScale
    configTagItemBlock:(YFTagItemConfigration)block;


#pragma mark - CRUD 

/** 增 */
- (NSNumber *)addTitle:(NSString *)title;
- (NSNumber *)addTitle:(NSString *)title atIndex:(NSInteger)index;

/** 删 */
- (void)removeItemAtIndex:(NSInteger)index;
/** 多删 */
- (void)removeItemAtIndexs:(NSArray *)indexs;

/** 交换 */
- (void)exchangeAtIndex:(NSInteger)index1 withIndex:(NSInteger)index2;

- (NSMutableArray *)updataTagArr:(NSMutableArray *)tagArr;
@end
