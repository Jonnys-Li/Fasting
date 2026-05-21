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
//  使用场景：Active Fasting 页编辑 Start/Ends、MealDetail 页编辑 Meal time、AddRecord 页编辑结束时刻。
//

#import "FSTBaseModalViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// 用户点保存时触发。aligned=YES 表示当前是 align chip 激活态的提交（按 plan 对齐分支）。
/// 调用方据此调 sessionManager 的 editActiveStartDate:alignWithPlan: 走对应分支。
typedef void (^FSTTimeEditorCommitHandler)(NSDate *pickedDate, BOOL aligned);

@interface FSTTimeEditorSheetViewController : FSTBaseModalViewController

/// 唯一指定初始化方法（标记为 NS_DESIGNATED_INITIALIZER）。
/// 参数语义见 UIViewController+FSTTimeEditor.h 中 `fst_presentTimeEditorWithTitle:` 全功能版的同名说明。
- (instancetype)initWithTitle:(NSString *)title
                  initialDate:(NSDate *)initialDate
                  minimumDate:(nullable NSDate *)minimumDate
                  maximumDate:(nullable NSDate *)maximumDate
                alignChipText:(nullable NSString *)alignChipText
                  alignedDate:(nullable NSDate *)alignedDate
              initiallyAligned:(BOOL)initiallyAligned
                      onCommit:(FSTTimeEditorCommitHandler)onCommit NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
