//
//  FSTPlanConfirmTimelineView.h
//  Fasting
//
//  计划确认页里的"开始 → 结束（预计）"小时间轴：两个圆点 + 连线 + 时间值 + 铅笔（仅 start 可编辑）。
//  - 角色：纯展示视图。
//  - 写入方：FSTPlanConfirmViewController 在 init 和 onEditStartTapped 回调后推入新日期。
//  - 用户视角：让用户在确认页明确看到"我马上要断到几点"。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTPlanConfirmTimelineView : UIView

/// 断食开始时间（用户可编辑）。VC 通常初始化为 now，用户点铅笔后调 TimeEditor 改时间。
@property (nonatomic, strong) NSDate *startDate;

/// 断食结束时间（预计，按 plan.fastingHours 推导，不可在确认页编辑）。
/// 写入方：VC 把 startDate + plan.fastingHours 算出后推入；本视图仅显示。
@property (nonatomic, strong) NSDate *endDate;

/// 用户点 start 铅笔回调。
/// 约定调用方弹 TimeEditor，得到新时间后写回 self.startDate 并同步重算 endDate。
@property (nonatomic, copy, nullable) dispatch_block_t onEditStartTapped;

@end

NS_ASSUME_NONNULL_END
