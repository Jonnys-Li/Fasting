//
//  FSTFastingHistoryRootView.h
//  Fasting
//
//  断食历史页的根视图：顶部导航栏（返回 + 标题 + 分享）+ "Today" 标签 + 列表容器。
//  tableView 由 VC 创建后通过 mount API 推入；RootView 自己负责外壳与 Today 标签。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTFastingHistoryRootView : UIView

/// 顶部「相对日期」标签的文案（默认 Today）。VC 在滚动时按可见 record 的日期更新。
@property (nonatomic, copy) NSString *todayText;

/// 把 VC 创建的 tableView 装入 RootView，按 todayLabel 下方 + 占满 RootView 宽高布局。
/// 须在 RootView 加入 superview 后调一次。
- (void)mountTableView:(UITableView *)tableView;

/// 返回按钮点击回调。
@property (nonatomic, copy, nullable) void (^onBackTapped)(void);

@end

NS_ASSUME_NONNULL_END
