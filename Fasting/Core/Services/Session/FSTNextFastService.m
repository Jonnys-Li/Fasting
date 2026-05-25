//
//  FSTNextFastService.m
//  Fasting
//
//  集中"下一次断食起点"的推导，被 [FSTSessionManager nextFastingStartDate] 调用。
//  调用方还包括 FSTDailyPlanReadyDisplayState（在 ready 子态决定何时自动起始）。
//

#import "FSTNextFastService.h"
#import "FSTSessionManager+Internal.h"
#import "FSTSessionPersistenceService.h"
#import "FSTRecordsRepository.h"
#import "FSTPlan.h"

@implementation FSTNextFastService

/// 推导下一次断食起点。
/// 优先级（自上而下，命中即返）：
///   1) override   — 用户在 Plan 页 Schedule 了具体时间（FSTNextStartOverrideKey）；
///   2) fastingEnd — 最近一次断食结束时刻（用户刚结束，要重新进入吃窗口）；
///   3) mealDate   — 没断食历史时退化到最近一餐；
///   4) anchor     — 都没有则用 eatingWindowAnchorDate（前一次清 session 时设置）；
///   5) now        — 兜底，并写回 anchor 防止后续推导漂移。
/// 然后再叠加：若 mealDate 比 anchor 新，则用 mealDate 顶替 anchor（用户在吃窗口里又吃了一餐，
/// 吃窗口实际应该从最后一餐算起，否则会出现"早就该开始断食了"的误导）。
/// 最后 + plan.eatingHours 得到 next start。
+ (NSDate *)nextStartDateForSession:(FSTSessionManager *)session {
    if (!session.currentPlan) return nil;
    NSDate *override = [FSTSessionPersistenceService nextStartOverrideDate];
    if (override) return override;

    FSTRecordsRepository *repository = [FSTRecordsRepository sharedRepository];
    NSDate *mealDate = [repository latestMealDate];
    NSDate *fastingEndDate = [repository latestFastingEndDate];
    NSDate *anchor = fastingEndDate ?: mealDate ?: session.eatingWindowAnchorDate;
    if (!anchor) {
        anchor = [NSDate date];
        session.eatingWindowAnchorDate = anchor;
        [FSTSessionPersistenceService saveEatingWindowAnchorForSession:session];
    }
    if (mealDate && [mealDate compare:anchor] == NSOrderedDescending) {
        anchor = mealDate;
    }
    return [anchor dateByAddingTimeInterval:session.currentPlan.eatingHours * 3600.0];
}

@end
