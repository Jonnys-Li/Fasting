//
//  FSTPercentFormatter.m
//  Fasting
//

#import "FSTPercentFormatter.h"
#import <math.h>

@implementation FSTPercentFormatter

+ (NSInteger)clampedPercentForFraction:(CGFloat)fraction targetReached:(BOOL)targetReached {
    NSInteger percent = (NSInteger)lround(MAX(0, fraction) * 100.0);
    if (targetReached) {
        return MIN(100, MAX(0, percent));
    }
    // 未达目标时禁止四舍五入到 100，否则圆环未满却显示 100%
    return MIN(99, MAX(0, percent));
}

+ (NSInteger)overtimePercentForFraction:(CGFloat)fraction {
    NSInteger percent = (NSInteger)ceil(MAX(0, fraction) * 100.0);
    // 超时瞬间 fraction 可能仍为 1.0，向上取整后仍是 100；强制下限 101
    return MAX(101, percent);
}

@end
