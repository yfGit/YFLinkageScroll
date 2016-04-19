//
//  YFContentScroll.h
//  YFLinkageScrollView
//
//  Created by Wolf on 16/3/24.
//  Copyright © 2016年 许毓方. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef void (^YFContentItemConfigration)( NSUInteger index);

@interface YFContentScroll : UIScrollView

@property (nonatomic, copy) YFContentItemConfigration contentItemConfigration;

/** 配置 */
- (void)configItemArr:(NSArray *)itemArr;


/** 增 */
- (void)addContent:(id)item;
- (void)addContent:(id)item atIndex:(NSInteger)index;


/** 删 */
- (void)removeItemAtIndex:(NSInteger)index;
/** 多删 */
- (void)removeItemAtIndexs:(NSArray *)indexs;

/** 交换 */
- (void)exchangeAtIndex:(NSInteger)index1 withIndex:(NSInteger)index2;

/** 更新 */
- (void)updataContentItem:(NSMutableArray *)contentItem;

@end
