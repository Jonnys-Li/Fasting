//
//  FSTDailyPlanReadyRingView.h
//  Fasting
//
//  Eating Time（准备开始断食）状态的圆环视图：
//  浅灰开口弧 track + 奶油 progress（随用餐时长推进）+ 头部琥珀小箭头。
//  内部顶部有切换按钮，中央显示 "Elapsed time X%" + HH:MM:SS，
//  底部嵌入计划胶囊（FSTPlanChipPillView），点击触发 onChangePlanTapped。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Plan 页"已选未开始"圆环的三种展示态。
/// 写入方：FSTDailyPlanReadyDisplayState 工厂三态判定（见其 .m 内的优先级注释）。
/// 读取方：FSTDailyPlanReadyRingView 内部 — 切换填充策略（Forward vs ReceedingFromStart）、配色、中心文本布局。
typedef NS_ENUM(NSInteger, FSTDailyPlanReadyRingPresentationState) {
    /// 吃窗口进行中（默认）。圆环按"已吃/总吃窗"比例填充奶油色，中央显示 elapsed 时间。
    FSTDailyPlanReadyRingPresentationEatingWindow = 0,
    /// 已显式 Schedule 一个未来 startDate。圆环按"已等/总等"比例填充，中央显示倒计时；progress 由 anchorDate→startDate 线性比例。
    FSTDailyPlanReadyRingPresentationScheduledCountdown,
    /// 吃窗口已耗尽，可立即开始断食。圆环视觉满格，中央显示 timeSinceLastFastText。
    FSTDailyPlanReadyRingPresentationReadyToStartFasting,
};

@interface FSTDailyPlanReadyRingView : UIView

@property (nonatomic, assign) FSTDailyPlanReadyRingPresentationState presentationState;

/// elapsed 模式下显示的 HH:MM:SS。
@property (nonatomic, copy, nullable) NSString *elapsedText;
/// remaining 模式下显示的倒计时 HH:MM:SS。
@property (nonatomic, copy, nullable) NSString *remainingText;
/// Ready-to-start 状态下显示的 "Time since last fast" 计时。
@property (nonatomic, copy, nullable) NSString *timeSinceLastFastText;

/// 0~1，当前窗口已经过去的比例。Eating 与 scheduled countdown 都把 progress 当作 elapsed fraction。
@property (nonatomic, assign) CGFloat progress;

/// 内嵌的计划胶囊显示名（如 "14-10"、"20-4"）。
@property (nonatomic, copy, nullable) NSString *planName;

/// 计划胶囊被点击。
@property (nonatomic, copy, nullable) dispatch_block_t onChangePlanTapped;

@end

NS_ASSUME_NONNULL_END
