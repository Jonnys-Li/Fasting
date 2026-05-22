//
//  UIButton+FST.m
//  Fasting
//

#import "UIButton+FST.h"
#import "FSTTheme.h"

@implementation UIButton (FST)

// MARK: - 胶囊按钮

+ (instancetype)fst_greenPillButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = FSTFontBold(18);
    button.backgroundColor = [UIColor fst_primaryGreen];
    button.layer.cornerRadius = 26;
    button.layer.masksToBounds = YES;
    return button;
}

+ (instancetype)fst_outlineGreenPillButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor fst_primaryGreen] forState:UIControlStateNormal];
    button.titleLabel.font = FSTFontSemibold(15);
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = FSTRadiusCard;
    button.layer.masksToBounds = YES;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    return button;
}

+ (instancetype)fst_yellowPillButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = FSTFontBold(18);
    button.backgroundColor = [UIColor fst_startButtonYellow];
    button.layer.cornerRadius = 32;
    button.layer.masksToBounds = YES;
    return button;
}

// MARK: - 图标按钮

+ (instancetype)fst_iconButtonWithSystemName:(NSString *)name size:(CGFloat)size {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:size * 0.45 weight:UIImageSymbolWeightSemibold];
    UIImage *image = [UIImage systemImageNamed:name withConfiguration:configuration];
    [button setImage:image forState:UIControlStateNormal];
    button.tintColor = [UIColor fst_textPrimary];
    button.backgroundColor = [UIColor fst_ringTrack];
    button.layer.cornerRadius = size / 2;
    button.layer.masksToBounds = YES;
    return button;
}

// MARK: - 导航圆形按钮

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
