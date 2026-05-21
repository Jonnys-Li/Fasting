//
//  FSTEatingWindowService.h
//  Fasting
//
//  吃窗口期计算服务：根据当前 plan、下次断食起始时间、上次断食结束时间，
//  推导出吃窗口当前进度、剩余时间、是否可开始断食、距上次断食过去多久。
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class FSTPlan;

NS_ASSUME_NONNULL_BEGIN

/// 吃窗口当前状态的不可变快照。
@interface FSTEatingWindowState : NSObject

/// 自吃窗口开始已过秒数。
@property (nonatomic, readonly) NSTimeInterval elapsedSeconds;

/// 距下次断食开始的剩余秒数（吃窗口剩余）；可开始时为 0。
@property (nonatomic, readonly) NSTimeInterval remainingSeconds;

/// 距上次断食结束已过去的秒数；
/// 可开始态（已超过 nextStartDate）下表示已经过了多久还没开始。
@property (nonatomic, readonly) NSTimeInterval timeSinceLastFastSeconds;

/// 吃窗口进度，钳到 [0, 1]。
@property (nonatomic, readonly) CGFloat progress;

/// 是否已经可以开始断食（吃窗口剩余 ≤ 0）。
@property (nonatomic, readonly) BOOL readyToStart;

/// 下次断食开始时间（与入参一致或派生默认值）。
@property (nonatomic, readonly, strong) NSDate *nextStartDate;

/// 下次断食结束时间 = nextStartDate + plan.fastingHours。
@property (nonatomic, readonly, strong) NSDate *nextEndDate;

@end

/// 吃窗口期换算静态工厂。
@interface FSTEatingWindowService : NSObject

/// 推导吃窗口当前状态。
///
/// @param plan              当前选中的计划。其 eatingHours / fastingHours 用于窗口换算。
/// @param nextStartDate     下次断食开始时间。nil 时用 now + eatingHours 默认。
/// @param latestFastEndDate 上次断食结束时间。nil 时退化为本次吃窗口开始时间。
/// @param referenceDate     参考时间（通常是 now，注入便于稳定计算）。
+ (FSTEatingWindowState *)stateForPlan:(FSTPlan *)plan
                          nextStartDate:(nullable NSDate *)nextStartDate
                      latestFastEndDate:(nullable NSDate *)latestFastEndDate
                          referenceDate:(NSDate *)referenceDate;

@end

NS_ASSUME_NONNULL_END
