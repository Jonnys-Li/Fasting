//
//  FSTPlanConfirmRootView.h
//  Fasting
//
//  确认开始断食页的根视图：标题 + 时间轴 + 开始按钮 + 准备提示，承担全部 UI 创建与 Masonry 约束。
//

#import <UIKit/UIKit.h>

@class FSTPlanConfirmTimelineView;
@class FSTPlanPrepCardView;

NS_ASSUME_NONNULL_BEGIN

@interface FSTPlanConfirmRootView : UIView

/// 页面标题（plan name）。
@property (nonatomic, strong, readonly) UILabel *titleLabel;

/// 时间轴视图（开始 → 结束）。
@property (nonatomic, strong, readonly) FSTPlanConfirmTimelineView *timelineView;

/// "Start Fasting" 按钮。
@property (nonatomic, strong, readonly) UIButton *startButton;

/// 断食准备提示卡。
@property (nonatomic, strong, readonly) FSTPlanPrepCardView *prepCardView;

/// 返回按钮点击回调。
@property (nonatomic, copy, nullable) void (^onBackTapped)(void);

/// 开始断食按钮点击回调。
@property (nonatomic, copy, nullable) void (^onStartTapped)(void);

/// 时间轴"编辑开始时间"点击回调（由 timelineView 转发）。
@property (nonatomic, copy, nullable) void (^onEditStartTapped)(void);

@end

NS_ASSUME_NONNULL_END
