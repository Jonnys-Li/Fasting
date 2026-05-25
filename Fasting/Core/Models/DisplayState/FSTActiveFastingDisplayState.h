//
//  FSTActiveFastingDisplayState.h
//  Fasting
//
//  Active Fasting 页一次刷新的不可变快照。
//  - 数据来源：[FSTActiveFastingDisplayState currentStateWithDisplayMode:]
//    由 FSTActiveFastingViewController 的 refreshTimer（每秒）+ FSTSessionDidChangeNotification 触发。
//    工厂内部读 [FSTSessionManager sharedManager] 的 active 状态，再交给 FSTFastingTimingService
//    把 elapsedSeconds / targetDurationSeconds 派生成 UI 所需字段。
//  - 数据去向：VC 的 -applyDisplayState: 把字段分发给 5 块子视图：
//    FSTFastingRingPanelView（环+计时器）、FSTFastingTimesRow（Start/End 时间行）、
//    FSTFastingPhaseSummaryCard（autophagy 卡）、FSTFastingTipsSectionView（tips 区）、
//    底部 stopButton。
//  - 设计意图（Step 2 重构产物）：把"算"和"推"拆开 — VC 只负责赋值，状态判定集中在工厂里，便于测试与维护。
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "FSTFastingRingPanelView.h"
#import "FSTFastingTipsSectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTActiveFastingDisplayState : NSObject

/// 当前不存在活跃断食 — 工厂兜底标志。
/// 来源：sessionManager.hasActiveFasting == NO（如 plan 已被外部清除、VC 在通知到达瞬间状态错位）。
/// 读取方：VC 的 -applyDisplayState: 见此 flag 即直接 return，不刷 UI 防崩。
@property (nonatomic, assign) BOOL sessionInvalid;

/// 圆环展示态三选一（active / complete / overtime）。
/// 写入：工厂依据 timing.overtime / timing.targetReached 决定；overtime 优先于 complete（视觉上红色覆盖绿色）。
/// 读取：FSTFastingRingPanelView.presentationState — 切换圆环颜色、中央文本格式、超时副文本可见性。
@property (nonatomic, assign) FSTRingPresentationState ringState;

/// 是否达到或超过目标（ringState 为 Complete 或 Overtime 时 YES）。
/// 这是 ringState 的便利布尔投影：VC 不需重判枚举即可分支 — 切 tipsStage（During/After）、
/// stopButton 配色（灰底黑字 / 绿底白字）、stopButton 标题（END / COMPLETE）。
@property (nonatomic, assign) BOOL targetReached;

/// 圆环上方 caption。
/// active：「Elapsed time XX%」或「Remaining time XX%」（按 displayMode 切）；
/// complete/overtime：固定「Time exceeded」。
/// 读取方：FSTFastingRingPanelView.timerCaption setter。
@property (nonatomic, copy) NSString *timerCaption;

/// 圆环中央大字。值由 ringState 决定三种分支：
///  - active：FSTFormatHHMMSS(elapsedSeconds 或 remainingSeconds)，按 displayMode 切；
///  - complete：固定 "100%"；
///  - overtime：形如 "+HH:MM:SS"，强调已超出目标。
/// 读取方：FSTFastingRingPanelView.timerText setter。
@property (nonatomic, copy) NSString *timerText;

/// overtime 副文本一（"Elapsed time (XXX%)"），非超时为 nil。
/// 读取方：FSTFastingRingPanelView — 超时时显示在主计时器下方，让用户感知超出百分比。
@property (nonatomic, copy, nullable) NSString *overtimeDetailText;

/// overtime 副文本二（已用 HH:MM:SS），非超时为 nil。
/// 读取方：FSTFastingRingPanelView — 紧贴 overtimeDetailText 显示真实总时长。
@property (nonatomic, copy, nullable) NSString *overtimeTotalText;

/// 预期结束时间（友好相对日期，如 "Today 8:30 PM"）。
/// 来源：sessionManager.activeExpectedEndDate ?: startDate + targetSeconds（兜底）。
/// 读取方：FSTFastingRingPanelView.endText（圆环底部 "Ends ..."）。
@property (nonatomic, copy) NSString *endText;

