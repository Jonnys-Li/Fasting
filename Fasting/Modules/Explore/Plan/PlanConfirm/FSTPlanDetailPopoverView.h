//
//  FSTPlanDetailPopoverView.h
//  Fasting
//
//  PlanConfirm 标题下方的「方案详情卡」：灰底圆角 + 顶部朝上小三角（指向标题/chevron）
//  + 两行带色点说明（Nh fasting / Mh eating）。本视图只渲染内容与三角；
//  展开 / 收起的高度切换由 FSTPlanConfirmRootView 控制。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTPlanDetailPopoverView : UIView

/// 展开态总高度（三角 + 卡片），供 RootView 设置高度约束用。
@property (nonatomic, readonly) CGFloat expandedHeight;

/// 推入方案的断食 / 进食小时数，刷新两行文案。
- (void)setFastingHours:(NSInteger)fastingHours eatingHours:(NSInteger)eatingHours;

@end

NS_ASSUME_NONNULL_END
