//
//  FSTPlanSelectListView.h
//  Fasting
//
//  方案列表视图 — 用 UITableView 承载 4 个内置 plan 卡。
//  - 触发场景：
//    (1) FSTPlanSelectViewController（PlanSelect 页）作为内容主体，用户首次或换方案时进入；
//    (2) ActiveFasting 圆环 chip 入口 — 用户在断食中点 plan chip 也会拉起这个视图（嵌在 sheet 里）。
//  - 角色：纯展示 + 选择回调；自己不持有 currentPlan 状态。
//  - 数据源：[FSTPlan defaultDailyPlans] — 当前仅 4 个内置方案。
//

#import <UIKit/UIKit.h>
#import "FSTPlan.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTPlanSelectListView : UIView

/// 用户点中某行 plan 后触发。
/// 调用方约定：
///   - PlanSelect 页：把 picked 透传给 FSTPlanConfirmViewController；
///   - ActiveFasting 圆环 chip：调 [sessionManager switchToPlanPreservingState:picked]（软切换）。
@property (nonatomic, copy, nullable) void (^onPlanPicked)(FSTPlan *picked);

@end

NS_ASSUME_NONNULL_END
