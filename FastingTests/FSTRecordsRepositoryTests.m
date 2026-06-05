#import <XCTest/XCTest.h>
#import "../Fasting/Core/Models/Records/FSTFastingRecord.m"
#import "../Fasting/Core/Models/Records/FSTFastingRecord+Persistence.m"
#import "../Fasting/Core/Models/Records/FSTMealRecord+Persistence.m"
#import "../Fasting/Core/Models/Records/FSTPlan.m"
#import "../Fasting/Core/Models/Records/FSTPlan+Persistence.m"
#import "../Fasting/Core/Services/RecordsRepository/FSTRecordsRepository.m"
#import "../Fasting/Core/Services/Session/FSTSessionLifecycleService.m"
#import "../Fasting/Core/Services/Session/FSTSessionManager.m"
#import "../Fasting/Core/Services/Session/FSTSessionPersistenceService.m"
#import "../Fasting/Core/Services/Session/FSTNextFastService.m"
#import "../Fasting/Modules/Fasting/Idle/Ready/FSTDailyPlanReadyDisplayState.m"

// Note: FSTFastingTimingService / FSTEatingWindowService 已在 MVC 重构中 inline 进
// FSTActiveFastingViewController / FSTFastingIdleViewController（单一调用点）。
// 这里只保留对 FSTRecordsRepository 排序 / upsert / delete 的回归测试。

@interface FSTRecordsRepositoryTests : XCTestCase
@end

@implementation FSTRecordsRepositoryTests

- (void)setUp {
    [super setUp];
    [self clearRecordDefaults];
}

- (void)tearDown {
    [self clearRecordDefaults];
    [super tearDown];
}

- (void)clearRecordDefaults {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kFSTRecords"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kFSTMealRecords"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kFSTNextStartOverride"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kFSTNextStartOverrideAnchor"];
}

- (void)testRecordsRepositoryOrdersUpsertsAndDeletesFastingRecords {
    FSTRecordsRepository *repository = [[FSTRecordsRepository alloc] init];
    [repository setValue:[NSMutableArray array] forKey:@"records"];
    [repository setValue:[NSMutableArray array] forKey:@"mealRecords"];

    NSDate *base = [NSDate dateWithTimeIntervalSince1970:2000];
    FSTFastingRecord *older = [[FSTFastingRecord alloc] init];
    older.recordID = @"older";
    older.startDate = base;
    older.endDate = [base dateByAddingTimeInterval:1000];
    older.fastingHours = 14;

    FSTFastingRecord *newer = [[FSTFastingRecord alloc] init];
    newer.recordID = @"newer";
    newer.startDate = base;
    newer.endDate = [base dateByAddingTimeInterval:2000];
    newer.fastingHours = 16;

    [repository updateFastingRecord:older];
    [repository updateFastingRecord:newer];
    XCTAssertEqualObjects([repository allRecords].firstObject.recordID, @"newer");

    older.endDate = [base dateByAddingTimeInterval:3000];
    [repository updateFastingRecord:older];
    XCTAssertEqual([repository allRecords].count, 2);
    XCTAssertEqualObjects([repository allRecords].firstObject.recordID, @"older");

    [repository deleteFastingRecord:older];
    XCTAssertEqual([repository allRecords].count, 1);
    XCTAssertEqualObjects([repository allRecords].firstObject.recordID, @"newer");
}

- (void)testRecordsRepositoryOrdersUpsertsAndDeletesMealRecords {
    FSTRecordsRepository *repository = [[FSTRecordsRepository alloc] init];
    [repository setValue:[NSMutableArray array] forKey:@"records"];
    [repository setValue:[NSMutableArray array] forKey:@"mealRecords"];

    NSDate *base = [NSDate dateWithTimeIntervalSince1970:3000];
    FSTMealRecord *breakfast = [[FSTMealRecord alloc] init];
    breakfast.recordID = @"breakfast";
    breakfast.date = base;

    FSTMealRecord *dinner = [[FSTMealRecord alloc] init];
    dinner.recordID = @"dinner";
    dinner.date = [base dateByAddingTimeInterval:3000];

    [repository addOrUpdateMealRecord:breakfast];
    [repository addOrUpdateMealRecord:dinner];
    XCTAssertEqualObjects([repository allMealRecords].firstObject.recordID, @"dinner");

    breakfast.date = [base dateByAddingTimeInterval:5000];
    [repository addOrUpdateMealRecord:breakfast];
    XCTAssertEqual([repository allMealRecords].count, 2);
    XCTAssertEqualObjects([repository latestMealDate], breakfast.date);

    [repository deleteMealRecord:breakfast];
    XCTAssertEqual([repository allMealRecords].count, 1);
    XCTAssertEqualObjects([repository allMealRecords].firstObject.recordID, @"dinner");
}

