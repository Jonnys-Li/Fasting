//
//  FSTMealRecord+Persistence.m
//  Fasting
//

#import "FSTFastingRecord.h"

#pragma mark - Defaults

static const NSInteger kDefaultTasteLevel = 1;

@implementation FSTMealRecord (Persistence)

+ (instancetype)fst_recordWithDictionary:(NSDictionary *)dictionary {
    FSTMealRecord *record = [[FSTMealRecord alloc] init];
    record.recordID = dictionary[@"recordID"] ?: [[NSUUID UUID] UUIDString];
    NSNumber *dateTimeInterval = dictionary[@"dateTimeInterval"];
    record.date = dateTimeInterval != nil ? [NSDate dateWithTimeIntervalSince1970:dateTimeInterval.doubleValue] : nil;
    // 枚举字段存 rawValue；缺 key 时保留 -init 的默认值（Meal / NotSure）。
    NSNumber *mealCategoryValue = dictionary[@"mealCategory"];
    if (mealCategoryValue != nil) record.mealCategory = mealCategoryValue.integerValue;
    NSNumber *dietTypeValue = dictionary[@"dietType"];
    if (dietTypeValue != nil) record.dietType = dietTypeValue.integerValue;
    record.tasteLevel        = dictionary[@"tasteLevel"]        ? [dictionary[@"tasteLevel"] integerValue] : kDefaultTasteLevel;
    record.detailDescription = dictionary[@"detailDescription"] ?: @"";
    record.imagePath         = dictionary[@"imagePath"] ?: @"";
    
    return record;
}

- (NSDictionary *)fst_dictionaryRepresentation {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    dictionary[@"recordID"]          = self.recordID ?: [[NSUUID UUID] UUIDString];
    if (self.date) dictionary[@"dateTimeInterval"] = @(self.date.timeIntervalSince1970);
    dictionary[@"mealCategory"]      = @(self.mealCategory);
    dictionary[@"dietType"]          = @(self.dietType);
    dictionary[@"tasteLevel"]        = @(self.tasteLevel);
    dictionary[@"detailDescription"] = self.detailDescription ?: @"";
    dictionary[@"imagePath"]         = self.imagePath ?: @"";
    
    return [dictionary copy];
}

@end
