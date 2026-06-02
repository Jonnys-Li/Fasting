//
//  FSTMealTimeCardView.h
//  Fasting
//
//  餐食详情中的"时间"卡片：标题 + 日期值 + 铅笔 + 可折叠 UIDatePicker。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealTimeCardView : UIView

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, copy, nullable) void (^onDateChanged)(NSDate *date);

@end

NS_ASSUME_NONNULL_END
