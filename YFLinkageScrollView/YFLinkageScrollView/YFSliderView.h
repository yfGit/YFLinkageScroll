//
//  YFSliderView.h
//  YFLinkageScrollView
//
//  Created by Wolf on 16/3/23.
//  Copyright © 2016年 许毓方. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, YFSliderType) {
    YFSliderTypeNone,           // 没有
    YFSliderTypeTop,            // 上面
    YFSliderTypeMid,            // 中间
    YFSliderTypeBottom,         // 下面
    YFSliderTypeBottomAlone     // 下面独立
};


@interface YFSliderView : UIView

@property (nonatomic, assign) CGFloat sliderWidth;

@property (nonatomic, assign) BOOL isCustomWidth;

/**
 *  slierContain
 *
 *  @param type          type
 *  @param containWidth  标签按钮宽
 *  @param tagHeight     slier高
 *  @param containHeight 标签按钮高
 *  @param customSlider  自定义 (width != 0 为自定义宽, 不缩放slider, 缩放宽度默认title宽度,不够 1.0+sliderWidthScale)
 *  @param customFrame   _slider = customSlider; frame会改变 
 */
- (instancetype)initWithType:(YFSliderType)type
                containWidth:(CGFloat)containWidth
                   tagHeight:(CGFloat)tagHeight
               containHeight:(CGFloat)containHeight
                   andSlider:(UIView *)customSlider
                       scale:(CGFloat)scale
                 customFrame:(CGRect)customFrame;


@end
