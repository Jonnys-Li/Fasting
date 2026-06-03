//
//  FSTRingProgressView.h
//  Fasting
//
//  圆环基类：以「底部开口弧」为唯一几何形态。
//  默认弧度 ≈240°（起点右下 4-5 点钟，终点左下 7-8 点钟，沿顶部 CCW 绘制），
//  底部留 ≈120° 缺口供承载下方文本/控件。
//  支持可选的「头部箭头」指示器，随 progress 沿弧滑行。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 圆环填充风格。`progress` 一律表示「已消耗比例 [0,1]」；箭头都位于 progress 对应的弧上位置，
/// 区别仅在 bar 相对箭头的方向：
///   - Forward       bar 在箭头**后面**（左侧），表示已完成部分
///   - Receding      bar 在箭头**前面**（右侧），表示待消耗部分；箭头如同"吃"着 bar 前进
/// 消费方：
///   - Forward     用于 Active Fasting 圆环（FSTFastingRingPanelView 内部环）— 表达"我已经断了多久"的累积感；
///   - Receding   用于 Eating Time 圆环（FSTFastingIdleReadyRingView）— 表达"还剩多久吃窗口耗尽"的递减感。
typedef NS_ENUM(NSInteger, FSTRingFillStyle) {
    /// 默认：strokeStart=0, strokeEnd=progress；箭头随 progress（=strokeEnd）沿弧前进，bar 在身后。
    FSTRingFillStyleForward = 0,
    /// 倒计时：strokeStart=progress, strokeEnd=1.0；箭头随 progress（=strokeStart）沿弧前进，bar 在前方。
    FSTRingFillStyleRecedingFromStart,
};

/// 圆环 6 种视觉态——把"状态 → 外观旋钮"的翻译表集中到 `fst_applyStyle:` 里。
/// 覆盖外观：progressColor / endTailColor / endTailFraction / showsEndTail / arrowHeadTintColor。
/// **不覆盖**行为属性：progress（业务数据驱动）/ fillStyle（panel 状态或用户操作驱动）/ arrowHeadImage（panel 在 setupSubviews 设一次）。
/// 写入方：FSTFastingRingPanelView.applyPresentationState、FSTFastingIdleReadyRingView.refreshDisplay
/// 读取方：FSTRingProgressView 内部 switch（见 .m 实现）
typedef NS_ENUM(NSInteger, FSTRingStyle) {
    FSTRingStyleActiveFasting,        ///< Active 页·进行中。绿环 + 白箭头 + 无 endTail。
    FSTRingStyleCompleteFasting,      ///< Active 页·已达标。ring 视觉与 Active 同；差异在 panel 层 completion icon / 大字。
    FSTRingStyleOvertimeFasting,      ///< Active 页·超时。绿环 + 白箭头 + endTail 末端渐变。
    FSTRingStyleEatingWindow,         ///< Plan-Ready·进食窗口。奶油环 + 琥珀箭头。
    FSTRingStyleScheduledCountdown,   ///< Plan-Ready·已 schedule 倒计时。奶油环 + 琥珀箭头。
    FSTRingStyleReadyToStartFasting,  ///< Plan-Ready·可立即开始。橙环 + 白箭头。
};

@interface FSTRingProgressView : UIView

@property (nonatomic, assign) CGFloat progress;       // 0~1，超过 1 内部裁剪
@property (nonatomic, strong) UIColor *trackColor;    // 底色
@property (nonatomic, strong) UIColor *progressColor; // 进度色
@property (nonatomic, assign) CGFloat lineWidth;      // 线宽，默认 22
@property (nonatomic, assign) BOOL showsEndTail;       // 是否在进度末端显示渐变尾段
@property (nonatomic, strong) UIColor *endTailColor;   // 渐变尾段终点色，默认 #FEECAC
@property (nonatomic, assign) CGFloat endTailFraction; // 渐变尾段占弧线比例，默认 0.10

/// 弧的起始角（弧度，UIKit 屏幕坐标，0 = 3 点钟）。默认 3π/4 = 135°（左下 7-8 点钟）。
/// 起点同时也是 progress=0 时的「头部」初始位置。
@property (nonatomic, assign) CGFloat arcStartAngle;
/// 弧的结束角（弧度）。默认 π/4 = 45°（右下 4-5 点钟）。
/// 路径方向固定为 CW（clockwise=YES，视觉顺时针），从左下经顶部到右下；
/// 左右两端 y 高度对称（都在 R·sin(45°) 深度）。
@property (nonatomic, assign) CGFloat arcEndAngle;

/// 可选的进度头部图标（例如小箭头）。设置后会在 progress 的领头位置绘制，
/// 沿切线方向旋转。图片原朝向应为「向上」(top of image = 箭头尖)。
@property (nonatomic, strong, nullable) UIImage *arrowHeadImage;

/// 箭头的 tint 色。设置为非 nil 时使用此颜色；否则跟随 progressColor。
@property (nonatomic, strong, nullable) UIColor *arrowHeadTintColor;

/// 圆环填充风格，控制 strokeStart/strokeEnd 与箭头位置。默认 `FSTRingFillStyleForward`。
@property (nonatomic, assign) FSTRingFillStyle fillStyle;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

/// 弧上 progress=p（0~1）对应的角度（UIKit 屏幕坐标弧度）。供外部贴标记到弧上某固定百分比位置。
- (CGFloat)angleAtProgress:(CGFloat)p;

@end

@interface FSTRingProgressView (Style)
/// 一键应用一组外观属性。幂等。不动 progress / fillStyle / arrowHeadImage。
- (void)fst_applyStyle:(FSTRingStyle)style;
@end

NS_ASSUME_NONNULL_END
