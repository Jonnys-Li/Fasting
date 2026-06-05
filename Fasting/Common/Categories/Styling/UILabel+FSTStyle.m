//
//  UILabel+FSTStyle.m
//  Fasting
//

#import "UILabel+FSTStyle.h"
#import "FSTTheme.h"

@implementation UILabel (FSTStyle)

+ (instancetype)fst_titleLabelWithText:(NSString *)text {
    return [self fst_labelWithText:text font:FSTFontHeadline() color:[UIColor fst_textPrimary]];
}

+ (instancetype)fst_subtitleLabelWithText:(NSString *)text {
    return [self fst_labelWithText:text font:FSTFontTitle() color:[UIColor fst_textPrimary]];
}

+ (instancetype)fst_bodyLabelWithText:(NSString *)text {
    UILabel *label = [self fst_labelWithText:text font:FSTFontBody() color:[UIColor fst_textSecondary]];
    label.numberOfLines = 0;
    return label;
}

+ (instancetype)fst_labelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = font;
    label.textColor = color;
    return label;
}

@end
