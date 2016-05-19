

//
//  YFContentScroll.m
//  YFLinkageScrollView
//
//  Created by Wolf on 16/3/24.
//  Copyright © 2016年 许毓方. All rights reserved.
//

#import "YFContentScroll.h"
#import "YFLinkageScrollView.h"

@interface YFContentScroll ()<UIScrollViewDelegate>
{}
@property (nonatomic, strong) NSMutableArray *itemArr;
@property (nonatomic, assign) BOOL isView;

@end

@implementation YFContentScroll

#pragma mark- Initial
- (void)configItemArr:(NSArray *)itemArr
{
    self.itemArr = [NSMutableArray arrayWithArray:itemArr];
    
    for (NSUInteger i = 0; i < self.itemArr.count; i++) {

        id item = itemArr[i];
        if ([item isKindOfClass:[UIView class]]) {

            self.isView = YES;
            UIView  *itemView = (UIView *)item;

            [self addSubview:itemView];
        }
    }
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator   = NO;
    self.pagingEnabled = YES;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];

    if ( self.isView || !self.itemArr ) return;

    UIViewController *viewCtrl = [self viewController:self];
    if ( viewCtrl ){

        for (int i = 0; i < self.itemArr.count; i++) {
            id item = self.itemArr[i];
            if ([item isKindOfClass:[UIViewController class]]) {
                UIViewController *itemVC = (UIViewController *)item;
                [viewCtrl addChildViewController:itemVC];

                [itemVC willMoveToParentViewController:viewCtrl];
                [self addSubview:itemVC.view];
                [itemVC didMoveToParentViewController:viewCtrl];

            }
        }
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator   = NO;
        self.pagingEnabled = YES;
    }
}

#pragma mark- Method

// 获取当前屏幕显示的viewcontroller
- (UIViewController *)viewController:(UIView *)view
{
    UIResponder *responder = view;
    while ((responder = [responder nextResponder]))
        if ([responder isKindOfClass: [UIViewController class]])
            return (UIViewController *)responder;
    // If the view controller isn't found, return nil.
    return nil;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (CGRectEqualToRect(frame, CGRectZero)) return;

    for (int i = 0; i < self.subviews.count; i++) {
        UIView *view = (UIView *)self.subviews[i];
        view.frame = CGRectMake(self.frame.size.width*i,
                                0,
                                self.frame.size.width,
                                self.frame.size.height);
    }
    self.contentSize = CGSizeMake(self.frame.size.width*self.itemArr.count, self.frame.size.height);
}

#pragma mark - CRUD

/**
 *  添加
 */
- (void)addContent:(id)item
{
    [self.itemArr addObject:item];

    CGRect frame = CGRectMake(self.frame.size.width*(self.itemArr.count-1),
                              0,
                              self.frame.size.width,
                              self.frame.size.height);

    if ([item isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)item;
        view.frame = frame;
        [self addSubview:item];
    }else if ([item isKindOfClass:[UIViewController class]]) {

        UIViewController *viewCtrl = [self viewController:self];
        UIViewController *itemVC = (UIViewController *)item;
        itemVC.view.frame = frame;
        if (viewCtrl) {
            [viewCtrl addChildViewController:itemVC];
            [itemVC willMoveToParentViewController:viewCtrl];
            [self addSubview:itemVC.view];
            [itemVC didMoveToParentViewController:viewCtrl];
        }
    }
    self.contentSize = CGSizeMake(self.frame.size.width*self.itemArr.count, self.frame.size.height);
}

- (void)addContent:(id)item atIndex:(NSInteger)index
{
    [self.itemArr insertObject:item atIndex:index];

    for (NSInteger i = index; i < self.subviews.count; i++) {
        UIView *view = self.subviews[i];
        view.frame = CGRectMake(self.frame.size.width*(i+1),
                                0,
                                self.frame.size.width,
                                self.frame.size.height);

    }

    CGRect frame = CGRectMake(self.frame.size.width*index,
                              0,
                              self.frame.size.width,
                              self.frame.size.height);
    if ([item isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)item;
        view.frame = frame;
        [self insertSubview:view atIndex:index];
    }else if ([item isKindOfClass:[UIViewController class]]) {
        UIViewController *viewCtrl = [self viewController:self];
        UIViewController *itemVC = (UIViewController *)item;
        itemVC.view.frame = frame;
        if (viewCtrl) {
            [viewCtrl addChildViewController:itemVC];
            [itemVC willMoveToParentViewController:viewCtrl];
            [self insertSubview:itemVC.view atIndex:index];
            [itemVC didMoveToParentViewController:viewCtrl];
        }
    }
    self.contentSize = CGSizeMake(self.frame.size.width*self.itemArr.count, self.frame.size.height);
}


/**
 *  删除
 */
