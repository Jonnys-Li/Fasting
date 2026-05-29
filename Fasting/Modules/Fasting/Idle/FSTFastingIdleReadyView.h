//
//  FSTFastingIdleReadyView.h
//  Fasting
//
//  Plan 页"已选未开始"状态的内容视图：Eating Time 标题 + breaking fast 卡 +
//  圆环 + Next fast 时间行 + Start / LogMeal 两个 CTA 按钮。
//

#import <UIKit/UIKit.h>
#import "FSTFastingIdleReadyRingView.h"

NS_ASSUME_NONNULL_BEGIN

/// Plan 页"已选未开始"状态下主 CTA 按钮的语义模式。
/// 写入方：FSTDailyPlanReadyDisplayState 工厂依据 scheduledCountdown 推导。
/// 读取方：FSTFastingIdleReadyView 内部 — 控制按钮标题（Start XX Fasting / Abort）、配色、tap 回调走 onStartFastingTapped 还是 onAbortPlanTapped。
typedef NS_ENUM(NSInteger, FSTDailyPlanReadyPrimaryActionMode) {
    /// 立即开始断食。出现在 eatingWindow / readyAfterEating 态。按钮文案 = "Start XX Fasting"。
    FSTDailyPlanReadyPrimaryActionStartFasting = 0,
    /// 中止预约。仅在 scheduledCountdown 态出现（用户已 Schedule 但要反悔）。按钮文案 = "Abort"，点击后预约被清除并回到 eatingWindow 普通态。
    FSTDailyPlanReadyPrimaryActionAbortPlan,
};

/// Plan 首页"已选未开始"状态下的内容视图，嵌入到 VC 的 scrollView contentView 内。
/// VC 把本视图 edges 约束到 contentView 即可；状态由 VC 通过 setter 推入。
@interface FSTFastingIdleReadyView : UIView

#pragma mark - 计划信息

/// 当前计划名（影响圆环 chip 与 "Start XX Fasting" 按钮的标题）。
@property (nonatomic, copy, nullable) NSString *planName;

#pragma mark - 圆环展示态

/// 圆环展示态：进食窗口或可开始断食态。
@property (nonatomic, assign) FSTDailyPlanReadyRingPresentationState ringPresentationState;

/// "Ready to start fasting?" 或 "Eating Time" 的标题文本。
@property (nonatomic, copy, nullable) NSString *titleText;

/// 圆环中央 elapsed 文本（已进入吃窗口的时间，格式 HH:MM:SS）。
@property (nonatomic, copy, nullable) NSString *elapsedText;

/// 圆环进度 [0, 1]。
@property (nonatomic, assign) CGFloat ringProgress;

/// "Next fast in" 倒计时文本。
@property (nonatomic, copy, nullable) NSString *remainingText;

/// "Time since last fast" 文本。
@property (nonatomic, copy, nullable) NSString *timeSinceLastFastText;

/// Next fast 起止时间行的两段文本。
@property (nonatomic, copy, nullable) NSString *nextFastStartText;
@property (nonatomic, copy, nullable) NSString *nextFastEndText;

/// 第一枚 CTA 的语义：开始断食，或中止尚未开始的预约倒计时。
@property (nonatomic, assign) FSTDailyPlanReadyPrimaryActionMode primaryActionMode;

#pragma mark - 子状态切换

/// 切换"可开始断食"子状态布局（隐藏 breaking fast 卡 + 圆环上移）。
- (void)applyReadyToStartLayout:(BOOL)readyToStart;

#pragma mark - 事件回调

@property (nonatomic, copy, nullable) void (^onBreakingFastTapped)(void);
@property (nonatomic, copy, nullable) void (^onChangePlanTapped)(void);
@property (nonatomic, copy, nullable) void (^onEditNextFastStartTapped)(void);
@property (nonatomic, copy, nullable) void (^onEditNextFastEndTapped)(void);
@property (nonatomic, copy, nullable) void (^onStartFastingTapped)(void);
@property (nonatomic, copy, nullable) void (^onAbortPlanTapped)(void);
@property (nonatomic, copy, nullable) void (^onLogMealTapped)(void);
@property (nonatomic, copy, nullable) void (^onAddRecordTapped)(void);

@end

NS_ASSUME_NONNULL_END
