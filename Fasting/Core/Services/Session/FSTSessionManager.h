//
//  FSTSessionManager.h
//  Fasting
//
//  全 App 单例状态管理器 — 唯一的 NSUserDefaults 读写入口。
//
//  Session 概念：包含以下字段族
//    - 计划：currentPlan + hasCompletedOnboarding
//    - 进行中断食：activeStartDate + activeEndOverrideDate
//    - 吃窗口：eatingWindowAnchorDate
//    - 预约：scheduledReadySource + scheduledReadyAnchorDate
//    - 一次性 token：pendingActiveStartDatePrompt
//    - 历史：records + mealRecords
//
//  写入约定：任何 mutation 都走 -persistAllStateAndNotifySession（统一持久化 + 通知），
//  这样不会漏调 saveXxxToDefaults，也不会漏发通知。例外：records / mealRecords 写入用 -saveRecordsToDefaults
//  + FSTRecordsDidChangeNotification，避免列表型订阅者被无关 session 变化打扰。
//
//  两个通知名的分工：
//    - FSTSessionDidChangeNotification — 任何 session 字段改变；订阅方：DailyPlan/ActiveFasting VC。
//    - FSTRecordsDidChangeNotification — 仅 records / mealRecords 增删；订阅方：FastingHistory/MealDiary/Timeline。
//

#import <Foundation/Foundation.h>
#import "FSTPlan.h"
#import "FSTFastingRecord.h"
#import "FSTWeightUnit.h"

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const FSTSessionDidChangeNotification;
extern NSNotificationName const FSTRecordsDidChangeNotification;

/// 预约准备态来源标记 — 表示 Plan 页"已选未开始"但用户显式 Schedule 了一个未来开始时间。
/// 写入方：[FSTSessionManager markScheduledReadyWithSource:anchorDate:]
/// 读取方：
///   - FSTDailyPlanReadyDisplayState 的工厂方法 — 决定 ringPresentationState 走 ScheduledCountdown 还是 EatingWindow；
///   - 中止预约（abort）后回退逻辑 — source 决定 abort 后回到吃窗口普通态还是 ActiveFasting 页。
typedef NS_ENUM(NSInteger, FSTScheduledReadySource) {
    /// 非预约态（默认）。Plan 页按当前 plan 渲染普通 Eating Time。
    FSTScheduledReadySourceNone = 0,
    /// 断食前编辑 nextFastingStartDate 到未来触发。abort 时回退到 Eating 普通态。
    FSTScheduledReadySourcePreStart,
    /// 进行中改 Start 到未来触发（active session 被截断为已结束并转预约）。
    /// abort 时也回到 Eating 普通态而非 ActiveFasting，因为原 session 已不存在。
    FSTScheduledReadySourceFromActiveSession,
};

@interface FSTSessionManager : NSObject

+ (instancetype)sharedManager;

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
- (BOOL)isActiveFastingAlignedWithPlan;

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
- (void)beginEatingWindowFromDate:(NSDate * _Nullable)date;

// 历史记录
- (NSArray<FSTFastingRecord *> *)allRecords;  // 倒序
- (void)updateFastingRecord:(FSTFastingRecord *)record;
- (void)deleteFastingRecord:(FSTFastingRecord *)record;

// 饮食记录
- (NSArray<FSTMealRecord *> *)allMealRecords; // 倒序
- (void)addOrUpdateMealRecord:(FSTMealRecord *)record;
- (void)deleteMealRecord:(FSTMealRecord *)record;

// 体重单位偏好
@property (nonatomic, assign) FSTWeightUnit preferredWeightUnit;

// 准备态推导
- (NSDate * _Nullable)latestFastingEndDate;
- (NSDate * _Nullable)latestMealDate;
- (NSDate * _Nullable)nextFastingStartDate;
/// 覆盖下一次断食开始时间。传 nil 清除覆盖，让 nextFastingStartDate 回到默认推导。
- (void)setNextFastingStartDate:(NSDate * _Nullable)date;

/// 编辑进行中断食的开始时刻。默认按当前计划重新对齐 end。持久化并发通知。
/// 无活跃断食时不生效。用于活跃断食页的 Start/Ends 铅笔编辑。
- (void)editActiveStartDate:(NSDate *)date;
- (void)editActiveStartDate:(NSDate *)date alignWithPlan:(BOOL)alignWithPlan;
- (void)editActiveEndDate:(NSDate *)date alignWithPlan:(BOOL)alignWithPlan;

@end

NS_ASSUME_NONNULL_END
