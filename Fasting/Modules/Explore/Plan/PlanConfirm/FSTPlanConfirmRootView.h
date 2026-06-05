//
//  FSTPlanConfirmRootView.h
//  Fasting
//
//  确认开始断食页的根视图：标题 + 可展开方案详情卡 + 时间轴 + 开始按钮 + 准备提示，承担外壳布局。
//  titleLabel 与 timelineView 由 VC 创建后通过 mount API 推入；RootView 只持有 nav 容器、
//  scroll/content 容器、startButton、prepCardView、detailPopover。
//  点标题/chevron 由 RootView 自己内联展开·收起 detailPopover（纯视图态，不回调 VC）。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTPlanConfirmRootView : UIView

/// 把 VC 创建的 titleLabel 与 timelineView 挂到 contentView，并锁定其上下游约束。
/// 须在 RootView 加入 superview 后调一次。
- (void)mountTitleLabel:(UILabel *)titleLabel
           timelineView:(UIView *)timelineView;

/// 返回按钮点击回调。
@property (nonatomic, copy, nullable) void (^onBackTapped)(void);

/// 开始断食按钮点击回调。
@property (nonatomic, copy, nullable) void (^onStartTapped)(void);

/// 推入当前方案的断食 / 进食小时数，刷新详情卡内容。VC 在 refreshPlanLabels 时调用。
- (void)setPlanFastingHours:(NSInteger)fastingHours eatingHours:(NSInteger)eatingHours;

@end

NS_ASSUME_NONNULL_END
