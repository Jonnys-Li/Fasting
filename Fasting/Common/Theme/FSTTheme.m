//
//  FSTTheme.m
//  Fasting
//

#import "FSTTheme.h"

const CGFloat FSTSpacingS  = 8;
const CGFloat FSTSpacingM  = 12;
const CGFloat FSTSpacingL  = 16;
const CGFloat FSTSpacingXL = 24;

const CGFloat FSTSpacingCardHorizontal = 28;
const CGFloat FSTControlHeightStandard = 48;

const CGFloat FSTRadiusS    = 12;
const CGFloat FSTRadiusM    = 14;
const CGFloat FSTRadiusChip = 17;
const CGFloat FSTRadiusCard = 18;
const CGFloat FSTRadiusL    = 22;
const CGFloat FSTRadiusXL   = 24;

const CGFloat FSTPoundsPerKilogram = 2.20462262;

UIFont *FSTFontRegular(CGFloat size) {
    return [UIFont systemFontOfSize:size weight:UIFontWeightRegular];
}
UIFont *FSTFontMedium(CGFloat size) {
    return [UIFont systemFontOfSize:size weight:UIFontWeightMedium];
}
UIFont *FSTFontSemibold(CGFloat size) {
    return [UIFont systemFontOfSize:size weight:UIFontWeightSemibold];
}
UIFont *FSTFontBold(CGFloat size) {
    return [UIFont systemFontOfSize:size weight:UIFontWeightBold];
}
UIFont *FSTFontHeavy(CGFloat size) {
    return [UIFont systemFontOfSize:size weight:UIFontWeightHeavy];
}
UIFont *FSTFontAvenirBold(CGFloat size) {
    return [UIFont fontWithName:@"AvenirNext-Bold" size:size] ?: FSTFontBold(size);
}
UIFont *FSTFontAvenirDemiBold(CGFloat size) {
    return [UIFont fontWithName:@"AvenirNext-DemiBold" size:size] ?: FSTFontSemibold(size);
}

UIFont *FSTFontHeadline(void) {
    return FSTFontBold(28);
}
UIFont *FSTFontTitle(void) {
    return FSTFontBold(22);
}
UIFont *FSTFontSubhead(void) {
    return FSTFontBold(20);
}
UIFont *FSTFontBody(void) {
    return FSTFontRegular(15);
}
UIFont *FSTFontCaption(void) {
    return FSTFontRegular(13);
}

NSString *FSTFormatHHMMSS(NSTimeInterval seconds) {
    if (seconds < 0) seconds = 0;
    NSInteger totalSeconds = (NSInteger)seconds;
    NSInteger hoursComponent = totalSeconds / 3600;
    NSInteger minutesComponent = (totalSeconds % 3600) / 60;
    NSInteger secondsComponent = totalSeconds % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hoursComponent, (long)minutesComponent, (long)secondsComponent];
}

/// NSDateFormatter 创建样板收口：en_US locale + 指定格式。各调用点保留独立 dispatch_once 缓存。
static NSDateFormatter *FSTMakeFormatter(NSString *format) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    return formatter;
}

NSString *FSTFormatTimeOnly(NSDate *date) {
    if (!date) return @"";
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = FSTMakeFormatter(@"HH:mm");
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
        formatter = FSTMakeFormatter(@"MMM d, hh:mm a");
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
        formatter = FSTMakeFormatter(@"MMM d");
    });
    return [formatter stringFromDate:date];
}

/// " AM"/" PM" → " am"/" pm"。NSDateFormatter 无小写 meridiem 选项，只能后处理。
static NSString *FSTLowercaseMeridiem(NSString *value) {
    return [[value stringByReplacingOccurrencesOfString:@" AM" withString:@" am"]
            stringByReplacingOccurrencesOfString:@" PM" withString:@" pm"];
}

NSString *FSTFormatRecordFullTimeLowercase(NSDate *date) {
    if (!date) return @"";
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = FSTMakeFormatter(@"MMM d, h:mm a");
    });
    return FSTLowercaseMeridiem([formatter stringFromDate:date]);
}

NSString *FSTFormatRecordEndTimeLowercase(NSDate *startDate, NSDate *endDate) {
    if (!endDate) return @"";
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if (startDate && ![calendar isDate:startDate inSameDayAsDate:endDate]) {
        return FSTFormatRecordFullTimeLowercase(endDate);
    }
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = FSTMakeFormatter(@"hh:mm a");
    });
    return FSTLowercaseMeridiem([formatter stringFromDate:endDate]);
}
