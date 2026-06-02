//
//  FSTModalDialogViewController.h
//  Fasting
//
//  通用确认/提示弹窗 — 居中卡片样式（继承自 FSTBaseModalViewController, CenteredCard 风格）。
//  典型场景：放弃断食确认、删除记录确认、"功能开发中"占位提示。
//  - 视觉结构：可选图标 + 标题 + 多行 message + 主按钮 + 可选次按钮。
//  - 触发：业务 VC 用 [self presentViewController:dialog animated:YES] 弹出，
//    用户点按钮触发回调，弹窗会自动 dismiss。
//

#import "FSTBaseModalViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// 顶部图标来源种类。
/// 写入方：caller 在 -initWithIconKind: 时指定。
/// 读取方：本 VC 内部 → FSTModalDialogContentView 的 iconSystemName / iconImageName。
typedef NS_ENUM(NSInteger, FSTModalDialogIconKind) {
    /// 不显示图标，iconName 传 nil 即可。
    FSTModalDialogIconKindNone = 0,
    /// SF Symbol，iconName 形如 "flag.fill" / "checkmark.circle"。
    FSTModalDialogIconKindSystemSymbol,
    /// Asset Catalog 图片，用于品牌或多色图标；iconName 形如 "breaking_fast_food"。
    FSTModalDialogIconKindAssetImage,
};

/// 弹窗按钮回调 — 点击后会先 dismiss 弹窗再触发 handler，调用方无需手动 dismiss。
typedef void (^FSTModalDialogActionHandler)(void);

@interface FSTModalDialogViewController : FSTBaseModalViewController

/// 唯一指定初始化。
/// @param iconKind         图标来源种类；None 时 iconName 可传 nil。
/// @param iconName         图标名（按 iconKind 解释为 SF Symbol 名或 Asset 名）。
/// @param title            主标题。
/// @param message          多行说明文字。
/// @param primaryTitle     主按钮标题（如 "OK" / "Delete" / "Discard"）。
/// @param secondaryTitle   次按钮标题（如 "Cancel"）。nil 时只显示一个主按钮。
/// @param primaryHandler   主按钮点击回调，nil 时仅 dismiss。
/// @param secondaryHandler 次按钮点击回调，nil 时仅 dismiss。
- (instancetype)initWithIconKind:(FSTModalDialogIconKind)iconKind
                        iconName:(nullable NSString *)iconName
                           title:(NSString *)title
                         message:(NSString *)message
                    primaryTitle:(NSString *)primaryTitle
                  secondaryTitle:(nullable NSString *)secondaryTitle
                  primaryHandler:(nullable FSTModalDialogActionHandler)primaryHandler
                secondaryHandler:(nullable FSTModalDialogActionHandler)secondaryHandler;

@end

NS_ASSUME_NONNULL_END
