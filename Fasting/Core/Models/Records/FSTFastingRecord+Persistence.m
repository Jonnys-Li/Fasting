//
//  FSTFastingRecord+Persistence.m
//  Fasting
//

#import "FSTFastingRecord+Persistence.h"

static const CGFloat kFSTFastingRecordDefaultCurrentWeightKg = 81.2;
static const CGFloat kFSTFastingRecordDefaultInitialWeightKg = 81.2;
static const CGFloat kFSTFastingRecordDefaultTargetWeightKg  = 70.0;
static const NSInteger kFSTFastingRecordDefaultFeelingLevel  = 1;

@implementation FSTFastingRecord (Persistence)

+ (instancetype)fst_recordWithDictionary:(NSDictionary *)dictionary {
    FSTFastingRecord *record = [FSTFastingRecord new];
    record.recordID     = dictionary[@"recordID"] ?: [[NSUUID UUID] UUIDString];
    record.planName     = dictionary[@"planName"] ?: @"";
    record.fastingHours = [dictionary[@"fastingHours"] integerValue];
    NSNumber *startTimeInterval = dictionary[@"startTimeInterval"];
    NSNumber *endTimeInterval   = dictionary[@"endTimeInterval"];
    record.startDate = startTimeInterval ? [NSDate dateWithTimeIntervalSince1970:startTimeInterval.doubleValue] : nil;
    record.endDate   = endTimeInterval   ? [NSDate dateWithTimeIntervalSince1970:endTimeInterval.doubleValue]   : nil;
    record.weightKg           = dictionary[@"weightKg"]           ? [dictionary[@"weightKg"]           doubleValue]  : kFSTFastingRecordDefaultCurrentWeightKg;
    record.initialWeightKg    = dictionary[@"initialWeightKg"]    ? [dictionary[@"initialWeightKg"]    doubleValue]  : kFSTFastingRecordDefaultInitialWeightKg;
    record.targetWeightKg     = dictionary[@"targetWeightKg"]     ? [dictionary[@"targetWeightKg"]     doubleValue]  : kFSTFastingRecordDefaultTargetWeightKg;
    record.appleHealthEnabled = dictionary[@"appleHealthEnabled"] ? [dictionary[@"appleHealthEnabled"] boolValue]    : NO;
    record.feelingLevel       = dictionary[@"feelingLevel"]       ? [dictionary[@"feelingLevel"]       integerValue] : kFSTFastingRecordDefaultFeelingLevel;
    record.note               = dictionary[@"note"] ?: @"";
    return record;
}

- (NSDictionary *)fst_dictionaryRepresentation {
    return @{
        @"recordID":           self.recordID ?: [[NSUUID UUID] UUIDString],
        @"planName":           self.planName ?: @"",
        @"fastingHours":       @(self.fastingHours),
        @"startTimeInterval":  @(self.startDate.timeIntervalSince1970),
        @"endTimeInterval":    @(self.endDate.timeIntervalSince1970),
        @"weightKg":           @(self.weightKg        > 0 ? self.weightKg        : kFSTFastingRecordDefaultCurrentWeightKg),
        @"initialWeightKg":    @(self.initialWeightKg > 0 ? self.initialWeightKg : kFSTFastingRecordDefaultInitialWeightKg),
        @"targetWeightKg":     @(self.targetWeightKg  > 0 ? self.targetWeightKg  : kFSTFastingRecordDefaultTargetWeightKg),
        @"appleHealthEnabled": @(self.appleHealthEnabled),
        @"feelingLevel":       @(self.feelingLevel),
        @"note":               self.note ?: @"",
    };
}

@end
