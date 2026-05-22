//
//  UIView+FSTLayout.m
//  Fasting
//

#import "UIView+FSTLayout.h"
#import "UIColor+FST.h"

@implementation UIView (FSTLayout)

- (void)fst_applyTintedBoxWithColor:(UIColor *)color alpha:(CGFloat)alpha radius:(CGFloat)radius {
    self.backgroundColor = [color colorWithAlphaComponent:alpha];
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

- (void)fst_applyMealCardStyle {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 20;
    self.layer.borderWidth = 1.2;
    self.layer.borderColor = [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.22].CGColor;
}

@end
