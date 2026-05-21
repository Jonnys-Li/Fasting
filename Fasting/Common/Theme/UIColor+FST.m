//
//  UIColor+FST.m
//  Fasting
//

#import "UIColor+FST.h"

@implementation UIColor (FST)

+ (UIColor *)fst_colorWithHex:(uint32_t)hex {
    return [self fst_colorWithHex:hex alpha:1.0];
}

+ (UIColor *)fst_colorWithHex:(uint32_t)hex alpha:(CGFloat)alpha {
    CGFloat r = ((hex >> 16) & 0xFF) / 255.0;
    CGFloat g = ((hex >> 8) & 0xFF) / 255.0;
    CGFloat b = (hex & 0xFF) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:alpha];
}

+ (UIColor *)fst_primaryGreen       { return [self fst_colorWithHex:0x62D49F]; }
+ (UIColor *)fst_primaryGreenDark   { return [self fst_colorWithHex:0x35BE83]; }
+ (UIColor *)fst_ringTrack          { return [self fst_colorWithHex:0xEDF3F8]; }
+ (UIColor *)fst_buttonGray         { return [self fst_colorWithHex:0xE6E8EC]; }
+ (UIColor *)fst_pageBackground     { return [self fst_colorWithHex:0xF5F5F9]; }
+ (UIColor *)fst_cardBackground     { return [UIColor whiteColor]; }
+ (UIColor *)fst_textPrimary        { return [self fst_colorWithHex:0x173A53]; }
+ (UIColor *)fst_textSecondary      { return [self fst_colorWithHex:0x7D8C9A]; }
+ (UIColor *)fst_separator          { return [self fst_colorWithHex:0xEDEEF0]; }
+ (UIColor *)fst_redDot             { return [self fst_colorWithHex:0xFF6B6B]; }
+ (UIColor *)fst_planOrange         { return [self fst_colorWithHex:0xFBE9E3]; }
+ (UIColor *)fst_planBlue           { return [self fst_colorWithHex:0xE7ECFA]; }
+ (UIColor *)fst_planYellow         { return [self fst_colorWithHex:0xFAF1DE]; }
+ (UIColor *)fst_planGreen          { return [self fst_colorWithHex:0xE6F3EA]; }

+ (UIColor *)fst_amber              { return [self fst_colorWithHex:0xDEA006]; }
+ (UIColor *)fst_progressCream      { return [self fst_colorWithHex:0xFEECAC]; }
+ (UIColor *)fst_peach              { return [self fst_colorWithHex:0xF5E0D8]; }
+ (UIColor *)fst_orangeCTA          { return [self fst_colorWithHex:0xFFA93F]; }
+ (UIColor *)fst_eatingTimeGreen    { return [self fst_colorWithHex:0x28D8A1]; }

@end
