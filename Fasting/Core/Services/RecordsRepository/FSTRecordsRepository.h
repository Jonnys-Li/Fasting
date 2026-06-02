//
//  FSTRecordsRepository.h
//  Fasting
//
//  历史断食记录与饮食记录的单点入口。负责 NSUserDefaults 持久化、按 recordID 增删查、
//  以及 FSTRecordsDidChangeNotification 广播。
//
//  与 FSTSessionManager 分工：
//    - 本类管 records / mealRecords 的数组与持久化；
//    - FSTSessionManager 管 plan / active session / scheduled / preference 等"会话"字段。
//      FSTSessionManager.finishFastingWithRecord: 内部转发到本类的 -updateFastingRecord:。
//

#import <Foundation/Foundation.h>
#import "FSTFastingRecord.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const FSTRecordsDidChangeNotification;

@interface FSTRecordsRepository : NSObject

+ (instancetype)sharedRepository;

// 断食记录（按 endDate 倒序）
- (NSArray<FSTFastingRecord *> *)allRecords;
- (void)updateFastingRecord:(FSTFastingRecord *)record;
- (void)deleteFastingRecord:(FSTFastingRecord *)record;

// 饮食记录（按 date 倒序）
- (NSArray<FSTMealRecord *> *)allMealRecords;
- (void)addOrUpdateMealRecord:(FSTMealRecord *)record;
- (void)deleteMealRecord:(FSTMealRecord *)record;

// 派生
- (nullable NSDate *)latestFastingEndDate;
- (nullable NSDate *)latestMealDate;

@end

NS_ASSUME_NONNULL_END
