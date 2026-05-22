//
//  FSTFastingRingPanelView.h
//  Fasting
//
//  Active Fasting 页核心面板：圆环 + 中心切换按钮 + 计时器 + plan chip。
//  - 角色：纯展示视图（无状态计算）。所有字段由 FSTActiveFastingViewController 的 -applyDisplayState:
//    用 FSTActiveFastingDisplayState 一次性推入。
//  - 视觉结构：底部开口弧（圆环主体）+ 中央时间/百分比 + 顶部 caption + 底部 plan chip + 火焰图标沿弧滑动。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 圆环中央计时器的显示模式。
/// 写入方：FSTActiveFastingViewController 持有 _ringDisplayMode ivar，用户点击圆环中心按钮翻转；
///         VC 把当前模式传入 [FSTActiveFastingDisplayState currentStateWithDisplayMode:]。
/// 读取方：FSTActiveFastingDisplayState 工厂 — 决定 timerText / timerCaption / percentText 显示 elapsed 还是 remaining。
typedef NS_ENUM(NSInteger, FSTRingDisplayMode) {
    FSTRingDisplayElapsed,    ///< 显示"已用时长 + 已用百分比"。
    FSTRingDisplayRemaining,  ///< 显示"剩余时长 + 剩余百分比"，倒计时心理感受。
};

/// 圆环的视觉表现态。
/// 写入方：FSTActiveFastingDisplayState 工厂依据 timing.overtime / targetReached 推导（overtime 优先于 complete）。
/// 读取方：FSTFastingRingPanelView 内部 — 切换环色（蓝/绿/红）、中央文本格式、超时副文本可见性。
typedef NS_ENUM(NSInteger, FSTRingPresentationState) {
    FSTRingPresentationActive,    ///< 进行中（未达标）。蓝色环 + HH:MM:SS 计时。
    FSTRingPresentationComplete,  ///< 已达标但未超时。绿色环 + "100%"。
    FSTRingPresentationOvertime,  ///< 已超时。红色覆盖 + "+HH:MM:SS"。优先级高于 Complete，因为超时更需要被强调。
};

@interface FSTFastingRingPanelView : UIView

/// 圆环上方小字 caption。
/// 由 DisplayState.timerCaption 推入；active 态形如 "Elapsed time 35%"，complete/overtime 固定 "Time exceeded"。
@property (nonatomic, copy, nullable) NSString *timerCaption;

/// 圆环中央大字（HH:MM:SS / "100%" / "+HH:MM:SS"）。
/// 由 DisplayState.timerText 推入；三种格式按 presentationState 切换。
@property (nonatomic, copy, nullable) NSString *timerText;

/// 超时态副文本一（"Elapsed time (XXX%)"）。非超时为 nil 时本视图自动隐藏。
@property (nonatomic, copy, nullable) NSString *overtimeDetailText;

/// 超时态副文本二（已用 HH:MM:SS）。非超时为 nil 时本视图自动隐藏。
@property (nonatomic, copy, nullable) NSString *overtimeTotalText;

/// 底部 "Ends ..." 友好相对时间（"Today 8:30 PM"）。
@property (nonatomic, copy, nullable) NSString *endText;

/// 进度百分比文本（"35%"）— active 态显示在圆环外侧。
@property (nonatomic, copy, nullable) NSString *percentText;

/// plan chip 的标题（如 "16-8"）。
@property (nonatomic, copy, nullable) NSString *planName;

/// 圆环填充进度 [0, 1]。直接驱动 CAShapeLayer.strokeEnd。
@property (nonatomic, assign) CGFloat progress;

/// 火焰图标进度 [0, 1] — 控制火焰沿弧滑动到的位置。
/// 与 progress 分开是为了让 targetReached 时 progress 强制 1.0 但火焰仍停在真实进度处。
@property (nonatomic, assign) CGFloat flameProgress;

/// 显示模式（Elapsed / Remaining）。本视图据此切换中心切换按钮的图标朝向。
@property (nonatomic, assign) FSTRingDisplayMode displayMode;

/// 圆环展示态。本视图据此切换：环色、中央文字大小/字重、超时副文本可见性。
@property (nonatomic, assign) FSTRingPresentationState presentationState;

/// 中心切换按钮被点击。
/// 触发：用户点 Elapsed/Remaining 切换图标；约定调用方翻转自己的 _ringDisplayMode ivar 并重算一次 DisplayState。
@property (nonatomic, copy, nullable) dispatch_block_t onModeTapped;

/// 计划胶囊被点击（用于打开计划选择器）。
/// 约定调用方 push FSTPlanSelectViewController；选完后通过 sessionManager.switchToPlanPreservingState 切 plan。
@property (nonatomic, copy, nullable) dispatch_block_t onPlanChipTapped;

/// 生成用于分享的圆环截图（隐藏 modeButton，不含交互控件）。
- (UIImage *)snapshotForSharing;

/// 外暴露给上层做约束锚定的子视图引用（如外部需要把其他控件贴到 ring 中心或 caption 下方）。
@property (nonatomic, strong, readonly) UIView *ringView;
@property (nonatomic, strong, readonly) UILabel *timerCaptionLabel;

@end

NS_ASSUME_NONNULL_END
