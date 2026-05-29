//
//  FSTFastingRecord+Persistence.m
//  Fasting
//

#import "FSTFastingRecord.h"

#pragma mark - Defaults

// 感觉等级（体重默认值见 FSTFastingRecord.h）
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
    record.weightKg           = dictionary[@"weightKg"]           ? [dictionary[@"weightKg"]           doubleValue]  : FSTDefaultCurrentWeightKg;
    record.initialWeightKg    = dictionary[@"initialWeightKg"]    ? [dictionary[@"initialWeightKg"]    doubleValue]  : FSTDefaultInitialWeightKg;
    record.targetWeightKg     = dictionary[@"targetWeightKg"]     ? [dictionary[@"targetWeightKg"]     doubleValue]  : FSTDefaultTargetWeightKg;
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
    dictionary[@"weightKg"]           = @(FSTWeightOrDefault(self.weightKg,        FSTDefaultCurrentWeightKg));
    dictionary[@"initialWeightKg"]    = @(FSTWeightOrDefault(self.initialWeightKg, FSTDefaultInitialWeightKg));
    dictionary[@"targetWeightKg"]     = @(FSTWeightOrDefault(self.targetWeightKg,  FSTDefaultTargetWeightKg));
    dictionary[@"appleHealthEnabled"] = @(self.appleHealthEnabled);
    dictionary[@"feelingLevel"]       = @(self.feelingLevel);
    dictionary[@"note"]               = self.note ?: @"";
    return [dictionary copy];
}

@end
