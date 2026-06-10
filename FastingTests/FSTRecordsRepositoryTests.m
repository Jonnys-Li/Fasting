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
#import "../Fasting/Core/Services/Session/FSTFastingRecordBuilder.m"
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

// 回归（bug：从进行中的断食在 Plan 流把开始时间预约到未来，应清掉 active 落到 Ready 倒计时，
// 而非因 hasActiveFasting 残留为真而 push Active）。复刻 FSTPlanConfirmViewController 未来分支的 session 调用。
- (void)testFutureScheduleAfterActiveFastClearsActiveAndShowsScheduledCountdown {
    FSTSessionManager *session = [[FSTSessionManager alloc] init];
    NSDate *now = [NSDate date];

    // 先制造一个进行中的断食（模拟刚测完 bug1 仍 active 的现场）。
    [session startFastingWithPlan:[self plan168] startDate:now];
    XCTAssertTrue(session.hasActiveFasting);

    // Plan 流「未来开始」分支（修复后）：选 plan + 原子化预约到未来。
    [session switchToPlanPreservingState:[self plan168]];
    [session scheduleFastingAtFutureDate:[now dateByAddingTimeInterval:3600.0] source:FSTScheduledReadySourcePreStart];

    // 关键：active 起点被清——否则 IdleVC 会 push Active 而非 Ready 倒计时环。
    XCTAssertFalse(session.hasActiveFasting);

    FSTDailyPlanReadyDisplayState *state =
        [FSTDailyPlanReadyDisplayState stateForSessionManager:session
                                            recordsRepository:[self emptyRepository]
                                                          now:now];
    XCTAssertFalse(state.shouldAutoStartNow);
    XCTAssertEqual(state.presentationState, FSTDailyPlanReadyRingPresentationScheduledCountdown);
    XCTAssertEqual(state.primaryActionMode, FSTDailyPlanReadyPrimaryActionAbortPlan);
}

@end

#pragma mark - 共享测试工具

// NextFast / Lifecycle 测试都要洗 session 持久化键 + 重置 **shared** repository 的内存数组
// （NextFastService / finishSession 内部硬依赖 [FSTRecordsRepository sharedRepository]，
//   只清 NSUserDefaults 清不掉单例 init 时已装载进内存的数组）。
static void FSTTestClearSessionDefaults(void) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray<NSString *> *keys = @[@"kFSTCurrentPlan", @"kFSTActiveStartTime", @"kFSTActiveEndOverrideTime",
                                  @"kFSTNextStartOverride", @"kFSTNextStartOverrideAnchor", @"kFSTEatingWindowAnchorTime",
                                  @"kFSTOnboardingCompleted", @"kFSTScheduledReadySource", @"kFSTScheduledReadyAnchorTime",
                                  @"kFSTPreferredWeightUnit", @"kFSTRecords", @"kFSTMealRecords"];
    for (NSString *key in keys) {
        [defaults removeObjectForKey:key];
    }
}

static void FSTTestResetSharedRepository(void) {
    FSTRecordsRepository *repository = [FSTRecordsRepository sharedRepository];
    [repository setValue:[NSMutableArray array] forKey:@"records"];
    [repository setValue:[NSMutableArray array] forKey:@"mealRecords"];
}

static FSTPlan *FSTTestPlan168(void) {
    FSTPlan *plan = [[FSTPlan alloc] init];
    plan.type = FSTPlanType168;
    plan.name = @"16-8";
    plan.fastingHours = 16;
    plan.eatingHours = 8;
    return plan;
}

#pragma mark - FSTNextFastService

// nextStartDateForSession: 的 5 级优先级推导（override → fastingEnd → mealDate → anchor → now 兜底）
// + 「mealDate 比 anchor 新则顶替」逻辑。固定时间基点，经 SessionManager 公开 API 驱动。
@interface FSTNextFastServiceTests : XCTestCase
@end

@implementation FSTNextFastServiceTests

- (void)setUp {
    [super setUp];
    FSTTestClearSessionDefaults();
    FSTTestResetSharedRepository();
}