/// 百分比文本（"35%"）。
/// 来源：基于 displayMode 取 timing.elapsedPercent 或 remainingPercent。
/// 读取方：FSTFastingRingPanelView active 态展示在圆环外侧。
@property (nonatomic, copy) NSString *percentText;

/// 当前 plan 名（如 "16-8"）；nil 兜底 "14-10"。
/// 读取方：FSTFastingRingPanelView 的 plan chip — 点击呼出 PlanSelect。
@property (nonatomic, copy) NSString *planName;

/// 圆环填充进度 [0, 1]。
/// targetReached 时强制 1.0（让环视觉满格），否则 = timing.elapsedClampedFraction。
/// 读取方：FSTFastingRingPanelView.progress — 直接驱动 CAShapeLayer 的 strokeEnd。
@property (nonatomic, assign) CGFloat ringProgress;

/// 火焰图标进度 [0, 1] = timing.elapsedClampedFraction（不在 targetReached 时强升）。
/// 读取方：FSTFastingRingPanelView 内火焰位移动画；和 ringProgress 区分是为了让火焰停在真实位置而非环顶。
@property (nonatomic, assign) CGFloat flameProgress;

/// Start time 行的文本（如 "Today 4:30 AM"）。
/// 来源：sessionManager.activeStartDate ?: now。
/// 读取方：FSTFastingTimesRow.startText — 点击该行弹 TimeEditor 编辑 start。
@property (nonatomic, copy) NSString *startText;

/// End time 行的文本。与 endText 内容相同但分开持有（解耦未来视图层的格式差异可能性）。
/// 读取方：FSTFastingTimesRow.endText — 点击可编辑 end。
@property (nonatomic, copy) NSString *endTimeText;

/// 是否展示 Autophagy 阶段卡（达标后才显示）。
/// 读取方：VC 控制 FSTFastingPhaseSummaryCard 的 hidden / 数据填充。
@property (nonatomic, assign) BOOL showAutophagyPhase;

/// Tips 区阶段（During / After）— 未达标 = During，达标 = After。Prepare 在本场景不会出现。
/// 读取方：[FSTFastingTipsSectionView configureForStage:] — 切换图标/文案/卡片背景色。
@property (nonatomic, assign) FSTTipsFastingStage tipsStage;

/// 底部按钮标题。未达标 "END FASTING"，达标 "COMPLETE FASTING"。
/// 用户视角：未达标 = 放弃，达标 = 完成 — 视觉差异（灰 vs 绿）也由此分叉。
@property (nonatomic, copy) NSString *stopButtonTitle;

/// 底部按钮背景色：灰色（#E3E5EA）vs 绿色（fst_eatingTimeGreen），随 targetReached 切换。
@property (nonatomic, strong) UIColor *stopButtonBackgroundColor;

/// 底部按钮文字色：深灰（#272A33）vs 白色，与背景色配对切换。
@property (nonatomic, strong) UIColor *stopButtonTitleColor;

/// Phase 阶段 dialog（点击 phaseCard 弹出）的三段文案/图标，由 targetReached 派生：
///  - 未达标：title "Blood Glucose Rise" / message "Blood sugar fluctuation is normal ..."  / icon "blood_glucose_stage"
///  - 已达标：title "Autophagy Starts!"   / message "Fasting goal reached. Your body ..." / icon "autophagy_stage"
/// 读取方：VC 的 -showPhaseDialog 直接读这三个字段构造 dialog，不再在 VC 里 if/else。
@property (nonatomic, copy) NSString *phaseDialogTitle;
@property (nonatomic, copy) NSString *phaseDialogMessage;
@property (nonatomic, copy) NSString *phaseDialogIconName;

/// 工厂方法：基于 [FSTSessionManager sharedManager] 当前 active 状态计算完整 DisplayState。
/// @param displayMode 圆环中央显示模式（Elapsed / Remaining）。由 VC 的 _ringDisplayMode ivar 推入，
///                    用户点击圆环中心按钮翻转。仅影响 timerCaption / timerText / percentText 的格式分支。
/// @return 不可变快照。无 active 断食则返回 sessionInvalid=YES 的兜底实例。
+ (instancetype)currentStateWithDisplayMode:(FSTRingDisplayMode)displayMode;

@end

NS_ASSUME_NONNULL_END
