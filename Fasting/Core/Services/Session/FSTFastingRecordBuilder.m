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
    FSTSessionManager *sm = [FSTSessionManager sharedManager];
    FSTFastingRecord *record = existing ?: [[FSTFastingRecord alloc] init];
    record.recordID     = record.recordID.length ? record.recordID : [[NSUUID UUID] UUIDString];
    record.planName     = record.planName.length ? record.planName : (sm.currentPlan.name ?: @"14-10");
    record.fastingHours = record.fastingHours > 0 ? record.fastingHours : sm.currentPlan.fastingHours;
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