- (void)tearDown {
    FSTTestClearSessionDefaults();
    FSTTestResetSharedRepository();
    [super tearDown];
}

- (FSTSessionManager *)sessionWithPlan {
    FSTSessionManager *session = [[FSTSessionManager alloc] init];
    [session switchToPlanPreservingState:FSTTestPlan168()];
    return session;
}

// 向 shared repository 注入一条 end 时刻为指定值的断食记录（updateFastingRecord 要求 start+end 齐全）。
- (void)injectFastingRecordEndingAt:(NSDate *)endDate {
    FSTFastingRecord *record = [[FSTFastingRecord alloc] init];
    record.recordID = [[NSUUID UUID] UUIDString];
    record.startDate = [endDate dateByAddingTimeInterval:-16 * 3600.0];
    record.endDate = endDate;
    [[FSTRecordsRepository sharedRepository] updateFastingRecord:record];
}

- (void)injectMealRecordAt:(NSDate *)date {
    FSTMealRecord *record = [[FSTMealRecord alloc] init];
    record.recordID = [[NSUUID UUID] UUIDString];
    record.date = date;
    [[FSTRecordsRepository sharedRepository] addOrUpdateMealRecord:record];
}

- (void)testNextStartIsNilWithoutPlan {
    FSTSessionManager *session = [[FSTSessionManager alloc] init];
    XCTAssertNil([session nextFastingStartDate]);
}

// 第 1 级：override 压倒一切 —— 不加 eatingHours、无视 records。
- (void)testOverrideBeatsAllOtherSources {
    FSTSessionManager *session = [self sessionWithPlan];
    [self injectFastingRecordEndingAt:[NSDate dateWithTimeIntervalSince1970:1000000]];
    NSDate *override = [NSDate dateWithTimeIntervalSince1970:5000000];
    [session setNextFastingStartDate:override];

    XCTAssertEqualWithAccuracy([session nextFastingStartDate].timeIntervalSince1970,
                               override.timeIntervalSince1970, 0.001);
}

// 第 2 级：最近一次断食结束时刻 + eatingHours。
- (void)testLatestFastingEndPlusEatingHours {
    FSTSessionManager *session = [self sessionWithPlan];
    NSDate *end = [NSDate dateWithTimeIntervalSince1970:1000000];
    [self injectFastingRecordEndingAt:end];

    XCTAssertEqualWithAccuracy([session nextFastingStartDate].timeIntervalSince1970,
                               end.timeIntervalSince1970 + 8 * 3600.0, 0.001);
}

// 第 3 级：无断食历史退化到最近一餐。
- (void)testFallsBackToMealDateWithoutFastingHistory {
    FSTSessionManager *session = [self sessionWithPlan];
    NSDate *meal = [NSDate dateWithTimeIntervalSince1970:2000000];
    [self injectMealRecordAt:meal];

    XCTAssertEqualWithAccuracy([session nextFastingStartDate].timeIntervalSince1970,
                               meal.timeIntervalSince1970 + 8 * 3600.0, 0.001);
}

// 第 4 级：无 records 用 eatingWindowAnchorDate。
- (void)testUsesEatingWindowAnchorWhenNoRecords {
    FSTSessionManager *session = [self sessionWithPlan];
    NSDate *anchor = [NSDate dateWithTimeIntervalSince1970:3000000];
    [session beginEatingWindowFromDate:anchor];

    XCTAssertEqualWithAccuracy([session nextFastingStartDate].timeIntervalSince1970,
                               anchor.timeIntervalSince1970 + 8 * 3600.0, 0.001);
}

