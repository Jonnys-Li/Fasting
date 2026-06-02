//
//  FSTMealDiaryRootView.h
//  Fasting
//
//  食物日记列表页的根视图：顶部固定栏 + 垂直时间轴滚动 + 底部黄色确认按钮。
//

#import <UIKit/UIKit.h>

@class FSTMealDiaryTopBarView;

NS_ASSUME_NONNULL_BEGIN

/// MealDiary 页的根视图。承担全部 UI 创建与 Masonry 约束，
/// VC 仅负责通过暴露的子视图属性进行状态推送与回调接线。
@interface FSTMealDiaryRootView : UIView

/// 顶部固定栏（日期选择、返回）。
@property (nonatomic, strong, readonly) FSTMealDiaryTopBarView *topBarView;

/// 垂直时间轴容器，VC 动态增删行。
@property (nonatomic, strong, readonly) UIStackView *timelineStack;

/// 底部"确认"按钮点击回调。
@property (nonatomic, copy, nullable) void (^onConfirmTapped)(void);

@end

NS_ASSUME_NONNULL_END
