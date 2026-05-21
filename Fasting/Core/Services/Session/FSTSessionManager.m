//
//  FSTSessionManager.m
//  Fasting
//

#import "FSTSessionManager.h"
#import "FSTFastingRecord+Persistence.h"
#import "FSTMealRecord+Persistence.h"
#import "FSTPlan+Persistence.h"

NSNotificationName const FSTSessionDidChangeNotification = @"FSTSessionDidChangeNotification";
NSNotificationName const FSTRecordsDidChangeNotification = @"FSTRecordsDidChangeNotification";

// 表示 NSUserDefaults 中持久化存储的 key；value 保持原样用于兼容历史数据。
static NSString * const FSTCurrentPlanKey      = @"kFSTCurrentPlan";
static NSString * const FSTActiveStartTimeKey  = @"kFSTActiveStartTime";
static NSString * const FSTActiveEndOverrideTimeKey = @"kFSTActiveEndOverrideTime";
static NSString * const FSTRecordsKey          = @"kFSTRecords";
static NSString * const FSTMealRecordsKey      = @"kFSTMealRecords";
static NSString * const FSTNextStartOverrideKey = @"kFSTNextStartOverride";
static NSString * const FSTEatingWindowAnchorTimeKey = @"kFSTEatingWindowAnchorTime";
static NSString * const FSTOnboardingCompletedKey = @"kFSTOnboardingCompleted";
static NSString * const FSTScheduledReadySourceKey = @"kFSTScheduledReadySource";
static NSString * const FSTScheduledReadyAnchorTimeKey = @"kFSTScheduledReadyAnchorTime";
static NSString * const FSTLegacyEatingWindowFromActiveEditKey = @"kFSTEatingWindowFromActiveEdit";
static NSString * const FSTDataMigrationVersionKey = @"kFSTDataMigrationVersion";
static const NSInteger FSTCurrentDataMigrationVersion = 1;

