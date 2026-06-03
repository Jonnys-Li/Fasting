//
//  UIView+FSTLayout.m
//  Fasting
//

#import "UIView+FSTLayout.h"
#import "UIColor+FST.h"

@implementation UIView (FSTLayout)

#pragma mark - 样式

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

+ (instancetype)fst_whiteCardWithRadius:(CGFloat)radius {
    return [self fst_containerWithBackground:[UIColor whiteColor] radius:radius];
}

+ (instancetype)fst_containerWithBackground:(UIColor *)bg radius:(CGFloat)radius {
    UIView *view = [[self alloc] init];
    view.backgroundColor = bg;
    view.layer.cornerRadius = radius;
    return view;
}

+ (instancetype)fst_circularDotWithSize:(CGFloat)size
                            borderColor:(nullable UIColor *)borderColor
                            borderWidth:(CGFloat)borderWidth
                                bgColor:(nullable UIColor *)bgColor {
    UIView *dot = [[self alloc] init];
    dot.layer.cornerRadius = size / 2.0;
    dot.layer.borderWidth = borderWidth;
    if (borderColor) dot.layer.borderColor = borderColor.CGColor;
    if (bgColor) dot.backgroundColor = bgColor;
    dot.clipsToBounds = YES;
    return dot;
}

+ (instancetype)fst_separatorLineWithColor:(UIColor *)color {
    UIView *line = [[self alloc] init];
    line.backgroundColor = color;
    return line;
}

#pragma mark - 批量添加

- (void)fst_addSubviews:(NSArray<UIView *> *)subviews {
    for (UIView *view in subviews) [self addSubview:view];
}

@end
