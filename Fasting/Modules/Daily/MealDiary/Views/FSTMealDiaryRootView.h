//
//  FSTMealDiaryRootView.h
//  Fasting
//
//  食物日记列表页的根视图：顶部固定栏 + 垂直时间轴滚动 + 底部黄色确认按钮。
//  topBarView 与 timelineStack 由 VC 创建后通过 mount API 推入；
//  RootView 自己持 scrollView/contentView/confirmButton。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealDiaryRootView : UIView

/// 把 VC 创建的 topBarView 与 timelineStack mount 到对应槽位。
/// 须在 RootView 加入 superview 后调一次。
- (void)mountTopBarView:(UIView *)topBarView timelineStack:(UIStackView *)timelineStack;

/// 底部"确认"按钮点击回调。
@property (nonatomic, copy, nullable) void (^onConfirmTapped)(void);

@end

NS_ASSUME_NONNULL_END
