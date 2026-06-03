//
//  FSTModalDialogContentView.h
//  Fasting
//
//  通用确认/提示弹窗的内容视图 — 图标圆背景 + 关闭按钮 + 标题 + 消息 + 主/次按钮。
//  由 FSTModalDialogViewController 创建并放入 cardContainer 内；
//  VC 负责 dismiss 与回调分发，本视图只负责 UI 创建与约束。
//
//  使用方式：[[FSTModalDialogContentView alloc] init]，然后 set 各文案/图标属性。
//  iconSystemName 与 iconImageName 互斥：imageName 优先，两个都没有则不显示图标。
//  secondaryTitle 为空时次按钮自动隐藏。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTModalDialogContentView : UIView

/// SF Symbol 名（与 iconImageName 互斥，imageName 优先）。
@property (nonatomic, copy, nullable) NSString *iconSystemName;

/// Asset Catalog 图片名（优先于 iconSystemName）。
@property (nonatomic, copy, nullable) NSString *iconImageName;

/// 主标题。
@property (nonatomic, copy, nullable) NSString *titleText;

/// 多行说明文字。
@property (nonatomic, copy, nullable) NSString *message;

/// 主按钮标题。
@property (nonatomic, copy, nullable) NSString *primaryTitle;

/// 次按钮标题，nil 或空串时只显示主按钮（自动隐藏次按钮 + 取消按钮间距）。
@property (nonatomic, copy, nullable) NSString *secondaryTitle;

/// 关闭按钮点击回调。
@property (nonatomic, copy, nullable) void (^onCloseTapped)(void);

/// 主按钮点击回调。
@property (nonatomic, copy, nullable) void (^onPrimaryTapped)(void);

/// 次按钮点击回调。
@property (nonatomic, copy, nullable) void (^onSecondaryTapped)(void);

@end

NS_ASSUME_NONNULL_END
