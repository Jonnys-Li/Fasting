//
//  FSTSessionState.h
//  Fasting
//
//  会话状态的纯数据模型（R14）。
//  把原先平铺在 FSTSessionManager 上的会话字段收敛到一处：字段定义集中、易找、易持久化、易单测。
//  FSTSessionManager 持有一个实例并把公开 getter/setter 转发给它；本模型不含任何业务逻辑，
//  也不反向 import 任何 Service（层级：Core/Models 不依赖 Core/Services）。
//
//  字段族：
//    - 计划：currentPlan + hasCompletedOnboarding
//    - 进行中断食：activeStartDate + activeEndOverrideDate
//    - 吃窗口：eatingWindowAnchorDate（零记录冷启动兜底，见 FSTNextFastService）
//    - 预约：scheduledReadySource + scheduledReadyAnchorDate
//    - 偏好：preferredWeightUnit
//    - 一次性 token（transient，不持久化）：pendingActiveStartDatePrompt
//
//  持久化映射（NSUserDefaults key 与读写时机）集中在 FSTSessionPersistenceService。
//

#import <Foundation/Foundation.h>
#import "FSTPlan.h"
#import "FSTWeightUnit.h"

NS_ASSUME_NONNULL_BEGIN

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

@interface FSTSessionState : NSObject

// 计划
@property (nonatomic, strong, nullable) FSTPlan *currentPlan;
@property (nonatomic, assign) BOOL hasCompletedOnboarding;

// 进行中的断食
@property (nonatomic, strong, nullable) NSDate *activeStartDate;
@property (nonatomic, strong, nullable) NSDate *activeEndOverrideDate;

// 吃窗口锚点（零记录冷启动兜底）
@property (nonatomic, strong, nullable) NSDate *eatingWindowAnchorDate;

// 预约准备态
@property (nonatomic, assign) FSTScheduledReadySource scheduledReadySource;
@property (nonatomic, strong, nullable) NSDate *scheduledReadyAnchorDate;

// 偏好
@property (nonatomic, assign) FSTWeightUnit preferredWeightUnit;

// 一次性 token（transient：不持久化，读取后清除）
@property (nonatomic, assign) BOOL pendingActiveStartDatePrompt;

@end

NS_ASSUME_NONNULL_END
