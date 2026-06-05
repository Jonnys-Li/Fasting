//
//  FSTFastingRecordCardView.h
//  Fasting
//
//  断食记录卡片 — Timeline 主页顶卡 + FastingHistory 列表共用的单元。
//  - 触发场景：Timeline VC 顶卡（最近一次断食）+ FastingHistory 列表（每一行）。
//  - 角色：UIControl 子类，整张卡可点击触发详情查看；右上角 "more" 三点用于二级操作（编辑/删除）。
//  - 数据流：用 -configureWithRecord: 一次性推入 record；本视图把 record 字段拆解为多个 *Text 属性渲染。
//

#import <UIKit/UIKit.h>
#import "FSTFastingRecord.h"

NS_ASSUME_NONNULL_BEGIN

/// 历史断食卡片上的难度评分（影响右上角 emoji 与配色）。
/// 写入方：[FSTFastingRecordCardView configureWithRecord:] 直接把 FSTFastingRecord.feelingLevel
///         cast 为本枚举（两者数值含义一致，无需翻转）。
/// 读取方：本视图内部 — 用 emoji（😣/😐/😊）与配色映射给用户视觉反馈。
///
/// 数值含义与 FSTFastingRecord.feelingLevel **完全对齐**：0=Hard, 1=Ok, 2=Easy。
/// AddRecord 页 FSTAddRecordFeelingCardView 的 emoji 按钮顺序也是 [有点难, 还可以, 简单]（tag=0/1/2），
/// 整个 App 同一套数值约定，避免认知陷阱。
typedef NS_ENUM(NSInteger, FSTFastingRating) {
    FSTFastingRatingHard = 0,  ///< 有点难 — 显示 😣 + 暖色调（橙/红）。
    FSTFastingRatingOk,        ///< 还可以 — 显示 😐 + 中性色调。
    FSTFastingRatingEasy,      ///< 简单 — 显示 😊 + 绿色调。
};

@interface FSTFastingRecordCardView : UIControl

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
/// 数值含义与 record.feelingLevel 完全对齐 — configureWithRecord 直接 cast 赋值，无翻转。
@property (nonatomic, assign) FSTFastingRating rating;

/// 卡片右上角 "..." 三点被点击。约定调用方弹 ActionSheet 提供"编辑 / 删除 / 分享"等二级操作。
@property (nonatomic, copy, nullable) dispatch_block_t onMoreTapped;

/// 用一条 record 配置所有展示字段。
/// 内部做的事：拆 durationSeconds → hoursText/minutesText；格式化时间 → start/endTimeText；
/// cast feelingLevel → rating（两者数值含义一致，无翻转）；写入 titleText = record.planName。
/// 传 nil 时本视图会被清空（用于占位）。
- (void)configureWithRecord:(nullable FSTFastingRecord *)record;

@end

NS_ASSUME_NONNULL_END
