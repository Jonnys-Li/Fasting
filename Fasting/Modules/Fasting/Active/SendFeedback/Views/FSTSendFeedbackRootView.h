//
//  FSTSendFeedbackRootView.h
//  Fasting
//
//  Send Feedback 页的根视图：信封 + 标题 + 6 枚分类 chip + 文字输入 + 图片 + 提交按钮。
//  RootView 自己构建外壳与 chip 区；textView 与 placeholderLabel 由 VC 创建后通过 mount API 推入。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTSendFeedbackRootView : UIView

/// 已选图片预览 —— VC 设置 image 并切换 hidden（当前样子化，未被外部读写）。
@property (nonatomic, strong, readonly) UIImageView *pickedImageView;

/// 当前选中的 chip 下标，-1 表示未选。视图内部维护选中态。
@property (nonatomic, assign) NSInteger selectedChipIndex;

/// 分类 chip 标题列表（内部初始化，外部只读）。
@property (nonatomic, copy, readonly) NSArray<NSString *> *chipTitles;

/// 把 VC 创建的 textView 与 placeholderLabel mount 到内部 textViewContainer。须在 RootView 加入 superview 后调一次。
- (void)mountTextView:(UITextView *)textView placeholderLabel:(UILabel *)placeholderLabel;

/// 返回按钮点击回调。
@property (nonatomic, copy, nullable) void (^onBackTapped)(void);

/// 提交按钮点击回调。
@property (nonatomic, copy, nullable) void (^onSubmitTapped)(void);

/// 添加图片按钮点击回调。
@property (nonatomic, copy, nullable) void (^onAddPictureTapped)(void);

@end

NS_ASSUME_NONNULL_END
