//
//  FSTMealRecord+Persistence.m
//  Fasting
//

#import "FSTMealRecord+Persistence.h"

static NSString *const kFSTMealRecordDefaultMealCategory = @"正餐";
static NSString *const kFSTMealRecordDefaultDietType     = @"我不确定";
static const NSInteger kFSTMealRecordDefaultTasteLevel   = 1;

@implementation FSTMealRecord (Persistence)

+ (instancetype)fst_recordWithDictionary:(NSDictionary *)dictionary {
    FSTMealRecord *record = [FSTMealRecord new];
    record.recordID = dictionary[@"recordID"] ?: [[NSUUID UUID] UUIDString];
    NSNumber *dateTimeInterval = dictionary[@"dateTimeInterval"];
    record.date = dateTimeInterval ? [NSDate dateWithTimeIntervalSince1970:dateTimeInterval.doubleValue] : [NSDate date];
    record.mealCategory      = dictionary[@"mealCategory"]      ?: kFSTMealRecordDefaultMealCategory;
    record.dietType          = dictionary[@"dietType"]          ?: kFSTMealRecordDefaultDietType;
    record.tasteLevel        = dictionary[@"tasteLevel"]        ? [dictionary[@"tasteLevel"] integerValue] : kFSTMealRecordDefaultTasteLevel;
    record.detailDescription = dictionary[@"detailDescription"] ?: @"";
    record.imagePath         = dictionary[@"imagePath"] ?: @"";
    return record;
}

- (NSDictionary *)fst_dictionaryRepresentation {
    return @{
        @"recordID":          self.recordID ?: [[NSUUID UUID] UUIDString],
        @"dateTimeInterval":  @((self.date ?: [NSDate date]).timeIntervalSince1970),
        @"mealCategory":      self.mealCategory ?: kFSTMealRecordDefaultMealCategory,
        @"dietType":          self.dietType ?: kFSTMealRecordDefaultDietType,
        @"tasteLevel":        @(self.tasteLevel),
        @"detailDescription": self.detailDescription ?: @"",
        @"imagePath":         self.imagePath ?: @"",
    };
}

@end
