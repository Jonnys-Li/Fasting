//
//  FSTSessionPersistenceService.h
//  Fasting
//
//  集中 NSUserDefaults 读写。SessionManager 把状态字段交给本 service 持久化；
//  NextStartOverride 单独导出，供 FSTNextFastService 使用。
//

#import <Foundation/Foundation.h>
#import "FSTWeightUnit.h"

NS_ASSUME_NONNULL_BEGIN

@class FSTSessionManager;

@interface FSTSessionPersistenceService : NSObject

+ (void)loadSession:(FSTSessionManager *)session;
+ (void)saveActiveStateForSession:(FSTSessionManager *)session;
+ (void)saveEatingWindowAnchorForSession:(FSTSessionManager *)session;
+ (void)saveOnboardingForSession:(FSTSessionManager *)session;
+ (void)saveScheduledReadyStateForSession:(FSTSessionManager *)session;
+ (void)saveAllForSession:(FSTSessionManager *)session;
+ (void)setPreferredWeightUnit:(FSTWeightUnit)unit;

/// Next-start override: 用户在 Plan 页 Schedule 的下次起点（可为 nil）。
+ (NSDate *_Nullable)nextStartOverrideDate;
+ (NSDate *_Nullable)nextStartOverrideAnchorDate;
+ (void)setNextStartOverrideDate:(NSDate *_Nullable)date;
+ (void)clearNextStartOverride;

@end

NS_ASSUME_NONNULL_END
