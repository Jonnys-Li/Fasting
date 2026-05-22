//
//  FSTPlan.m
//  Fasting
//

#import "FSTPlan.h"

@implementation FSTPlan

+ (NSArray<FSTPlan *> *)defaultDailyPlans {
    FSTPlan *planFourteenTen = [FSTPlan new];
    planFourteenTen.name = @"14-10";
    planFourteenTen.fastingHours = 14;
    planFourteenTen.eatingHours = 10;
    planFourteenTen.difficultyLevel = 1;
    planFourteenTen.cardBackgroundHex = 0xFBE9E3;
    planFourteenTen.accentBoltHex = 0xE9633F;

    FSTPlan *planSixteenEight = [FSTPlan new];
    planSixteenEight.name = @"16-8";
    planSixteenEight.fastingHours = 16;
    planSixteenEight.eatingHours = 8;
    planSixteenEight.difficultyLevel = 1;
    planSixteenEight.cardBackgroundHex = 0xE7ECFA;
    planSixteenEight.accentBoltHex = 0x4A7DDB;

    FSTPlan *planEighteenSix = [FSTPlan new];
    planEighteenSix.name = @"18-6";
    planEighteenSix.fastingHours = 18;
    planEighteenSix.eatingHours = 6;
    planEighteenSix.difficultyLevel = 2;
    planEighteenSix.cardBackgroundHex = 0xFAF1DE;
    planEighteenSix.accentBoltHex = 0xE0A92F;

    FSTPlan *planTwentyFour = [FSTPlan new];
    planTwentyFour.name = @"20-4";
    planTwentyFour.fastingHours = 20;
    planTwentyFour.eatingHours = 4;
    planTwentyFour.difficultyLevel = 3;
    planTwentyFour.cardBackgroundHex = 0xE6F3EA;
    planTwentyFour.accentBoltHex = 0x3F9D5E;

    return @[planFourteenTen, planSixteenEight, planEighteenSix, planTwentyFour];
}

@end
