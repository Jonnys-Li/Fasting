//
//  FSTSessionManager.m
//  Fasting
//
//  本类只负责单例持有状态字段；具体业务拆给协作类：
//    - 持久化  → FSTSessionPersistenceService（NSUserDefaults 读写、key 常量集中）
//    - 生命周期 → FSTSessionLifecycleService（start / cancel / finish / edit 等所有 mutation）
//    - 下次起点 → FSTNextFastService（nextFastingStartDate 推导）
//
//  Property 私有 readwrite 暴露在 FSTSessionManager+Internal.h，只允许上述 service 引入。
//  写入约定保持不变：mutation 走 -persistAllStateAndNotifySession，发 FSTSessionDidChangeNotification。
//

#import "FSTSessionManager.h"
#import "FSTSessionManager+Internal.h"
#import "FSTSessionPersistenceService.h"
#import "FSTSessionLifecycleService.h"
#import "FSTNextFastService.h"

NSNotificationName const FSTSessionDidChangeNotification = @"FSTSessionDidChangeNotification";

@implementation FSTSessionManager

+ (instancetype)sharedManager {
    static FSTSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [FSTSessionManager new];
        [manager loadFromDefaults];
    });
    return manager;
}

#pragma mark - Persistence

- (void)loadFromDefaults {
    [FSTSessionPersistenceService loadSession:self];
}

- (void)setPreferredWeightUnit:(FSTWeightUnit)preferredWeightUnit {
    _preferredWeightUnit = preferredWeightUnit;
    [FSTSessionPersistenceService setPreferredWeightUnit:preferredWeightUnit];
}

- (void)persistAllState {
    [FSTSessionPersistenceService saveAllForSession:self];
}

- (void)persistAllStateAndNotifySession {
    [self persistAllState];
    [[NSNotificationCenter defaultCenter] postNotificationName:FSTSessionDidChangeNotification object:self];
}

#pragma mark - Active state (纯派生 getter，无副作用)

- (BOOL)hasActiveFasting {
    return self.activeStartDate != nil && self.currentPlan != nil;
}

- (NSTimeInterval)targetDurationSeconds {
    if (!self.currentPlan) return 0;
    return self.currentPlan.fastingHours * 3600.0;
}

- (NSTimeInterval)activeTargetDurationSeconds {
    if (!self.activeStartDate) return [self targetDurationSeconds];
    NSDate *expectedEndDate = [self activeExpectedEndDate];
    if (!expectedEndDate) return [self targetDurationSeconds];
    return MAX(1.0, [expectedEndDate timeIntervalSinceDate:self.activeStartDate]);
}

- (NSTimeInterval)elapsedSeconds {
    if (!self.activeStartDate) return 0;
    return [[NSDate date] timeIntervalSinceDate:self.activeStartDate];
}

- (CGFloat)elapsedFraction {
    NSTimeInterval target = [self activeTargetDurationSeconds];
    if (target <= 0) return 0;
    return (CGFloat)([self elapsedSeconds] / target);
}

- (NSDate *)activeExpectedEndDate {
    if (!self.activeStartDate) return nil;
    if (self.activeEndOverrideDate) return self.activeEndOverrideDate;
    NSTimeInterval target = [self targetDurationSeconds];
    if (target <= 0) return nil;
    return [self.activeStartDate dateByAddingTimeInterval:target];
}

- (BOOL)isActiveFastingAlignedWithPlan {
    return self.activeEndOverrideDate == nil;
}

#pragma mark - Lifecycle (mutation 全部委托给 FSTSessionLifecycleService)

- (void)startFastingWithPlan:(FSTPlan *)plan startDate:(NSDate *)date {
    [FSTSessionLifecycleService startSession:self plan:plan startDate:date];
}

- (void)cancelActiveFasting {
    [FSTSessionLifecycleService cancelSession:self];
}

- (void)finishFastingWithRecord:(FSTFastingRecord *)record {
    [FSTSessionLifecycleService finishSession:self record:record];
}

- (void)clearCurrentPlan {
    [FSTSessionLifecycleService clearPlanForSession:self];
}

- (void)switchToPlanPreservingState:(FSTPlan *)plan {
    [FSTSessionLifecycleService switchSession:self toPlan:plan];
}

- (void)markScheduledReadyWithSource:(FSTScheduledReadySource)source anchorDate:(NSDate *)anchorDate {
    [FSTSessionLifecycleService markSession:self scheduledReadyWithSource:source anchorDate:anchorDate];
}

- (void)clearScheduledReadyState {
    [FSTSessionLifecycleService clearScheduledReadyForSession:self];
}

- (void)beginEatingWindowFromDate:(NSDate *)date {
    [FSTSessionLifecycleService beginEatingWindowForSession:self fromDate:date];
}

- (void)scheduleFastingAtFutureDate:(NSDate *)futureDate source:(FSTScheduledReadySource)source {
    [FSTSessionLifecycleService scheduleSession:self atFutureDate:futureDate source:source];
}

- (void)editActiveStartDate:(NSDate *)date {
    [self editActiveStartDate:date alignWithPlan:YES];
}

- (void)editActiveStartDate:(NSDate *)date alignWithPlan:(BOOL)alignWithPlan {
    [FSTSessionLifecycleService editStartForSession:self date:date alignWithPlan:alignWithPlan];
}

- (void)editActiveEndDate:(NSDate *)date alignWithPlan:(BOOL)alignWithPlan {
    [FSTSessionLifecycleService editEndForSession:self date:date alignWithPlan:alignWithPlan];
}

#pragma mark - 一次性 token

- (void)requestActiveStartDatePrompt {
    self.pendingActiveStartDatePrompt = YES;
}

- (BOOL)consumeActiveStartDatePromptRequest {
    BOOL shouldPrompt = self.pendingActiveStartDatePrompt;
    self.pendingActiveStartDatePrompt = NO;
    return shouldPrompt;
}

#pragma mark - Next fast start derivation

- (NSDate *)nextFastingStartDate {
    return [FSTNextFastService nextStartDateForSession:self];
}

- (NSDate *)nextFastingStartCountdownAnchorDate {
    return [FSTSessionPersistenceService nextStartOverrideAnchorDate];
}

- (void)setNextFastingStartDate:(NSDate *)date {
    [FSTSessionPersistenceService setNextStartOverrideDate:date];
    [[NSNotificationCenter defaultCenter] postNotificationName:FSTSessionDidChangeNotification object:self];
}

@end
