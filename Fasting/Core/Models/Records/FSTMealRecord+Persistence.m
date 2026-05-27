//
//  FSTMealRecord+Persistence.m
//  Fasting
//

#import "FSTFastingRecord.h"

#pragma mark - Defaults

static NSString *const kDefaultMealCategory = @"Meal";
static NSString *const kDefaultDietType     = @"Not sure";
static const NSInteger kDefaultTasteLevel   = 1;

@implementation FSTMealRecord (Persistence)

+ (instancetype)fst_recordWithDictionary:(NSDictionary *)dictionary {
    FSTMealRecord *record = [FSTMealRecord new];
    record.recordID = dictionary[@"recordID"] ?: [[NSUUID UUID] UUIDString];
    NSNumber *dateTimeInterval = dictionary[@"dateTimeInterval"];
    record.date = dateTimeInterval != nil ? [NSDate dateWithTimeIntervalSince1970:dateTimeInterval.doubleValue] : nil;
    record.mealCategory      = dictionary[@"mealCategory"]      ?: kDefaultMealCategory;
    record.dietType          = dictionary[@"dietType"]          ?: kDefaultDietType;
    record.tasteLevel        = dictionary[@"tasteLevel"]        ? [dictionary[@"tasteLevel"] integerValue] : kDefaultTasteLevel;
    record.detailDescription = dictionary[@"detailDescription"] ?: @"";
    record.imagePath         = dictionary[@"imagePath"] ?: @"";
    return record;
}

- (NSDictionary *)fst_dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[@"recordID"]          = self.recordID ?: [[NSUUID UUID] UUIDString];
    if (self.date) dictionary[@"dateTimeInterval"] = @(self.date.timeIntervalSince1970);
    dictionary[@"mealCategory"]      = self.mealCategory ?: kDefaultMealCategory;
    dictionary[@"dietType"]          = self.dietType ?: kDefaultDietType;
    dictionary[@"tasteLevel"]        = @(self.tasteLevel);
    dictionary[@"detailDescription"] = self.detailDescription ?: @"";
    dictionary[@"imagePath"]         = self.imagePath ?: @"";
    return [dictionary copy];
}

@end
