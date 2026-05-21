//
//  FSTBaseViewController.h
//  Fasting
//
//  全 App 控制器基类：统一页面背景色、隐藏导航栏、状态栏样式。
//  业务 VC 继承此基类即可省去 viewDidLoad 里的样板代码。
//  另外提供一套统一的 1 秒刷新定时器 API（Step 3 重构），原由各 VC 自己写的 timer 全部替换为基类方法。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTBaseViewController : UIViewController

/// 启动 1 秒一次的刷新定时器，每次 tick 调 -refreshTimerDidFire。
/// 可重入：多次调用会先停旧定时器再起新的，避免叠加。
/// 调用方典型场景：viewWillAppear 时启动；ActiveFasting / DailyPlan / MealDiary 三个 VC 都按秒推 UI。
- (void)startRefreshTimer;

/// 停定时器。
/// 调用方典型场景：viewWillDisappear 时调用以省电；dealloc 也会自动清理（基类已实现）。
- (void)stopRefreshTimer;

/// 定时器每秒触发的回调。基类空实现；子类 override 通常调用 -refreshUI 之类的 DisplayState 重算。
/// 注意：永远不要直接调本方法做强制刷新，应该让用户事件驱动业务方法，再让 timer 按秒自然刷。
- (void)refreshTimerDidFire;

@end

NS_ASSUME_NONNULL_END
