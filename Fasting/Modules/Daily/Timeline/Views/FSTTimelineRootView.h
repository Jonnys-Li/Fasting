//
//  FSTTimelineRootView.h
//  Fasting
//
//  Timeline Tab 主页的根视图：标题 + 两张模块卡（断食 + 餐食）纵向滚动。
//  fastingModuleView / mealModuleView 由 VC 创建后通过 mount API 推入。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTTimelineRootView : UIView

/// 把 VC 创建的两张模块卡挂到 contentView。须在 RootView 加入 superview 后调一次。
- (void)mountFastingModuleView:(UIView *)fastingModuleView
                mealModuleView:(UIView *)mealModuleView;

@end

NS_ASSUME_NONNULL_END
