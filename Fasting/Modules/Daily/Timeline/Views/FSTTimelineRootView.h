//
//  FSTTimelineRootView.h
//  Fasting
//
//  Timeline Tab 主页的根视图：标题 + 两张模块卡（断食 + 餐食）纵向滚动。
//

#import <UIKit/UIKit.h>

@class FSTFastingTimelineCardView;
@class FSTTimelineModuleView;

NS_ASSUME_NONNULL_BEGIN

/// Timeline 页的根视图。承担全部 UI 创建与 Masonry 约束，
/// VC 仅负责通过暴露的子视图属性进行状态推送与回调接线。
@interface FSTTimelineRootView : UIView

/// 断食摘要卡。
@property (nonatomic, strong, readonly) FSTFastingTimelineCardView *fastingModuleView;

/// 餐食日记卡。
@property (nonatomic, strong, readonly) FSTTimelineModuleView *mealModuleView;

@end

NS_ASSUME_NONNULL_END
