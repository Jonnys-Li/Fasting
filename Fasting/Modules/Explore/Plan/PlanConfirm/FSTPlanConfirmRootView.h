//
//  FSTPlanConfirmRootView.h
//  Fasting
//
//  确认开始断食页的根视图：标题 + 时间轴 + 开始按钮 + 准备提示，承担外壳布局。
//  titleLabel 与 timelineView 由 VC 创建后通过 mount API 推入；RootView 只持有 nav 容器、
//  scroll/content 容器、startButton、prepCardView。
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

@end

NS_ASSUME_NONNULL_END
