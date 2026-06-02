//
//  FSTPlan.m
//  Fasting
//

#import "FSTPlan.h"

@implementation FSTPlan

+ (NSArray<FSTPlan *> *)defaultDailyPlans {
    FSTPlan *planFourteenTen = [[FSTPlan alloc] init];
    planFourteenTen.name = @"14-10";
    planFourteenTen.fastingHours = 14;
    planFourteenTen.eatingHours = 10;
    planFourteenTen.difficultyLevel = 1;

    FSTPlan *planSixteenEight = [[FSTPlan alloc] init];
    planSixteenEight.name = @"16-8";
    planSixteenEight.fastingHours = 16;
    planSixteenEight.eatingHours = 8;
    planSixteenEight.difficultyLevel = 1;

    FSTPlan *planEighteenSix = [[FSTPlan alloc] init];
    planEighteenSix.name = @"18-6";
    planEighteenSix.fastingHours = 18;
    planEighteenSix.eatingHours = 6;
    planEighteenSix.difficultyLevel = 2;

    FSTPlan *planTwentyFour = [[FSTPlan alloc] init];
    planTwentyFour.name = @"20-4";
    planTwentyFour.fastingHours = 20;
    planTwentyFour.eatingHours = 4;
    planTwentyFour.difficultyLevel = 3;

    return @[planFourteenTen, planSixteenEight, planEighteenSix, planTwentyFour];
}

@end
