//
//  FSTFastingTipsSectionView.h
//  Fasting
//
//  Active Fasting 页面 "COMPLETE FASTING" 按钮下方的 Tips 区，
//  包含：Section header（smiley + Tips）、Lemon water 卡、阶段卡（按 stage 切色）、可折叠 Fasting tips 卡。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// "阶段卡"展示的三态。
/// 写入方（Active Fasting 页）：依据 timing.targetReached 决定 During / After。
/// 写入方（Idle Ready 页）：依据 ringPresentationState（ScheduledCountdown=Prepare，其余=After）。
/// 读取方：[FSTFastingStageCard configureForStage:] 与 [FSTFastingTipsSectionView configureForStage:] — 切换图标 / 文案 / 卡片背景色。
typedef NS_ENUM(NSInteger, FSTTipsFastingStage) {
    /// 准备阶段（Ready ScheduledCountdown）。阶段卡用蓝色背景 + 富蛋白/纤维/补水/天然食物建议。
    FSTTipsFastingStagePrepare,
    /// 进行中（未达目标时长）。阶段卡用绿色背景 + 水合/分散注意力/避免剧烈运动的提示。
    FSTTipsFastingStageDuring,
    /// 已达成 / 已完成（达标或超时 / Eating Window / ReadyToStartFasting 红圈）。阶段卡用橙色背景 + 复食期建议。
    FSTTipsFastingStageAfter,
};

@interface FSTFastingTipsSectionView : UIView

/// 切换阶段卡的颜色 / 图标 / 文案。可多次调用。
- (void)configureForStage:(FSTTipsFastingStage)stage;

/// Compact 模式：去掉 QA 折叠卡，只保留 header + lemon + stage（用于非 Active 圆环态）。
/// 默认 NO（full 模式，含 QA 折叠卡）。**只在 alloc 后设置一次，不支持运行时切换。**
@property (nonatomic, assign) BOOL compact;

/// Lemon water 卡 "Drink now" 按钮回调。
@property (nonatomic, copy, nullable) void (^onDrinkNowTapped)(void);

/// QA 折叠卡展开 / 收起时同步回调（在展开动画块内触发）。
/// 用途：上层 RootView 在同一动画上下文里设置 scrollView contentOffset，让"展开 + 滚动"
/// 视觉同步（一步动作）。compact 模式下不会触发（无 QA 卡）。
@property (nonatomic, copy, nullable) void (^onExpansionChanged)(BOOL expanded);

@end

NS_ASSUME_NONNULL_END