@interface FSTSessionManager ()
@property (nonatomic, strong, readwrite, nullable) FSTPlan *currentPlan;
@property (nonatomic, assign, readwrite) BOOL hasCompletedOnboarding;
@property (nonatomic, strong, readwrite, nullable) NSDate *activeStartDate;
@property (nonatomic, strong, readwrite, nullable) NSDate *activeEndOverrideDate;
@property (nonatomic, strong, nullable) NSDate *eatingWindowAnchorDate;
@property (nonatomic, assign) BOOL pendingActiveStartDatePrompt;
@property (nonatomic, assign, readwrite) FSTScheduledReadySource scheduledReadySource;
@property (nonatomic, strong, readwrite, nullable) NSDate *scheduledReadyAnchorDate;
@property (nonatomic, strong) NSMutableArray<FSTFastingRecord *> *records;
@property (nonatomic, strong) NSMutableArray<FSTMealRecord *> *mealRecords;
@end

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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber *onboardingCompleted = [userDefaults objectForKey:FSTOnboardingCompletedKey];
    self.hasCompletedOnboarding = onboardingCompleted.boolValue;

    NSDictionary *planDictionary = [userDefaults objectForKey:FSTCurrentPlanKey];
    self.currentPlan = planDictionary ? [FSTPlan fst_planWithDictionary:planDictionary] : nil;

    NSNumber *startTimeInterval = [userDefaults objectForKey:FSTActiveStartTimeKey];
    self.activeStartDate = startTimeInterval ? [NSDate dateWithTimeIntervalSince1970:startTimeInterval.doubleValue] : nil;

    NSNumber *endOverrideTimeInterval = [userDefaults objectForKey:FSTActiveEndOverrideTimeKey];
    self.activeEndOverrideDate = endOverrideTimeInterval ? [NSDate dateWithTimeIntervalSince1970:endOverrideTimeInterval.doubleValue] : nil;

    NSNumber *eatingAnchorTimeInterval = [userDefaults objectForKey:FSTEatingWindowAnchorTimeKey];
    self.eatingWindowAnchorDate = eatingAnchorTimeInterval ? [NSDate dateWithTimeIntervalSince1970:eatingAnchorTimeInterval.doubleValue] : nil;

    // 预约态枚举的反序列化 + 范围钳制 + 旧 Bool 一次性升迁。
    // v0 用 FSTLegacyEatingWindowFromActiveEditKey 这个 Bool 来标记 ActiveSession-edit 来的预约；
    // v1 改成多源枚举（FSTScheduledReadySource）。此处兼容旧数据：若新枚举为 None 但旧 Bool 为 YES，
    // 一次性 lift 到 FromActiveSession。saveScheduledReadyStateToDefaults 会顺便 remove 旧 key，自然淘汰。
    NSNumber *scheduledSourceValue = [userDefaults objectForKey:FSTScheduledReadySourceKey];
    self.scheduledReadySource = scheduledSourceValue ? scheduledSourceValue.integerValue : FSTScheduledReadySourceNone;
    if (self.scheduledReadySource < FSTScheduledReadySourceNone ||
        self.scheduledReadySource > FSTScheduledReadySourceFromActiveSession) {
        self.scheduledReadySource = FSTScheduledReadySourceNone;
    }
    if (self.scheduledReadySource == FSTScheduledReadySourceNone &&
        [userDefaults boolForKey:FSTLegacyEatingWindowFromActiveEditKey]) {
        self.scheduledReadySource = FSTScheduledReadySourceFromActiveSession;
    }

    NSNumber *scheduledAnchorTimeInterval = [userDefaults objectForKey:FSTScheduledReadyAnchorTimeKey];
    self.scheduledReadyAnchorDate = scheduledAnchorTimeInterval ? [NSDate dateWithTimeIntervalSince1970:scheduledAnchorTimeInterval.doubleValue] : nil;
    if (self.scheduledReadySource == FSTScheduledReadySourceNone) {
        self.scheduledReadyAnchorDate = nil;
    }

    NSArray *fastingRecordDictionaries = [userDefaults objectForKey:FSTRecordsKey];
    self.records = [NSMutableArray array];
    for (NSDictionary *entry in fastingRecordDictionaries) {
        FSTFastingRecord *record = [FSTFastingRecord fst_recordWithDictionary:entry];
        if (record) [self.records addObject:record];
    }

    NSArray *mealRecordDictionaries = [userDefaults objectForKey:FSTMealRecordsKey];
    self.mealRecords = [NSMutableArray array];
    for (NSDictionary *entry in mealRecordDictionaries) {
        FSTMealRecord *record = [FSTMealRecord fst_recordWithDictionary:entry];
        if (record) [self.mealRecords addObject:record];
    }

    // 旧开发数据没有 onboarding 标记时，不能让残留的 plan/active session 跳过首次选计划流程。
    // 这里把它们一并清零，强制走 onboarding；否则 user 会绕过 PlanSelect 直接落到 Active 页，体验断层。
    if (!self.hasCompletedOnboarding && (self.currentPlan || self.activeStartDate || self.activeEndOverrideDate)) {
        [self clearLoadedPlanState];
    }

    [self migrateDataIfNeeded];
}

/// 数据迁移单调向前。每跨一个版本号补一段迁移代码。
/// v1：重新序列化所有 records / mealRecords，让 Step 7 的新 key 落盘；旧 key 在下一次
///     -saveRecordsToDefaults 的 setObject 时被覆盖，无需主动 remove。
- (void)migrateDataIfNeeded {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger version = [userDefaults integerForKey:FSTDataMigrationVersionKey];
    if (version >= FSTCurrentDataMigrationVersion) return;

    if (self.records.count > 0) [self saveRecordsToDefaults];
    if (self.mealRecords.count > 0) [self saveMealRecordsToDefaults];

    [userDefaults setInteger:FSTCurrentDataMigrationVersion forKey:FSTDataMigrationVersionKey];
}

