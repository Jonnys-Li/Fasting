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

+ (instancetype)fst_centerLabelWithFont:(UIFont *)font color:(UIColor *)color {
    return [self fst_labelWithText:nil font:font color:color alignment:NSTextAlignmentCenter];
}

+ (instancetype)fst_labelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color {
    UILabel *label = [[UILabel alloc] init];
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

+ (instancetype)fst_labelWithText:(NSString *)text
                             font:(UIFont *)font
                            color:(UIColor *)color
                         alignment:(NSTextAlignment)alignment
                    numberOfLines:(NSInteger)numberOfLines {
    UILabel *label = [self fst_labelWithText:text font:font color:color alignment:alignment];
    label.numberOfLines = numberOfLines;
    return label;
}

@end
