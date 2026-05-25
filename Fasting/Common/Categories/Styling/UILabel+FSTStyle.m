//
//  UILabel+FSTStyle.m
//  Fasting
//

#import "UILabel+FSTStyle.h"
#import "FSTTheme.h"

@implementation UILabel (FSTStyle)

+ (instancetype)fst_titleLabelWithText:(NSString *)text {
    UILabel *label = [UILabel new];
    label.text = text;
    label.font = FSTFontHeadline();
    label.textColor = [UIColor fst_textPrimary];
    return label;
}

+ (instancetype)fst_subtitleLabelWithText:(NSString *)text {
    UILabel *label = [UILabel new];
    label.text = text;
    label.font = FSTFontTitle();
    label.textColor = [UIColor fst_textPrimary];
    return label;
}

+ (instancetype)fst_bodyLabelWithText:(NSString *)text {
    UILabel *label = [UILabel new];
    label.text = text;
    label.font = FSTFontBody();
    label.textColor = [UIColor fst_textSecondary];
    label.numberOfLines = 0;
    return label;
}

+ (instancetype)fst_centerLabelWithFont:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [UILabel new];
    label.font = font;
    label.textColor = color;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

+ (instancetype)fst_labelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [UILabel new];
    label.text = text;
    label.font = font;
    label.textColor = color;
    return label;
}

+ (instancetype)fst_labelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment {
    UILabel *label = [self fst_labelWithText:text font:font color:color];
    label.textAlignment = alignment;
    return label;
}

@end
