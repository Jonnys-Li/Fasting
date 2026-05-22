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

// MARK: - 扩展文字色

/// #272A33 卡片标题、面板标题、按钮标题深色文字。
+ (UIColor *)fst_textHeading;
/// #5C6373 计时器说明、副标注文字。
+ (UIColor *)fst_textCaption;
/// #5A5C66 Tips 卡片正文色。
+ (UIColor *)fst_textTipBody;
/// #52596B Breaking Fast 卡片副标题。
+ (UIColor *)fst_textSubtitle;
/// #233243 弹窗标题文字。
+ (UIColor *)fst_dialogTitle;
/// #526A8F 计划准备卡片正文。
+ (UIColor *)fst_planPrepBody;

// MARK: - 扩展控件色

/// #E3E5EA 停止按钮 / 未激活态按钮背景。
+ (UIColor *)fst_buttonInactive;
/// #F5C24A Start Fasting 黄色 CTA 背景。
+ (UIColor *)fst_startButtonYellow;
/// #EBEDEE 圆环次浅灰底色 / 胶囊筹码底色。
+ (UIColor *)fst_ringTrackLight;

// MARK: - 扩展表面/背景色

/// #F5F7FA 输入框、行内底色。
+ (UIColor *)fst_inputBackground;
/// #F4F6F8 提示标签底色。
+ (UIColor *)fst_hintBackground;
/// #F0F1F3 分段控件底色。
+ (UIColor *)fst_segmentBackground;
/// #F1F2F4 标签筛选未选中态底色。
+ (UIColor *)fst_chipBackground;
/// #F6F7F9 饮食日记卡片底色。
+ (UIColor *)fst_mealDiaryCardBackground;
/// #E0E2E6 饮食日记卡片描边。
+ (UIColor *)fst_mealDiaryCardBorder;
/// #B0B5BE 饮食日记铅笔图标灰色。
+ (UIColor *)fst_editPencilGray;

// MARK: - Tips / Stage 阶段卡配色

/// #E2EEFF 阶段卡蓝色背景。
+ (UIColor *)fst_stageBlue;
/// #DCF1ED 阶段卡绿色背景。
+ (UIColor *)fst_stageGreen;
/// #FFF1E7 阶段卡橙色背景。
+ (UIColor *)fst_stageOrange;
/// #FFF8D9 Tips 黄色卡片背景。
+ (UIColor *)fst_tipCardYellow;

// MARK: - Timeline 配色

/// #29B78B 时间线卡片外围绿色背景。
+ (UIColor *)fst_timelineGreen;
/// #54D9B0 时间线卡片内部浅绿（圆点/面板）。
+ (UIColor *)fst_timelineInnerGreen;

// MARK: - 警告 / 强调

/// #FF6D4A 超时/警告橙色。
+ (UIColor *)fst_warningOrange;
/// #FF9876 Ready-to-start 圆环 progress 橙。
+ (UIColor *)fst_ringReadyOrange;

// MARK: - Meal Detail 专属

/// #F4F3FA MealDetail 页面底色。
+ (UIColor *)fst_mealDetailBackground;
/// #F0D895 MealDetail 保存按钮底色。
+ (UIColor *)fst_mealSaveButton;
/// #E7A847 MealTime 日期文字色。
+ (UIColor *)fst_mealDateText;
/// #FFF1C9 MealDetail 图片按钮底色。
+ (UIColor *)fst_mealImageBackground;
/// #E8B64C MealDetail 图片按钮 tint。
+ (UIColor *)fst_mealImageTint;
/// #F8F1E5 MealSlot 图标底色。
+ (UIColor *)fst_mealSlotIconBackground;

// MARK: - AddRecord 专属

/// #5DA986 AddRecord 顶栏绿。
+ (UIColor *)fst_addRecordHeaderGreen;
/// #4A9275 AddRecord 山形装饰底色。
+ (UIColor *)fst_addRecordMountainGreen;
/// #F2F4FA AddRecord 页面底色。
+ (UIColor *)fst_addRecordBackground;
/// #E9EEF6 AddRecord 取消按钮底色。
+ (UIColor *)fst_addRecordCancelButton;

// MARK: - Dialog 弹窗专属

/// #F1F4FA 弹窗图标底色。
+ (UIColor *)fst_dialogIconBackground;
/// #8F9CB2 弹窗图标 tint。
+ (UIColor *)fst_dialogIconTint;
/// #F3F5F9 弹窗关闭按钮底色。
+ (UIColor *)fst_dialogCloseBackground;
/// #C4CAD3 弹窗关闭按钮 tint。
+ (UIColor *)fst_dialogCloseTint;
/// #EDF1F7 弹窗次要按钮底色。
+ (UIColor *)fst_dialogSecondaryButton;

// MARK: - TimeEditor 专属

/// #27D6A0 对齐选中态背景（需搭配 alpha）。
+ (UIColor *)fst_alignSelectedGreen;
/// #C9CDD4 对齐未选中态背景（需搭配 alpha）。
+ (UIColor *)fst_alignUnselectedGray;
/// #008D5A 对齐选中态文字。
+ (UIColor *)fst_alignSelectedText;

// MARK: - Plan 专属

/// #6689E8 推荐面板蓝色卡片。
+ (UIColor *)fst_recommendBlue;
/// #F4A94F 推荐面板橙色卡片。
+ (UIColor *)fst_recommendOrange;
/// #EAF3FF 计划准备卡片底色。
+ (UIColor *)fst_planPrepBackground;

@end

NS_ASSUME_NONNULL_END
