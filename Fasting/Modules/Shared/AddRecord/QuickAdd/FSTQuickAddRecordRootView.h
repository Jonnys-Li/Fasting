//
//  FSTQuickAddRecordRootView.h
//  Fasting
//
//  快速添加断食记录页的根视图：顶部 navBar + duration 行 + 两段 TimeRow + 底部保存按钮的滚动布局。
//  RootView 自己构建外壳（navBar / scrollView / contentView / durationRow 容器 / separator / saveButton），
//  startRow / endRow / durationValueLabel 由 VC 创建后通过 mount API 推入并布局。
//

#import <UIKit/UIKit.h>

@class FSTTimeRowView;

NS_ASSUME_NONNULL_BEGIN

@interface FSTQuickAddRecordRootView : UIView

/// 把 VC 创建好的 startRow / endRow / durationValueLabel mount 到 RootView 的对应槽位并装上约束。
/// 必须在 RootView 加入 superview 之后调用一次。
- (void)mountStartRow:(FSTTimeRowView *)startRow
               endRow:(FSTTimeRowView *)endRow
   durationValueLabel:(UILabel *)durationValueLabel;

/// 返回按钮点击回调。
@property (nonatomic, copy, nullable) void (^onBackTapped)(void);

/// 保存按钮点击回调。
@property (nonatomic, copy, nullable) void (^onSaveTapped)(void);

@end

NS_ASSUME_NONNULL_END
