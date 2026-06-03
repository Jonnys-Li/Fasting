//
//  FSTMealDetailRootView.h
//  Fasting
//
//  餐食详情页的根视图：顶部返回按钮+标题 + 5 张卡片纵向滚动 + 底部保存按钮。
//  RootView 自己负责外壳（topBar / scrollView / cardStack 容器 / bottomBar / saveButton）；
//  5 张卡片由 VC 创建后通过 mount API 推入 cardStack。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealDetailRootView : UIView

/// 把 VC 创建好的 5 张卡片 mount 到内部 cardStack，按入参顺序自上而下排列。
/// 须在 RootView 加入 superview 之后调用一次。
- (void)mountCards:(NSArray<UIView *> *)cards;

/// 顶部返回按钮点击回调。
@property (nonatomic, copy, nullable) void (^onBackTapped)(void);

/// 底部"保存"按钮点击回调。
@property (nonatomic, copy, nullable) void (^onSaveTapped)(void);

@end

NS_ASSUME_NONNULL_END
