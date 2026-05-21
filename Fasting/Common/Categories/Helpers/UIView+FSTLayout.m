//
//  UIView+FSTLayout.m
//  Fasting
//

#import "UIView+FSTLayout.h"

@implementation UIView (FSTLayout)

- (void)fst_applyTintedBoxWithColor:(UIColor *)color alpha:(CGFloat)alpha radius:(CGFloat)radius {
    self.backgroundColor = [color colorWithAlphaComponent:alpha];
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

@end
