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
/// 使用方式（caller 端）：
///     bar = [FSTFastingTopBar new];
///     bar.leftButton    = ...;            // 可空
///     bar.rightButtons  = @[...];         // 可空，按入参顺序从右向左排列
///     bar.centerContent = ...;            // 可空
///     bar.contentHeight = kFooHeight;     // 可不设，默认 56pt
///     [bar installInViewController:vc];   // 内部会调一次 -updateData 应用上述属性
///
/// 安装后再改属性，需要手动再调 -updateData 一次。
///
/// z-order：通过 -installInViewController: 安装时，本视图 addSubview 到 VC.view，
/// 调用方需要先把 scrollView 加入 VC.view，再调用 installInViewController:，
/// 这样 topBar 在 z-order 上方，scrollView 内容向上滚动时不会穿透。
///
/// 把 scrollView.top 锚到本视图底部时，使用 Masonry 的 `topBar.mas_bottom`。
@interface FSTFastingTopBar : UIView

/// 左侧按钮（可空）。
@property (nonatomic, strong, nullable) UIButton *leftButton;

/// 右侧按钮组，按入参顺序从右向左排列（首元素最右）。
@property (nonatomic, copy, nullable) NSArray<UIButton *> *rightButtons;

/// 中间内容（label / segment / 等，可空）。
@property (nonatomic, strong, nullable) UIView *centerContent;

/// safeArea.top 以下的可视高度，set 0 或不设使用默认 56pt。
@property (nonatomic, assign) CGFloat contentHeight;

/// 加到 VC.view 顶部并装上约束。先把 scrollView 加入 VC.view，再调用本方法。
/// 内部会调一次 -updateData 应用 left/center/right 属性当前值。
- (void)installInViewController:(UIViewController *)viewController;

/// 重新读 left/center/right 属性并刷新 contentContainer 内的子视图布局。
/// 一般由 -installInViewController: 自动调用；属性安装后再变化才需手动调用。
- (void)updateData;

@end

NS_ASSUME_NONNULL_END
