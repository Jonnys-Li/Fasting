//
//  FSTSessionLifecycleService.h
//  Fasting
//
//  集中 SessionManager 所有 mutation 入口。每个方法直接改 session 字段并触发持久化 + 通知。
//

#import "FSTSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@class FSTPlan, FSTFastingRecord;

@interface FSTSessionLifecycleService : NSObject

+ (void)startSession:(FSTSessionManager *)session plan:(FSTPlan *)plan startDate:(NSDate *)date;
+ (void)cancelSession:(FSTSessionManager *)session;
+ (void)finishSession:(FSTSessionManager *)session record:(FSTFastingRecord *)record;
+ (void)clearPlanForSession:(FSTSessionManager *)session;
+ (void)switchSession:(FSTSessionManager *)session toPlan:(FSTPlan *)plan;
+ (void)markSession:(FSTSessionManager *)session
scheduledReadyWithSource:(FSTScheduledReadySource)source
         anchorDate:(NSDate *_Nullable)anchorDate;
+ (void)clearScheduledReadyForSession:(FSTSessionManager *)session;
+ (void)beginEatingWindowForSession:(FSTSessionManager *)session fromDate:(NSDate *_Nullable)date;
+ (void)scheduleSession:(FSTSessionManager *)session
           atFutureDate:(NSDate *)futureDate
                 source:(FSTScheduledReadySource)source;
+ (void)editStartForSession:(FSTSessionManager *)session
                       date:(NSDate *)date
              alignWithPlan:(BOOL)alignWithPlan;
+ (void)editEndForSession:(FSTSessionManager *)session
                     date:(NSDate *)date
            alignWithPlan:(BOOL)alignWithPlan;

@end

NS_ASSUME_NONNULL_END
