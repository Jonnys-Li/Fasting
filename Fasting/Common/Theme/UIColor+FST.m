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

// 扩展文字色
+ (UIColor *)fst_textHeading        { return [self fst_colorWithHex:0x272A33]; }
+ (UIColor *)fst_textCaption        { return [self fst_colorWithHex:0x5C6373]; }
+ (UIColor *)fst_textTipBody        { return [self fst_colorWithHex:0x5A5C66]; }
+ (UIColor *)fst_textSubtitle       { return [self fst_colorWithHex:0x52596B]; }
+ (UIColor *)fst_dialogTitle        { return [self fst_colorWithHex:0x233243]; }
+ (UIColor *)fst_planPrepBody       { return [self fst_colorWithHex:0x526A8F]; }

// 扩展控件色
+ (UIColor *)fst_buttonInactive     { return [self fst_colorWithHex:0xE3E5EA]; }
+ (UIColor *)fst_startButtonYellow  { return [self fst_colorWithHex:0xF5C24A]; }
+ (UIColor *)fst_ringTrackLight     { return [self fst_colorWithHex:0xEBEDEE]; }

// 扩展表面/背景色
+ (UIColor *)fst_inputBackground    { return [self fst_colorWithHex:0xF5F7FA]; }
+ (UIColor *)fst_hintBackground     { return [self fst_colorWithHex:0xF4F6F8]; }
+ (UIColor *)fst_segmentBackground  { return [self fst_colorWithHex:0xF0F1F3]; }
+ (UIColor *)fst_chipBackground     { return [self fst_colorWithHex:0xF1F2F4]; }
+ (UIColor *)fst_mealDiaryCardBackground { return [self fst_colorWithHex:0xF6F7F9]; }
+ (UIColor *)fst_mealDiaryCardBorder    { return [self fst_colorWithHex:0xE0E2E6]; }
+ (UIColor *)fst_editPencilGray         { return [self fst_colorWithHex:0xB0B5BE]; }

// Tips / Stage 阶段卡配色
+ (UIColor *)fst_stageBlue          { return [self fst_colorWithHex:0xE2EEFF]; }
+ (UIColor *)fst_stageGreen         { return [self fst_colorWithHex:0xDCF1ED]; }
+ (UIColor *)fst_stageOrange        { return [self fst_colorWithHex:0xFFF1E7]; }
+ (UIColor *)fst_tipCardYellow      { return [self fst_colorWithHex:0xFFF8D9]; }

// Timeline 配色
+ (UIColor *)fst_timelineGreen      { return [self fst_colorWithHex:0x29B78B]; }
+ (UIColor *)fst_timelineInnerGreen { return [self fst_colorWithHex:0x54D9B0]; }

// 警告 / 强调
+ (UIColor *)fst_warningOrange      { return [self fst_colorWithHex:0xFF6D4A]; }
+ (UIColor *)fst_ringReadyOrange    { return [self fst_colorWithHex:0xFF9876]; }

// Meal Detail 专属
+ (UIColor *)fst_mealDetailBackground    { return [self fst_colorWithHex:0xF4F3FA]; }
+ (UIColor *)fst_mealSaveButton          { return [self fst_colorWithHex:0xF0D895]; }
+ (UIColor *)fst_mealDateText            { return [self fst_colorWithHex:0xE7A847]; }
+ (UIColor *)fst_mealImageBackground     { return [self fst_colorWithHex:0xFFF1C9]; }
+ (UIColor *)fst_mealImageTint           { return [self fst_colorWithHex:0xE8B64C]; }
+ (UIColor *)fst_mealSlotIconBackground  { return [self fst_colorWithHex:0xF8F1E5]; }

// AddRecord 专属
+ (UIColor *)fst_addRecordHeaderGreen    { return [self fst_colorWithHex:0x5DA986]; }
+ (UIColor *)fst_addRecordMountainGreen  { return [self fst_colorWithHex:0x4A9275]; }
+ (UIColor *)fst_addRecordBackground     { return [self fst_colorWithHex:0xF2F4FA]; }
+ (UIColor *)fst_addRecordCancelButton   { return [self fst_colorWithHex:0xE9EEF6]; }

// Dialog 弹窗专属
+ (UIColor *)fst_dialogIconBackground    { return [self fst_colorWithHex:0xF1F4FA]; }
+ (UIColor *)fst_dialogIconTint          { return [self fst_colorWithHex:0x8F9CB2]; }
+ (UIColor *)fst_dialogCloseBackground   { return [self fst_colorWithHex:0xF3F5F9]; }
+ (UIColor *)fst_dialogCloseTint         { return [self fst_colorWithHex:0xC4CAD3]; }
+ (UIColor *)fst_dialogSecondaryButton   { return [self fst_colorWithHex:0xEDF1F7]; }

// TimeEditor 专属
+ (UIColor *)fst_alignSelectedGreen      { return [self fst_colorWithHex:0x27D6A0]; }
+ (UIColor *)fst_alignUnselectedGray     { return [self fst_colorWithHex:0xC9CDD4]; }
+ (UIColor *)fst_alignSelectedText       { return [self fst_colorWithHex:0x008D5A]; }

// Plan 专属
+ (UIColor *)fst_recommendBlue           { return [self fst_colorWithHex:0x6689E8]; }
+ (UIColor *)fst_recommendOrange         { return [self fst_colorWithHex:0xF4A94F]; }
+ (UIColor *)fst_planPrepBackground      { return [self fst_colorWithHex:0xEAF3FF]; }

@end
