//
//  FSTPlan+Persistence.m
//  Fasting
//

#import "FSTPlan+Persistence.h"
#import "UIColor+FST.h"

@implementation FSTPlan (Persistence)

+ (nullable instancetype)fst_planWithDictionary:(NSDictionary *)dictionary {
    NSString *name = dictionary[@"name"];
    if (!name) return nil;
    for (FSTPlan *plan in [self defaultDailyPlans]) {
        if ([plan.name isEqualToString:name]) return plan;
    }
    // 回退兼容：未在默认列表中命中时按字段构造，外观回退到通用绿色
    FSTPlan *plan = [FSTPlan new];
    plan.name                = name;
    plan.fastingHours        = [dictionary[@"fastingHours"]    integerValue];
    plan.eatingHours         = [dictionary[@"eatingHours"]     integerValue];
    plan.difficultyLevel     = [dictionary[@"difficultyLevel"] integerValue];
    plan.cardBackgroundColor = [UIColor fst_planGreen];
    plan.accentBoltColor     = [UIColor fst_primaryGreen];
    return plan;
}

- (NSDictionary *)fst_dictionaryRepresentation {
    return @{
        @"name":            self.name ?: @"",
        @"fastingHours":    @(self.fastingHours),
        @"eatingHours":     @(self.eatingHours),
        @"difficultyLevel": @(self.difficultyLevel),
    };
}

@end
