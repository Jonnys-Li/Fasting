//
//  FSTSceneStateRestoration.h
//  Fasting
//
//  Scene state restoration（NSUserActivity 链路）的编解码助手。
//  把 root TabBar 的状态（tab 选中态 + 每个 tab 的 nav 栈 + 每个 VC 的关键参数）
//  ↔ NSUserActivity userInfo 互转，让 app 被 kill 后下次启动能落回原 VC。
//
//  使用约定：
//    - 仅 SceneDelegate 调用，其他模块不应直接使用。
//    - 纯 class methods，无状态；不持有 window / scene 引用。
//
//  恢复 scope（详细列表见 .m 的 encoder/decoder 分支）：
//    IN  — tab 选中态、push 上去的 VC 类型 + 关键参数（recordID / planName / startDate / endDate）
//    OUT — modal sheets、半填表单内容、scroll 位置、onboarding 中段、一次性 UX hint
//
//  schema 演进：调整 token 结构时同步把 FSTSceneRestorationSchemaVersion +1，
//  老 activity 因版本不匹配会被丢弃，调用方走默认路由。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FSTRootTabBarController;

@interface FSTSceneStateRestoration : NSObject

/// 把 root（必须是 FSTRootTabBarController）编码成 NSUserActivity；
/// root 不是 TabBar 返回 nil。SceneDelegate -stateRestorationActivityForScene: 直接转发。
+ (nullable NSUserActivity *)activityForRootViewController:(UIViewController *)root;

/// 从 activity 重建 TabBar + 每个 tab 的 nav 栈；activity 为 nil / 版本不匹配 / type 不对返回 nil。
/// 调用方拿到结果后赋给 window.rootViewController；window 管理本身不属于本类。
/// 单个 token 解码失败（依赖记录被删等）截断该 tab 的 stack，但不阻断其他 tab 的恢复。
+ (nullable FSTRootTabBarController *)restoredRootTabBarFromActivity:(nullable NSUserActivity *)activity;

@end

NS_ASSUME_NONNULL_END
