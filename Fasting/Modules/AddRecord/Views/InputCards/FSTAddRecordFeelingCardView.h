//
//  FSTAddRecordFeelingCardView.h
//  Fasting
//
//  心情卡片：3 个 emoji 按钮（有点难 / 还可以 / 简单）。当前选中那个 alpha 1.0，其他 0.38。
//  - 触发场景：AddRecord 页 — 用户结束断食后填写感受。
//  - 写入方：上游 VC 用 self.feelingLevel = record.feelingLevel 推入初值；用户点 emoji 也会修改此值。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTAddRecordFeelingCardView : UIView

/// 当前心情等级（与 FSTFastingRecord.feelingLevel 同义）。
/// 取值：0 = 有点难 😣，1 = 还可以 😐，2 = 简单 😊。
/// 与 FSTFastingTimelineCardView.FSTFastingRating 数值含义对齐 — 全 App 同一套约定。
@property (nonatomic, assign) NSInteger feelingLevel;

@end

NS_ASSUME_NONNULL_END
