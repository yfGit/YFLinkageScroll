//
//  YFTagScroll.m
//  YFLinkageScrollView
//
//  Created by Wolf on 16/3/24.
//  Copyright © 2016年 许毓方. All rights reserved.
//

#import "YFTagScroll.h"

@interface YFTagScroll ()
{
    UIFont  *font;
    UIColor *bgColor;
}

@end


@implementation YFTagScroll

#pragma mark - Init
- (NSArray *)configTagArray:(NSArray *)tagArr tagScale:(CGFloat)tagScale configTagItemBlock:(YFTagItemConfigration)block
{
    self.titleArr = [NSMutableArray arrayWithArray:tagArr];
    NSMutableArray *titleWith = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.titleArr.count; i++) {

        UIButton *btn = [[UIButton alloc] init];
        if (block) {
            btn = block(btn, i);
        }else {

            if (i==0) {
                [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }else {
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            btn.titleLabel.font = [UIFont systemFontOfSize:15];
        }

        [self addSubview:btn];


        [btn setTitle:self.titleArr[i] forState:UIControlStateNormal];

        btn.tag = kTagPadding+i;
        if ( i==0 ) {
            if (!self.tagColorSelect) {
                self.tagColorSelect = btn.currentTitleColor;
            }
        }else {
            if (!self.tagColorNor) {
                self.tagColorNor = btn.currentTitleColor;

            }
        }
        font = btn.titleLabel.font;
        bgColor = btn.backgroundColor;

        CGSize size = [btn.currentTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, self.frame.size.height)
                                                     options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:btn.titleLabel.font}
                                                     context:nil].size;
        [titleWith addObject:@(size.width)];
        [btn addTarget:self action:@selector(tagAction:) forControlEvents:UIControlEventTouchUpInside];
    }

    if (!self.tagColorNor) {    // 可能初始化只有一个
        self.tagColorNor = [UIColor blackColor];
    }

    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator   = NO;

    return titleWith;
}

- (void)tagAction:(UIButton *)btn
{   if (self.tagSelectBlock) {
        self.tagSelectBlock(btn, btn.tag-kTagPadding);
    }
}

#pragma mark - Layout
/**
 *  分配frame
 */
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (CGRectEqualToRect(frame, CGRectZero)) return;

    for (int i = 0; i < self.titleArr.count; i++) {
        UIButton *btn = (UIButton *)[self viewWithTag:kTagPadding+i];
        btn.frame = CGRectMake(self.tagItemWidth*i, 0, self.tagItemWidth, self.frame.size.height);

        if (i==self.currentIdx) {
            btn.transform   = CGAffineTransformMakeScale(self.tagScale, self.tagScale);
        }else {
            btn.transform   = CGAffineTransformIdentity;
        }
    }
    self.contentSize = CGSizeMake(self.tagItemWidth*self.titleArr.count, self.frame.size.height);

    if (self.infoBlock) {
        self.infoBlock(self.tagColorNor, self.tagColorSelect);
    }
}

#pragma mark - CRUD

- (void)setNor:(UIButton *)btn withTitle:(NSString *)title
{
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:self.tagColorNor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(tagAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = font;
    btn.backgroundColor = bgColor;
}

/**
 *  新增item
 */
- (NSNumber *)addTitle:(NSString *)title
{
    [self.titleArr addObject:title];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:
                     CGRectMake((self.titleArr.count-1)*self.tagItemWidth, 0, self.tagItemWidth, self.frame.size.height)];
    [self setNor:btn withTitle:title];
    btn.tag = self.titleArr.count-1+kTagPadding;
    [self addSubview:btn];

    self.contentSize = CGSizeMake(self.tagItemWidth*self.titleArr.count, self.frame.size.height);

    CGSize size = [btn.currentTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, self.frame.size.height)
                                                  options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:btn.titleLabel.font}
                                                  context:nil].size;
    return @(size.width);
}

- (NSNumber *)addTitle:(NSString *)title atIndex:(NSInteger)index
{
    [self.titleArr insertObject:title atIndex:index];

    for (NSInteger i = index; i < self.subviews.count; i++) {
        UIButton *btn = (UIButton *)self.subviews[i];
        btn.tag = kTagPadding+i+1;
        btn.frame = CGRectMake(self.tagItemWidth*(i+1), 0, self.tagItemWidth, self.frame.size.height);
        btn.transform = CGAffineTransformIdentity;
    }

    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(index*self.tagItemWidth, 0, self.tagItemWidth, self.frame.size.height)];
    [self setNor:btn withTitle:title];
    btn.tag = index+kTagPadding;
    [self insertSubview:btn atIndex:index];

    CGSize size = [btn.currentTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, self.frame.size.height)
                                                 options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:btn.titleLabel.font}
                                                 context:nil].size;
    self.contentSize = CGSizeMake(self.tagItemWidth*self.titleArr.count, self.frame.size.height);
    return @(size.width);
}


