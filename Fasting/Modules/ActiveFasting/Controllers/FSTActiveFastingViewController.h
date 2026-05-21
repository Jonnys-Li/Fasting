//
//  FSTActiveFastingViewController.h
//  Fasting
//
//  进行中断食的页面 — 显示圆环计时器、Start/End 编辑、Tips、阶段卡、End/Complete 按钮。
//  - 来源：FSTPlanConfirmViewController.onFastingStarted 触发后 push 进入；
//    或下次 App 启动时若 sessionManager.hasActiveFasting=YES，由 DailyPlan VC 自动 push 进入。
//  - 输入：refreshTimer（每秒）+ FSTSessionDidChangeNotification（外部改了 start/end/plan）+
//          [FSTSessionManager consumeActiveStartDatePromptRequest]（首次进入弹 start 编辑器）。
//  - 状态计算：靠 [FSTActiveFastingDisplayState currentStateWithDisplayMode:] 把 RingPanel/
//    TimesRow/PhaseCard/Tips/StopButton 五块所需字段算好一次性推入。
//  - 持有：FSTActiveFastingRootView 一个 root 视图，所有子视图由 root 管理。
//

#import "FSTBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTActiveFastingViewController : FSTBaseViewController

/// 首次显示时弹出"什么时候开始断食"的时间确认框（让用户矫正 startDate）。
/// 写入方：上游 PlanConfirm VC 在 push 本 VC 前根据情境设置；
///         典型场景：用户在 Plan 页 Schedule 了一个未来时间到达后被引导进入 ActiveFasting，
///         由于真实开始时刻可能早于触发本 VC 的时刻，给用户一个矫正机会。
/// 也可通过 [sessionManager requestActiveStartDatePrompt] + consume 机制驱动（跨 VC 跳转后由 viewDidAppear 消费 token）。
@property (nonatomic, assign) BOOL promptsForStartTimeOnFirstAppear;

@end

NS_ASSUME_NONNULL_END