- (void)saveActiveStateToDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.currentPlan) {
        [userDefaults setObject:[self.currentPlan fst_dictionaryRepresentation] forKey:FSTCurrentPlanKey];
    } else {
        [userDefaults removeObjectForKey:FSTCurrentPlanKey];
    }
    if (self.activeStartDate) {
        [userDefaults setObject:@(self.activeStartDate.timeIntervalSince1970) forKey:FSTActiveStartTimeKey];
    } else {
        [userDefaults removeObjectForKey:FSTActiveStartTimeKey];
    }
    if (self.activeEndOverrideDate) {
        [userDefaults setObject:@(self.activeEndOverrideDate.timeIntervalSince1970) forKey:FSTActiveEndOverrideTimeKey];
    } else {
        [userDefaults removeObjectForKey:FSTActiveEndOverrideTimeKey];
    }
}

- (void)saveEatingWindowAnchorToDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.eatingWindowAnchorDate) {
        [userDefaults setObject:@(self.eatingWindowAnchorDate.timeIntervalSince1970) forKey:FSTEatingWindowAnchorTimeKey];
    } else {
        [userDefaults removeObjectForKey:FSTEatingWindowAnchorTimeKey];
    }
}

- (void)saveOnboardingCompletedToDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.hasCompletedOnboarding) {
        [userDefaults setBool:YES forKey:FSTOnboardingCompletedKey];
    } else {
        [userDefaults removeObjectForKey:FSTOnboardingCompletedKey];
    }
}

- (void)saveScheduledReadyStateToDefaults {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.scheduledReadySource != FSTScheduledReadySourceNone) {
        [userDefaults setObject:@(self.scheduledReadySource) forKey:FSTScheduledReadySourceKey];
    } else {
        [userDefaults removeObjectForKey:FSTScheduledReadySourceKey];
    }
    if (self.scheduledReadySource != FSTScheduledReadySourceNone && self.scheduledReadyAnchorDate) {
        [userDefaults setObject:@(self.scheduledReadyAnchorDate.timeIntervalSince1970) forKey:FSTScheduledReadyAnchorTimeKey];
    } else {
        [userDefaults removeObjectForKey:FSTScheduledReadyAnchorTimeKey];
    }
    [userDefaults removeObjectForKey:FSTLegacyEatingWindowFromActiveEditKey];
}

- (void)clearLoadedPlanState {
    self.currentPlan = nil;
    self.activeStartDate = nil;
    self.activeEndOverrideDate = nil;
    self.eatingWindowAnchorDate = nil;
    self.scheduledReadySource = FSTScheduledReadySourceNone;
    self.scheduledReadyAnchorDate = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FSTNextStartOverrideKey];
    [self persistAllState];
}

- (void)persistAllState {
    [self saveActiveStateToDefaults];
    [self saveEatingWindowAnchorToDefaults];
    [self saveOnboardingCompletedToDefaults];
    [self saveScheduledReadyStateToDefaults];
}

- (void)persistAllStateAndNotifySession {
    [self persistAllState];
    [[NSNotificationCenter defaultCenter] postNotificationName:FSTSessionDidChangeNotification object:self];
}

