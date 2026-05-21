//
//  FSTAddRecordWeightCardView.h
//  Fasting
//
//  体重卡片：当前体重大字 + 编辑铅笔 + 初始/目标体重小字 + Apple Health 开关。
//  - 触发场景：AddRecord 页 — 用户保存断食记录时调整本次体重。
//  - 写入方：上游 VC 初始化时推入 record 上的 4 个字段；用户编辑后通过回调反向同步回 record 草稿。
//  - 注意：所有 weight 字段单位恒为 kg；FSTWeightInputViewController 内部处理 lb 显示与换算。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTAddRecordWeightCardView : UIView

/// 当次记录体重（kg）。
/// 写入方：VC 初始化推入；用户点铅笔编辑后通过 onEditTapped → FSTWeightInputViewController → onSave 回写。
/// 读取方：本视图的大字标签 + 上游 VC 把它写回 FSTFastingRecord.weightKg。
@property (nonatomic, assign) CGFloat weightKg;

/// 起始体重（kg）。来自 record.initialWeightKg；当前 UI 仅显示，不允许在 AddRecord 页编辑。
@property (nonatomic, assign) CGFloat initialWeightKg;

/// 目标体重（kg）。来自 record.targetWeightKg；显示在卡底，编辑入口在其他设置页（当前未实现）。
@property (nonatomic, assign) CGFloat targetWeightKg;

/// Apple Health 同步开关。
/// 当前 App 未真正接入 HealthKit；这个开关只是把 record.appleHealthEnabled 标记位写盘，未来接入时无需迁移数据。
@property (nonatomic, assign) BOOL appleHealthEnabled;

/// 用户点铅笔回调。
/// 约定调用方 present FSTWeightInputViewController；它 onSave 时回写 self.weightKg 并同步到 record 草稿。
@property (nonatomic, copy, nullable) void (^onEditTapped)(void);

/// Apple Health 开关变化回调。
/// 约定调用方把新值写回 record.appleHealthEnabled。
@property (nonatomic, copy, nullable) void (^onHealthChanged)(BOOL enabled);

@end

NS_ASSUME_NONNULL_END
