//
//  FSTFastingTimingService.m
//  Fasting
//

#import "FSTFastingTimingService.h"
#import "FSTPercentFormatter.h"
#import <math.h>

@interface FSTFastingTiming ()
@property (nonatomic, readwrite) NSTimeInterval elapsedSeconds;
@property (nonatomic, readwrite) NSTimeInterval remainingSeconds;
@property (nonatomic, readwrite) NSTimeInterval overtimeSeconds;
@property (nonatomic, readwrite) CGFloat elapsedFraction;
@property (nonatomic, readwrite) CGFloat elapsedClampedFraction;
@property (nonatomic, readwrite) CGFloat remainingFraction;
@property (nonatomic, readwrite) NSInteger elapsedPercent;
@property (nonatomic, readwrite) NSInteger remainingPercent;
@property (nonatomic, readwrite) NSInteger overtimePercent;
@property (nonatomic, readwrite) BOOL targetReached;
@property (nonatomic, readwrite) BOOL overtime;
@end

@implementation FSTFastingTiming
@end

@implementation FSTFastingTimingService

+ (FSTFastingTiming *)timingForElapsedSeconds:(NSTimeInterval)elapsedSeconds
                        targetDurationSeconds:(NSTimeInterval)targetSeconds {
    NSTimeInterval safeElapsed = MAX(0, elapsedSeconds);
    NSTimeInterval safeTarget  = MAX(1, targetSeconds);  // 钳到 ≥1，防止除零
    NSTimeInterval remaining   = MAX(0, safeTarget - safeElapsed);
    NSTimeInterval overtime    = MAX(0, safeElapsed - safeTarget);
    NSInteger overtimeWhole    = (NSInteger)floor(overtime);

    CGFloat rawFraction       = (CGFloat)(safeElapsed / safeTarget);
    CGFloat clampedFraction   = MIN(1.0, rawFraction);
    CGFloat remainingFraction = (CGFloat)(remaining / safeTarget);
    BOOL targetReached        = safeElapsed >= safeTarget;
    BOOL inOvertime           = overtimeWhole > 0;

    NSInteger elapsedPercent  = [FSTPercentFormatter clampedPercentForFraction:rawFraction targetReached:targetReached];
    NSInteger remainingPercent = targetReached ? 0 : (100 - elapsedPercent);
    NSInteger overtimePercent  = inOvertime ? [FSTPercentFormatter overtimePercentForFraction:rawFraction] : elapsedPercent;

    FSTFastingTiming *timing = [FSTFastingTiming new];
    timing.elapsedSeconds         = safeElapsed;
    timing.remainingSeconds       = remaining;
    timing.overtimeSeconds        = overtime;
    timing.elapsedFraction        = rawFraction;
    timing.elapsedClampedFraction = clampedFraction;
    timing.remainingFraction      = remainingFraction;
    timing.elapsedPercent         = elapsedPercent;
    timing.remainingPercent       = remainingPercent;
    timing.overtimePercent        = overtimePercent;
    timing.targetReached          = targetReached;
    timing.overtime               = inOvertime;
    return timing;
}

@end
