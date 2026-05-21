//
//  FSTFastingTimelineCardView.h
//  Fasting
//
//  历史断食记录卡片 — Timeline / FastingHistory 列表里的单元。
//  - 触发场景：Timeline VC 顶卡（最近一次断食）+ FastingHistory 列表（每一行）。
//  - 角色：UIControl 子类，整张卡可点击触发详情查看；右上角 "more" 三点用于二级操作（编辑/删除）。
//  - 数据流：用 -configureWithRecord: 一次性推入 record；本视图把 record 字段拆解为多个 *Text 属性渲染。
//

#import <UIKit/UIKit.h>
#import "FSTFastingRecord.h"

NS_ASSUME_NONNULL_BEGIN

/// 历史断食卡片上的难度评分（影响右上角 emoji 与配色）。
/// 写入方：[FSTFastingTimelineCardView configureWithRecord:] 把 FSTFastingRecord.feelingLevel **翻转**为本枚举（详见下方陷阱）。
/// 读取方：本视图内部 — 用 emoji（😊/😐/😣）与配色映射给用户视觉反馈。
///
/// ⚠️ 重要陷阱（潜在 bug，待用户决策）：
/// 本枚举与 FSTFastingRecord.feelingLevel 的数值含义**顺序相反**：
///   - FSTFastingRating:        0=Easy（简单）, 1=Ok, 2=Hard（有点难）
///   - FSTFastingRecord.feelingLevel: 0=有点难, 1=还可以, 2=简单
/// 当前 configureWithRecord: 应做 2 - feelingLevel 转换；若以后需要统一，须同步迁移历史数据。
typedef NS_ENUM(NSInteger, FSTFastingRating) {
    FSTFastingRatingEasy = 0,  ///< 简单 — 历史卡显示 😊 + 绿色调。
    FSTFastingRatingOk,        ///< 还可以 — 显示 😐 + 中性色调。
    FSTFastingRatingHard,      ///< 有点难 — 显示 😣 + 暖色调（橙/红）。
};

@interface FSTFastingTimelineCardView : UIControl

/// 卡顶标题（plan name，如 "16-8 Fast"）。来自 record.planName。
@property (nonatomic, copy, nullable) NSString *titleText;

/// 时长大字的"小时"部分（如 "16"）。
/// 由 configureWithRecord 用 record.durationSeconds 拆分为 "HH" + "MM" 两部分渲染（避免大字体里出现冒号）。
@property (nonatomic, copy, nullable) NSString *hoursText;

/// 时长大字的"分钟"部分（如 "23"）。
@property (nonatomic, copy, nullable) NSString *minutesText;

/// 开始时间友好字符串。来自 record.startDate 经 FSTFormatRecordDateLine 格式化。
@property (nonatomic, copy, nullable) NSString *startTimeText;

/// 结束时间友好字符串。来自 record.endDate。
@property (nonatomic, copy, nullable) NSString *endTimeText;

/// 难度评分（影响右上角 emoji 与配色）。
/// ⚠️ 与 record.feelingLevel 顺序相反（详见上方枚举陷阱注释）；configureWithRecord 内部已做翻转。
@property (nonatomic, assign) FSTFastingRating rating;

/// 卡片右上角 "..." 三点被点击。约定调用方弹 ActionSheet 提供"编辑 / 删除 / 分享"等二级操作。
@property (nonatomic, copy, nullable) dispatch_block_t onMoreTapped;

/// 用一条 record 配置所有展示字段。
/// 内部做的事：拆 durationSeconds → hoursText/minutesText；格式化时间 → start/endTimeText；
/// 翻转 feelingLevel → rating（注意陷阱）；写入 titleText = record.planName。
/// 传 nil 时本视图会被清空（用于占位）。
- (void)configureWithRecord:(nullable FSTFastingRecord *)record;

@end

NS_ASSUME_NONNULL_END
