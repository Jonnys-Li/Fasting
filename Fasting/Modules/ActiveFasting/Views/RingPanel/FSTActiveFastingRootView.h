//
//  FSTActiveFastingRootView.h
//  Fasting
//
//  活跃断食页的根视图：滚动容器 + headline + 血糖阶段卡 + 圆环面板 +
//  可编辑时间行 + 中止按钮 + tips section。
//

#import <UIKit/UIKit.h>

@class FSTFastingPhaseSummaryCard;
@class FSTFastingRingPanelView;
@class FSTFastingTimesRow;
@class FSTFastingTipsSectionView;

NS_ASSUME_NONNULL_BEGIN

/// 活跃断食页根视图。承担除 topBar 之外的全部 UI 与约束。
///
/// 因为 FSTFastingTopBar 需要直接 install 到 VC.view 顶层（使用 safeArea 锚点），
/// 所以本视图不包含 topBar；VC 创建并 install topBar 之后，需要把 self.scrollView.top
/// 约束到 topBar.mas_bottom（其余三边由本视图内部约束）。
@interface FSTActiveFastingRootView : UIView

/// 滚动容器。VC 在 topBar install 完毕后需要补一条 `top.equalTo(topBar.mas_bottom)` 约束。
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong, readonly) UIView *contentView;

/// "You're fasting!" 标题。
@property (nonatomic, strong, readonly) UILabel *headlineLabel;

/// 血糖阶段摘要卡，可点击进详情页。
@property (nonatomic, strong, readonly) FSTFastingPhaseSummaryCard *phaseCard;

/// 中央圆环面板（含 timerText / endText / planName / progress / displayMode 等 setter）。
@property (nonatomic, strong, readonly) FSTFastingRingPanelView *ringPanel;

/// 圆环下方的可编辑时间行（绿色高亮 Start）。
@property (nonatomic, strong, readonly) FSTFastingTimesRow *timesRow;

/// 中止按钮（END FASTING / COMPLETE FASTING 两种样式）。
@property (nonatomic, strong, readonly) UIButton *stopButton;

/// 底部贴士区（Drink now / 阶段提示）。
@property (nonatomic, strong, readonly) FSTFastingTipsSectionView *tipsSection;

#pragma mark - 事件回调

@property (nonatomic, copy, nullable) void (^onPhaseCardTapped)(void);
@property (nonatomic, copy, nullable) void (^onRingModeTapped)(void);
@property (nonatomic, copy, nullable) void (^onPlanChipTapped)(void);
@property (nonatomic, copy, nullable) void (^onEditStartTapped)(void);
@property (nonatomic, copy, nullable) void (^onEditEndTapped)(void);
@property (nonatomic, copy, nullable) void (^onStopTapped)(void);
@property (nonatomic, copy, nullable) void (^onDrinkNowTapped)(void);
@property (nonatomic, copy, nullable) void (^onSendFeedbackTapped)(void);

@end

NS_ASSUME_NONNULL_END
