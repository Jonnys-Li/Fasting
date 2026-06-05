//
//  FSTDailyPlanReadyDisplayState.m
//  Fasting
//

#import "FSTDailyPlanReadyDisplayState.h"
#import "FSTSessionManager.h"
#import "FSTRecordsRepository.h"
#import "FSTPlan.h"
// 刻意不 import FSTTheme：格式化交给 VC，本对象保持纯 Foundation + Core（不引 Masonry），可单测。

@interface FSTDailyPlanReadyDisplayState ()
@property (nonatomic, assign, readwrite) BOOL shouldAutoStartNow;
@property (nonatomic, strong, readwrite, nullable) NSDate *autoStartDate;
@property (nonatomic, assign, readwrite) FSTDailyPlanReadyRingPresentationState presentationState;
@property (nonatomic, assign, readwrite) BOOL compactLayout;
@property (nonatomic, copy, readwrite) NSString *titleText;
@property (nonatomic, assign, readwrite) CGFloat ringProgress;
@property (nonatomic, assign, readwrite) FSTDailyPlanReadyPrimaryActionMode primaryActionMode;
@property (nonatomic, assign, readwrite) FSTTipsFastingStage tipsStage;
@property (nonatomic, assign, readwrite) NSTimeInterval elapsedSeconds;
@property (nonatomic, assign, readwrite) NSTimeInterval remainingSeconds;
@property (nonatomic, assign, readwrite) NSTimeInterval timeSinceLastFastSeconds;
@property (nonatomic, strong, readwrite) NSDate *nextFastStartDate;
@property (nonatomic, strong, readwrite) NSDate *nextFastEndDate;
@end

@implementation FSTDailyPlanReadyDisplayState

