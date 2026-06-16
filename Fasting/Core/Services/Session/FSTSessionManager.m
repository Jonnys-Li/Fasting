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
//  写入约定保持不变：mutation 走 -persistAllState（统一持久化）。
//

#import "FSTSessionManager.h"
#import "FSTSessionManager+Internal.h"
#import "FSTSessionPersistenceService.h"
#import "FSTSessionLifecycleService.h"
#import "FSTNextFastService.h"

@interface FSTSessionManager ()
/// 所有会话字段的真正存储（R14）。公开只读 / +Internal readwrite 的字段属性全部转发到这里。
@property (nonatomic, strong) FSTSessionState *state;
@end

@implementation FSTSessionManager

+ (instancetype)sharedManager {
    static FSTSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FSTSessionManager alloc] init];
    });
    return manager;
}

#pragma mark - Persistence

- (instancetype)init {
    if (self = [super init]) {
        // state 必须先于 loadSession 建好：下面所有字段 setter 都转发到 self.state，
        // 若此时 state 为 nil，load 写入会 message nil 而静默丢值。
        self.state = [[FSTSessionState alloc] init];
        [FSTSessionPersistenceService loadSession:self];
    }
    return self;
}

- (void)persistAllState {
    [FSTSessionPersistenceService saveAllForSession:self];
}

#pragma mark - 字段存储转发（R14：真正存储在 FSTSessionState，本类只转发）

- (FSTPlan *)currentPlan {
    return self.state.currentPlan;
}

- (void)setCurrentPlan:(FSTPlan *)currentPlan {
    self.state.currentPlan = currentPlan;
}

- (BOOL)hasCompletedOnboarding {
    return self.state.hasCompletedOnboarding;
}

- (void)setHasCompletedOnboarding:(BOOL)hasCompletedOnboarding {
    self.state.hasCompletedOnboarding = hasCompletedOnboarding;
}

- (NSDate *)activeStartDate {
    return self.state.activeStartDate;
}

- (void)setActiveStartDate:(NSDate *)activeStartDate {
    self.state.activeStartDate = activeStartDate;
}

- (NSDate *)activeEndOverrideDate {
    return self.state.activeEndOverrideDate;
}

- (void)setActiveEndOverrideDate:(NSDate *)activeEndOverrideDate {
    self.state.activeEndOverrideDate = activeEndOverrideDate;
}

- (NSDate *)eatingWindowAnchorDate {
    return self.state.eatingWindowAnchorDate;
}

- (void)setEatingWindowAnchorDate:(NSDate *)eatingWindowAnchorDate {
    self.state.eatingWindowAnchorDate = eatingWindowAnchorDate;
}

- (FSTScheduledReadySource)scheduledReadySource {
    return self.state.scheduledReadySource;
}

- (void)setScheduledReadySource:(FSTScheduledReadySource)scheduledReadySource {
    self.state.scheduledReadySource = scheduledReadySource;
}

- (NSDate *)scheduledReadyAnchorDate {
    return self.state.scheduledReadyAnchorDate;
}

- (void)setScheduledReadyAnchorDate:(NSDate *)scheduledReadyAnchorDate {
    self.state.scheduledReadyAnchorDate = scheduledReadyAnchorDate;
}

- (BOOL)pendingActiveStartDatePrompt {
    return self.state.pendingActiveStartDatePrompt;
}

- (void)setPendingActiveStartDatePrompt:(BOOL)pendingActiveStartDatePrompt {
    self.state.pendingActiveStartDatePrompt = pendingActiveStartDatePrompt;
}

- (FSTWeightUnit)preferredWeightUnit {
    return self.state.preferredWeightUnit;
}

- (void)setPreferredWeightUnit:(FSTWeightUnit)preferredWeightUnit {
    self.state.preferredWeightUnit = preferredWeightUnit;
    [FSTSessionPersistenceService setPreferredWeightUnit:preferredWeightUnit];
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

- (void)scheduleFastingAtFutureDate:(NSDate *)futureDate source:(FSTScheduledReadySource)source {
    [FSTSessionLifecycleService scheduleSession:self atFutureDate:futureDate source:source];
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
}

@end