// 第 5 级：全空兜底到 now，并把 anchor 写回内存 + 落盘（防后续推导漂移）。
- (void)testFallsBackToNowAndWritesAnchorBack {
    FSTSessionManager *session = [self sessionWithPlan];
    NSDate *before = [NSDate date];
    NSDate *next = [session nextFastingStartDate];
    NSDate *after = [NSDate date];

    XCTAssertNotNil(next);
    XCTAssertTrue([next timeIntervalSinceDate:before] >= 8 * 3600.0 - 0.001);
    XCTAssertTrue([next timeIntervalSinceDate:after] <= 8 * 3600.0 + 0.001);
    XCTAssertNotNil(session.eatingWindowAnchorDate);
    XCTAssertNotNil([[NSUserDefaults standardUserDefaults] objectForKey:@"kFSTEatingWindowAnchorTime"]);
}

// 顶替逻辑：吃窗口里又吃了一餐（mealDate > fastingEnd）→ 吃窗口从最后一餐重新起算。
- (void)testNewerMealDateReplacesFastingEndAnchor {
    FSTSessionManager *session = [self sessionWithPlan];
    NSDate *end = [NSDate dateWithTimeIntervalSince1970:1000000];
    NSDate *meal = [end dateByAddingTimeInterval:3600.0];
    [self injectFastingRecordEndingAt:end];
    [self injectMealRecordAt:meal];

    XCTAssertEqualWithAccuracy([session nextFastingStartDate].timeIntervalSince1970,
                               meal.timeIntervalSince1970 + 8 * 3600.0, 0.001);
}

// 边界另一侧：mealDate 比 fastingEnd 旧则不顶替。
- (void)testOlderMealDateDoesNotReplaceFastingEnd {
    FSTSessionManager *session = [self sessionWithPlan];
    NSDate *end = [NSDate dateWithTimeIntervalSince1970:1000000];
    [self injectFastingRecordEndingAt:end];
    [self injectMealRecordAt:[end dateByAddingTimeInterval:-3600.0]];

    XCTAssertEqualWithAccuracy([session nextFastingStartDate].timeIntervalSince1970,
                               end.timeIntervalSince1970 + 8 * 3600.0, 0.001);
}

@end

#pragma mark - FSTSessionLifecycleService

// 编辑活跃断食起止时刻的双模式（alignWithPlan）+ 60s 最短钳制 + finish 状态归位。
// 全部经 SessionManager 公开 API 驱动。
@interface FSTSessionLifecycleServiceTests : XCTestCase
@end

@implementation FSTSessionLifecycleServiceTests

- (void)setUp {
    [super setUp];
    FSTTestClearSessionDefaults();
    FSTTestResetSharedRepository();
}

- (void)tearDown {
    FSTTestClearSessionDefaults();
    FSTTestResetSharedRepository();
    [super tearDown];
}

- (FSTSessionManager *)sessionStartedAt:(NSDate *)startDate {
    FSTSessionManager *session = [[FSTSessionManager alloc] init];
    [session startFastingWithPlan:FSTTestPlan168() startDate:startDate];
    return session;
}

// align:YES 改 start → 清掉自定义 end，end 重新对齐 newStart + plan.fastingHours。
- (void)testEditStartAlignWithPlanClearsCustomEnd {
    NSDate *base = [NSDate dateWithTimeIntervalSince1970:1000000];
    FSTSessionManager *session = [self sessionStartedAt:base];
    [session editActiveEndDate:[base dateByAddingTimeInterval:2 * 3600.0] alignWithPlan:NO];
    XCTAssertNotNil(session.activeEndOverrideDate);

    NSDate *newStart = [base dateByAddingTimeInterval:3600.0];
    [session editActiveStartDate:newStart alignWithPlan:YES];

    XCTAssertNil(session.activeEndOverrideDate);
    XCTAssertEqualWithAccuracy([session activeExpectedEndDate].timeIntervalSince1970,
                               newStart.timeIntervalSince1970 + 16 * 3600.0, 0.001);
}

