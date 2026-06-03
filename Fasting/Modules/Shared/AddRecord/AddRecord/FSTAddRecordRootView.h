//
//  FSTAddRecordRootView.h
//  Fasting
//
//  添加/编辑断食记录页的根视图：顶部绿色 header + 4 张卡片纵向滚动 + 底部取消/保存按钮。
//  headerView 与 4 张卡片由 VC 创建后通过 mount API 推入；RootView 自己持
//  scrollView/contentView/cardStack/bottomBar/取消/保存。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTAddRecordRootView : UIView

/// 把 VC 创建的 headerView 与 4 张 InputCard mount 到对应槽位。
/// 须在 RootView 加入 superview 后调一次。
- (void)mountHeaderView:(UIView *)headerView
                  cards:(NSArray<UIView *> *)cards;

/// 底部"取消"按钮点击回调。
@property (nonatomic, copy, nullable) void (^onCancelTapped)(void);

/// 底部"保存"按钮点击回调。
@property (nonatomic, copy, nullable) void (^onSaveTapped)(void);

@end

NS_ASSUME_NONNULL_END
