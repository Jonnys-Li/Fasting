//
//  FSTPlanConfirmViewController.h
//  Fasting
//
//  确认开始断食的页面：标题 (plan name) + 时间轴 + 开始按钮 + 推荐 + 准备提示。
//  - 来源：FSTPlanSelectViewController 选定方案后 push 进来。
//  - 去向：用户点 START → [sessionManager startFastingWithPlan:] → 触发 onFastingStarted 回调 →
//    上游 FSTDailyPlanViewController 据此 popTo 自己再 push 到 ActiveFasting。
//

#import "FSTBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class FSTPlan;

@interface FSTPlanConfirmViewController : FSTBaseViewController

/// 用一个选定的 plan 初始化。
/// @param plan 不可为 nil；通常来自 FSTPlan.defaultDailyPlans 的一项。
- (instancetype)initWithPlan:(FSTPlan *)plan;

/// 用户点 START 并成功开始断食后回调。
/// 上游 VC（FSTDailyPlanViewController）约定：在此回调里 popToViewController:self animated:NO，
/// 再 push FSTActiveFastingViewController，让用户看到平滑的过渡而非两层栈。
@property (nonatomic, copy, nullable) dispatch_block_t onFastingStarted;

@end

NS_ASSUME_NONNULL_END
