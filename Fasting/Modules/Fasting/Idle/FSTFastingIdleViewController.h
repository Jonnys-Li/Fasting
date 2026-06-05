//
//  FSTFastingIdleViewController.h
//  Fasting
//
//  断食 Tab（FSTTabIndexFasting）的主页 VC，也是 onboarding 后的默认落点。
//  - 角色：根据 sessionManager 当前 session 状态在两种 body 视图间切换（reloadRootContent 顶层分流）：
//      1) PickerView — 未选 plan（onboarding 引导态），4 选 1；
//      2) ReadyView  — 已选 plan 但未开始；其内部再分 3 个 presentation 子态（吃窗口进行 /
//         预约倒计时 / 可立即开始），由 FSTDailyPlanReadyDisplayState 收敛为单一 presentationState 轴。
//    （hasActiveFasting=YES 不在此渲染：viewWillAppear 直接 push 到 ActiveFasting。
//     "破戒"提示是 ReadyView 内的卡片 + handleBreakingFastTapped 弹的居中弹窗，并非顶层第三态。）
//  - 输入：refreshTimer（每秒推动倒计时）+ viewWillAppear（切回 Tab / 从子页 pop 回来时刷新）。
//  - 输出：导航跳转到 FSTPlanSelectViewController（选 plan）、FSTPlanConfirmViewController（确认开始）、
//    FSTActiveFastingViewController（已开始的活跃断食）、FSTMealDetailViewController（LogMeal）。
//  - 状态计算：[FSTDailyPlanReadyDisplayState stateForSessionManager:recordsRepository:now:] 把全部派生 UI
//    字段（含 shouldAutoStartNow 副作用判定）算好一次性推入 ReadyView；refreshReadyState 只「算→推→执行副作用」。
//

#import "FSTBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTFastingIdleViewController : FSTBaseViewController

@end

NS_ASSUME_NONNULL_END
