//
//  FSTModalDialogContentView.h
//  Fasting
//
//  通用确认/提示弹窗的内容视图 — 图标圆背景 + 关闭按钮 + 标题 + 消息 + 主/次按钮。
//  由 FSTModalDialogViewController 创建并放入 cardContainer 内；
//  VC 负责 dismiss 与回调分发，本视图只负责 UI 创建与约束。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTModalDialogContentView : UIView

/// 唯一指定初始化。
/// @param systemName     SF Symbol 名，nil 时尝试用 imageName。
/// @param imageName      Asset Catalog 图片名，nil 时用 systemName。
/// @param title          主标题。
/// @param message        多行说明文字。
/// @param primaryTitle   主按钮标题。
/// @param secondaryTitle 次按钮标题，nil 时只显示主按钮。
- (instancetype)initWithIconSystemName:(nullable NSString *)systemName
                         iconImageName:(nullable NSString *)imageName
                                 title:(NSString *)title
                               message:(NSString *)message
                          primaryTitle:(NSString *)primaryTitle
                        secondaryTitle:(nullable NSString *)secondaryTitle NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// 关闭按钮点击回调。
@property (nonatomic, copy, nullable) void (^onCloseTapped)(void);

/// 主按钮点击回调。
@property (nonatomic, copy, nullable) void (^onPrimaryTapped)(void);

/// 次按钮点击回调。
@property (nonatomic, copy, nullable) void (^onSecondaryTapped)(void);

@end

NS_ASSUME_NONNULL_END