// align:NO 改 start → 快照保留自定义 end，不回退 plan 默认。
- (void)testEditStartKeepingCustomEndSnapshotsExpectedEnd {
    NSDate *base = [NSDate dateWithTimeIntervalSince1970:1000000];
    FSTSessionManager *session = [self sessionStartedAt:base];
    NSDate *customEnd = [base dateByAddingTimeInterval:2 * 3600.0];
    [session editActiveEndDate:customEnd alignWithPlan:NO];

    [session editActiveStartDate:[base dateByAddingTimeInterval:1800.0] alignWithPlan:NO];

    XCTAssertEqualWithAccuracy(session.activeEndOverrideDate.timeIntervalSince1970,
                               customEnd.timeIntervalSince1970, 0.001);
}

// start 被编辑到自定义 end 之后 → end 钳到 newStart + 60s。
- (void)testEditStartClampsEndToStartPlus60s {
    NSDate *base = [NSDate dateWithTimeIntervalSince1970:1000000];
    FSTSessionManager *session = [self sessionStartedAt:base];
    [session editActiveEndDate:[base dateByAddingTimeInterval:2 * 3600.0] alignWithPlan:NO];

    NSDate *lateStart = [base dateByAddingTimeInterval:3 * 3600.0];
    [session editActiveStartDate:lateStart alignWithPlan:NO];

    XCTAssertEqualWithAccuracy(session.activeEndOverrideDate.timeIntervalSince1970,
                               lateStart.timeIntervalSince1970 + 60.0, 0.001);
}

// end 被编辑到 start + 10s → 钳到 start + 60s。
- (void)testEditEndClampsToStartPlus60s {
    NSDate *base = [NSDate dateWithTimeIntervalSince1970:1000000];
    FSTSessionManager *session = [self sessionStartedAt:base];

    [session editActiveEndDate:[base dateByAddingTimeInterval:10.0] alignWithPlan:NO];

    XCTAssertEqualWithAccuracy(session.activeEndOverrideDate.timeIntervalSince1970,
                               base.timeIntervalSince1970 + 60.0, 0.001);
}

// end align:YES → 清 override，end 回到 plan 默认（start + 16h）。
- (void)testEditEndAlignWithPlanRestoresPlanDefault {
    NSDate *base = [NSDate dateWithTimeIntervalSince1970:1000000];
    FSTSessionManager *session = [self sessionStartedAt:base];
    [session editActiveEndDate:[base dateByAddingTimeInterval:2 * 3600.0] alignWithPlan:NO];

    [session editActiveEndDate:[base dateByAddingTimeInterval:5 * 3600.0] alignWithPlan:YES];

    XCTAssertNil(session.activeEndOverrideDate);
    XCTAssertEqualWithAccuracy([session activeExpectedEndDate].timeIntervalSince1970,
                               base.timeIntervalSince1970 + 16 * 3600.0, 0.001);
}

// 无活跃断食时 edit 不生效（guard）。
- (void)testEditIgnoredWithoutActiveFasting {
    FSTSessionManager *session = [[FSTSessionManager alloc] init];
    [session switchToPlanPreservingState:FSTTestPlan168()];

    [session editActiveStartDate:[NSDate dateWithTimeIntervalSince1970:1000000] alignWithPlan:YES];

    XCTAssertNil(session.activeStartDate);
}

// finish 后：record 入 shared repository、active 字段清空、吃窗口锚点 = record.endDate、scheduledReady 归 None。
- (void)testFinishFastingResetsToEatingWindow {
    NSDate *base = [NSDate dateWithTimeIntervalSince1970:1000000];
    FSTSessionManager *session = [self sessionStartedAt:base];

    FSTFastingRecord *record = [[FSTFastingRecord alloc] init];
    record.recordID = @"finished";
    record.startDate = base;
    record.endDate = [base dateByAddingTimeInterval:16 * 3600.0];
    [session finishFastingWithRecord:record];

    XCTAssertEqualObjects([[FSTRecordsRepository sharedRepository] allRecords].firstObject.recordID, @"finished");
    XCTAssertFalse(session.hasActiveFasting);
    XCTAssertNil(session.activeEndOverrideDate);
    XCTAssertEqualWithAccuracy(session.eatingWindowAnchorDate.timeIntervalSince1970,
                               record.endDate.timeIntervalSince1970, 0.001);
    XCTAssertEqual(session.scheduledReadySource, FSTScheduledReadySourceNone);
}

