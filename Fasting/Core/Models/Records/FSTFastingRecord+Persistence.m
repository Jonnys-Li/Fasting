//
//  FSTFastingRecord+Persistence.m
//  Fasting
//

#import "FSTFastingRecord.h"

#pragma mark - Defaults

// 体重（kg）
static const CGFloat kDefaultCurrentWeightKg = 81.2;
static const CGFloat kDefaultInitialWeightKg = 81.2;
static const CGFloat kDefaultTargetWeightKg  = 70.0;

// 感觉等级
static const NSInteger kDefaultFeelingLevel = 1;

@implementation FSTFastingRecord (Persistence)

+ (instancetype)fst_recordWithDictionary:(NSDictionary *)dictionary {
    FSTFastingRecord *record = [FSTFastingRecord new];
    record.recordID     = dictionary[@"recordID"] ?: [[NSUUID UUID] UUIDString];
    record.planName     = dictionary[@"planName"] ?: @"";
    record.fastingHours = [dictionary[@"fastingHours"] integerValue];
    NSNumber *startTimeInterval = dictionary[@"startTimeInterval"];
    NSNumber *endTimeInterval   = dictionary[@"endTimeInterval"];
    record.startDate = startTimeInterval != nil ? [NSDate dateWithTimeIntervalSince1970:startTimeInterval.doubleValue] : nil;
    record.endDate   = endTimeInterval   != nil ? [NSDate dateWithTimeIntervalSince1970:endTimeInterval.doubleValue]   : nil;
    record.weightKg           = dictionary[@"weightKg"]           ? [dictionary[@"weightKg"]           doubleValue]  : kDefaultCurrentWeightKg;
    record.initialWeightKg    = dictionary[@"initialWeightKg"]    ? [dictionary[@"initialWeightKg"]    doubleValue]  : kDefaultInitialWeightKg;
    record.targetWeightKg     = dictionary[@"targetWeightKg"]     ? [dictionary[@"targetWeightKg"]     doubleValue]  : kDefaultTargetWeightKg;
    record.appleHealthEnabled = dictionary[@"appleHealthEnabled"] ? [dictionary[@"appleHealthEnabled"] boolValue]    : NO;
    record.feelingLevel       = dictionary[@"feelingLevel"]       ? [dictionary[@"feelingLevel"]       integerValue] : kDefaultFeelingLevel;
    record.note               = dictionary[@"note"] ?: @"";
    return record;
}

- (NSDictionary *)fst_dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[@"recordID"]           = self.recordID ?: [[NSUUID UUID] UUIDString];
    dictionary[@"planName"]           = self.planName ?: @"";
    dictionary[@"fastingHours"]       = @(self.fastingHours);
    if (self.startDate) dictionary[@"startTimeInterval"] = @(self.startDate.timeIntervalSince1970);
    if (self.endDate)   dictionary[@"endTimeInterval"]   = @(self.endDate.timeIntervalSince1970);
    dictionary[@"weightKg"]           = @(self.weightKg        > 0 ? self.weightKg        : kDefaultCurrentWeightKg);
    dictionary[@"initialWeightKg"]    = @(self.initialWeightKg > 0 ? self.initialWeightKg : kDefaultInitialWeightKg);
    dictionary[@"targetWeightKg"]     = @(self.targetWeightKg  > 0 ? self.targetWeightKg  : kDefaultTargetWeightKg);
    dictionary[@"appleHealthEnabled"] = @(self.appleHealthEnabled);
    dictionary[@"feelingLevel"]       = @(self.feelingLevel);
    dictionary[@"note"]               = self.note ?: @"";
    return [dictionary copy];
}

@end
