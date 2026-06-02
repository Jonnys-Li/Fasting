//
//  FSTFastingIdleRootView.h
//  Fasting
//
//  Plan 首页（idle 态）的滚动容器壳：持有 scrollView + contentView，并在
//  picker / ready 两种 body 视图之间切换。VC 通过 loadView 装载本视图。
//  topBar 仍由 VC 在 self.view 顶层 install（safeArea 锚），故每次切状态、
//  重建 topBar 后，VC 调 -anchorContentBelowTopBar: 把内容顶到 topBar 之下。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTFastingIdleRootView : UIView

/// 当前承载的 body（picker 或 ready），赋值即切换：移除旧 body 并把新 body
/// 的 edges 贴满 contentView。传 nil 清空。
@property (nonatomic, strong, nullable) UIView *bodyView;

/// 把 scrollView 顶部锚到 topBar 之下（topBar 每次切状态会被 VC 重建，故需重锚）。
- (void)anchorContentBelowTopBar:(UIView *)topBar;

@end

NS_ASSUME_NONNULL_END
