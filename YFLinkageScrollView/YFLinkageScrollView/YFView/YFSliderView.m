//
//  YFSliderView.m
//  YFLinkageScrollView
//
//  Created by Wolf on 16/3/23.
//  Copyright © 2016年 许毓方. All rights reserved.
//

#import "YFSliderView.h"

@interface YFSliderView ()


@property (nonatomic, strong) UIView *slider;

@end

@implementation YFSliderView

- (instancetype)initWithType:(YFSliderType)type containWidth:(CGFloat)containWidth tagHeight:(CGFloat)tagHeight containHeight:(CGFloat)containHeight andSlider:(UIView *)customSlider scale:(CGFloat)scale customFrame:(CGRect)customFrame
{

    self = [super init];
    if (self) {

//        self.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];

        if (customSlider) {
            tagHeight = customSlider.frame.size.height;
        }

        switch (type) {
            case YFSliderTypeBottom:
                self.frame = CGRectMake(0, containHeight-tagHeight, containWidth, tagHeight);
                break;
            case YFSliderTypeTop:
                self.frame = CGRectMake(0, 0, containWidth, tagHeight);
                break;
            case YFSliderTypeMid:
                self.frame = CGRectMake(0, 0, containWidth, containHeight);
                break;
            case YFSliderTypeBottomAlone:
                self.frame = CGRectMake(0, 0, containWidth, containHeight);
                break;
            default:
                break;
        }
        
        if (customSlider) {
            self.slider = customSlider;
            self.slider.frame = customFrame;
            CGRect rect = self.slider.frame;
            if (self.slider.frame.size.width == 0) {
                rect.size.width = containWidth;
                self.isCustomWidth = NO;
            }else {
                self.isCustomWidth = YES;
            }
            self.slider.frame = rect;
        }else {
            self.slider = [[UIView alloc] init];
            if (type == YFSliderTypeMid) {
                tagHeight = containHeight-10;
            }
            self.slider.frame = CGRectMake(0, 0, containWidth, tagHeight);
            self.slider.layer.cornerRadius = self.slider.frame.size.height/2;
            self.slider.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:1.0 alpha:0.3];
        }

        [self addSubview:self.slider];
        self.slider.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    }
    return self;
}

- (void)setSliderWidth:(CGFloat)sliderWidth
{
    CGPoint center = self.slider.center;

    CGRect rect = self.slider.frame;
    rect.size.width  = sliderWidth;
    self.slider.frame = rect;

    self.slider.center = center;
}

- (CGFloat)sliderWidth
{
    return self.slider.frame.size.width;
}

- (void)dealloc
{
    
}

@end
