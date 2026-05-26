//
//  FSTSessionLifecycleService.m
//  Fasting
//
//  集中 SessionManager 所有 mutation：start / cancel / finish / clear / switch / scheduleReady /
//  beginEatingWindow / schedule / edit start / edit end。每个方法直接改 session 字段后调用
//  -persistAllState。重点跨域逻辑（如 finish 写 record + 清字段）的注释保留。
//

#import "FSTSessionLifecycleService.h"
#import "FSTSessionManager+Internal.h"
#import "FSTSessionPersistenceService.h"
#import "FSTRecordsRepository.h"
#import "FSTFastingRecord.h"
#import "FSTPlan.h"

@implementation FSTSessionLifecycleService

/// 开始一次新的断食。调用方：PlanConfirm 页点 START、ActiveFasting 页 Reset 起点等。
/// 做 4 件事：
///   1) 切 plan + 起点（startDate 为 nil 时用 now 兜底）；
///   2) 清 endOverride — 本次按 plan 默认对齐 endDate；
///   3) 清 scheduledReady 与 eatingWindowAnchor — 避免上一次预约/吃窗口状态残留干扰新 session；
///   4) 移除 nextStartOverride — 让吃窗口下一次推导回到默认逻辑。
+ (void)startSession:(FSTSessionManager *)session plan:(FSTPlan *)plan startDate:(NSDate *)date {
    session.currentPlan = plan;
    session.activeStartDate = date ?: [NSDate date];
    session.activeEndOverrideDate = nil;
    session.eatingWindowAnchorDate = nil;
    session.hasCompletedOnboarding = YES;
    session.scheduledReadySource = FSTScheduledReadySourceNone;
    session.scheduledReadyAnchorDate = nil;
    [FSTSessionPersistenceService clearNextStartOverride];
    [session persistAllState];
}

+ (void)cancelSession:(FSTSessionManager *)session {
    session.activeStartDate = nil;
    session.activeEndOverrideDate = nil;
    session.eatingWindowAnchorDate = [NSDate date];
    [session persistAllState];
}

/// 断食完成路径。调用方：AddRecord 页点保存。
/// 顺序很关键：
///   1) 先写 records — Repository 内部发 FSTRecordsDidChangeNotification，
///      History/Timeline/MealDiary 这些只关心列表的页面立即刷新；
///   2) 清空 active 字段；
///   3) eatingWindowAnchorDate = endDate（或 now 兜底）— 作为吃窗口"0 分钟"起点，
///      让 FSTEatingWindowService 的 elapsed 从结束时刻开始算；
///   4) 清 scheduledReady — 防止下一轮吃窗口继承上次的预约残留状态；
///   5) 统一 persist — DailyPlan VC 通过 viewWillAppear / refreshTimer 在切回时自动切到 Eating Time 视图。
+ (void)finishSession:(FSTSessionManager *)session record:(FSTFastingRecord *)record {
    if (record) {
        if (!record.recordID.length) record.recordID = [[NSUUID UUID] UUIDString];
        [[FSTRecordsRepository sharedRepository] updateFastingRecord:record];
    }
    session.activeStartDate = nil;
    session.activeEndOverrideDate = nil;
    session.eatingWindowAnchorDate = record.endDate ?: [NSDate date];
    session.scheduledReadySource = FSTScheduledReadySourceNone;
    session.scheduledReadyAnchorDate = nil;
    [session persistAllState];
}

+ (void)clearPlanForSession:(FSTSessionManager *)session {
    session.currentPlan = nil;
    session.activeStartDate = nil;
    session.activeEndOverrideDate = nil;
    session.eatingWindowAnchorDate = nil;
    session.hasCompletedOnboarding = NO;
    session.scheduledReadySource = FSTScheduledReadySourceNone;
    session.scheduledReadyAnchorDate = nil;
    [FSTSessionPersistenceService clearNextStartOverride];
    [session persistAllState];
}

+ (void)switchSession:(FSTSessionManager *)session toPlan:(FSTPlan *)plan {
    if (!plan) return;
    session.currentPlan = plan;
    session.activeEndOverrideDate = nil;
    session.hasCompletedOnboarding = YES;
    [session persistAllState];
}