@end

#pragma mark - Persistence round-trip

// 三个模型的字典互转：全字段 round-trip + 空字典默认值 + 序列化时的体重默认替换。
// MealRecord 按枚举化后的整数存储格式断言（钉住 dietType 非 0 默认值，防回归）。
@interface FSTRecordPersistenceTests : XCTestCase
@end

@implementation FSTRecordPersistenceTests

- (void)testFastingRecordRoundTrip {
    FSTFastingRecord *record = [[FSTFastingRecord alloc] init];
    record.recordID = @"rid";
    record.planName = @"16-8";
    record.fastingHours = 16;
    record.startDate = [NSDate dateWithTimeIntervalSince1970:1000000];
    record.endDate   = [NSDate dateWithTimeIntervalSince1970:1057600];
    record.weightKg = 80.5;
    record.initialWeightKg = 82.0;
    record.targetWeightKg = 70.0;
    record.appleHealthEnabled = YES;
    record.feelingLevel = 2;
    record.note = @"note";

    FSTFastingRecord *decoded = [FSTFastingRecord fst_recordWithDictionary:[record fst_dictionaryRepresentation]];

    XCTAssertEqualObjects(decoded.recordID, @"rid");
    XCTAssertEqualObjects(decoded.planName, @"16-8");
    XCTAssertEqual(decoded.fastingHours, 16);
    XCTAssertEqualWithAccuracy(decoded.startDate.timeIntervalSince1970, 1000000, 0.001);
    XCTAssertEqualWithAccuracy(decoded.endDate.timeIntervalSince1970, 1057600, 0.001);
    XCTAssertEqualWithAccuracy(decoded.weightKg, 80.5, 0.001);
    XCTAssertEqualWithAccuracy(decoded.initialWeightKg, 82.0, 0.001);
    XCTAssertEqualWithAccuracy(decoded.targetWeightKg, 70.0, 0.001);
    XCTAssertTrue(decoded.appleHealthEnabled);
    XCTAssertEqual(decoded.feelingLevel, 2);
    XCTAssertEqualObjects(decoded.note, @"note");
}

- (void)testFastingRecordDefaultsForEmptyDictionary {
    FSTFastingRecord *record = [FSTFastingRecord fst_recordWithDictionary:@{}];

    XCTAssertTrue(record.recordID.length > 0);  // 自动补 UUID
    XCTAssertEqualObjects(record.planName, @"");
    XCTAssertEqual(record.fastingHours, 0);
    XCTAssertNil(record.startDate);
    XCTAssertNil(record.endDate);
    XCTAssertEqualWithAccuracy(record.weightKg, FSTDefaultCurrentWeightKg, 0.001);
    XCTAssertEqualWithAccuracy(record.initialWeightKg, FSTDefaultInitialWeightKg, 0.001);
    XCTAssertEqualWithAccuracy(record.targetWeightKg, FSTDefaultTargetWeightKg, 0.001);
    XCTAssertFalse(record.appleHealthEnabled);
    XCTAssertEqual(record.feelingLevel, 1);
    XCTAssertEqualObjects(record.note, @"");
}

// 序列化时 0 体重被替换为默认值（FSTWeightOrDefault 行为）。
- (void)testFastingRecordSerializationSubstitutesDefaultWeights {
    FSTFastingRecord *record = [[FSTFastingRecord alloc] init];
    record.recordID = @"rid";

    NSDictionary *dictionary = [record fst_dictionaryRepresentation];

    XCTAssertEqualWithAccuracy([dictionary[@"weightKg"] doubleValue], FSTDefaultCurrentWeightKg, 0.001);
    XCTAssertEqualWithAccuracy([dictionary[@"initialWeightKg"] doubleValue], FSTDefaultInitialWeightKg, 0.001);
    XCTAssertEqualWithAccuracy([dictionary[@"targetWeightKg"] doubleValue], FSTDefaultTargetWeightKg, 0.001);
}

