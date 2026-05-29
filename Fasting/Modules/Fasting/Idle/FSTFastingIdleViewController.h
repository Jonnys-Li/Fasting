//
//  FSTFastingIdleViewController.h
//  Fasting
//
//  断食 Tab（FSTTabIndexFasting）的主页 VC，也是 onboarding 后的默认落点。
//  - 角色：根据 sessionManager 当前 session 状态切换三种子视图：
//      1) PickerView    — 未选 plan（onboarding 引导态）；
//      2) ReadyView     — 已选 plan 但未开始（吃窗口进行中 / 预约倒计时 / 可开始断食）；
//      3) BreakingFast 卡顶层 — 上一次断食刚结束的"破戒"提示，叠加在 ReadyView 之上。
//    具体走哪条由 -refreshReadyState 内部判定（详见 .m）。
//  - 输入：refreshTimer（每秒推动倒计时）+ viewWillAppear（切回 Tab / 从子页 pop 回来时刷新）。
//  - 输出：导航跳转到 FSTPlanSelectViewController（选 plan）、FSTPlanConfirmViewController（确认开始）、
//    FSTActiveFastingViewController（已开始的活跃断食）、FSTMealDetailViewController（LogMeal）。
//  - 状态计算：靠 [FSTDailyPlanReadyDisplayState stateForPlan:] 把所有派生 UI 字段算好一次性推入 ReadyView。
//

#import "FSTBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTFastingIdleViewController : FSTBaseViewController

@end

NS_ASSUME_NONNULL_END
