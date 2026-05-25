//
//  FSTRootTabBarController.h
//  Fasting
//
//  App 根 TabBar — 三个 Tab 的容器。
//  - 引导锁定：currentPlan == nil（未完成 onboarding）时 user 被锁在 Fasting Tab，
//    其他 Tab 点击被代理方法拦截并回弹到 Fasting；首次完成选 plan 后才解除锁定。
//  - Tab 之间的状态同步靠 FSTSessionManager 通知；TabBarController 自身不持有业务状态。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 三个 Tab 的下标常量。
/// 写入方：本控制器在初始化时按此顺序构造 viewControllers；
///         代理方法 -tabBarController:shouldSelectViewController: 用 selectedIndex 与之比较实现引导锁定。
/// 读取方：本类内部以及任何需要按下标定位 Tab 的代码（不直接散布到业务模块）。
typedef NS_ENUM(NSInteger, FSTTabIndex) {
    FSTTabIndexTimeline = 0,  ///< 时间线 Tab：历史断食/餐食记录的可视化。
    FSTTabIndexFasting  = 1,  ///< 断食主 Tab：Plan 选择 / 进行中断食 / 准备态。onboarding 锁定时强制停留在此。
    FSTTabIndexExplore  = 2,  ///< 探索 Tab：内容/教程入口（当前可能仅占位）。
};

@interface FSTRootTabBarController : UITabBarController <UITabBarControllerDelegate>

/// 完成"保存类"流程：切到 Timeline tab + pop Fasting nav 栈 + 执行 session 变更，全过程用快照遮罩抑制 chrome 闪烁。
/// updates 仅承担 session 数据变更（写记录 / 清 active 等），导航编排交给本方法。
- (void)fst_finishFlowReturningToTimelineWithUpdates:(dispatch_block_t)updates;

@end

NS_ASSUME_NONNULL_END
