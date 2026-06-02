//
//  FSTFastingIdlePickerView.h
//  Fasting
//
//  Plan 页"未选计划"状态的内容视图：副标题 + 4 个计划卡列表。
//

#import <UIKit/UIKit.h>

@class FSTPlan;

NS_ASSUME_NONNULL_BEGIN

/// Plan 首页"未选计划"状态下的 body 视图，由 FSTFastingIdleRootView 承载
/// （edges 贴满其 contentView）。
@interface FSTFastingIdlePickerView : UIView

/// 用户点击任一计划卡时回调。
@property (nonatomic, copy, nullable) void (^onPlanPicked)(FSTPlan *pickedPlan);

@end

NS_ASSUME_NONNULL_END
