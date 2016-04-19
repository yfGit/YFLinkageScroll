//
//  YFLinkageScrollView.h
//  YFLinkageScrollView
//
//  Created by Wolf on 16/4/8.
//  Copyright © 2016年 许毓方. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "YFTagScroll.h"
#import "YFSliderView.h"
#import "YFContentScroll.h"

#pragma mark - *************************** Protocol ***************************

@protocol YFLinkageScrollViewDelegate <NSObject>

@optional
/** 当前index */
- (void)yfScrollViewChangeCurrentIndex:(NSInteger)currentIndex item:(id)item;

/** 左出界, 超出的值,正数 */
- (void)yfScrollViewOutOfLeft:(CGFloat)value;

/** 右出界, 超出的值,正数 */
- (void)yfScrollViewOutOfRight:(CGFloat)value;

@end


@interface YFLinkageScrollView : UIView

#pragma mark - ************************** Properties **************************

@property (nonatomic, weak) id<YFLinkageScrollViewDelegate> delegate;

/** 标签Scroll ,用于背景色, bouces,showH V控制*/
@property (nonatomic, strong) YFTagScroll *tagScroll;
/** 内容Scroll */
@property (nonatomic, strong) YFContentScroll *ctScroll;


/** 显示会刚好显示全(scrollRectToVisible:), 默认tag居中 */
@property (nonatomic, assign) BOOL isMoveToVisible;

/** slider宽度, 默认取title字符宽度, 这个值为基本上增加 1.0+sliderWidthScale */
@property (nonatomic, assign) CGFloat sliderWidthScale;

/** 全局tagItem点击和setCurrentIndex:,动画时间 default:0.5 */
@property (nonatomic, assign) CGFloat animDuration;

/** YFSliderTypeBottomAlone 时 containScroll 的背景色, 默认clearColor */
@property (nonatomic, strong) UIColor *sliderColor;

/** 横屏时的显示个数 */
@property (nonatomic, assign) CGFloat rotateVisibleCount;


#pragma mark - ***************************** Init *****************************
/**
 *  初始化
 *  缩放1.2  
 *  slider按tagArr的title字符宽度
 */
- (void)configWithScrolltagArray:(NSArray *)tagArr
                    visibleCount:(float)visibleCount
                      sliderType:(YFSliderType)type
               contentScrollItem:(NSArray *)contentArr;

/**
 *  自定义初始化
 *
 *  @param tagArr       标签字符串
 *  @param tagEdge      TagScroll上左右控制内嵌,默认贴边, 下控制高度
 *  @param tagScale     标签选中时缩放值 1.2为默认的1.2倍
 *  @param block        tag按钮的样式,默认(选中红,默认黑)
 *  @param visibleCount self.frame 能显示多少个按钮, 可为小数(提示后面还有)
 *  @param type         slider Type上左右控制内嵌,默认贴边, 下控制高度
 *  @param customSlider 自定义slider
 *  @param contentArr   内容, viewControllers 或 Views
 */
- (void)configWithScrolltagArray:(NSArray *)tagArr
              tagScrollEdgeInset:(UIEdgeInsets)tagEdge
                        tagScale:(CGFloat)tagScale
              configTagItemBlock:(YFTagItemConfigration)block
                    visibleCount:(float)visibleCount
                      sliderType:(YFSliderType)type
                    customSlider:(UIView *)customSlider
               contentScrollItem:(NSArray *)contentArr;



#pragma mark - ***************************** Jump *****************************

/**
 *  直接跳转页面
 *
 *  @param currentIndex         跳转的页面
 *  @param animated             ctScroll的动画
 *  @param tagAnimated          TagScroll的动画
 */
- (void)setCurrentIndex:(NSInteger)currentIndex
               animated:(BOOL)animated
            TagAnimated:(BOOL)tagAnimated;


#pragma mark - ***************************** CRUD *****************************

// 调用之前, 主控制器先改变对应数据的CRUD, 以下方法会调用代理, 免得越界
/**
 *  增加在最后一个
 *
 *  @param title 标签字符串
 *  @param item  内容, UIView 或 UIViewController
 */
- (void)addTagTitle:(NSString *)title contentItem:(id)item;
/**
 *  增加在index, 会移动到新插入的位置
 */
- (void)addTagTitle:(NSString *)title contentItem:(id)item atIndex:(NSInteger)index;

/**
 *  删除
 */
- (void)removeContentAtIndex:(NSInteger)index;
/**
 *  多删(不想枚举判断了(浪费),传字符串,负数自己负责,如果可以直接报错的限制方法,请issue我)
 */
- (void)removeContentAtIndexs:(NSArray<NSNumber *> *)indexs;

/**
 *  交换元素
 */
- (void)exchangeAtIndex:(NSInteger)index1 withIndex:(NSInteger)index2;
/** 
 *切换之后的数组对比, 看网易新闻加的 
 */
- (void)updateTagArr:(NSMutableArray *)tagArr contentArr:(NSMutableArray *)contentArr;


@end