//
//  FSTActiveFastingDisplayState.m
//  Fasting
//

#import "FSTActiveFastingDisplayState.h"
#import "FSTSessionManager.h"
#import "FSTFastingTimingService.h"
#import "FSTTheme.h"
#import "UIColor+FST.h"

@implementation FSTActiveFastingDisplayState

+ (instancetype)currentStateWithDisplayMode:(FSTRingDisplayMode)displayMode {
    FSTActiveFastingDisplayState *state = [FSTActiveFastingDisplayState new];
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];

    // 兜底：VC 收到通知或 timer tick 时可能恰好处于"plan 已被清空但 VC 尚未 pop"的瞬态。
    // 此时返回 sessionInvalid=YES 让 VC 的 -applyDisplayState: 早退，避免后续读 nil 字段崩。
    if (![sessionManager hasActiveFasting]) {
        state.sessionInvalid = YES;
        return state;
    }

    FSTFastingTiming *timing = [FSTFastingTimingService timingForElapsedSeconds:sessionManager.elapsedSeconds
                                                         targetDurationSeconds:sessionManager.activeTargetDurationSeconds];

    BOOL isRemainingMode = displayMode == FSTRingDisplayRemaining;
    NSInteger displayedPercent = isRemainingMode ? timing.remainingPercent : timing.elapsedPercent;

    // 圆环三态判定优先级：overtime > complete > active。
    // overtime 先判是因为它的视觉（红环 + "+HH:MM:SS"）需要覆盖 complete 的视觉（绿环 + "100%"）。
    // 用户已超出目标时，更需要被提示「你已超时」而不是「已完成」。
    FSTRingPresentationState ringState = FSTRingPresentationActive;
    if (timing.overtime) {
        ringState = FSTRingPresentationOvertime;
    } else if (timing.targetReached) {
        ringState = FSTRingPresentationComplete;
    }

    NSTimeInterval targetSeconds = MAX(1, sessionManager.activeTargetDurationSeconds);
    NSDate *startDate = sessionManager.activeStartDate ?: [NSDate date];
    NSDate *endDate   = [sessionManager activeExpectedEndDate] ?: [startDate dateByAddingTimeInterval:targetSeconds];

    BOOL targetReached = (ringState == FSTRingPresentationComplete || ringState == FSTRingPresentationOvertime);

    state.ringState     = ringState;
    state.targetReached = targetReached;

    // Ring panel
    state.timerCaption = (ringState != FSTRingPresentationActive)
        ? @"Time exceeded"
        : [NSString stringWithFormat:@"%@ %ld%%",
           isRemainingMode ? @"Remaining time" : @"Elapsed time",
           (long)displayedPercent];

    if (ringState == FSTRingPresentationComplete) {
        state.timerText = @"100%";
    } else if (ringState == FSTRingPresentationOvertime) {
        state.timerText = [NSString stringWithFormat:@"+%@", FSTFormatHHMMSS(timing.overtimeSeconds)];
    } else {
        state.timerText = FSTFormatHHMMSS(isRemainingMode ? timing.remainingSeconds : timing.elapsedSeconds);
    }

    state.overtimeDetailText = timing.overtime ? [NSString stringWithFormat:@"Elapsed time (%ld%%)", (long)timing.overtimePercent] : nil;
    state.overtimeTotalText  = timing.overtime ? FSTFormatHHMMSS(timing.elapsedSeconds) : nil;
    state.endText            = FSTFormatRelativeDateTime(endDate);
    state.percentText        = [NSString stringWithFormat:@"%ld%%", (long)displayedPercent];
    state.planName           = sessionManager.currentPlan.name ?: @"14-10";
    state.ringProgress       = timing.targetReached ? 1.0 : timing.elapsedClampedFraction;
    state.flameProgress      = timing.elapsedClampedFraction;

    // Times row
    state.startText  = FSTFormatRelativeDateTime(startDate);
    state.endTimeText = FSTFormatRelativeDateTime(endDate);

    // Phase + tips
    state.showAutophagyPhase = targetReached;
    state.tipsStage          = targetReached ? FSTTipsFastingStageAfter : FSTTipsFastingStageDuring;

    // Stop button — 用户视角的语义分叉：
    // 未达标点击 = 放弃断食（END，灰底，进入"是否放弃"确认弹窗）；
    // 达标点击 = 完成断食（COMPLETE，绿底，直接跳到 AddRecord 填写感受）。
    // 配色与标题成对切换，确保用户在两个场景中都能一眼分辨。
    state.stopButtonTitle           = targetReached ? @"COMPLETE FASTING" : @"END FASTING";
    state.stopButtonBackgroundColor = targetReached ? [UIColor fst_eatingTimeGreen] : [UIColor fst_colorWithHex:0xE3E5EA];
    state.stopButtonTitleColor      = targetReached ? [UIColor whiteColor] : [UIColor fst_colorWithHex:0x272A33];

    return state;
}

@end
