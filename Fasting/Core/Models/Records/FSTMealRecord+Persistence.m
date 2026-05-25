//
//  FSTMealRecord+Persistence.m
//  Fasting
//

#import "FSTFastingRecord.h"

static NSString *const kFSTMealRecordDefaultMealCategory = @"Meal";
static NSString *const kFSTMealRecordDefaultDietType     = @"Not sure";
static const NSInteger kFSTMealRecordDefaultTasteLevel   = 1;

@implementation FSTMealRecord (Persistence)

+ (instancetype)fst_recordWithDictionary:(NSDictionary *)dictionary {
    FSTMealRecord *record = [FSTMealRecord new];
    record.recordID = dictionary[@"recordID"] ?: [[NSUUID UUID] UUIDString];
    NSNumber *dateTimeInterval = dictionary[@"dateTimeInterval"];
    record.date = dateTimeInterval != nil ? [NSDate dateWithTimeIntervalSince1970:dateTimeInterval.doubleValue] : nil;
    record.mealCategory      = dictionary[@"mealCategory"]      ?: kFSTMealRecordDefaultMealCategory;
    record.dietType          = dictionary[@"dietType"]          ?: kFSTMealRecordDefaultDietType;
    record.tasteLevel        = dictionary[@"tasteLevel"]        ? [dictionary[@"tasteLevel"] integerValue] : kFSTMealRecordDefaultTasteLevel;
    record.detailDescription = dictionary[@"detailDescription"] ?: @"";
    record.imagePath         = dictionary[@"imagePath"] ?: @"";
    return record;
}

- (NSDictionary *)fst_dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[@"recordID"]          = self.recordID ?: [[NSUUID UUID] UUIDString];
    if (self.date) dictionary[@"dateTimeInterval"] = @(self.date.timeIntervalSince1970);
    dictionary[@"mealCategory"]      = self.mealCategory ?: kFSTMealRecordDefaultMealCategory;
    dictionary[@"dietType"]          = self.dietType ?: kFSTMealRecordDefaultDietType;
    dictionary[@"tasteLevel"]        = @(self.tasteLevel);
    dictionary[@"detailDescription"] = self.detailDescription ?: @"";
    dictionary[@"imagePath"]         = self.imagePath ?: @"";
    return [dictionary copy];
}

@end