- (void)removeItemAtIndex:(NSInteger)index
{
    [self.itemArr removeObjectAtIndex:index];

    // 删
    UIView *view = (UIView *)self.subviews[index];
    [view removeFromSuperview];
    UIViewController *viewCtrl = [self viewController:view];
    view = nil;
    if (viewCtrl && viewCtrl != [self viewController:self]) {
        [viewCtrl removeFromParentViewController];
        viewCtrl = nil;
    }
    
    // 改
    for (NSInteger i = index; i < self.subviews.count; i++) {
        UIView *subView = (UIView *)self.subviews[i];
        subView.frame = CGRectMake(self.frame.size.width*i,
                                0,
                                self.frame.size.width,
                                self.frame.size.height);
    }
    self.contentSize = CGSizeMake(self.frame.size.width*self.itemArr.count, self.frame.size.height);
}


/** 多删 */
- (void)removeItemAtIndexs:(NSArray *)indexs
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (NSInteger i = 0; i < indexs.count; i++) {
        NSInteger idx = [indexs[i] unsignedIntegerValue];
        [indexSet addIndex:idx];
    }
    [self.itemArr removeObjectsAtIndexes:indexSet];

    NSInteger minimum = 99;
    indexs = [indexs sortedArrayUsingSelector:@selector(compare:)];

    for (NSInteger i = [indexs.lastObject integerValue]; i >= [indexs.firstObject integerValue]; i--) {
        if ([indexs containsObject:[NSNumber numberWithInteger:i]]) {
            UIView *view = self.subviews[i];
            [view removeFromSuperview];
            UIViewController *viewCtrl = [self viewController:view];
            view = nil;
            if (viewCtrl && viewCtrl != [self viewController:self]) {
                [viewCtrl removeFromParentViewController];
                viewCtrl = nil;
            }
            if (i < minimum)
                minimum = i;
        }
    }

    for (NSInteger i = minimum; i < self.subviews.count; i++) {
        UIView *subView = (UIView *)self.subviews[i];
        subView.frame = CGRectMake(self.frame.size.width*i,
                                   0,
                                   self.frame.size.width,
                                   self.frame.size.height);
    }
    self.contentSize = CGSizeMake(self.frame.size.width*self.itemArr.count, self.frame.size.height);
}


/** 
 *  交换
 *  subViews 的位置
 */
- (void)exchangeAtIndex:(NSInteger)index1 withIndex:(NSInteger)index2
{
    [self.itemArr exchangeObjectAtIndex:index1 withObjectAtIndex:index2];

    UIView *view1 = (UIView *)self.subviews[index1];
    UIView *view2 = (UIView *)self.subviews[index2];
    CGRect tempFrame = view1.frame;
    view1.frame = view2.frame;
    view2.frame = tempFrame;

    [self exchangeSubviewAtIndex:index1 withSubviewAtIndex:index2];
}

/**
 *  更新
 *
 *  注意指针
 */
- (void)updataContentItem:(NSMutableArray *)contentItem
{
    for (NSInteger i = self.itemArr.count-1; i >= 0; i--) {  // 删除将不存在的
        if (![contentItem containsObject:self.itemArr[i]]) {
            UIView *view = self.subviews[i];
            [view removeFromSuperview];
            UIViewController *viewCtrl = [self viewController:view];
            view = nil;
            if (viewCtrl && viewCtrl != [self viewController:self]) {
                [viewCtrl removeFromParentViewController];
                viewCtrl = nil;
            }
        }
    }

    for (int i = 0; i < contentItem.count; i++) {   // 重设frame,新增

        CGRect frame = CGRectMake(self.frame.size.width*i,
                                  0,
                                  self.frame.size.width,
                                  self.frame.size.height);
        if ([self.itemArr containsObject:contentItem[i]]) {
            UIView *view = self.subviews[[self.itemArr indexOfObject:contentItem[i]]];
            view.frame = frame;
            [self insertSubview:view atIndex:i];
        }else {
            if ([contentItem[i] isKindOfClass:[UIView class]]) {
                UIView *view = (UIView *)contentItem[i];
                view.frame = frame;
                [self insertSubview:view atIndex:i];
            }else if ([contentItem[i] isKindOfClass:[UIViewController class]]) {
                UIViewController *viewCtrl = [self viewController:self];
                UIViewController *itemVC = (UIViewController *)contentItem[i];
                itemVC.view.frame = frame;
                if (viewCtrl) {
                    [viewCtrl addChildViewController:itemVC];
                    [itemVC willMoveToParentViewController:viewCtrl];
                    [self insertSubview:itemVC.view atIndex:i];
                    [itemVC didMoveToParentViewController:viewCtrl];
                }
            }
        }
    }
    self.itemArr = [NSMutableArray arrayWithArray:contentItem];
    self.contentSize = CGSizeMake(self.frame.size.width*self.itemArr.count, self.frame.size.height);
}
- (void)dealloc
{

}
@end