- (void)testMealRecordRoundTrip {
    FSTMealRecord *record = [[FSTMealRecord alloc] init];
    record.recordID = @"mid";
    record.date = [NSDate dateWithTimeIntervalSince1970:2000000];
    record.mealCategory = FSTMealCategorySnack;
    record.dietType = FSTDietTypeHighCarb;
    record.tasteLevel = 2;
    record.detailDescription = @"desc";
    record.imagePath = @"MealImages/x.jpg";

    NSDictionary *dictionary = [record fst_dictionaryRepresentation];
    // 枚举字段以 NSNumber rawValue 落盘
    XCTAssertEqualObjects(dictionary[@"mealCategory"], @(FSTMealCategorySnack));
    XCTAssertEqualObjects(dictionary[@"dietType"], @(FSTDietTypeHighCarb));

    FSTMealRecord *decoded = [FSTMealRecord fst_recordWithDictionary:dictionary];
    XCTAssertEqualObjects(decoded.recordID, @"mid");
    XCTAssertEqualWithAccuracy(decoded.date.timeIntervalSince1970, 2000000, 0.001);
    XCTAssertEqual(decoded.mealCategory, FSTMealCategorySnack);
    XCTAssertEqual(decoded.dietType, FSTDietTypeHighCarb);
    XCTAssertEqual(decoded.tasteLevel, 2);
    XCTAssertEqualObjects(decoded.detailDescription, @"desc");
    XCTAssertEqualObjects(decoded.imagePath, @"MealImages/x.jpg");
}

// 钉住非 0 默认值：缺 key 时 dietType 必须是 NotSure（raw=4）而非零值 Keto。
- (void)testMealRecordDefaultsForEmptyDictionary {
    FSTMealRecord *record = [FSTMealRecord fst_recordWithDictionary:@{}];

    XCTAssertTrue(record.recordID.length > 0);
    XCTAssertNil(record.date);
    XCTAssertEqual(record.mealCategory, FSTMealCategoryMeal);
    XCTAssertEqual(record.dietType, FSTDietTypeNotSure);
    XCTAssertEqual(record.tasteLevel, 1);
    XCTAssertEqualObjects(record.detailDescription, @"");
    XCTAssertEqualObjects(record.imagePath, @"");
}

- (void)testMealRecordCopyPreservesEnumFields {
    FSTMealRecord *record = [[FSTMealRecord alloc] init];
    record.recordID = @"mid";
    record.mealCategory = FSTMealCategorySnack;
    record.dietType = FSTDietTypeLowCarb;

    FSTMealRecord *copy = [record copy];

    XCTAssertEqual(copy.mealCategory, FSTMealCategorySnack);
    XCTAssertEqual(copy.dietType, FSTDietTypeLowCarb);
}

// 内置方案按 type 匹配还原（不依赖 name）。
- (void)testPlanRoundTripMatchesBuiltinByType {
    FSTPlan *plan = FSTTestPlan168();

    FSTPlan *decoded = [FSTPlan fst_planWithDictionary:[plan fst_dictionaryRepresentation]];

    XCTAssertEqual(decoded.type, FSTPlanType168);
    XCTAssertEqual(decoded.fastingHours, 16);
    XCTAssertEqual(decoded.eatingHours, 8);
}

// 自定义方案从存储字段逐项重建。
- (void)testPlanCustomRebuildsFromStoredFields {
    NSDictionary *dictionary = @{@"type": @(FSTPlanTypeCustom), @"name": @"13-11",
                                 @"fastingHours": @13, @"eatingHours": @11, @"difficultyLevel": @1};

    FSTPlan *decoded = [FSTPlan fst_planWithDictionary:dictionary];

    XCTAssertEqual(decoded.type, FSTPlanTypeCustom);
    XCTAssertEqualObjects(decoded.name, @"13-11");
    XCTAssertEqual(decoded.fastingHours, 13);
    XCTAssertEqual(decoded.eatingHours, 11);
    XCTAssertEqual(decoded.difficultyLevel, 1);
}

