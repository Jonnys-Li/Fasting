#import <XCTest/XCTest.h>
#import "../Fasting/Core/Models/Records/FSTFastingRecord.m"
#import "../Fasting/Core/Models/Records/FSTFastingRecord+Persistence.m"
#import "../Fasting/Core/Models/Records/FSTMealRecord+Persistence.m"
#import "../Fasting/Core/Models/Records/FSTPlan.m"
#import "../Fasting/Core/Services/RecordsRepository/FSTRecordsRepository.m"
#import "../Fasting/Core/Services/Session/FSTSessionLifecycleService.m"
#import "../Fasting/Core/Services/Session/FSTSessionManager.m"
#import "../Fasting/Core/Services/Session/FSTSessionPersistenceService.m"
#import "../Fasting/Core/Services/Session/FSTNextFastService.m"

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
    FSTRecordsRepository *repository = [FSTRecordsRepository new];
    [repository setValue:[NSMutableArray array] forKey:@"records"];
    [repository setValue:[NSMutableArray array] forKey:@"mealRecords"];

    NSDate *base = [NSDate dateWithTimeIntervalSince1970:2000];
    FSTFastingRecord *older = [FSTFastingRecord new];
    older.recordID = @"older";
    older.startDate = base;
    older.endDate = [base dateByAddingTimeInterval:1000];
    older.fastingHours = 14;

    FSTFastingRecord *newer = [FSTFastingRecord new];
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
    FSTRecordsRepository *repository = [FSTRecordsRepository new];
    [repository setValue:[NSMutableArray array] forKey:@"records"];
    [repository setValue:[NSMutableArray array] forKey:@"mealRecords"];

    NSDate *base = [NSDate dateWithTimeIntervalSince1970:3000];
    FSTMealRecord *breakfast = [FSTMealRecord new];
    breakfast.recordID = @"breakfast";
    breakfast.date = base;

    FSTMealRecord *dinner = [FSTMealRecord new];
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
    FSTSessionManager *manager = [FSTSessionManager new];
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
