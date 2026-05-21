//
//  UINavigationController+FSTHelpers.h
//  Fasting
//
//  UINavigationController 业务辅助方法集（Step 4 重构产物）。
//  目的：把"在导航栈里按类型回找某个 VC"这种重复模式抽到一处，避免每个 VC 自己写 for 循环。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (FSTHelpers)

/// 在 viewControllers 数组里查找第一个 isKindOfClass:cls 的 VC（按栈底→栈顶顺序）。
/// 调用方：
///   - FSTActiveFastingViewController：完成断食后回找 FSTDailyPlanViewController 做 popTo；
///   - FSTPlanConfirmViewController：开始断食后回找 FSTDailyPlanViewController 同理。
/// 找不到时返回 nil（调用方需要兜底 pop 到 root 或 dismiss）。
- (nullable __kindof UIViewController *)fst_firstViewControllerOfClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
