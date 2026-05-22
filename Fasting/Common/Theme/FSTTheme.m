//
//  FSTTheme.m
//  Fasting
//

#import "FSTTheme.h"

const CGFloat FSTSpacingS  = 8;
const CGFloat FSTSpacingM  = 12;
const CGFloat FSTSpacingL  = 16;
const CGFloat FSTSpacingXL = 24;

UIFont *FSTFontRegular(CGFloat size)  { return [UIFont systemFontOfSize:size weight:UIFontWeightRegular]; }
UIFont *FSTFontMedium(CGFloat size)   { return [UIFont systemFontOfSize:size weight:UIFontWeightMedium]; }
UIFont *FSTFontSemibold(CGFloat size) { return [UIFont systemFontOfSize:size weight:UIFontWeightSemibold]; }
UIFont *FSTFontBold(CGFloat size)     { return [UIFont systemFontOfSize:size weight:UIFontWeightBold]; }
UIFont *FSTFontAvenirBold(CGFloat size)     { return [UIFont fontWithName:@"AvenirNext-Bold" size:size] ?: FSTFontBold(size); }
UIFont *FSTFontAvenirDemiBold(CGFloat size) { return [UIFont fontWithName:@"AvenirNext-DemiBold" size:size] ?: FSTFontSemibold(size); }

NSString *FSTFormatHHMMSS(NSTimeInterval seconds) {
    if (seconds < 0) seconds = 0;
    NSInteger totalSeconds = (NSInteger)seconds;
    NSInteger hoursComponent = totalSeconds / 3600;
    NSInteger minutesComponent = (totalSeconds % 3600) / 60;
    NSInteger secondsComponent = totalSeconds % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hoursComponent, (long)minutesComponent, (long)secondsComponent];
}

NSString *FSTFormatTimeOnly(NSDate *date) {
    if (!date) return @"";
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"HH:mm";
    });
    return [formatter stringFromDate:date];
}

NSString *FSTFormatRelativeDateTime(NSDate *date) {
    if (!date) return @"";
    return [NSString stringWithFormat:@"%@, %@", FSTFormatRelativeDay(date), FSTFormatTimeOnly(date)];
}

NSString *FSTFormatRecordDateLine(NSDate *date) {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"MMM d, hh:mm a";
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    });
    return [formatter stringFromDate:date];
}

NSString *FSTFormatRelativeDay(NSDate *date) {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if ([calendar isDateInToday:date])     return @"Today";
    if ([calendar isDateInYesterday:date]) return @"Yesterday";
    if ([calendar isDateInTomorrow:date])  return @"Tomorrow";
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"MMM d";
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    });
    return [formatter stringFromDate:date];
}
