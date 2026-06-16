//
//  FSTSessionManager.h
//  Fasting
//
//  会话状态单例 —— plan / active session / scheduled / preference / 一次性 token。
//
//  Session 字段族：
//    - 计划：currentPlan + hasCompletedOnboarding
//    - 进行中断食：activeStartDate + activeEndOverrideDate
//    - 吃窗口：eatingWindowAnchorDate（仅零记录冷启动兜底，见 FSTNextFastService）
//    - 预约：scheduledReadySource + scheduledReadyAnchorDate
//    - 一次性 token：pendingActiveStartDatePrompt
//
//  历史记录（records / mealRecords）已搬到 [FSTRecordsRepository sharedRepository]，调用方直接用 repository。
//  finishFastingWithRecord: 是跨域的：先写 record（转发到 repository）再清 active 状态，由本类编排。
//
//  写入约定：任何 mutation 都走 -persistAllState（统一持久化）；
//  唯一例外 preferredWeightUnit —— 自身 setter 直写 defaults，不在 saveAllForSession 范围内。
//
//  通知：records / mealRecords 增删通过 FSTRecordsDidChangeNotification（见 FSTRecordsRepository.h）；
//  session 字段变更目前不发通知，VC 通过 refreshTimer + viewWillAppear + UIApplicationWillEnterForegroundNotification 自驱动。
//

#import <Foundation/Foundation.h>
#import "FSTSessionState.h"   // 会话状态模型 + FSTScheduledReadySource 枚举（R14）
#import "FSTPlan.h"
#import "FSTFastingRecord.h"
#import "FSTWeightUnit.h"

NS_ASSUME_NONNULL_BEGIN

// FSTScheduledReadySource 枚举已随会话字段一起迁入 FSTSessionState.h（R14）。

@interface FSTSessionManager : NSObject

+ (instancetype)sharedManager;

// 以下会话字段的存储已收敛到 FSTSessionState（R14）：这里只保留对外只读访问，内部转发到 state。
// 计划
@property (nonatomic, strong, readonly, nullable) FSTPlan *currentPlan;
@property (nonatomic, assign, readonly) BOOL hasCompletedOnboarding;

// 进行中的断食
@property (nonatomic, strong, readonly, nullable) NSDate *activeStartDate;
@property (nonatomic, strong, readonly, nullable) NSDate *activeEndOverrideDate;
- (BOOL)hasActiveFasting;
- (NSTimeInterval)targetDurationSeconds;     // currentPlan.fastingHours * 3600，0 表示无
- (NSTimeInterval)activeTargetDurationSeconds; // 进行中断食的真实目标时长；自定义 end 时可不同于 plan
- (NSTimeInterval)elapsedSeconds;            // 从 activeStartDate 到 now
- (CGFloat)elapsedFraction;                  // [0,+∞)，>=1 表示已完成
- (NSDate * _Nullable)activeExpectedEndDate;

- (void)startFastingWithPlan:(FSTPlan *)plan startDate:(NSDate *)date;
- (void)cancelActiveFasting;
- (void)finishFastingWithRecord:(FSTFastingRecord *)record;
- (void)clearCurrentPlan;
/// 切换当前计划，保留 activeStartDate / nextFastingStartDate override / 历史记录，并清除自定义 active end。
/// 用于"软切换计划"——比如 Eating Time 圆环内 chip 进入选择界面后改方案。
- (void)switchToPlanPreservingState:(FSTPlan *)plan;

/// 下一次进入活跃断食页时弹出开始时间确认框；读取后自动清除。
- (void)requestActiveStartDatePrompt;
- (BOOL)consumeActiveStartDatePromptRequest;

/// 当前 Plan ready 是否处于「断食尚未开始」的预约倒计时态。
/// source 决定中止后的落点；anchorDate 用于计算倒计时进度百分比。
@property (nonatomic, assign, readonly) FSTScheduledReadySource scheduledReadySource;
@property (nonatomic, strong, readonly, nullable) NSDate *scheduledReadyAnchorDate;
- (void)markScheduledReadyWithSource:(FSTScheduledReadySource)source anchorDate:(NSDate * _Nullable)anchorDate;
- (void)clearScheduledReadyState;

/// 原子化"切到 scheduled-ready 态"：cancelActiveFasting + setNextFastingStartDate +
/// markScheduledReadyWithSource 三步合一。调用方：在 active 中编辑 startDate 到未来、或
/// 在首次开始断食时选择"未来某时开始"。futureDate 为 nil 时不生效。
- (void)scheduleFastingAtFutureDate:(NSDate *)futureDate source:(FSTScheduledReadySource)source;

// 体重单位偏好
@property (nonatomic, assign) FSTWeightUnit preferredWeightUnit;

// 准备态推导
- (NSDate * _Nullable)nextFastingStartDate;
/// 手动覆盖 nextFastingStartDate 时记录的设置时刻，用于 Eating / Prepare 圆环按本轮倒计时计算进度。
- (NSDate * _Nullable)nextFastingStartCountdownAnchorDate;
/// 覆盖下一次断食开始时间。传 nil 清除覆盖，让 nextFastingStartDate 回到默认推导。
- (void)setNextFastingStartDate:(NSDate * _Nullable)date;

/// 编辑进行中断食的开始时刻。alignWithPlan=YES 时按当前计划重新对齐 end。
/// 无活跃断食时不生效。用于活跃断食页的 Start/Ends 铅笔编辑。
- (void)editActiveStartDate:(NSDate *)date alignWithPlan:(BOOL)alignWithPlan;
- (void)editActiveEndDate:(NSDate *)date alignWithPlan:(BOOL)alignWithPlan;

@end

NS_ASSUME_NONNULL_END
