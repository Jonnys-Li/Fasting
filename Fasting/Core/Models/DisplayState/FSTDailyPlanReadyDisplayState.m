//
//  FSTDailyPlanReadyDisplayState.m
//  Fasting
//

#import "FSTDailyPlanReadyDisplayState.h"
#import "FSTSessionManager.h"
#import "FSTRecordsRepository.h"
#import "FSTEatingWindowService.h"
#import "FSTPlan.h"
#import "FSTTheme.h"

@implementation FSTDailyPlanReadyDisplayState

+ (instancetype)stateForPlan:(FSTPlan *)plan {
    FSTDailyPlanReadyDisplayState *state = [FSTDailyPlanReadyDisplayState new];
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    NSDate *now = [NSDate date];
    NSDate *nextStartDate = [sessionManager nextFastingStartDate];

    FSTEatingWindowState *windowState =
        [FSTEatingWindowService stateForPlan:plan
                               nextStartDate:nextStartDate
                           latestFastEndDate:[[FSTRecordsRepository sharedRepository] latestFastingEndDate]
                               referenceDate:now];

    // 三态判定优先级：scheduledCountdown > readyAfterEating > 默认 eatingWindow。
    // scheduledCountdown 先判：用户显式 Schedule 了一个未来 startDate（写入 scheduledReadySource），
    //   此时即便 windowState.readyToStart=YES（吃窗口实际已耗尽），也要保留倒计时视觉而非进入"可开始"态。
    // readyAfterEating 表示吃窗口自然耗尽到达可开始时刻，但用户未主动 Schedule —— UI 上是 CTA 高亮等待用户决定。
    // compactLayout 在前两种态下都为 YES：让圆环上移、隐藏 breaking fast 卡，集中视觉到"准备开始"。
    BOOL scheduledCountdown = sessionManager.scheduledReadySource != FSTScheduledReadySourceNone &&
                              nextStartDate != nil &&
                              [nextStartDate compare:now] == NSOrderedDescending;
    BOOL readyAfterEating = !scheduledCountdown && windowState.readyToStart;
    BOOL compactLayout = scheduledCountdown || readyAfterEating;

    state.titleText = scheduledCountdown ? @"Ready to start fasting!"
                                         : (readyAfterEating ? @"Ready to start fasting?" : @"Eating Time");
    state.ringPresentationState = scheduledCountdown ? FSTDailyPlanReadyRingPresentationScheduledCountdown
                                : (readyAfterEating ? FSTDailyPlanReadyRingPresentationReadyToStartFasting
                                                    : FSTDailyPlanReadyRingPresentationEatingWindow);
    state.elapsedText           = FSTFormatHHMMSS(windowState.elapsedSeconds);
    state.ringProgress          = scheduledCountdown ? [self scheduledProgressForStartDate:nextStartDate referenceDate:now]
                                                     : windowState.progress;
    state.remainingText         = FSTFormatHHMMSS(scheduledCountdown ? [nextStartDate timeIntervalSinceDate:now]
                                                                     : windowState.remainingSeconds);
    state.timeSinceLastFastText = FSTFormatHHMMSS(windowState.timeSinceLastFastSeconds);
    state.nextFastStartText     = FSTFormatRelativeDateTime(windowState.nextStartDate);
    state.nextFastEndText       = FSTFormatRelativeDateTime(windowState.nextEndDate);
    state.primaryActionMode     = scheduledCountdown ? FSTDailyPlanReadyPrimaryActionAbortPlan
                                                     : FSTDailyPlanReadyPrimaryActionStartFasting;

    state.compactLayout         = compactLayout;

    // 自动起始判定 — 把原本散在 VC.refreshReadyState 的"每秒重判调度是否触发"逻辑收敛到工厂里。
    // 条件：已 scheduled && nextStartDate 已到达/越过 now && plan 存在。
    // plan 缺失时 shouldAutoStartScheduledFasting = NO，让 VC 在下一次 reload 自动落回 Picker。
    BOOL fireDue = sessionManager.scheduledReadySource != FSTScheduledReadySourceNone &&
                   nextStartDate != nil &&
                   [nextStartDate compare:now] != NSOrderedDescending &&
                   plan != nil;
    state.shouldAutoStartScheduledFasting = fireDue;
    state.scheduledFireDate               = fireDue ? nextStartDate : nil;

    return state;
}

/// 计算 ScheduledCountdown 态下圆环的填充进度 [0, 1]。
/// 业务语义：从"用户按下 Schedule 那一刻（anchorDate）"到"目标 startDate"之间走过了多少。
/// 用户视角：圆环从空到满 = 等待时间被消耗的可视化反馈。
/// - anchorDate 由 [FSTSessionManager markScheduledReadyWithSource:anchorDate:] 写入；缺失时退化为 now（进度立即为 1）。
/// - total 用 MAX(1, …) 防止 startDate==anchorDate 时除零。
/// - elapsed 用 MAX(0, …) 防止参考时间早于 anchor（理论上不会发生，但 Defensive）。
+ (CGFloat)scheduledProgressForStartDate:(NSDate *)startDate referenceDate:(NSDate *)referenceDate {
    if (!startDate) return 0;
    NSDate *anchorDate = [FSTSessionManager sharedManager].scheduledReadyAnchorDate ?: referenceDate;
    NSTimeInterval total = MAX(1.0, [startDate timeIntervalSinceDate:anchorDate]);
    NSTimeInterval elapsed = MAX(0, [referenceDate timeIntervalSinceDate:anchorDate]);
    return (CGFloat)MIN(1.0, elapsed / total);
}

@end
