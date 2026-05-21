//
//  FSTPercentFormatter.h
//  Fasting
//
//  断食进度百分比格式化工具：把 [0, +∞) 的 fraction 映射成 UI 展示用的整数百分比。
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

/// 把"已用 / 目标"小数比例换算成 UI 展示的整数百分比。封装的两个映射规则在多处复用，故集中放置。
@interface FSTPercentFormatter : NSObject

/// 进行中或刚到达目标时的整数百分比。
///
/// 规则：未到目标时上限钳到 99（避免 99.6% 被四舍五入显示为 100%），到达目标时才允许 100。
///
/// @param fraction 已用秒数除以目标秒数，允许 > 1
/// @param targetReached 是否已达到目标时长
+ (NSInteger)clampedPercentForFraction:(CGFloat)fraction targetReached:(BOOL)targetReached;

/// 超时态的整数百分比。
///
/// 规则：保证至少为 101，避免在超时瞬间仍显示 100。
///
/// @param fraction 已用秒数除以目标秒数（此时通常 > 1）
+ (NSInteger)overtimePercentForFraction:(CGFloat)fraction;

@end

NS_ASSUME_NONNULL_END
