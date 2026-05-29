//
//  UIButton+FST.m
//  Fasting
//

#import "UIButton+FST.h"
#import "FSTTheme.h"

@implementation UIButton (FST)

// MARK: - 胶囊按钮（统一入口）

/// 静态 spec 表。每个 style 对应一组键值：
///   必填：bg / titleColor / font / radius
///   可选：contentInsets / shadow / adjustsFontSizeToFitWidth / minimumScaleFactor
/// 想新增一种胶囊按钮款式：在 enum 加一项，再在这里加一行 spec，无需改工厂方法本体。
+ (NSDictionary<NSNumber *, NSDictionary *> *)fst_pillSpecs {
    static NSDictionary<NSNumber *, NSDictionary *> *specs;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        specs = @{
            @(FSTPillButtonStylePrimaryGreen): @{
                @"bg":         [UIColor fst_primaryGreen],
                @"titleColor": [UIColor whiteColor],
                @"font":       FSTFontBold(18),
                @"radius":     @26,
            },
            @(FSTPillButtonStyleOutlineGreen): @{
                @"bg":            [UIColor whiteColor],
                @"titleColor":    [UIColor fst_primaryGreen],
                @"font":          FSTFontSemibold(15),
                @"radius":        @(FSTRadiusCard),
                @"contentInsets": [NSValue valueWithUIEdgeInsets:UIEdgeInsetsMake(0, 16, 0, 16)],
            },
            @(FSTPillButtonStyleYellow): @{
                @"bg":         [UIColor fst_startButtonYellow],
                @"titleColor": [UIColor fst_textPrimary],  // 修正：黄底白字不可读，统一为深色
                @"font":       FSTFontBold(18),
                @"radius":     @32,
            },

            @(FSTPillButtonStyleAppCTA): @{
                @"bg":         [UIColor fst_primaryGreen],
                @"titleColor": [UIColor whiteColor],
                @"font":       FSTFontSubhead(),  // Bold 20
                @"radius":     @29,
            },
            @(FSTPillButtonStyleOrangeCTA): @{
                @"bg":         [UIColor fst_orangeCTA],
                @"titleColor": [UIColor whiteColor],
                @"font":       FSTFontSubhead(),
                @"radius":     @30,
            },
            @(FSTPillButtonStyleNeutral): @{
                @"bg":         [UIColor fst_addRecordCancelButton],
                @"titleColor": [UIColor fst_textPrimary],
                @"font":       FSTFontSubhead(),
                @"radius":     @29,
            },

            @(FSTPillButtonStylePlanCTA): @{
                @"bg":         [UIColor fst_primaryGreen],
                @"titleColor": [UIColor whiteColor],
                @"font":       FSTFontBold(19),
                @"radius":     @30,
                @"shadow":     @{
                    @"color":   [UIColor fst_primaryGreen],
                    @"opacity": @0.22,
                    @"offset":  [NSValue valueWithCGSize:CGSizeMake(0, 10)],
                    @"radius":  @20,
                },
            },

            @(FSTPillButtonStyleShareCard): @{
                @"bg":         [UIColor fst_eatingTimeGreen],
                @"titleColor": [UIColor whiteColor],
                @"font":       FSTFontBold(16),
                @"radius":     @24,
            },
            @(FSTPillButtonStyleTipPrompt): @{
                @"bg":         [UIColor fst_eatingTimeGreen],
                @"titleColor": [UIColor whiteColor],
                @"font":       FSTFontBold(14),
                @"radius":     @(FSTRadiusL),
            },
            @(FSTPillButtonStyleSheetSave): @{
                @"bg":         [UIColor fst_eatingTimeGreen],
                @"titleColor": [UIColor whiteColor],
                @"font":       FSTFontAvenirDemiBold(20),
                @"radius":     @24,
            },

            @(FSTPillButtonStyleModalPrimary): @{
                @"bg":                          [UIColor fst_eatingTimeGreen],
                @"titleColor":                  [UIColor whiteColor],
                @"font":                        FSTFontBold(24),
                @"radius":                      @29,
                @"adjustsFontSizeToFitWidth":   @YES,
                @"minimumScaleFactor":          @0.72,
            },
            @(FSTPillButtonStyleModalSecondary): @{
                @"bg":                          [UIColor fst_dialogSecondaryButton],
                @"titleColor":                  [UIColor fst_dialogTitle],
                @"font":                        FSTFontBold(24),
                @"radius":                      @29,
                @"adjustsFontSizeToFitWidth":   @YES,
                @"minimumScaleFactor":          @0.72,
            },

            @(FSTPillButtonStyleInactive): @{
                @"bg":         [UIColor fst_buttonInactive],
                @"titleColor": [UIColor fst_textHeading],
                @"font":       FSTFontAvenirDemiBold(16),
                @"radius":     @(FSTRadiusXL),
            },
        };
    });
    return specs;
}

