//
//  FSTFastingRecord.m
//  Fasting
//
//  仅承担数据声明与纯数据派生计算；与 NSDictionary 的互转交给
//  FSTFastingRecord+Persistence / FSTMealRecord+Persistence Category。
//

#import "FSTFastingRecord.h"

#pragma mark - Weight defaults

const CGFloat FSTDefaultCurrentWeightKg = 81.2;
const CGFloat FSTDefaultInitialWeightKg = 81.2;
const CGFloat FSTDefaultTargetWeightKg  = 70.0;

#pragma mark - Difficulty thresholds

static const NSInteger kDifficultyHardThreshold   = 20;
static const NSInteger kDifficultyMediumThreshold = 18;

@implementation FSTFastingRecord

- (NSTimeInterval)durationSeconds {
    if (!self.startDate || !self.endDate) return 0;
    return [self.endDate timeIntervalSinceDate:self.startDate];
}

- (NSInteger)difficultyLevel {
    if (self.fastingHours >= kDifficultyHardThreshold)   return 3;
    if (self.fastingHours >= kDifficultyMediumThreshold) return 2;
    return 1;
}

@end

@implementation FSTMealRecord

- (id)copyWithZone:(NSZone *)zone {
    FSTMealRecord *copy = [[FSTMealRecord alloc] init];
    copy.recordID          = self.recordID;
    copy.date              = self.date;
    copy.mealCategory      = self.mealCategory;
    copy.dietType          = self.dietType;
    copy.tasteLevel        = self.tasteLevel;
    copy.detailDescription = self.detailDescription;
    copy.imagePath         = self.imagePath;
    return copy;
}

@end
