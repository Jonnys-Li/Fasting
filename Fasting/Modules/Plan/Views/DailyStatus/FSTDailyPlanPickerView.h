//
//  FSTDailyPlanPickerView.h
//  Fasting
//
//  Plan 页"未选计划"状态的内容视图：副标题 + 4 个计划卡列表。
//

#import <UIKit/UIKit.h>

@class FSTPlan;

NS_ASSUME_NONNULL_BEGIN

/// Plan 首页"未选计划"状态下的内容视图，需嵌入到 VC 的 scrollView contentView 内。
/// VC 把本视图 edges 约束到 contentView 即可。
@interface FSTDailyPlanPickerView : UIView

/// 用户点击任一计划卡时回调。
@property (nonatomic, copy, nullable) void (^onPlanPicked)(FSTPlan *pickedPlan);

@end

NS_ASSUME_NONNULL_END
