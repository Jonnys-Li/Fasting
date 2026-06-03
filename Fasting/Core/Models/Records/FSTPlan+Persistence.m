//
//  FSTPlan+Persistence.m
//  Fasting
//

#import "FSTPlan.h"

@implementation FSTPlan (Persistence)

+ (nullable instancetype)fst_planWithDictionary:(NSDictionary *)dictionary {
    // 内置方案按 type 匹配（type 缺失/旧数据 → 0 = Custom，走下方重建）。
    FSTPlanType type = [dictionary[@"type"] integerValue];
    if (type != FSTPlanTypeCustom) {
        for (FSTPlan *plan in [self defaultDailyPlans]) {
            if (plan.type == type) return plan;
        }
    }
    // 自定义 / 未匹配：从存储字段重建。
    NSString *name = dictionary[@"name"];
    if (!name) return nil;
    FSTPlan *plan = [[FSTPlan alloc] init];
    plan.type                = FSTPlanTypeCustom;
    plan.name                = name;
    plan.fastingHours        = [dictionary[@"fastingHours"]    integerValue];
    plan.eatingHours         = [dictionary[@"eatingHours"]     integerValue];
    plan.difficultyLevel     = [dictionary[@"difficultyLevel"] integerValue];
    return plan;
}

- (NSDictionary *)fst_dictionaryRepresentation {
    return @{
        @"type":            @(self.type),
        @"name":            self.name ?: @"",
        @"fastingHours":    @(self.fastingHours),
        @"eatingHours":     @(self.eatingHours),
        @"difficultyLevel": @(self.difficultyLevel),
    };
}

@end
