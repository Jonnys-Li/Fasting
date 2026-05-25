//
//  FSTFastingHistoryRootView.h
//  Fasting
//
//  断食历史页的根视图：顶部导航栏（返回 + 标题 + 分享）+ "Today" 标签 + 列表。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// FastingHistory 页的根视图。承担全部 UI 创建与 Masonry 约束，
/// VC 仅负责通过暴露的子视图属性进行状态推送与回调接线。
@interface FSTFastingHistoryRootView : UIView

/// 断食记录列表。VC 设置 dataSource/delegate。
@property (nonatomic, strong, readonly) UITableView *tableView;

/// 顶部「相对日期」标签的文案（默认 Today）。VC 在滚动时按可见 record 的日期更新。
@property (nonatomic, copy) NSString *todayText;

/// 返回按钮点击回调。
@property (nonatomic, copy, nullable) void (^onBackTapped)(void);

@end

NS_ASSUME_NONNULL_END
