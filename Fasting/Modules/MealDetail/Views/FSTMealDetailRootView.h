//
//  FSTMealDetailRootView.h
//  Fasting
//
//  餐食详情页的根视图：顶部返回按钮+标题 + 5 张卡片纵向滚动 + 底部保存按钮。
//

#import <UIKit/UIKit.h>

@class FSTMealTimeCardView;
@class FSTMealSlotCardView;
@class FSTMealDietCardView;
@class FSTMealTasteCardView;
@class FSTMealDetailContentCardView;

NS_ASSUME_NONNULL_BEGIN

/// MealDetail 页的根视图。承担全部 UI 创建与 Masonry 约束，
/// VC 仅负责通过暴露的子视图属性进行状态推送与回调接线。
@interface FSTMealDetailRootView : UIView

/// 时间卡片。
@property (nonatomic, strong, readonly) FSTMealTimeCardView *timeCardView;

/// 正餐/零食卡片。
@property (nonatomic, strong, readonly) FSTMealSlotCardView *slotCardView;

/// 饮食类型卡片。
@property (nonatomic, strong, readonly) FSTMealDietCardView *dietCardView;

/// 口味卡片。
@property (nonatomic, strong, readonly) FSTMealTasteCardView *tasteCardView;

/// 详情（照片+描述）卡片。
@property (nonatomic, strong, readonly) FSTMealDetailContentCardView *detailCardView;

/// 顶部返回按钮点击回调。
@property (nonatomic, copy, nullable) void (^onBackTapped)(void);

/// 底部"保存"按钮点击回调。
@property (nonatomic, copy, nullable) void (^onSaveTapped)(void);

@end

NS_ASSUME_NONNULL_END
