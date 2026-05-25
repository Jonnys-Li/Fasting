//
//  FSTDailyPlanReadyDisplayState.h
//  Fasting
//
//  Plan 页"已选未开始"状态的一次刷新快照。
//  - 数据来源：[FSTDailyPlanReadyDisplayState stateForPlan:]
//    由 FSTDailyPlanViewController 每秒（refreshTimer）+ FSTSessionDidChangeNotification 触发。
//    工厂读取 [FSTSessionManager sharedManager] 的吃窗口锚点、预约源、下次起始时间，
//    再交给 FSTEatingWindowService 推导吃窗口进度，根据 scheduledReadySource 决定是否切到"预约倒计时"分支。
//  - 数据去向：VC 的 -applyReadyDisplayState: 把字段推入 FSTDailyPlanReadyView 与其内嵌的圆环。
//  - 三态判定：
//      (a) scheduledCountdown — 已显式 Schedule 一个未来开始时间，圆环按倒计时填充；
//      (b) readyAfterEating  — 吃窗口耗尽，可以立即开始断食；
//      (c) 默认 eatingWindow  — 吃窗口进行中（普通态）。
//  - 设计意图（Step 2 重构产物）：把"算"和"推"拆开，VC 的 apply 方法零分支。
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "FSTDailyPlanReadyView.h"

NS_ASSUME_NONNULL_BEGIN

@class FSTPlan;

@interface FSTDailyPlanReadyDisplayState : NSObject

/// 大标题文本。三态分支：
///  - scheduledCountdown："Ready to start fasting!"（已 Schedule，倒计时归零中）
///  - readyAfterEating ："Ready to start fasting?"（吃窗口耗尽，等用户决定）
///  - 默认 eatingWindow ："Eating Time"
/// 读取方：FSTDailyPlanReadyView.titleText。
@property (nonatomic, copy) NSString *titleText;

/// 圆环展示态（ScheduledCountdown / ReadyToStartFasting / EatingWindow）。
/// 写入：工厂三态判定的产物；读取：FSTDailyPlanReadyRingView 切换填充策略与配色。
@property (nonatomic, assign) FSTDailyPlanReadyRingPresentationState ringPresentationState;

/// 圆环中央"已进入吃窗口"时长（HH:MM:SS）。
/// 来源：windowState.elapsedSeconds（来自 FSTEatingWindowService）。
/// 读取方：FSTDailyPlanReadyView.elapsedText — 普通 eatingWindow 态下显示在环中心。
@property (nonatomic, copy) NSString *elapsedText;

/// 圆环填充进度 [0, 1]。
/// scheduledCountdown 态：基于 anchorDate → nextStartDate 的线性比例（见 +scheduledProgressForStartDate:referenceDate:）；
/// 其他态：windowState.progress（吃窗口已用比例）。
/// 读取方：FSTDailyPlanReadyRingView.progress。
@property (nonatomic, assign) CGFloat ringProgress;

/// "Next fast in" 倒计时文本（HH:MM:SS）。
/// scheduledCountdown：nextStartDate - now；其他态：windowState.remainingSeconds。
/// 读取方：FSTDailyPlanReadyView.remainingText。
@property (nonatomic, copy) NSString *remainingText;

/// "Time since last fast" 文本（HH:MM:SS）。
/// 来源：windowState.timeSinceLastFastSeconds（距 latestFastingEndDate 的间隔）。
/// 读取方：FSTDailyPlanReadyView.timeSinceLastFastText。
@property (nonatomic, copy) NSString *timeSinceLastFastText;

/// 下次断食起止时间行的两段友好文本（如 "Today 8:00 PM"）。
/// 来源：windowState.nextStartDate / nextEndDate（FSTEatingWindowService 推导）。
/// 读取方：FSTDailyPlanReadyView 的 Next fast 时间行 — 用户点击可弹 TimeEditor 编辑。
@property (nonatomic, copy, nullable) NSString *nextFastStartText;
@property (nonatomic, copy, nullable) NSString *nextFastEndText;

/// 主 CTA 的语义模式。
/// scheduledCountdown：AbortPlan（中止预约 → 回 Eating 普通态）；
/// 其他态：StartFasting（立即开始）。
/// 读取方：FSTDailyPlanReadyView.primaryActionMode — 控制按钮标题、配色、tap 回调。
@property (nonatomic, assign) FSTDailyPlanReadyPrimaryActionMode primaryActionMode;

/// 紧凑布局开关 — scheduledCountdown 或 readyAfterEating 时为 YES。
/// 视觉作用：隐藏 breaking fast 卡 + 圆环上移，把空间让给"准备开始"的中心视觉。
/// 读取方：VC 调 [readyView applyReadyToStartLayout:compactLayout]。
@property (nonatomic, assign) BOOL compactLayout;

/// 工厂判定"现在应该自动起始已预约的断食"。
/// 取值条件：scheduledReadySource != None && nextStartDate <= now && currentPlan 存在。
/// VC 用法：refreshReadyState 末尾 if (state.shouldAutoStartScheduledFasting) → startFasting + push Active；
///        替代原 startScheduledFastingIfDueWithNextStartDate: 的每秒重判逻辑。
@property (nonatomic, assign) BOOL shouldAutoStartScheduledFasting;

/// shouldAutoStartScheduledFasting==YES 时的预约起始时间。VC 直接传给 startFastingWithPlan:startDate:。
@property (nonatomic, strong, nullable) NSDate *scheduledFireDate;

/// 工厂方法：基于当前 [FSTSessionManager sharedManager] 状态推导 ReadyDisplayState。
/// @param plan 当前选中的计划（由 VC 传入，通常 = sessionManager.currentPlan）。其 eatingHours 用于吃窗口换算。
/// @return 完整快照。
+ (instancetype)stateForPlan:(FSTPlan *)plan;

@end

NS_ASSUME_NONNULL_END
