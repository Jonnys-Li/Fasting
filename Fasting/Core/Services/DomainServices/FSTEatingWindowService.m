//
//  FSTEatingWindowService.m
//  Fasting
//

#import "FSTEatingWindowService.h"
#import "FSTPlan.h"

static const NSTimeInterval kFSTEatingWindowDefaultEatingHours  = 10.0;
static const NSTimeInterval kFSTEatingWindowDefaultFastingHours = 14.0;
static const NSTimeInterval kFSTEatingWindowSecondsPerHour      = 3600.0;

@interface FSTEatingWindowState ()
@property (nonatomic, readwrite) NSTimeInterval elapsedSeconds;
@property (nonatomic, readwrite) NSTimeInterval remainingSeconds;
@property (nonatomic, readwrite) NSTimeInterval timeSinceLastFastSeconds;
@property (nonatomic, readwrite) CGFloat progress;
@property (nonatomic, readwrite) BOOL readyToStart;
@property (nonatomic, readwrite, strong) NSDate *nextStartDate;
@property (nonatomic, readwrite, strong) NSDate *nextEndDate;
@end

@implementation FSTEatingWindowState
@end

@implementation FSTEatingWindowService

+ (FSTEatingWindowState *)stateForPlan:(FSTPlan *)plan
                          nextStartDate:(nullable NSDate *)nextStartDate
                      latestFastEndDate:(nullable NSDate *)latestFastEndDate
                          referenceDate:(NSDate *)referenceDate {
    NSDate *now = referenceDate ?: [NSDate date];
    NSTimeInterval eatingHours = plan.eatingHours > 0 ? plan.eatingHours : kFSTEatingWindowDefaultEatingHours;
    NSTimeInterval fastingHours = plan.fastingHours > 0 ? plan.fastingHours : kFSTEatingWindowDefaultFastingHours;
    NSTimeInterval eatingWindowSeconds  = MAX(1, eatingHours * kFSTEatingWindowSecondsPerHour);
    NSTimeInterval fastingWindowSeconds = MAX(1, fastingHours * kFSTEatingWindowSecondsPerHour);

    NSDate *resolvedNextStart = nextStartDate ?: [now dateByAddingTimeInterval:eatingWindowSeconds];
    NSDate *windowStartDate   = [resolvedNextStart dateByAddingTimeInterval:-eatingWindowSeconds];
    NSDate *resolvedNextEnd   = [resolvedNextStart dateByAddingTimeInterval:fastingWindowSeconds];

    NSTimeInterval elapsed   = MAX(0, [now timeIntervalSinceDate:windowStartDate]);
    NSTimeInterval remaining = MAX(0, [resolvedNextStart timeIntervalSinceDate:now]);
    BOOL readyToStart        = remaining <= 0.0;

    // 可开始态：以 nextStartDate 为基准衡量"还没开始多久"；否则以上次结束时间为基准
    NSDate *lastEndAnchor = latestFastEndDate ?: windowStartDate;
    NSTimeInterval timeSinceLastFast = readyToStart ? MAX(0, [now timeIntervalSinceDate:resolvedNextStart])
                                                    : MAX(0, [now timeIntervalSinceDate:lastEndAnchor]);

    FSTEatingWindowState *state = [FSTEatingWindowState new];
    state.elapsedSeconds           = elapsed;
    state.remainingSeconds         = remaining;
    state.timeSinceLastFastSeconds = timeSinceLastFast;
    state.progress                 = (CGFloat)MIN(1.0, elapsed / eatingWindowSeconds);
    state.readyToStart             = readyToStart;
    state.nextStartDate            = resolvedNextStart;
    state.nextEndDate              = resolvedNextEnd;
    return state;
}

@end
