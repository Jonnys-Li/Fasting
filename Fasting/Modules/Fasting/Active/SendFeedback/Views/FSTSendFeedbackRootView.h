//
//  FSTSendFeedbackRootView.h
//  Fasting
//
//  Send Feedback 页的根视图：信封 + 标题 + 6 枚分类 chip + 文字输入 + 图片 + 提交按钮。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// SendFeedback 页的根视图。承担全部 UI 创建与 Masonry 约束，
/// VC 仅负责通过暴露的子视图属性进行状态推送与回调接线。
@interface FSTSendFeedbackRootView : UIView

/// 文字输入框 —— VC 需设置 delegate 并读取文本。
@property (nonatomic, strong, readonly) UITextView *textView;

/// 占位提示标签 —— VC 根据输入更新 hidden。
@property (nonatomic, strong, readonly) UILabel *placeholderLabel;

/// 已选图片预览 —— VC 设置 image 并切换 hidden。
@property (nonatomic, strong, readonly) UIImageView *pickedImageView;

/// 当前选中的 chip 下标，-1 表示未选。视图内部维护选中态。
@property (nonatomic, assign) NSInteger selectedChipIndex;

/// 分类 chip 标题列表（内部初始化，外部只读即可）。
@property (nonatomic, copy, readonly) NSArray<NSString *> *chipTitles;

/// 返回按钮点击回调。
@property (nonatomic, copy, nullable) void (^onBackTapped)(void);

/// 提交按钮点击回调。
@property (nonatomic, copy, nullable) void (^onSubmitTapped)(void);

/// 添加图片按钮点击回调。
@property (nonatomic, copy, nullable) void (^onAddPictureTapped)(void);

@end

NS_ASSUME_NONNULL_END
