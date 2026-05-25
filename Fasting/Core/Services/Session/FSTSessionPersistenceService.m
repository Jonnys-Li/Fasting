//
//  FSTSessionPersistenceService.m
//  Fasting
//
//  集中 NSUserDefaults 的 key 常量与读写实现。SessionManager 只把自己交给本 service 做存储；
//  setNextStartOverrideDate / nextStartOverrideDate 单独导出，供 FSTNextFastService 使用。
//

#import "FSTSessionPersistenceService.h"
#import "FSTSessionManager+Internal.h"
#import "FSTPlan.h"

static NSString * const FSTCurrentPlanKey            = @"kFSTCurrentPlan";
static NSString * const FSTActiveStartTimeKey        = @"kFSTActiveStartTime";
static NSString * const FSTActiveEndOverrideTimeKey  = @"kFSTActiveEndOverrideTime";
static NSString * const FSTNextStartOverrideKey      = @"kFSTNextStartOverride";
static NSString * const FSTEatingWindowAnchorTimeKey = @"kFSTEatingWindowAnchorTime";
static NSString * const FSTOnboardingCompletedKey    = @"kFSTOnboardingCompleted";
static NSString * const FSTScheduledReadySourceKey   = @"kFSTScheduledReadySource";
static NSString * const FSTScheduledReadyAnchorTimeKey = @"kFSTScheduledReadyAnchorTime";
static NSString * const FSTPreferredWeightUnitKey    = @"kFSTPreferredWeightUnit";

@implementation FSTSessionPersistenceService

+ (NSUserDefaults *)defaults {
    return [NSUserDefaults standardUserDefaults];
}

/// 统一的 NSDate <-> NSNumber(timeIntervalSince1970) 读写：消除每个 key 重复的 nil 检查。
+ (NSDate *)dateForKey:(NSString *)key {
    NSNumber *value = [[self defaults] objectForKey:key];
    return value != nil ? [NSDate dateWithTimeIntervalSince1970:value.doubleValue] : nil;
}

+ (void)setDate:(NSDate *)date forKey:(NSString *)key {
    if (date) {
        [[self defaults] setObject:@(date.timeIntervalSince1970) forKey:key];
    } else {
        [[self defaults] removeObjectForKey:key];
    }
}

#pragma mark - Bulk

+ (void)loadSession:(FSTSessionManager *)session {
    NSUserDefaults *defaults = [self defaults];

    session.hasCompletedOnboarding = [[defaults objectForKey:FSTOnboardingCompletedKey] boolValue];

    NSDictionary *planDictionary = [defaults objectForKey:FSTCurrentPlanKey];
    session.currentPlan = planDictionary ? [FSTPlan fst_planWithDictionary:planDictionary] : nil;

    session.activeStartDate        = [self dateForKey:FSTActiveStartTimeKey];
    session.activeEndOverrideDate  = [self dateForKey:FSTActiveEndOverrideTimeKey];
    session.eatingWindowAnchorDate = [self dateForKey:FSTEatingWindowAnchorTimeKey];

    NSNumber *scheduledSourceValue = [defaults objectForKey:FSTScheduledReadySourceKey];
    session.scheduledReadySource = scheduledSourceValue != nil ? scheduledSourceValue.integerValue : FSTScheduledReadySourceNone;
    session.scheduledReadyAnchorDate = [self dateForKey:FSTScheduledReadyAnchorTimeKey];
    if (session.scheduledReadySource == FSTScheduledReadySourceNone) {
        // None 态不该有 anchor 残留，强制清空一次避免老数据污染。
        session.scheduledReadyAnchorDate = nil;
    }

    session.preferredWeightUnit = [defaults integerForKey:FSTPreferredWeightUnitKey];
}

+ (void)saveActiveStateForSession:(FSTSessionManager *)session {
    NSUserDefaults *defaults = [self defaults];
    if (session.currentPlan) {
        [defaults setObject:[session.currentPlan fst_dictionaryRepresentation] forKey:FSTCurrentPlanKey];
    } else {
        [defaults removeObjectForKey:FSTCurrentPlanKey];
    }
    [self setDate:session.activeStartDate forKey:FSTActiveStartTimeKey];
    [self setDate:session.activeEndOverrideDate forKey:FSTActiveEndOverrideTimeKey];
}

+ (void)saveEatingWindowAnchorForSession:(FSTSessionManager *)session {
    [self setDate:session.eatingWindowAnchorDate forKey:FSTEatingWindowAnchorTimeKey];
}

+ (void)saveOnboardingForSession:(FSTSessionManager *)session {
    if (session.hasCompletedOnboarding) {
        [[self defaults] setBool:YES forKey:FSTOnboardingCompletedKey];
    } else {
        [[self defaults] removeObjectForKey:FSTOnboardingCompletedKey];
    }
}

+ (void)saveScheduledReadyStateForSession:(FSTSessionManager *)session {
    NSUserDefaults *defaults = [self defaults];
    if (session.scheduledReadySource != FSTScheduledReadySourceNone) {
        [defaults setObject:@(session.scheduledReadySource) forKey:FSTScheduledReadySourceKey];
    } else {
        [defaults removeObjectForKey:FSTScheduledReadySourceKey];
    }
    NSDate *anchorToSave = session.scheduledReadySource != FSTScheduledReadySourceNone ? session.scheduledReadyAnchorDate : nil;
    [self setDate:anchorToSave forKey:FSTScheduledReadyAnchorTimeKey];
}

+ (void)saveAllForSession:(FSTSessionManager *)session {
    [self saveActiveStateForSession:session];
    [self saveEatingWindowAnchorForSession:session];
    [self saveOnboardingForSession:session];
    [self saveScheduledReadyStateForSession:session];
}

+ (void)setPreferredWeightUnit:(FSTWeightUnit)unit {
    [[self defaults] setInteger:unit forKey:FSTPreferredWeightUnitKey];
}

#pragma mark - Next-start override (供 FSTNextFastService / SessionManager 调用)

+ (NSDate *)nextStartOverrideDate {
    return [self dateForKey:FSTNextStartOverrideKey];
}

+ (void)setNextStartOverrideDate:(NSDate *)date {
    [self setDate:date forKey:FSTNextStartOverrideKey];
}

+ (void)clearNextStartOverride {
    [[self defaults] removeObjectForKey:FSTNextStartOverrideKey];
}

@end