+ (instancetype)stateForSessionManager:(FSTSessionManager *)sessionManager
                     recordsRepository:(FSTRecordsRepository *)recordsRepository
                                   now:(NSDate *)now {
    FSTDailyPlanReadyDisplayState *state = [[FSTDailyPlanReadyDisplayState alloc] init];

    FSTPlan *plan = sessionManager.currentPlan;
    NSDate *nextStartDate = [sessionManager nextFastingStartDate];

    // 预约到点自动起始：scheduled && nextStartDate <= now && plan 存在。
    // 命中即短路 —— 其余展示字段无意义，由 VC 读 shouldAutoStartNow 执行副作用。
    BOOL scheduled = (sessionManager.scheduledReadySource != FSTScheduledReadySourceNone) && (nextStartDate != nil);
    if (scheduled && plan != nil && [nextStartDate compare:now] != NSOrderedDescending) {
        state.shouldAutoStartNow = YES;
        state.autoStartDate = nextStartDate;
        return state;
    }

    // 吃窗口推导 —— 基于 plan.eatingHours / fastingHours 与 nextStart/latestEnd 时刻（plan 为 nil 时走兜底）。
    NSTimeInterval eatingHours  = plan.eatingHours  > 0 ? plan.eatingHours  : 10.0;
    NSTimeInterval fastingHours = plan.fastingHours > 0 ? plan.fastingHours : 14.0;
    NSTimeInterval eatingWindowSeconds  = MAX(1, eatingHours  * 3600.0);
    NSTimeInterval fastingWindowSeconds = MAX(1, fastingHours * 3600.0);
    NSDate *resolvedNextStart = nextStartDate ?: [now dateByAddingTimeInterval:eatingWindowSeconds];
    NSDate *windowStartDate   = [resolvedNextStart dateByAddingTimeInterval:-eatingWindowSeconds];
    NSDate *resolvedNextEnd   = [resolvedNextStart dateByAddingTimeInterval:fastingWindowSeconds];
    NSTimeInterval elapsed    = MAX(0, [now timeIntervalSinceDate:windowStartDate]);
    NSTimeInterval remaining  = MAX(0, [resolvedNextStart timeIntervalSinceDate:now]);
    BOOL readyToStart         = remaining <= 0.0;
    NSDate *latestFastEnd = [recordsRepository latestFastingEndDate] ?: windowStartDate;
    // 可开始态以 nextStart 为基准衡量"已超时多久"；普通态以 latestFastEnd 为基准。
    NSTimeInterval timeSinceLastFast = readyToStart
        ? MAX(0, [now timeIntervalSinceDate:resolvedNextStart])
        : MAX(0, [now timeIntervalSinceDate:latestFastEnd]);
    CGFloat windowProgress = (CGFloat)MIN(1.0, elapsed / eatingWindowSeconds);

    // 三态判定 → 收敛为单一 presentationState（scheduledCountdown 优先：即便吃窗口耗尽也保留倒计时视觉）。
    BOOL scheduledCountdown = scheduled && [nextStartDate compare:now] == NSOrderedDescending;
    BOOL readyAfterEating   = !scheduledCountdown && readyToStart;
    FSTDailyPlanReadyRingPresentationState presentationState =
        scheduledCountdown ? FSTDailyPlanReadyRingPresentationScheduledCountdown
      : (readyAfterEating  ? FSTDailyPlanReadyRingPresentationReadyToStartFasting
                           : FSTDailyPlanReadyRingPresentationEatingWindow);

    // 环进度 elapsed 基准：手动改过 nextStart 时按本轮 anchor→start 倒计时算（仅普通/可开始态）。
    NSDate *countdownAnchorDate = [sessionManager nextFastingStartCountdownAnchorDate];
    BOOL usesManualCountdownProgress = !scheduledCountdown &&
                                       countdownAnchorDate != nil &&
                                       [resolvedNextStart compare:countdownAnchorDate] == NSOrderedDescending;
    NSTimeInterval ringElapsed = usesManualCountdownProgress
        ? MAX(0, [now timeIntervalSinceDate:countdownAnchorDate])
        : elapsed;
    CGFloat ringProgress = windowProgress;
    if (usesManualCountdownProgress) {
        NSTimeInterval countdownTotal = MAX(1.0, [resolvedNextStart timeIntervalSinceDate:countdownAnchorDate]);
        ringProgress = (CGFloat)MIN(1.0, ringElapsed / countdownTotal);
    }
    // scheduledCountdown 环进度走 anchorDate→startDate 线性比例（覆盖上面的吃窗/手动算法）。
    if (scheduledCountdown) {
        ringProgress = [self scheduledProgressForStartDate:nextStartDate
                                             referenceDate:now
                                                anchorDate:sessionManager.scheduledReadyAnchorDate];
    }

    state.presentationState = presentationState;
    state.compactLayout     = (presentationState != FSTDailyPlanReadyRingPresentationEatingWindow);
    state.ringProgress      = ringProgress;
    state.elapsedSeconds    = ringElapsed;
    state.remainingSeconds  = scheduledCountdown ? [nextStartDate timeIntervalSinceDate:now] : remaining;
    state.timeSinceLastFastSeconds = timeSinceLastFast;
    state.nextFastStartDate = resolvedNextStart;
    state.nextFastEndDate   = resolvedNextEnd;

    // 标题 / 主按钮 / Tips 阶段：纯按 presentationState 分派（EatingWindow 与 ReadyToStart 的 Tips 都映射 After）。
    switch (presentationState) {
        case FSTDailyPlanReadyRingPresentationScheduledCountdown:
            state.titleText         = @"Ready to start fasting!";
            state.primaryActionMode = FSTDailyPlanReadyPrimaryActionAbortPlan;
            state.tipsStage         = FSTTipsFastingStagePrepare;
            break;
        case FSTDailyPlanReadyRingPresentationReadyToStartFasting:
            state.titleText         = @"Ready to start fasting?";
            state.primaryActionMode = FSTDailyPlanReadyPrimaryActionStartFasting;
            state.tipsStage         = FSTTipsFastingStageAfter;
            break;
        case FSTDailyPlanReadyRingPresentationEatingWindow:
            state.titleText         = @"Eating Time";
            state.primaryActionMode = FSTDailyPlanReadyPrimaryActionStartFasting;
            state.tipsStage         = FSTTipsFastingStageAfter;
            break;
    }

    return state;
}

/// ScheduledCountdown 圆环进度：从 anchorDate 到 startDate 的线性比例。
+ (CGFloat)scheduledProgressForStartDate:(nullable NSDate *)startDate
                           referenceDate:(NSDate *)referenceDate
                              anchorDate:(nullable NSDate *)anchorDate {
    if (!startDate) return 0;
    NSDate *anchor = anchorDate ?: referenceDate;
    NSTimeInterval total = MAX(1.0, [startDate timeIntervalSinceDate:anchor]);
    NSTimeInterval elapsed = MAX(0, [referenceDate timeIntervalSinceDate:anchor]);
    return (CGFloat)MIN(1.0, elapsed / total);
}

@end
