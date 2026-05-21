//
//  FSTFastingTipsSectionView.h
//  Fasting
//
//  Active Fasting 页面 "COMPLETE FASTING" 按钮下方的 Tips 区，
//  包含：Section header（smiley + Tips）、Lemon water 卡、阶段卡（按 stage 切色）、可折叠 Fasting tips 卡。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Active Fasting 页 Tips 区"阶段卡"展示的三态。
/// 写入方：FSTActiveFastingDisplayState 工厂依据 timing.targetReached 决定 During / After（Prepare 不会出现）。
/// 读取方：[FSTFastingTipsSectionView configureForStage:] — 切换图标 / 文案 / 卡片背景色。
typedef NS_ENUM(NSInteger, FSTTipsFastingStage) {
    /// 计划前阶段。当前 Active Fasting 不会落到此值；保留枚举供未来 Plan 页引导流复用。
    FSTTipsFastingStagePrepare = 0,
    /// 进行中（未达目标时长）。阶段卡用绿色 + "你正在燃烧脂肪"风格文案。
    FSTTipsFastingStageDuring  = 1,
    /// 已达成 / 已完成（达标或超时）。阶段卡用琥珀色 + "Autophagy / Deep ketosis"风格文案。
    FSTTipsFastingStageAfter   = 2,
};

@interface FSTFastingTipsSectionView : UIView

/// 切换阶段卡的颜色 / 图标 / 文案。可多次调用。
- (void)configureForStage:(FSTTipsFastingStage)stage;

/// Lemon water 卡 "Drink now" 按钮回调。
@property (nonatomic, copy, nullable) void (^onDrinkNowTapped)(void);

@end

NS_ASSUME_NONNULL_END
