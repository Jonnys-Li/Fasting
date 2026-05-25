//
//  FSTAddRecordTimeCardView.h
//  Fasting
//
//  时间卡片：显示当前计划、开始/结束时间行（点击展开 UIDatePicker）、底部提示。
//

#import "FSTAddRecordBaseCardView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTAddRecordTimeCardView : FSTAddRecordBaseCardView

/// 当前断食计划名（如 "14-10"），显示在卡片头
@property (nonatomic, copy, nullable) NSString *planName;

/// 开始时间
@property (nonatomic, strong) NSDate *startDate;

/// 结束时间
@property (nonatomic, strong) NSDate *endDate;

/// 是否编辑已有记录（影响底部提示文案：YES 时强调"停止断食"，NO 时强调"开始断食"）
@property (nonatomic, assign) BOOL editingExistingRecord;

/// startDate 或 endDate 被改动时回调
@property (nonatomic, copy, nullable) void (^onDatesChanged)(NSDate *startDate, NSDate *endDate);

@end

NS_ASSUME_NONNULL_END