- (void)saveRecordsToDefaults {
    NSMutableArray *serialized = [NSMutableArray array];
    for (FSTFastingRecord *record in self.records) {
        [serialized addObject:[record fst_dictionaryRepresentation]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:serialized forKey:FSTRecordsKey];
}

- (void)saveMealRecordsToDefaults {
    NSMutableArray *serialized = [NSMutableArray array];
    for (FSTMealRecord *record in self.mealRecords) {
        [serialized addObject:[record fst_dictionaryRepresentation]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:serialized forKey:FSTMealRecordsKey];
}

#pragma mark - Active state

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

/// 开始一次新的断食。调用方：PlanConfirm 页点 START、ActiveFasting 页 Reset 起点等。
/// 做 4 件事：
///   1) 切 plan + 起点（startDate 为 nil 时用 now 兜底）；
///   2) 清 endOverride — 本次按 plan 默认对齐 endDate；
///   3) 清 scheduledReady 与 eatingWindowAnchor — 避免上一次预约/吃窗口状态残留干扰新 session；
///   4) 移除 nextStartOverride — 让吃窗口下一次推导回到默认逻辑。
/// 完成后 -persistAllStateAndNotifySession 让所有订阅者刷新。
- (void)startFastingWithPlan:(FSTPlan *)plan startDate:(NSDate *)date {
    self.currentPlan = plan;
    self.activeStartDate = date ?: [NSDate date];
    self.activeEndOverrideDate = nil;
    self.eatingWindowAnchorDate = nil;
    self.hasCompletedOnboarding = YES;
    self.scheduledReadySource = FSTScheduledReadySourceNone;
    self.scheduledReadyAnchorDate = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FSTNextStartOverrideKey];
    [self persistAllStateAndNotifySession];
}

- (void)cancelActiveFasting {
    self.activeStartDate = nil;
    self.activeEndOverrideDate = nil;
    self.eatingWindowAnchorDate = [NSDate date];
    [self persistAllStateAndNotifySession];
}

/// 断食完成路径。调用方：AddRecord 页点保存。
/// 顺序很关键：
///   1) 先写 records 并单独发 FSTRecordsDidChangeNotification — History/Timeline/MealDiary 这些
///      只关心列表的页面立即刷新，不需要等下面的 session 变更通知；
///   2) 清空 active 字段；
///   3) eatingWindowAnchorDate = endDate（或 now 兜底）— 作为吃窗口"0 分钟"起点，
///      让 FSTEatingWindowService 的 elapsed 从结束时刻开始算；
///   4) 清 scheduledReady — 防止下一轮吃窗口继承上次的预约残留状态；
///   5) 统一 persist + 发 session 通知，让 DailyPlan VC 切回 Eating Time 视图。
- (void)finishFastingWithRecord:(FSTFastingRecord *)record {
    if (record) {
        if (!record.recordID.length) record.recordID = [[NSUUID UUID] UUIDString];
        [self.records insertObject:record atIndex:0];
        [self saveRecordsToDefaults];
        [[NSNotificationCenter defaultCenter] postNotificationName:FSTRecordsDidChangeNotification object:self];
    }
    self.activeStartDate = nil;
    self.activeEndOverrideDate = nil;
    self.eatingWindowAnchorDate = record.endDate ?: [NSDate date];
    self.scheduledReadySource = FSTScheduledReadySourceNone;
    self.scheduledReadyAnchorDate = nil;
    [self persistAllStateAndNotifySession];
}

- (void)clearCurrentPlan {
    self.currentPlan = nil;
    self.activeStartDate = nil;
    self.activeEndOverrideDate = nil;
    self.eatingWindowAnchorDate = nil;
    self.hasCompletedOnboarding = NO;
    self.scheduledReadySource = FSTScheduledReadySourceNone;
    self.scheduledReadyAnchorDate = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FSTNextStartOverrideKey];
    [self persistAllStateAndNotifySession];
}

- (void)switchToPlanPreservingState:(FSTPlan *)plan {
    if (!plan) return;
    self.currentPlan = plan;
    self.activeEndOverrideDate = nil;
    self.hasCompletedOnboarding = YES;
    [self persistAllStateAndNotifySession];
}

- (void)requestActiveStartDatePrompt {
    self.pendingActiveStartDatePrompt = YES;
}

- (BOOL)consumeActiveStartDatePromptRequest {
    BOOL shouldPrompt = self.pendingActiveStartDatePrompt;
    self.pendingActiveStartDatePrompt = NO;
    return shouldPrompt;
}

- (void)markScheduledReadyWithSource:(FSTScheduledReadySource)source anchorDate:(NSDate *)anchorDate {
    if (source == FSTScheduledReadySourceNone) {
        [self clearScheduledReadyState];
        return;
    }
    self.scheduledReadySource = source;
    self.scheduledReadyAnchorDate = anchorDate ?: [NSDate date];
    self.hasCompletedOnboarding = YES;
    [self persistAllStateAndNotifySession];
}

