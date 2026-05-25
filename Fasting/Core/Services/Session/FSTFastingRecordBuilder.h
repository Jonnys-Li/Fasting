//
//  FSTFastingRecordBuilder.h
//  Fasting
//
//  把 AddRecord / QuickAddRecord 两个 VC 重复的「构造 FSTFastingRecord 草稿」逻辑抽到一处。
//  默认值从 [FSTSessionManager sharedManager].currentPlan 派生（planName / fastingHours），
//  recordID 缺省生成。
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@class FSTFastingRecord;

/// 构造或更新一个 FSTFastingRecord 草稿。
/// @param existing 编辑现有记录时传入；新增时传 nil。
/// @param startDate / endDate 必填。
/// @param weightKg / initialKg / targetKg 体重三件套（kg）。
/// @param feelingLevel 0=Hard, 1=Ok, 2=Easy（与 FSTFastingRating 数值对齐）。
/// @param note 备注文本；nil 自动归为 @""。
/// @param appleHealthEnabled HealthKit 同步标记位。
/// @return 已写入字段、ready 给 FSTRecordsRepository.updateFastingRecord: 的对象。
FSTFastingRecord *FSTBuildFastingRecord(FSTFastingRecord *_Nullable existing,
                                         NSDate *startDate,
                                         NSDate *endDate,
                                         CGFloat weightKg,
                                         CGFloat initialKg,
                                         CGFloat targetKg,
                                         NSInteger feelingLevel,
                                         NSString *_Nullable note,
                                         BOOL appleHealthEnabled);

NS_ASSUME_NONNULL_END
