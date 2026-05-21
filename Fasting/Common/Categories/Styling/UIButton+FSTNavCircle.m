//
//  UIButton+FSTNavCircle.m
//  Fasting
//

#import "UIButton+FSTNavCircle.h"
#import "UIColor+FST.h"

@implementation UIButton (FSTNavCircle)

+ (instancetype)fst_navCircleButtonWithSystemName:(NSString *)symbolName
                                         diameter:(CGFloat)diameter
                                        tintColor:(nullable UIColor *)tintColor {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImageSymbolConfiguration *config =
        [UIImageSymbolConfiguration configurationWithPointSize:diameter * 0.4
                                                        weight:UIImageSymbolWeightSemibold];
    [button setImage:[UIImage systemImageNamed:symbolName withConfiguration:config]
            forState:UIControlStateNormal];
    button.tintColor = tintColor ?: [UIColor fst_textPrimary];
    [self fst_applyCircleStyle:button diameter:diameter];
    return button;
}

+ (instancetype)fst_navCircleButtonWithImageNamed:(NSString *)imageName
                                         diameter:(CGFloat)diameter {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [button setImage:image forState:UIControlStateNormal];
    CGFloat inset = diameter * 0.26;
    button.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
    [self fst_applyCircleStyle:button diameter:diameter];
    return button;
}

+ (instancetype)fst_navPlainButtonWithImageNamed:(NSString *)imageName
                                            size:(CGSize)size {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [button setImage:image forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.layer.shadowOpacity = 0;
    button.imageEdgeInsets = UIEdgeInsetsZero;
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.adjustsImageWhenHighlighted = NO;
    button.bounds = CGRectMake(0, 0, size.width, size.height);
    return button;
}

+ (void)fst_applyCircleStyle:(UIButton *)button diameter:(CGFloat)diameter {
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = diameter / 2.0;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOpacity = 0.08;
    button.layer.shadowOffset = CGSizeMake(0, 4);
    button.layer.shadowRadius = 8;
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.adjustsImageWhenHighlighted = NO;
}

@end
