//
//  FSTFastingTopBar.h
//  Fasting
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 共享的粘性顶部导航栏。
///
/// 视觉：白底从屏幕物理顶端铺到 safeArea.top + contentHeight；内部按钮锚到 safeArea.top
/// 以避开灵动岛/状态栏。三个槽位（left / center / right），right 自右向左排列。
///
/// z-order：通过 -installInViewController: 安装时，本视图 addSubview 到 VC.view，
/// 调用方需要先把 scrollView 加入 VC.view，再调用 installInViewController:，
/// 这样 topBar 在 z-order 上方，scrollView 内容向上滚动时不会穿透。
///
/// 把 scrollView.top 锚到本视图底部时，使用 Masonry 的 `topBar.mas_bottom`。
@interface FSTFastingTopBar : UIView

/// @param leftButton     左侧按钮（可空）
/// @param rightButtons   右侧按钮组，按入参顺序从右向左排列（首元素最右）
/// @param centerContent  中间内容（label / segment / 等，可空）
/// @param contentHeight  safeArea.top 以下的可视高度，传 0 使用默认 56pt
- (instancetype)initWithLeftButton:(nullable UIButton *)leftButton
                      rightButtons:(nullable NSArray<UIButton *> *)rightButtons
                     centerContent:(nullable UIView *)centerContent
                     contentHeight:(CGFloat)contentHeight NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// 加到 VC.view 顶部并装上约束。先把 scrollView 加入 VC.view，再调用本方法。
- (void)installInViewController:(UIViewController *)viewController;
- (void)updateData;

@end

NS_ASSUME_NONNULL_END
