//
//  UIColor+FST.h
//  Fasting
//
//  全 App 颜色板 — 所有业务文件应只使用此文件暴露的命名色，禁止散布 hex 字面值。
//  分两组：
//   - 主色板：Plan/Active/Card/Text 等常规 UI 元素；
//   - Eating Time 设计色：吃窗口主题专属配色（圆环、CTA、计划胶囊等）。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (FST)

/// 把 0xRRGGBB 整数转成 UIColor（alpha=1）。业务一律用这两个工厂，禁止裸 UIColor colorWithRed:。
+ (UIColor *)fst_colorWithHex:(uint32_t)hex;
+ (UIColor *)fst_colorWithHex:(uint32_t)hex alpha:(CGFloat)alpha;

// MARK: - 主色板（参照 Figma）

/// #39CC8F 风格主绿。用于 Active Fasting 完成态、主 CTA 按钮、绿色圆环 fill。
+ (UIColor *)fst_primaryGreen;
/// 深一档绿。用于卡片底部内嵌阴影、按下态。
+ (UIColor *)fst_primaryGreenDark;
/// 圆环底色（浅灰）。Active Fasting 与 Plan Ready 圆环共用。
+ (UIColor *)fst_ringTrack;
/// 未达成时 "END FASTING" 按钮的灰色背景。
+ (UIColor *)fst_buttonGray;
/// 全局页面浅灰背景（卡片之间的间隙底色）。
+ (UIColor *)fst_pageBackground;
/// 卡片白底。所有 Card 风格组件的容器色。
+ (UIColor *)fst_cardBackground;
/// 主文字 #1A1A1A。标题、强调正文。
+ (UIColor *)fst_textPrimary;
/// 副文字 #8E8E93。说明文字、时间戳、placeholder。
+ (UIColor *)fst_textSecondary;
/// 分隔线灰。列表 separator、内嵌卡片之间的细线。
+ (UIColor *)fst_separator;
/// 红色小圆点。Fast ends 提醒标记、未读徽标。
+ (UIColor *)fst_redDot;

// MARK: - Plan 卡片配色（与 FSTPlan.cardBackgroundColor 一一对应）
+ (UIColor *)fst_planOrange;         ///< 14:10 卡片色（难度 1）
+ (UIColor *)fst_planBlue;           ///< 16:8  卡片色（难度 2）
+ (UIColor *)fst_planYellow;         ///< 18:6  卡片色（难度 3）
+ (UIColor *)fst_planGreen;          ///< 20:4  卡片色（难度 4）

// MARK: - Eating Time 设计色（参考 pic/Eating Time/）

/// #DEA006 Eating Time 圆环箭头、强调色。
+ (UIColor *)fst_amber;
/// #FEECAC Eating Time 圆环 progress fill — 奶油色，配合 amber 箭头使用。
+ (UIColor *)fst_progressCream;
/// #F5E0D8 计划胶囊（PlanChipPill）底色。
+ (UIColor *)fst_peach;
/// #FFA93F 备用主 CTA 橙。当前少量场景使用。
+ (UIColor *)fst_orangeCTA;
/// #28D8A1 Eating Time 断食强调绿。Active Fasting 完成态按钮、断食圆环达成色。
+ (UIColor *)fst_eatingTimeGreen;

@end

NS_ASSUME_NONNULL_END
