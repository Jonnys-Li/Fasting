//
//  FSTActiveFastingRootView.h
//  Fasting
//
//  活跃断食页的根视图：滚动容器 + headline + 血糖阶段卡 + 圆环面板 +
//  可编辑时间行 + 中止按钮 + tips section + send feedback 行。
//
//  因为 FSTFastingTopBar 需要直接 install 到 VC.view 顶层（使用 safeArea 锚点），
//  所以本视图不包含 topBar；VC 在 install topBar 之后调 -anchorContentBelowTopBar: 把
//  scrollView 顶部锚到 topBar 之下。
//  phaseCard / ringPanel / timesRow / stopButton / tipsSection 由 VC 创建后通过 mount API 推入。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTActiveFastingRootView : UIView

/// 把 VC 创建的 5 个核心子视图 mount 到 contentView 并锁定彼此的纵向约束。
/// 须在 RootView 加入 superview 后调一次。
- (void)mountPhaseCard:(UIControl *)phaseCard
             ringPanel:(UIView *)ringPanel
              timesRow:(UIView *)timesRow
            stopButton:(UIButton *)stopButton
           tipsSection:(UIView *)tipsSection;

/// 把内部 scrollView 的 top 锚到 topBar 之下（topBar 由 VC 直接 install 到 VC.view，
/// 不在 RootView 内部）。须在 topBar 装好后调一次。
- (void)anchorContentBelowTopBar:(UIView *)topBar;

@property (nonatomic, copy, nullable) void (^onDrinkNowTapped)(void);
@property (nonatomic, copy, nullable) void (^onSendFeedbackTapped)(void);

@end

NS_ASSUME_NONNULL_END
