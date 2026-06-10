//
//  UIButton+FST.h
//  Fasting
//
//  UIButton 样式扩展：胶囊按钮（统一 style enum + spec 表）+ 图标按钮 + 导航圆形按钮。
//
//  设计：所有胶囊按钮（pill）走单一入口 +fst_pillButtonWithTitle:style:，
//  样式差异通过 FSTPillButtonStyle 枚举区分；新增款式只需扩 enum + 在 .m 的 spec 表中补一行，
//  不再像以前那样每加一种风格就加一个工厂方法。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 胶囊按钮风格。每个 style 对应一组完整 spec：背景色 / 文字色 / 字体 / 圆角 / 内边距 / 阴影 等。
/// 具体值见 UIButton+FST.m 的 fst_pillSpecs 表。
typedef NS_ENUM(NSInteger, FSTPillButtonStyle) {
    // — 核心款（高复用）—

    /// 大号实心绿：primaryGreen 底 + 白色 Bold 18 + 圆角 26。用于一般主 CTA。
    FSTPillButtonStylePrimaryGreen,

    /// 白底绿字：白底 + primaryGreen Semibold 15 + 圆角 18（FSTRadiusCard）+ 左右 16 内边距。
    FSTPillButtonStyleOutlineGreen,

    /// 大号黄：startButtonYellow 底 + textPrimary 文字（黄底白字不可读，已修正） Bold 18 + 圆角 32。
    FSTPillButtonStyleYellow,

    /// 日常应用 CTA：primaryGreen 底 + 白色 Subhead(Bold 20) + 圆角 29。用于 Start Fasting / Save 等。
    FSTPillButtonStyleAppCTA,

    /// 橙色 CTA：orangeCTA 底 + 白色 Subhead(Bold 20) + 圆角 30。用于 LOG MEAL。
    FSTPillButtonStyleOrangeCTA,

    /// 中性灰底：addRecordCancelButton 底 + textPrimary + Subhead(Bold 20) + 圆角 29。用于 Cancel。
    FSTPillButtonStyleNeutral,

    // — 特定语境款（单点使用，但样式独立性强）—

    /// PlanConfirm 强调款：primaryGreen 底 + 白色 Bold 19 + 圆角 30 + 阴影。仅 Plan 确认页主按钮。
    FSTPillButtonStylePlanCTA,

    /// 分享卡片按钮：eatingTimeGreen 底 + 白色 Bold 16 + 圆角 24。用于 Share 弹窗 Save/Share。
    FSTPillButtonStyleShareCard,

    /// Tips 卡内提示按钮：eatingTimeGreen 底 + 白色 Bold 14 + FSTRadiusL(22)。用于 Drink Now 等。
    FSTPillButtonStyleTipPrompt,

    /// Sheet 保存按钮：eatingTimeGreen 底 + 白色 AvenirDemiBold 20 + 圆角 24。用于 TimeEditor Save。
    FSTPillButtonStyleSheetSave,

    /// Modal 主按钮：eatingTimeGreen 底 + 白色 Bold 24 + 圆角 29 + 自适应字号。用于 ModalDialog Primary。
    FSTPillButtonStyleModalPrimary,

    /// Modal 辅按钮：dialogSecondaryButton 底 + dialogTitle 文字 + Bold 24 + 圆角 29 + 自适应字号。
    FSTPillButtonStyleModalSecondary,

    /// 灰底停止款：buttonInactive 底 + textHeading 文字 + AvenirDemiBold 16 + FSTRadiusXL。用于 END FASTING。
    FSTPillButtonStyleInactive,

    /// Reset 小胶囊：白底 + primaryGreen AvenirDemiBold 15 + 圆角 19（= 38pt 高的一半，正胶囊）。
    /// 仅 Idle Ready 顶栏「Reset」按钮。圆角 19 刻意区别于 OutlineGreen 的 FSTRadiusCard(18)，不可合并。
    FSTPillButtonStyleResetChip,
};

@interface UIButton (FST)

// MARK: - 胶囊按钮（统一入口）

/// 创建胶囊按钮。所有视觉参数由 style 决定，调用方不再单独设 bg / font / radius。
/// 如有特殊覆盖需求（如 PlanConfirm 的阴影），优先考虑新增一个 style 而不是在调用点 setter。
+ (instancetype)fst_pillButtonWithTitle:(NSString *)title style:(FSTPillButtonStyle)style;

// MARK: - 图标按钮

/// 圆形图标按钮：浅灰底色 + SF Symbol 图标。
+ (instancetype)fst_iconButtonWithSystemName:(NSString *)name size:(CGFloat)size;

// MARK: - 导航圆形按钮

/// 用 Asset Catalog 中的图片构建白色圆形导航按钮（原始渲染）。
/// 尺寸约束在工厂内部锁定为 diameter×diameter——cornerRadius / imageEdgeInsets 都由 diameter
/// 派生，按钮必须恰为该尺寸圆形才成立；调用方只负责摆位置，不要再加 size 约束。
+ (instancetype)fst_navCircleButtonWithImageNamed:(NSString *)imageName
                                         diameter:(CGFloat)diameter;

// MARK: - 裸图标按钮（通用）

/// 通用裸图标按钮：透明背景 + 无阴影 + ScaleAspectFit + adjustsImageWhenHighlighted=NO。
/// 适用于编辑铅笔、导航返回/分享等所有"贴一张图就能点"的场景。
/// 尺寸约束在工厂内部锁定为 size；调用方只负责摆位置，不要再加 size 约束。
/// - tintColor == nil：图片用 AlwaysOriginal，保留资源自带色（nav_back / nav_share 这类原色 icon）。
/// - tintColor != nil：图片用 AlwaysTemplate + tintColor 染色（MealDiary 的 edit_pencil 染灰这类需求）。
+ (instancetype)fst_plainImageButtonWithImageNamed:(NSString *)imageName
                                              size:(CGSize)size
                                         tintColor:(nullable UIColor *)tintColor;

@end

NS_ASSUME_NONNULL_END
