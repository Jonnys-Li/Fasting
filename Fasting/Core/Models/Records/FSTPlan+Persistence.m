//
//  FSTPlan+Persistence.m
//  Fasting
//

#import "FSTPlan.h"

@implementation FSTPlan (Persistence)

+ (nullable instancetype)fst_planWithDictionary:(NSDictionary *)dictionary {
    NSString *name = dictionary[@"name"];
    if (!name) return nil;
    for (FSTPlan *plan in [self defaultDailyPlans]) {
        if ([plan.name isEqualToString:name]) return plan;
    }
    FSTPlan *plan = [FSTPlan new];
    plan.name                = name;
    plan.fastingHours        = [dictionary[@"fastingHours"]    integerValue];
    plan.eatingHours         = [dictionary[@"eatingHours"]     integerValue];
    plan.difficultyLevel     = [dictionary[@"difficultyLevel"] integerValue];
    plan.cardBackgroundHex   = 0xE6F3EA;
    plan.accentBoltHex       = 0x3F9D5E;
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