- (void)testPlanReturnsNilWithoutName {
    XCTAssertNil([FSTPlan fst_planWithDictionary:@{@"type": @(FSTPlanTypeCustom)}]);
}

@end

#pragma mark - FSTFastingRecordBuilder

// FSTBuildFastingRecord：plan 默认值填充 / 无 plan 兜底 / existing 身份字段不被覆盖。
// 注意内部硬依赖 [FSTSessionManager sharedManager]，每个用例显式摆放单例状态，tearDown 清理防污染。
@interface FSTFastingRecordBuilderTests : XCTestCase
@end

@implementation FSTFastingRecordBuilderTests

- (void)setUp {
    [super setUp];
    FSTTestClearSessionDefaults();
    [[FSTSessionManager sharedManager] clearCurrentPlan];
    FSTTestClearSessionDefaults();  // clearCurrentPlan 会 persist，再洗一遍
}

- (void)tearDown {
    [[FSTSessionManager sharedManager] clearCurrentPlan];
    FSTTestClearSessionDefaults();
    [super tearDown];
}

- (void)testBuilderFillsDefaultsFromSharedManagerPlan {
    [[FSTSessionManager sharedManager] switchToPlanPreservingState:FSTTestPlan168()];
    NSDate *start = [NSDate dateWithTimeIntervalSince1970:1000000];
    NSDate *end = [start dateByAddingTimeInterval:16 * 3600.0];

    FSTFastingRecord *record = FSTBuildFastingRecord(nil, start, end, 80.0, 82.0, 70.0, 1, nil, NO);

    XCTAssertTrue(record.recordID.length > 0);
    XCTAssertEqualObjects(record.planName, @"16-8");
    XCTAssertEqual(record.fastingHours, 16);
    XCTAssertEqualObjects(record.startDate, start);
    XCTAssertEqualObjects(record.endDate, end);
    XCTAssertEqualObjects(record.note, @"");  // nil note → @""
}

// 钉住现状：无 plan 时 fallback 只兜 planName（@"14-10"），fastingHours 仍为 0。
- (void)testBuilderFallsBackTo1410WithoutPlan {
    NSDate *start = [NSDate dateWithTimeIntervalSince1970:1000000];

    FSTFastingRecord *record = FSTBuildFastingRecord(nil, start, [start dateByAddingTimeInterval:3600.0],
                                                     80.0, 82.0, 70.0, 1, nil, NO);

    XCTAssertEqualObjects(record.planName, @"14-10");
    XCTAssertEqual(record.fastingHours, 0);
}

// existing 的身份字段（recordID / planName / fastingHours）不被覆盖；起止/体重/感受更新。
- (void)testBuilderPreservesExistingIdentity {
    [[FSTSessionManager sharedManager] switchToPlanPreservingState:FSTTestPlan168()];
    FSTFastingRecord *existing = [[FSTFastingRecord alloc] init];
    existing.recordID = @"keep-id";
    existing.planName = @"20-4";
    existing.fastingHours = 20;

    NSDate *start = [NSDate dateWithTimeIntervalSince1970:1000000];
    NSDate *end = [start dateByAddingTimeInterval:20 * 3600.0];
    FSTFastingRecord *record = FSTBuildFastingRecord(existing, start, end, 79.0, 82.0, 70.0, 2, @"good", YES);

    XCTAssertEqual(record, existing);  // 原对象被复用
    XCTAssertEqualObjects(record.recordID, @"keep-id");
    XCTAssertEqualObjects(record.planName, @"20-4");
    XCTAssertEqual(record.fastingHours, 20);
    XCTAssertEqualObjects(record.startDate, start);
    XCTAssertEqualWithAccuracy(record.weightKg, 79.0, 0.001);
    XCTAssertEqual(record.feelingLevel, 2);
    XCTAssertEqualObjects(record.note, @"good");
    XCTAssertTrue(record.appleHealthEnabled);
}

@end