- (void)testSessionManagerRecordsAndClearsNextStartOverrideAnchor {
    FSTSessionManager *manager = [[FSTSessionManager alloc] init];
    NSDate *beforeSet = [NSDate date];
    NSDate *nextStartDate = [beforeSet dateByAddingTimeInterval:60.0];

    [manager setNextFastingStartDate:nextStartDate];

    NSDate *anchorDate = [manager nextFastingStartCountdownAnchorDate];
    XCTAssertNotNil(anchorDate);
    XCTAssertTrue([anchorDate compare:beforeSet] != NSOrderedAscending);
    XCTAssertTrue([anchorDate compare:[NSDate date]] != NSOrderedDescending);

    [manager setNextFastingStartDate:nil];

    XCTAssertNil([manager nextFastingStartCountdownAnchorDate]);
}

@end

#pragma mark - FSTDailyPlanReadyDisplayState

// 注：与上面的 Repository 测试同处一文件，因为测试 target 直接 #import 源 .m —— 拆成独立文件会让
// FSTSessionManager.m 等被两个 TU 各编译一次而重复符号。新增另一测试类放同一文件即可（见 CLAUDE.md）。
@interface FSTDailyPlanReadyDisplayStateTests : XCTestCase
@end

@implementation FSTDailyPlanReadyDisplayStateTests

- (void)setUp {
    [super setUp];
    [self clearSessionDefaults];
}

- (void)tearDown {
    [self clearSessionDefaults];
    [super tearDown];
}

// 清掉全部 session / record 持久化键 —— 测试用 [[FSTSessionManager alloc] init] 起新实例，
// 但 init 会从共享 NSUserDefaults 装载，故每个用例前后都要洗干净，避免互相污染。
- (void)clearSessionDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray<NSString *> *keys = @[@"kFSTCurrentPlan", @"kFSTActiveStartTime", @"kFSTActiveEndOverrideTime",
                                  @"kFSTNextStartOverride", @"kFSTNextStartOverrideAnchor", @"kFSTEatingWindowAnchorTime",
                                  @"kFSTOnboardingCompleted", @"kFSTScheduledReadySource", @"kFSTScheduledReadyAnchorTime",
                                  @"kFSTPreferredWeightUnit", @"kFSTRecords", @"kFSTMealRecords"];
    for (NSString *key in keys) {
        [defaults removeObjectForKey:key];
    }
}

- (FSTPlan *)plan168 {
    FSTPlan *plan = [[FSTPlan alloc] init];
    plan.type = FSTPlanType168;
    plan.name = @"16-8";
    plan.fastingHours = 16;
    plan.eatingHours = 8;
    return plan;
}

- (FSTRecordsRepository *)emptyRepository {
    FSTRecordsRepository *repository = [[FSTRecordsRepository alloc] init];
    [repository setValue:[NSMutableArray array] forKey:@"records"];
    [repository setValue:[NSMutableArray array] forKey:@"mealRecords"];
    return repository;
}

// 普通吃窗口：已选 plan、未预约、下一次开始还在未来 → EatingWindow（非紧凑、Start 按钮、Tips=After）。
- (void)testEatingWindowStateWhenNextStartIsInFuture {
    FSTSessionManager *session = [[FSTSessionManager alloc] init];
    [session switchToPlanPreservingState:[self plan168]];
    NSDate *now = [NSDate date];
    [session setNextFastingStartDate:[now dateByAddingTimeInterval:2 * 3600.0]];  // 2h 后

    FSTDailyPlanReadyDisplayState *state =
        [FSTDailyPlanReadyDisplayState stateForSessionManager:session
                                            recordsRepository:[self emptyRepository]
                                                          now:now];

    XCTAssertFalse(state.shouldAutoStartNow);
    XCTAssertEqual(state.presentationState, FSTDailyPlanReadyRingPresentationEatingWindow);
    XCTAssertEqual(state.primaryActionMode, FSTDailyPlanReadyPrimaryActionStartFasting);
    XCTAssertEqual(state.tipsStage, FSTTipsFastingStageAfter);
    XCTAssertFalse(state.compactLayout);
    XCTAssertTrue(state.ringProgress >= 0 && state.ringProgress <= 1);
}