- (void)clearScheduledReadyState {
    if (self.scheduledReadySource == FSTScheduledReadySourceNone && !self.scheduledReadyAnchorDate) return;
    self.scheduledReadySource = FSTScheduledReadySourceNone;
    self.scheduledReadyAnchorDate = nil;
    [self persistAllStateAndNotifySession];
}

- (void)beginEatingWindowFromDate:(NSDate *)date {
    self.activeStartDate = nil;
    self.activeEndOverrideDate = nil;
    self.eatingWindowAnchorDate = date ?: [NSDate date];
    self.scheduledReadySource = FSTScheduledReadySourceNone;
    self.scheduledReadyAnchorDate = nil;
    self.hasCompletedOnboarding = YES;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FSTNextStartOverrideKey];
    [self persistAllStateAndNotifySession];
}

- (NSArray<FSTFastingRecord *> *)allRecords {
    return [self.records copy];
}

- (void)updateFastingRecord:(FSTFastingRecord *)record {
    if (!record.recordID.length) return;
    NSUInteger existingIndex = [self.records indexOfObjectPassingTest:^BOOL(FSTFastingRecord *obj, NSUInteger idx, BOOL *stop) {
        return [obj.recordID isEqualToString:record.recordID];
    }];
    if (existingIndex != NSNotFound) {
        self.records[existingIndex] = record;
    } else {
        [self.records insertObject:record atIndex:0];
    }
    [self.records sortUsingComparator:^NSComparisonResult(FSTFastingRecord *a, FSTFastingRecord *b) {
        return [b.endDate compare:a.endDate];
    }];
    [self saveRecordsToDefaults];
    [[NSNotificationCenter defaultCenter] postNotificationName:FSTRecordsDidChangeNotification object:self];
}

- (void)deleteFastingRecord:(FSTFastingRecord *)record {
    if (!record.recordID.length) return;
    NSIndexSet *indexes = [self.records indexesOfObjectsPassingTest:^BOOL(FSTFastingRecord *obj, NSUInteger idx, BOOL *stop) {
        return [obj.recordID isEqualToString:record.recordID];
    }];
    if (indexes.count == 0) return;
    [self.records removeObjectsAtIndexes:indexes];
    [self saveRecordsToDefaults];
    [[NSNotificationCenter defaultCenter] postNotificationName:FSTRecordsDidChangeNotification object:self];
}

- (NSArray<FSTMealRecord *> *)allMealRecords {
    return [self.mealRecords copy];
}

- (void)addOrUpdateMealRecord:(FSTMealRecord *)record {
    if (!record) return;
    if (!record.recordID.length) record.recordID = [[NSUUID UUID] UUIDString];
    NSUInteger existingIndex = [self.mealRecords indexOfObjectPassingTest:^BOOL(FSTMealRecord *obj, NSUInteger idx, BOOL *stop) {
        return [obj.recordID isEqualToString:record.recordID];
    }];
    if (existingIndex != NSNotFound) {
        self.mealRecords[existingIndex] = record;
    } else {
        [self.mealRecords insertObject:record atIndex:0];
    }
    [self.mealRecords sortUsingComparator:^NSComparisonResult(FSTMealRecord *a, FSTMealRecord *b) {
        return [b.date compare:a.date];
    }];
    [self saveMealRecordsToDefaults];
    [[NSNotificationCenter defaultCenter] postNotificationName:FSTRecordsDidChangeNotification object:self];
}

- (void)deleteMealRecord:(FSTMealRecord *)record {
    if (!record.recordID.length) return;
    NSIndexSet *indexes = [self.mealRecords indexesOfObjectsPassingTest:^BOOL(FSTMealRecord *obj, NSUInteger idx, BOOL *stop) {
        return [obj.recordID isEqualToString:record.recordID];
    }];
    if (indexes.count == 0) return;
    [self.mealRecords removeObjectsAtIndexes:indexes];
    [self saveMealRecordsToDefaults];
    [[NSNotificationCenter defaultCenter] postNotificationName:FSTRecordsDidChangeNotification object:self];
}

