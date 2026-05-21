//
//  FSTPlan.m
//  Fasting
//

#import "FSTPlan.h"
#import "UIColor+FST.h"

@implementation FSTPlan

+ (NSArray<FSTPlan *> *)defaultDailyPlans {
    FSTPlan *planFourteenTen = [FSTPlan new];
    planFourteenTen.name = @"14-10";
    planFourteenTen.fastingHours = 14;
    planFourteenTen.eatingHours = 10;
    planFourteenTen.difficultyLevel = 1;
    planFourteenTen.cardBackgroundColor = [UIColor fst_planOrange];
    planFourteenTen.accentBoltColor = [UIColor fst_colorWithHex:0xE9633F];

    FSTPlan *planSixteenEight = [FSTPlan new];
    planSixteenEight.name = @"16-8";
    planSixteenEight.fastingHours = 16;
    planSixteenEight.eatingHours = 8;
    planSixteenEight.difficultyLevel = 1;
    planSixteenEight.cardBackgroundColor = [UIColor fst_planBlue];
    planSixteenEight.accentBoltColor = [UIColor fst_colorWithHex:0x4A7DDB];

    FSTPlan *planEighteenSix = [FSTPlan new];
    planEighteenSix.name = @"18-6";
    planEighteenSix.fastingHours = 18;
    planEighteenSix.eatingHours = 6;
    planEighteenSix.difficultyLevel = 2;
    planEighteenSix.cardBackgroundColor = [UIColor fst_planYellow];
    planEighteenSix.accentBoltColor = [UIColor fst_colorWithHex:0xE0A92F];

    FSTPlan *planTwentyFour = [FSTPlan new];
    planTwentyFour.name = @"20-4";
    planTwentyFour.fastingHours = 20;
    planTwentyFour.eatingHours = 4;
    planTwentyFour.difficultyLevel = 3;
    planTwentyFour.cardBackgroundColor = [UIColor fst_planGreen];
    planTwentyFour.accentBoltColor = [UIColor fst_colorWithHex:0x3F9D5E];

    return @[planFourteenTen, planSixteenEight, planEighteenSix, planTwentyFour];
}

@end
