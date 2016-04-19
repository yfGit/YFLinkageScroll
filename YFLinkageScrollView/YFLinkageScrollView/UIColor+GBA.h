//
//  UIColor+GBA.h
//  Q递
//
//  Created by imac on 15/6/18.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (GBA)
+ (UIColor *) colorWithHexString: (NSString *)color;

+ (UIColor *) colorWithHexString: (NSString *)color alpha:(CGFloat)alpha;

@end
