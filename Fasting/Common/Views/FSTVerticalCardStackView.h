//
//  FSTVerticalCardStackView.h
//  Fasting
//
//  通用的"卡片纵向堆栈"容器：把若干张同宽卡片沿垂直方向排列，间距与边距可配置。
//  与 UIStackView 的差别在于它直接用 Masonry 约束生成 intrinsic content size，
//  方便嵌入 UIScrollView 的 contentView 做滚动布局。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 卡片纵向堆栈容器。先 `cards = @[a, b, c]` 配置子卡片，可选地调整 `cardSpacing`
/// 与 `contentInsets`；本视图会自动 addSubview 并约束子卡片。
@interface FSTVerticalCardStackView : UIView

/// 子卡片，按顺序自上而下排列。重新赋值会拆掉原有约束并按新数组重建。
@property (nonatomic, copy) NSArray<UIView *> *cards;

/// 相邻卡片之间的间距，默认 18。
@property (nonatomic, assign) CGFloat cardSpacing;

/// 容器内的内距（顶/左/底/右），默认 (0, 22, 28, 22)。
/// 顶部留 0 因为常见用法是 contentView 自己已经留过上边距。
@property (nonatomic, assign) UIEdgeInsets contentInsets;

@end

NS_ASSUME_NONNULL_END
