//
//  FSTFastingRecordBuilder.m
//  Fasting
//

#import "FSTFastingRecordBuilder.h"
#import "FSTFastingRecord.h"
#import "FSTSessionManager.h"
#import "FSTPlan.h"

FSTFastingRecord *FSTBuildFastingRecord(FSTFastingRecord *existing,
                                         NSDate *startDate,
                                         NSDate *endDate,
                                         CGFloat weightKg,
                                         CGFloat initialKg,
                                         CGFloat targetKg,
                                         NSInteger feelingLevel,
                                         NSString *note,
                                         BOOL appleHealthEnabled) {
    // 无 plan 时兜底取内置首方案（14-10），保证 planName 与 fastingHours 同源。
    FSTPlan *fallbackPlan = [FSTSessionManager sharedManager].currentPlan ?: [FSTPlan defaultDailyPlans].firstObject;
    FSTFastingRecord *record = existing ?: [[FSTFastingRecord alloc] init];
    record.recordID     = record.recordID.length ? record.recordID : [[NSUUID UUID] UUIDString];
    // planType / planName 同源：新建（planName 为空）取 fallback，编辑则保留 record 既有身份（见 R13）。
    BOOL hasPlanIdentity = record.planName.length > 0;
    record.planType     = hasPlanIdentity ? record.planType : fallbackPlan.type;
    record.planName     = hasPlanIdentity ? record.planName : fallbackPlan.name;
    record.fastingHours = record.fastingHours > 0 ? record.fastingHours : fallbackPlan.fastingHours;
    record.startDate    = startDate;
    record.endDate      = endDate;
    record.weightKg           = weightKg;
    record.initialWeightKg    = initialKg;
    record.targetWeightKg     = targetKg;
    record.appleHealthEnabled = appleHealthEnabled;
    record.feelingLevel = feelingLevel;
    record.note         = note ?: @"";
    return record;
}