+ (void)markSession:(FSTSessionManager *)session
scheduledReadyWithSource:(FSTScheduledReadySource)source
         anchorDate:(NSDate *)anchorDate {
    if (source == FSTScheduledReadySourceNone) {
        [self clearScheduledReadyForSession:session];
        return;
    }
    session.scheduledReadySource = source;
    session.scheduledReadyAnchorDate = anchorDate ?: [NSDate date];
    session.hasCompletedOnboarding = YES;
    [session persistAllState];
}

+ (void)clearScheduledReadyForSession:(FSTSessionManager *)session {
    if (session.scheduledReadySource == FSTScheduledReadySourceNone && !session.scheduledReadyAnchorDate) return;
    session.scheduledReadySource = FSTScheduledReadySourceNone;
    session.scheduledReadyAnchorDate = nil;
    [session persistAllState];
}

+ (void)beginEatingWindowForSession:(FSTSessionManager *)session fromDate:(NSDate *)date {
    session.activeStartDate = nil;
    session.activeEndOverrideDate = nil;
    session.eatingWindowAnchorDate = date ?: [NSDate date];
    session.scheduledReadySource = FSTScheduledReadySourceNone;
    session.scheduledReadyAnchorDate = nil;
    session.hasCompletedOnboarding = YES;
    [FSTSessionPersistenceService clearNextStartOverride];
    [session persistAllState];
}

+ (void)scheduleSession:(FSTSessionManager *)session
           atFutureDate:(NSDate *)futureDate
                 source:(FSTScheduledReadySource)source {
    if (!futureDate) return;
    [self cancelSession:session];
    [session setNextFastingStartDate:futureDate];
    [self markSession:session scheduledReadyWithSource:source anchorDate:[NSDate date]];
}

/// 编辑活跃断食的 Start 时刻 — 双模式：
///   alignWithPlan=YES：擦掉 endOverride，end 跟随 plan 自动对齐到 newStart + plan.fastingHours。
///   alignWithPlan=NO ：保留用户的自定义 end —— 但要先快照当前的 expectedEnd，否则改 start 后再写 nil end 会回退到 plan 默认。
/// 两种模式都强制 end ≥ start + 60s，防止用户拉成零长度断食（视觉/逻辑都崩）。
+ (void)editStartForSession:(FSTSessionManager *)session
                       date:(NSDate *)date
              alignWithPlan:(BOOL)alignWithPlan {
    if (!date || !session.hasActiveFasting) return;
    NSDate *currentExpectedEndDate = [session activeExpectedEndDate];

    session.activeStartDate = date;
    if (alignWithPlan) {
        session.activeEndOverrideDate = nil;
    } else {
        NSDate *expectedEndDate = currentExpectedEndDate ?: [date dateByAddingTimeInterval:[session targetDurationSeconds]];
        NSDate *minimumEndDate = [date dateByAddingTimeInterval:60.0];
        session.activeEndOverrideDate = [expectedEndDate compare:minimumEndDate] == NSOrderedAscending ? minimumEndDate : expectedEndDate;
    }
    [session persistAllState];
}

/// 编辑活跃断食的 End 时刻 — 双模式：
///   alignWithPlan=YES：清掉 override，让 end 回到 plan 默认（startDate + plan.fastingHours）。
///   alignWithPlan=NO ：把 end 锁定为用户输入；同样强制 end ≥ start + 60s 防零长度。
+ (void)editEndForSession:(FSTSessionManager *)session
                     date:(NSDate *)date
            alignWithPlan:(BOOL)alignWithPlan {
    if (!date || !session.hasActiveFasting || !session.activeStartDate) return;
    if (alignWithPlan) {
        session.activeEndOverrideDate = nil;
    } else {
        NSDate *minimumEndDate = [session.activeStartDate dateByAddingTimeInterval:60.0];
        session.activeEndOverrideDate = [date compare:minimumEndDate] == NSOrderedAscending ? minimumEndDate : date;
    }
    [session persistAllState];
}

@end
