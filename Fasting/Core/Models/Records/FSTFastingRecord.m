//
//  FSTFastingRecord.m
//  Fasting
//
//  仅承担数据声明与纯数据派生计算；与 NSDictionary 的互转交给
//  FSTFastingRecord+Persistence / FSTMealRecord+Persistence Category。
//

#import "FSTFastingRecord.h"

static const NSInteger kFSTDifficultyHardThreshold   = 20;
static const NSInteger kFSTDifficultyMediumThreshold = 18;

@implementation FSTFastingRecord

- (NSTimeInterval)durationSeconds {
    if (!self.startDate || !self.endDate) return 0;
    return [self.endDate timeIntervalSinceDate:self.startDate];
}

- (NSInteger)difficultyLevel {
    if (self.fastingHours >= kFSTDifficultyHardThreshold)   return 3;
    if (self.fastingHours >= kFSTDifficultyMediumThreshold) return 2;
    return 1;
}

@end

@implementation FSTMealRecord
@end