+ (instancetype)fst_pillButtonWithTitle:(NSString *)title style:(FSTPillButtonStyle)style {
    NSDictionary *spec = [self fst_pillSpecs][@(style)];
    NSAssert(spec != nil, @"FSTPillButtonStyle %ld has no spec — add it to fst_pillSpecs.", (long)style);

    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:spec[@"titleColor"] forState:UIControlStateNormal];
    button.titleLabel.font = spec[@"font"];
    button.backgroundColor = spec[@"bg"];
    button.layer.cornerRadius = [spec[@"radius"] floatValue];
    button.layer.masksToBounds = YES;

    if (spec[@"contentInsets"]) {
        button.contentEdgeInsets = [spec[@"contentInsets"] UIEdgeInsetsValue];
    }
    if (spec[@"adjustsFontSizeToFitWidth"]) {
        button.titleLabel.adjustsFontSizeToFitWidth = [spec[@"adjustsFontSizeToFitWidth"] boolValue];
    }
    if (spec[@"minimumScaleFactor"]) {
        button.titleLabel.minimumScaleFactor = [spec[@"minimumScaleFactor"] floatValue];
    }
    if (spec[@"shadow"]) {
        // 阴影需要 masksToBounds=NO，否则阴影会被裁掉。
        // 圆角通过 layer.cornerRadius 直接生效；按钮内容由 contentEdgeInsets 控制不外溢。
        button.layer.masksToBounds = NO;
        NSDictionary *shadow = spec[@"shadow"];
        button.layer.shadowColor   = ((UIColor *)shadow[@"color"]).CGColor;
        button.layer.shadowOpacity = [shadow[@"opacity"] floatValue];
        button.layer.shadowOffset  = [shadow[@"offset"] CGSizeValue];
        button.layer.shadowRadius  = [shadow[@"radius"] floatValue];
    }
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
    [button setImage:[UIImage fst_originalImageNamed:imageName] forState:UIControlStateNormal];
    CGFloat inset = diameter * 0.26;
    button.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
    [self fst_applyCircleStyle:button diameter:diameter];
    return button;
}

+ (instancetype)fst_plainImageButtonWithImageNamed:(NSString *)imageName
                                              size:(CGSize)size
                                         tintColor:(nullable UIColor *)tintColor {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    // tintColor 决定渲染模式：有色就 Template + 染色，无色就保留资源原色。
    UIImageRenderingMode mode = tintColor ? UIImageRenderingModeAlwaysTemplate
                                          : UIImageRenderingModeAlwaysOriginal;
    UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:mode];
    [button setImage:image forState:UIControlStateNormal];
    if (tintColor) {
        button.tintColor = tintColor;
    }
    button.backgroundColor = [UIColor clearColor];
    button.layer.shadowOpacity = 0;
    button.imageEdgeInsets = UIEdgeInsetsZero;
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    button.adjustsImageWhenHighlighted = NO;
    button.bounds = CGRectMake(0, 0, size.width, size.height);
    return button;
}

+ (instancetype)fst_navPlainButtonWithImageNamed:(NSString *)imageName
                                            size:(CGSize)size {
    return [self fst_plainImageButtonWithImageNamed:imageName size:size tintColor:nil];
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
