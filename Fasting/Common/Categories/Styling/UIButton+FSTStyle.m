//
//  UIButton+FSTStyle.m
//  Fasting
//

#import "UIButton+FSTStyle.h"
#import "FSTTheme.h"

@implementation UIButton (FSTStyle)

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
    button.layer.cornerRadius = 18;
    button.layer.masksToBounds = YES;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    return button;
}

+ (instancetype)fst_yellowPillButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = FSTFontBold(18);
    button.backgroundColor = [UIColor fst_colorWithHex:0xF5C24A];
    button.layer.cornerRadius = 32;
    button.layer.masksToBounds = YES;
    return button;
}

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

@end
