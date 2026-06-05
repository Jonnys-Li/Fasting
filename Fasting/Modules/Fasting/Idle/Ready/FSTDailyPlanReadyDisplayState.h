//
//  FSTDailyPlanReadyDisplayState.h
//  Fasting
//
//  Plan 首页「准备开始（ready）」态的派生展示值对象。
//
//  把「session/repository 当前状态 + now」一次性算成 ReadyView 需要的全部字段：标题、
//  圆环呈现态、环进度、主按钮模式、Tips 阶段、紧凑布局开关，以及原始秒数 / 日期（文案由 VC 格式化）。
//  3 个 ready 子态（吃窗口进行 / 预约倒计时 / 可立即开始）收敛为单一 presentationState 轴，
//  其余字段都由它 + 时间算术派生 —— 调用方（FSTFastingIdleViewController）不再持有任何
//  3 路状态判断，refreshReadyState 收缩为「算 → 推 → 执行副作用」。
//
//  本对象保持纯净：不写 session、不做导航。预约到点该自动起始的判定以 shouldAutoStartNow /
//  autoStartDate 暴露，由 VC 执行副作用（startFasting + push Active）。
//

#import <Foundation/Foundation.h>
#import "FSTFastingIdleReadyView.h"      // FSTDailyPlanReadyPrimaryActionMode
#import "FSTFastingIdleReadyRingView.h"  // FSTDailyPlanReadyRingPresentationState
#import "FSTFastingTipsSectionView.h"    // FSTTipsFastingStage

NS_ASSUME_NONNULL_BEGIN

@class FSTSessionManager, FSTRecordsRepository;

@interface FSTDailyPlanReadyDisplayState : NSObject

/// 由 session + repository + now 一次性算出全部 ready 态展示字段。
/// now 注入（而非内部取 [NSDate date]）以便确定性单测。
+ (instancetype)stateForSessionManager:(FSTSessionManager *)sessionManager
                     recordsRepository:(FSTRecordsRepository *)recordsRepository
                                   now:(NSDate *)now;

#pragma mark - 副作用判定（VC 执行，本对象只判不做）

/// 预约的开始时刻已到（scheduled && nextStartDate <= now && plan 存在）。
/// 为 YES 时其余展示字段无意义：VC 应直接 startFasting 并 push 到 Active，不再 push 数据。
@property (nonatomic, assign, readonly) BOOL shouldAutoStartNow;
/// shouldAutoStartNow=YES 时用于起始断食的开始时刻（即 nextFastingStartDate）。
@property (nonatomic, strong, readonly, nullable) NSDate *autoStartDate;

#pragma mark - 展示字段（唯一真态轴 + 其派生）

/// 唯一 3 路状态轴：EatingWindow / ScheduledCountdown / ReadyToStartFasting。
@property (nonatomic, assign, readonly) FSTDailyPlanReadyRingPresentationState presentationState;
/// 紧凑布局开关（≡ presentationState != EatingWindow）。
@property (nonatomic, assign, readonly) BOOL compactLayout;

/// 标题文案（字面量，按 presentationState 分派，非格式化结果）。
@property (nonatomic, copy, readonly) NSString *titleText;
@property (nonatomic, assign, readonly) CGFloat ringProgress;
@property (nonatomic, assign, readonly) FSTDailyPlanReadyPrimaryActionMode primaryActionMode;
@property (nonatomic, assign, readonly) FSTTipsFastingStage tipsStage;

/// 原始秒数 / 日期 —— 由 VC 在 apply 时用 FSTFormatHHMMSS / FSTFormatRelativeDateTime 格式化后下发。
/// 本对象不碰 FSTTheme（及其 Masonry），保持纯 Foundation 可单测。
@property (nonatomic, assign, readonly) NSTimeInterval elapsedSeconds;
@property (nonatomic, assign, readonly) NSTimeInterval remainingSeconds;
@property (nonatomic, assign, readonly) NSTimeInterval timeSinceLastFastSeconds;
@property (nonatomic, strong, readonly) NSDate *nextFastStartDate;
@property (nonatomic, strong, readonly) NSDate *nextFastEndDate;

@end

NS_ASSUME_NONNULL_END