// 预约倒计时：scheduled + 开始时刻在未来 → ScheduledCountdown（紧凑、Abort 按钮、Tips=Prepare、不自动起始）。
- (void)testScheduledCountdownStateWhenScheduledStartIsInFuture {
    FSTSessionManager *session = [[FSTSessionManager alloc] init];
    [session switchToPlanPreservingState:[self plan168]];
    NSDate *now = [NSDate date];
    [session setNextFastingStartDate:[now dateByAddingTimeInterval:3600.0]];      // 1h 后
    [session markScheduledReadyWithSource:FSTScheduledReadySourcePreStart anchorDate:now];

    FSTDailyPlanReadyDisplayState *state =
        [FSTDailyPlanReadyDisplayState stateForSessionManager:session
                                            recordsRepository:[self emptyRepository]
                                                          now:now];

    XCTAssertFalse(state.shouldAutoStartNow);
    XCTAssertEqual(state.presentationState, FSTDailyPlanReadyRingPresentationScheduledCountdown);
    XCTAssertEqual(state.primaryActionMode, FSTDailyPlanReadyPrimaryActionAbortPlan);
    XCTAssertEqual(state.tipsStage, FSTTipsFastingStagePrepare);
    XCTAssertTrue(state.compactLayout);
    XCTAssertTrue(state.ringProgress >= 0 && state.ringProgress <= 0.05);  // anchor==now → 进度 ≈ 0
}

// 可立即开始：已选 plan、未预约、下一次开始已过去（吃窗口耗尽）→ ReadyToStartFasting（满环、不自动起始）。
- (void)testReadyToStartStateWhenWindowElapsedWithoutSchedule {
    FSTSessionManager *session = [[FSTSessionManager alloc] init];
    [session switchToPlanPreservingState:[self plan168]];
    NSDate *now = [NSDate date];
    [session setNextFastingStartDate:[now dateByAddingTimeInterval:-3600.0]];     // 1h 前（已可开始）

    FSTDailyPlanReadyDisplayState *state =
        [FSTDailyPlanReadyDisplayState stateForSessionManager:session
                                            recordsRepository:[self emptyRepository]
                                                          now:now];

    XCTAssertFalse(state.shouldAutoStartNow);  // 关键：ready 但未 scheduled，不应自动起始
    XCTAssertEqual(state.presentationState, FSTDailyPlanReadyRingPresentationReadyToStartFasting);
    XCTAssertEqual(state.primaryActionMode, FSTDailyPlanReadyPrimaryActionStartFasting);
    XCTAssertEqual(state.tipsStage, FSTTipsFastingStageAfter);
    XCTAssertTrue(state.compactLayout);
    XCTAssertEqualWithAccuracy(state.ringProgress, 1.0, 0.0001);  // 满环
}

// 预约到点：scheduled + 开始时刻刚过去 → shouldAutoStartNow=YES、autoStartDate=该开始时刻；
// 边界另一侧（开始时刻仍在未来）→ 不自动起始，停在 ScheduledCountdown。
- (void)testAutoStartTriggersWhenScheduledStartJustPassed {
    FSTSessionManager *session = [[FSTSessionManager alloc] init];
    [session switchToPlanPreservingState:[self plan168]];
    NSDate *now = [NSDate date];
    NSDate *justPassed = [now dateByAddingTimeInterval:-10.0];   // 10s 前
    [session setNextFastingStartDate:justPassed];
    [session markScheduledReadyWithSource:FSTScheduledReadySourcePreStart anchorDate:[now dateByAddingTimeInterval:-3600.0]];

    FSTDailyPlanReadyDisplayState *state =
        [FSTDailyPlanReadyDisplayState stateForSessionManager:session
                                            recordsRepository:[self emptyRepository]
                                                          now:now];
    XCTAssertTrue(state.shouldAutoStartNow);
    XCTAssertEqualWithAccuracy([state.autoStartDate timeIntervalSinceDate:justPassed], 0, 1.0);

    [session setNextFastingStartDate:[now dateByAddingTimeInterval:10.0]];        // 改到 10s 后
    FSTDailyPlanReadyDisplayState *future =
        [FSTDailyPlanReadyDisplayState stateForSessionManager:session
                                            recordsRepository:[self emptyRepository]
                                                          now:now];
    XCTAssertFalse(future.shouldAutoStartNow);
    XCTAssertEqual(future.presentationState, FSTDailyPlanReadyRingPresentationScheduledCountdown);
}

@end