/**
 *  删除当前item, tag值改变
 */
- (void)removeItemAtIndex:(NSInteger)index
{
    [self.titleArr removeObjectAtIndex:index];

    UIButton *btn = (UIButton *)[self viewWithTag:index+kTagPadding];
    [btn removeFromSuperview];
    btn = nil;

    for (NSInteger i = index; i < self.subviews.count; i++) {
        UIButton *btn = (UIButton *)self.subviews[i];
        btn.tag = kTagPadding+i;
        btn.frame = CGRectMake(self.tagItemWidth*i, 0, self.tagItemWidth, self.frame.size.height);
        btn.transform = CGAffineTransformIdentity;
    }

    self.contentSize = CGSizeMake(self.tagItemWidth*self.titleArr.count, self.frame.size.height);
}

/**
 *  多删
 *
 *
 */
- (void)removeItemAtIndexs:(NSArray *)indexs
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSInteger i = 0; i < indexs.count; i++) {
        NSInteger idx = [indexs[i] unsignedIntegerValue];
        [indexSet addIndex:idx];
    }
    [self.titleArr removeObjectsAtIndexes:indexSet];  // 删除数据源

    NSInteger minimum = 99;
    for (NSNumber *idx in indexs) {  // 找出最小的index
        UIButton *btn = (UIButton *)[self viewWithTag:idx.integerValue+kTagPadding];
        [btn removeFromSuperview];
        btn = nil;
        if (idx.integerValue < minimum)
            minimum = idx.integerValue;
    }

    for (NSInteger i = minimum; i < self.subviews.count; i++) {  // 从最小的index开始重设frame
        UIButton *btn = (UIButton *)self.subviews[i];
        btn.tag = kTagPadding+i;
        btn.frame = CGRectMake(self.tagItemWidth*i, 0, self.tagItemWidth, self.frame.size.height);
        btn.transform = CGAffineTransformIdentity;
    }
    self.contentSize = CGSizeMake(self.tagItemWidth*self.titleArr.count, self.frame.size.height);
}

/**
 *  交换
 */
- (void)exchangeAtIndex:(NSInteger)index1 withIndex:(NSInteger)index2
{
    [self.titleArr exchangeObjectAtIndex:index1 withObjectAtIndex:index2];

    UIButton *btn1 = (UIButton *)[self viewWithTag:kTagPadding+index1];
    UIButton *btn2 = (UIButton *)[self viewWithTag:kTagPadding+index2];

    CGRect tempFrame = btn1.frame;
    btn1.frame = btn2.frame;
    btn2.frame = tempFrame;

    btn1.tag = kTagPadding+index2;
    btn2.tag = kTagPadding+index1;

    [self exchangeSubviewAtIndex:index1 withSubviewAtIndex:index2];
}

/**
 *  更新数据源
 *
 *  删除不存在的, 再更新
 */
- (NSMutableArray *)updataTagArr:(NSMutableArray *)tagArr
{
    for (NSInteger i = self.titleArr.count-1; i >= 0 ; i--) {  // 删除将不存在的
        if (![tagArr containsObject:self.titleArr[i]]) {
            UIButton *btn = (UIButton *)[self viewWithTag:kTagPadding+[self.titleArr indexOfObject:self.titleArr[i]]];
            [btn removeFromSuperview];
            btn = nil;
        }
    }

    NSMutableArray *titleWith = [NSMutableArray array];
    for (int i = 0; i < tagArr.count; i++) {   // 重设frame
        CGSize size;
        if ([self.titleArr containsObject:tagArr[i]]) {
            UIButton *btn = (UIButton *)[self viewWithTag:kTagPadding+[self.titleArr indexOfObject:tagArr[i]]];
            btn.frame = CGRectMake(self.tagItemWidth*i, 0, self.tagItemWidth, self.frame.size.height);
            btn.transform = CGAffineTransformIdentity;
            [self insertSubview:btn atIndex:i];
            size = [btn.currentTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, self.frame.size.height)
                                                         options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:btn.titleLabel.font}
                                                         context:nil].size;
        }else {
            UIButton *btn = [[UIButton alloc] init];
            btn.frame = CGRectMake(self.tagItemWidth*i, 0, self.tagItemWidth, self.frame.size.height);
            [self setNor:btn withTitle:tagArr[i]];
            btn.tag = kTagPadding+i;
            [self insertSubview:btn atIndex:i];
            size = [btn.currentTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, self.frame.size.height)
                                                         options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:btn.titleLabel.font}
                                                         context:nil].size;
        }
        [titleWith addObject:@(size.width)];
    }
    self.titleArr = [NSMutableArray arrayWithArray:tagArr];
    self.contentSize = CGSizeMake(self.tagItemWidth*self.titleArr.count, self.frame.size.height);
    return titleWith;
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end
