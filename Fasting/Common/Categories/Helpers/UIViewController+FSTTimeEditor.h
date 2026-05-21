//
//  UIViewController+FSTTimeEditor.h
//  Fasting
//
//  时间编辑器调用入口 — 把"present TimeEditorSheet → 在回调里更新模型"这套模式封装到 UIViewController 上。
//  为什么是 Category 而不是单独的 helper：复用 UIViewController.presentViewController 调用上下文 (self)，
//  避免每个调用点都要传 presenting controller；同时让 ActiveFasting / Plan / MealDetail 等 VC 调用更直观。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 共享时间编辑器：底部白色 sheet + 滚轮 UIDatePicker。
/// 提供关闭和保存两个动作；保存时回调 onCommit。
@interface UIViewController (FSTTimeEditor)

/// 简版 — 不带 align chip、不带 min/max 限制。用于纯粹的时间选择（如餐食时间编辑）。
/// @param title       sheet 顶部标题文案（"Start time" / "End time" / "Meal time" 等）。
/// @param initialDate picker 初始定位的时间。
/// @param onCommit    用户点保存时触发；参数是新选定时间。取消则不触发。
- (void)fst_presentTimeEditorWithTitle:(NSString *)title
                           initialDate:(NSDate *)initialDate
                              onCommit:(void (^)(NSDate *pickedDate))onCommit;

/// 全功能版 — 用于活跃断食页的 Start/Ends 编辑：可以带 min/max、可以带一个 align chip 让用户切换"按 plan 对齐"。
/// @param minimumDate   picker 不允许选早于此时间（用于 endDate 至少要 > startDate+60s）。nil 不限。
/// @param maximumDate   picker 不允许选晚于此时间（如未来时间在活跃中通常禁止）。nil 不限。
/// @param alignChipText 顶部 chip 的标题（如 "Align with plan"）。nil 时不显示 chip。
/// @param alignedDate   chip 激活时的"对齐目标日期"。chip 切换会让 picker 跳到该日期并禁用滚动。
/// @param initiallyAligned 进入时 chip 是否激活态（YES = picker 锁定到 alignedDate）。
/// @param onCommit       回调参数 (pickedDate, aligned)：aligned=YES 表示当前是 align chip 激活的提交，
///                       调用方可借此调 sessionManager 的 editActiveStartDate:alignWithPlan: 走 align 分支。
- (void)fst_presentTimeEditorWithTitle:(NSString *)title
                           initialDate:(NSDate *)initialDate
                           minimumDate:(nullable NSDate *)minimumDate
                           maximumDate:(nullable NSDate *)maximumDate
                         alignChipText:(nullable NSString *)alignChipText
                           alignedDate:(nullable NSDate *)alignedDate
                       initiallyAligned:(BOOL)initiallyAligned
                               onCommit:(void (^)(NSDate *pickedDate, BOOL aligned))onCommit;

@end

NS_ASSUME_NONNULL_END
