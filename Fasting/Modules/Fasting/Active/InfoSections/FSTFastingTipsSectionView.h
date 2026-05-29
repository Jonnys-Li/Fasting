//
//  FSTFastingTipsSectionView.h
//  Fasting
//
//  Active Fasting 页面 "COMPLETE FASTING" 按钮下方的 Tips 区，
//  包含：Section header（smiley + Tips）、Lemon water 卡、阶段卡（按 stage 切色）、可折叠 Fasting tips 卡。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Active Fasting 页 Tips 区"阶段卡"展示的两态。
/// 写入方：FSTActiveFastingDisplayState 工厂依据 timing.targetReached 决定 During / After。
/// 读取方：[FSTFastingTipsSectionView configureForStage:] — 切换图标 / 文案 / 卡片背景色。
typedef NS_ENUM(NSInteger, FSTTipsFastingStage) {
    /// 进行中（未达目标时长）。阶段卡用绿色背景 + 水合/分散注意力/避免剧烈运动的提示。
    FSTTipsFastingStageDuring,
    /// 已达成 / 已完成（达标或超时）。阶段卡用橙色背景 + 复食期建议（避免暴食、补蛋白、必要时休息）。
    FSTTipsFastingStageAfter,
};

@interface FSTFastingTipsSectionView : UIView

/// 切换阶段卡的颜色 / 图标 / 文案。可多次调用。
- (void)configureForStage:(FSTTipsFastingStage)stage;

/// Lemon water 卡 "Drink now" 按钮回调。
@property (nonatomic, copy, nullable) void (^onDrinkNowTapped)(void);

@end

NS_ASSUME_NONNULL_END
