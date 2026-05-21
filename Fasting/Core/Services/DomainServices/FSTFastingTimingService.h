//
//  FSTFastingTimingService.h
//  Fasting
//
//  断食时间换算服务：从 elapsed / target 推导出 UI 需要的全部派生值（remaining、overtime、
//  fraction、percent、targetReached）。不可变结果对象 FSTFastingTiming 由 VC 直接读取后
//  通过 setter 推入 RootView。
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

/// 断食时序的派生快照。所有字段在构造完成后不可变。
@interface FSTFastingTiming : NSObject

/// 实际已用秒数（不为负）。
@property (nonatomic, readonly) NSTimeInterval elapsedSeconds;

/// 距离目标剩余秒数；达成目标后为 0。
@property (nonatomic, readonly) NSTimeInterval remainingSeconds;

/// 超出目标的秒数；未达成时为 0。
@property (nonatomic, readonly) NSTimeInterval overtimeSeconds;

/// 已用 / 目标，未做钳制。超时态下大于 1。
@property (nonatomic, readonly) CGFloat elapsedFraction;

/// 已用 / 目标，钳到 [0, 1]。用于圆环的"进度"展示。
@property (nonatomic, readonly) CGFloat elapsedClampedFraction;

/// 剩余 / 目标，钳到 [0, 1]。
@property (nonatomic, readonly) CGFloat remainingFraction;

/// 已用整数百分比（未达目标钳到 99，达成钳到 100）。
@property (nonatomic, readonly) NSInteger elapsedPercent;

/// 剩余整数百分比（targetReached 时为 0，否则 = 100 - elapsedPercent）。
@property (nonatomic, readonly) NSInteger remainingPercent;

/// 超时态下的整数百分比（不小于 101）；未超时为 elapsedPercent。
@property (nonatomic, readonly) NSInteger overtimePercent;

/// 是否达到目标（含超时）。
@property (nonatomic, readonly) BOOL targetReached;

/// 是否进入超时（overtimeSeconds 至少一整秒）。
@property (nonatomic, readonly) BOOL overtime;

@end

/// 断食时序换算静态工厂。
@interface FSTFastingTimingService : NSObject

/// 由 elapsedSeconds / targetSeconds 推导出全部派生值。
///
/// @param elapsedSeconds 实际已用秒数（来自 FSTSessionManager.elapsedSeconds）
/// @param targetSeconds  目标秒数（来自 FSTSessionManager.activeTargetDurationSeconds）
+ (FSTFastingTiming *)timingForElapsedSeconds:(NSTimeInterval)elapsedSeconds
                        targetDurationSeconds:(NSTimeInterval)targetSeconds;

@end

NS_ASSUME_NONNULL_END
