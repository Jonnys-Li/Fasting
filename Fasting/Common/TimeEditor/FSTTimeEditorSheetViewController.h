//
//  FSTTimeEditorSheetViewController.h
//  Fasting
//
//  时间编辑底卡 — 继承自 FSTBaseModalViewController (BottomSheet 风格)。
//  视觉：底部白色 sheet + 滚轮 UIDatePicker + 可选 "Align with plan" chip + 关闭/保存按钮。
//
//  调用入口：业务侧不直接 alloc/init 这个类，而是用 UIViewController+FSTTimeEditor 上的方法
//  [self fst_presentTimeEditorWithTitle:...] —— 该 Category 负责构造本 VC 并 present。
//
//  使用方式（按 R3：UIVC 配置走 property setter）：
//     sheet = [FSTTimeEditorSheetViewController new];
//     sheet.titleText            = @"...";
//     sheet.initialDate          = ...;
//     sheet.alignChipText        = @"Align with 14-10";  // 可不设
//     sheet.alignMode            = FSTTimeEditorAlignModeStartFast;
//     sheet.alignDurationSeconds = ...;                  // chip 模式下必设
//     sheet.alignReferenceDate   = ...;                  // EndFast / ReferencePlusDuration 必设
//     sheet.onCommit             = ^(NSDate *p, BOOL a) { ... };
//     [self presentViewController:sheet animated:YES completion:nil];
//
//  Align chip 交互（参照 demo1 的 FastingTimeEditorSheetViewController 设计）：
//    - 不是 toggle，而是一次性 Apply。点击后 picker 跳到对齐时间，chip 变灰禁用。
//    - 用户滚动 picker 后 chip 重新亮起（视 mode 决定）。
//    - 三种 mode：StartFast / EndFast / ReferencePlusDuration，决定启用条件 + 对齐目标计算。
//
//  使用场景：Active Fasting 页编辑 Start/Ends、MealDetail 页编辑 Meal time、AddRecord 页编辑结束时刻。
//

#import "FSTBaseModalViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// Align chip 的对齐行为模式。决定「启用条件」与「点击后跳到哪个时间」。
typedef NS_ENUM(NSInteger, FSTTimeEditorAlignMode) {
    /// 编辑「开始时间」：Align 默认可点；点击后 picker 跳到 `now - alignDurationSeconds`（让现在正好是完成点），
    /// chip 变灰；用户改 picker 后 chip 重新亮起。
    FSTTimeEditorAlignModeStartFast = 0,
    /// 编辑「结束时间」：Align 默认变灰（防误触）；用户改 picker 后才启用；点击后 picker 跳到
    /// `alignReferenceDate + alignDurationSeconds`，chip 又变灰。
    FSTTimeEditorAlignModeEndFast,
    /// 通用参考点 + 时长：可点条件同 StartFast；点击后 picker 跳到 `alignReferenceDate + alignDurationSeconds`。
    FSTTimeEditorAlignModeReferencePlusDuration,
};

/// 用户点保存时触发。aligned=YES 表示保存时 chip 处于已应用状态（对齐分支）。
/// 调用方据此调 sessionManager 的 editActiveStartDate:alignWithPlan: 走对应分支。
/// pickedDate 始终是 picker 当前值（已包含对齐的写入）。
typedef void (^FSTTimeEditorCommitHandler)(NSDate *pickedDate, BOOL aligned);

@interface FSTTimeEditorSheetViewController : FSTBaseModalViewController

#pragma mark - 显示配置

/// sheet 顶部大标题。
@property (nonatomic, copy, nullable) NSString *titleText;

/// picker 初始定位时间。nil 时使用 [NSDate date]。
@property (nonatomic, strong, nullable) NSDate *initialDate;

/// picker 允许的最早时间，nil 不限。
@property (nonatomic, strong, nullable) NSDate *minimumDate;

/// picker 允许的最晚时间，nil 不限。
@property (nonatomic, strong, nullable) NSDate *maximumDate;

#pragma mark - Align chip 配置（chip 文案设为非空才会显示）

/// 顶部 chip 文案（如 "Align with 14-10"）。nil/空 表示不显示 chip。
@property (nonatomic, copy, nullable) NSString *alignChipText;

/// 对齐时长（如 plan.fastingHours * 3600）。chip 显示时必设；为防退化最小取 60 秒。
@property (nonatomic, assign) NSTimeInterval alignDurationSeconds;

/// 对齐模式，决定 chip 启用条件与 targetDate 算法。
@property (nonatomic, assign) FSTTimeEditorAlignMode alignMode;

/// EndFast / ReferencePlusDuration 模式下的参考时刻；StartFast 模式忽略。
@property (nonatomic, strong, nullable) NSDate *alignReferenceDate;

#pragma mark - 提交回调

/// 保存回调；aligned=YES 表示按对齐分支保存。
@property (nonatomic, copy, nullable) FSTTimeEditorCommitHandler onCommit;

@end

NS_ASSUME_NONNULL_END
