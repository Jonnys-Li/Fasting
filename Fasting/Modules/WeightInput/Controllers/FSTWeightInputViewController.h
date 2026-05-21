//
//  FSTWeightInputViewController.h
//  Fasting
//
//  体重输入弹窗 — 继承自 FSTBaseModalViewController (CenteredCard)。
//  - 触发：AddRecord 页 FSTAddRecordWeightCardView 点 "+" 按钮弹出；MealDetail 也可能调用。
//  - 视觉：滚轮 picker + kg/lb 单位切换（FSTWeightUnitToggleView）+ Save 按钮。
//  - 行为：picker 内部按 lb 显示时实时换算；保存时回调 onSave 传出归一化的 kg 值，调用方负责写回 record。
//

#import "FSTBaseModalViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTWeightInputViewController : FSTBaseModalViewController

/// 初始体重（kg）。
/// 写入方：上游 VC 在 present 前赋值；nil/0 时弹窗会用一个合理默认值（如 70 kg）开局。
/// 读取方：本 VC 内部把它转成 picker 的初始选中行。
@property (nonatomic, assign) CGFloat weightKg;

/// 保存回调 — 用户点 Save 时触发，参数是归一化的 kg 值（无论 picker 用什么单位显示）。
/// 调用方约定：写回到本地 record 草稿后由 AddRecord/MealDetail VC 整体保存到 sessionManager。
@property (nonatomic, copy, nullable) void (^onSave)(CGFloat newWeightKg);

@end

NS_ASSUME_NONNULL_END