- (NSDate *)latestFastingEndDate {
    FSTFastingRecord *record = self.records.firstObject;
    return record.endDate;
}

- (NSDate *)latestMealDate {
    FSTMealRecord *record = self.mealRecords.firstObject;
    return record.date;
}

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
- (NSDate *)nextFastingStartDate {
    if (!self.currentPlan) return nil;
    NSNumber *override = [[NSUserDefaults standardUserDefaults] objectForKey:FSTNextStartOverrideKey];
    if (override) return [NSDate dateWithTimeIntervalSince1970:override.doubleValue];
    NSDate *mealDate = [self latestMealDate];
    NSDate *fastingEndDate = [self latestFastingEndDate];
    NSDate *anchor = fastingEndDate ?: mealDate ?: self.eatingWindowAnchorDate;
    if (!anchor) {
        anchor = [NSDate date];
        self.eatingWindowAnchorDate = anchor;
        [self saveEatingWindowAnchorToDefaults];
    }
    if (mealDate && [mealDate compare:anchor] == NSOrderedDescending) {
        anchor = mealDate;
    }
    return [anchor dateByAddingTimeInterval:self.currentPlan.eatingHours * 3600.0];
}

- (void)setNextFastingStartDate:(NSDate *)date {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (date) {
        [userDefaults setObject:@(date.timeIntervalSince1970) forKey:FSTNextStartOverrideKey];
    } else {
        [userDefaults removeObjectForKey:FSTNextStartOverrideKey];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:FSTSessionDidChangeNotification object:self];
}


- (void)editActiveStartDate:(NSDate *)date {
    [self editActiveStartDate:date alignWithPlan:YES];
}

/// 编辑活跃断食的 Start 时刻 — 双模式：
///   alignWithPlan=YES：擦掉 endOverride，end 跟随 plan 自动对齐到 newStart + plan.fastingHours。
///   alignWithPlan=NO ：保留用户的自定义 end —— 但要先快照当前的 expectedEnd，否则改 start 后再写 nil end 会回退到 plan 默认。
/// 两种模式都强制 end ≥ start + 60s，防止用户拉成零长度断食（视觉/逻辑都崩）。
- (void)editActiveStartDate:(NSDate *)date alignWithPlan:(BOOL)alignWithPlan {
    if (!date || !self.hasActiveFasting) return;
    NSDate *currentExpectedEndDate = [self activeExpectedEndDate];

    self.activeStartDate = date;
    if (alignWithPlan) {
        self.activeEndOverrideDate = nil;
    } else {
        NSDate *expectedEndDate = currentExpectedEndDate ?: [date dateByAddingTimeInterval:[self targetDurationSeconds]];
        NSDate *minimumEndDate = [date dateByAddingTimeInterval:60.0];
        self.activeEndOverrideDate = [expectedEndDate compare:minimumEndDate] == NSOrderedAscending ? minimumEndDate : expectedEndDate;
    }
    [self persistAllStateAndNotifySession];
}

/// 编辑活跃断食的 End 时刻 — 双模式：
///   alignWithPlan=YES：清掉 override，让 end 回到 plan 默认（startDate + plan.fastingHours）。
///   alignWithPlan=NO ：把 end 锁定为用户输入；同样强制 end ≥ start + 60s 防零长度。
- (void)editActiveEndDate:(NSDate *)date alignWithPlan:(BOOL)alignWithPlan {
    if (!date || !self.hasActiveFasting || !self.activeStartDate) return;
    if (alignWithPlan) {
        self.activeEndOverrideDate = nil;
    } else {
        NSDate *minimumEndDate = [self.activeStartDate dateByAddingTimeInterval:60.0];
        self.activeEndOverrideDate = [date compare:minimumEndDate] == NSOrderedAscending ? minimumEndDate : date;
    }
    [self persistAllStateAndNotifySession];
}

@end
