//
//  FSTTimeRowView.h
//  Fasting
//
//  通用时间行子组件：圆点 + 标题 + 右侧日期文字 + 铅笔图标 + 下方 UIDatePicker。
//  最初从 FSTQuickAddRecordRootView 的 start/end section 抽出（两块几乎完全重复的 65 行镜像），
//  把"颜色 + 文案"用属性参数化后两处共用一份实现。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTTimeRowView : UIView

/// header 标题文字（"Fast starts" / "Fast ends" 等）。
@property (nonatomic, copy) NSString *title;

/// 圆点颜色（绿 / 红等，区分语义）。
@property (nonatomic, strong) UIColor *dotColor;

/// 右侧 dateLabel 的文字。VC 通过 NSDateFormatter 格式化后赋值。
@property (nonatomic, copy, nullable) NSString *dateText;

/// 暴露给 VC 直接配置初始 date / min / max；onDateChanged 已内部接好。
@property (nonatomic, strong, readonly) UIDatePicker *picker;

/// picker 数值变更回调。参数为最新的 NSDate。
@property (nonatomic, copy, nullable) void (^onDateChanged)(NSDate *date);

@end

NS_ASSUME_NONNULL_END
