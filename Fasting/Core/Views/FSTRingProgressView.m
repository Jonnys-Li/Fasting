//
//  FSTRingProgressView.m
//  Fasting
//
//  开口弧基类：trackLayer 画底色弧（白/浅灰），progressLayer 画进度弧（strokeEnd 控制 0~1）。
//  可选 arrowHead UIImageView 跟随进度的领头位置滑动并旋转（切线方向）。
//

#import "FSTRingProgressView.h"
#import "UIColor+FST.h"

@interface FSTRingProgressView ()
@property (nonatomic, strong) CAShapeLayer *trackLayer;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) CAGradientLayer *endTailGradientLayer;
@property (nonatomic, strong) CAShapeLayer *endTailMaskLayer;
@property (nonatomic, strong) UIImageView *arrowHeadView;
/// 记录箭头上一次落点对应的弧上角度（用于绕弧动画的起点）；NAN 表示尚未初始化。
@property (nonatomic, assign) CGFloat lastArrowAngle;
@end

@implementation FSTRingProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _lineWidth = 22;
        _trackColor = [UIColor fst_ringTrack];
        _progressColor = [UIColor fst_primaryGreen];
        _endTailColor = [UIColor fst_progressCream];
        _endTailFraction = 0.10;
        _arcStartAngle = (CGFloat)(M_PI * 3.0 / 4.0);  // 135° 左下（progress=0 起点）
        _arcEndAngle   = (CGFloat)(M_PI / 4.0);        // 45°  右下（progress=1 终点）
        _fillStyle = FSTRingFillStyleForward;
        _lastArrowAngle = (CGFloat)NAN;

        _trackLayer = [CAShapeLayer layer];
        _trackLayer.fillColor = [UIColor clearColor].CGColor;
        _trackLayer.strokeColor = _trackColor.CGColor;
        _trackLayer.lineWidth = _lineWidth;
        _trackLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:_trackLayer];

        _progressLayer = [CAShapeLayer layer];
        _progressLayer.fillColor = [UIColor clearColor].CGColor;
        _progressLayer.strokeColor = _progressColor.CGColor;
        _progressLayer.lineWidth = _lineWidth;
        _progressLayer.lineCap = kCALineCapRound;
        _progressLayer.strokeEnd = 0;
        [self.layer addSublayer:_progressLayer];

        _endTailGradientLayer = [CAGradientLayer layer];
        _endTailGradientLayer.hidden = YES;
        [self.layer addSublayer:_endTailGradientLayer];

        _endTailMaskLayer = [CAShapeLayer layer];
        _endTailMaskLayer.fillColor = [UIColor clearColor].CGColor;
        _endTailMaskLayer.strokeColor = [UIColor whiteColor].CGColor;
        _endTailMaskLayer.lineWidth = _lineWidth;
        _endTailMaskLayer.lineCap = kCALineCapRound;
        _endTailMaskLayer.strokeStart = 1.0 - _endTailFraction;
        _endTailMaskLayer.strokeEnd = 1.0;
        _endTailGradientLayer.mask = _endTailMaskLayer;
        [self updateEndTailGradientColors];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.trackLayer.frame = self.bounds;
    self.progressLayer.frame = self.bounds;
    self.endTailGradientLayer.frame = self.bounds;
    self.endTailMaskLayer.frame = self.bounds;

    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) / 2.0 - self.lineWidth / 2.0;

    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius
                                                    startAngle:self.arcStartAngle
                                                      endAngle:self.arcEndAngle
                                                     clockwise:YES];
    self.trackLayer.path = path.CGPath;
    self.progressLayer.path = path.CGPath;
    self.endTailMaskLayer.path = path.CGPath;
    [self updateEndTailGradientDirection];

    [self updateArrowHeadAnimated:NO];
}

#pragma mark - Arrow head（沿弧线滑行的指示器）

/// 返回 progress=p 时领头点的弧线角度（屏幕坐标弧度）。
/// 路径方向：clockwise=YES，从 arcStartAngle 沿 INCREASING 屏幕角度方向（视觉顺时针）
/// 覆盖 arcSpan 到 arcEndAngle。
- (CGFloat)angleAtProgress:(CGFloat)p {
    CGFloat span = self.arcEndAngle - self.arcStartAngle;
    while (span <= 0) span += (CGFloat)(2 * M_PI);
    return self.arcStartAngle + p * span;
}

- (void)setArrowHeadImage:(UIImage *)arrowHeadImage {
    _arrowHeadImage = arrowHeadImage;
    if (arrowHeadImage) {
        if (!self.arrowHeadView) {
            self.arrowHeadView = [[UIImageView alloc] initWithImage:arrowHeadImage];
            self.arrowHeadView.tintColor = self.arrowHeadTintColor ?: self.progressColor;
            self.arrowHeadView.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:self.arrowHeadView];
        } else {
            self.arrowHeadView.image = arrowHeadImage;
        }
        [self updateArrowHeadAnimated:NO];
    } else {
        [self.arrowHeadView removeFromSuperview];
        self.arrowHeadView = nil;
    }
}

- (void)setArrowHeadTintColor:(UIColor *)arrowHeadTintColor {
    _arrowHeadTintColor = arrowHeadTintColor;
    self.arrowHeadView.tintColor = arrowHeadTintColor ?: self.progressColor;
}

- (void)setFillStyle:(FSTRingFillStyle)fillStyle {
    if (_fillStyle == fillStyle) return;
    _fillStyle = fillStyle;
    self.lastArrowAngle = (CGFloat)NAN;  // 防止从旧位置走弧线滑过去
    // 重新落定 strokeStart/strokeEnd 到新 style 对应值，并把箭头位置同步。
    [self setProgress:self.progress animated:NO];
}

/// 把 arrow head 移到当前 progress 对应的弧上位置，并旋转到切线方向。
/// animated=YES 时沿弧线绕圆周运动（CAKeyframeAnimation along arc path），
/// 而不是在两点间走直线；rotation 用 CABasicAnimation 同步插值。
- (void)updateArrowHeadAnimated:(BOOL)animated {
    if (!self.arrowHeadView) return;
    if (self.bounds.size.width <= 0) return;

    CGFloat clampedProgress = MAX(0, MIN(1.0, self.progress));
    // 箭头始终位于 progress 对应的弧上位置——即 bar 的"领头边缘"：
    //   Forward 模式下 = strokeEnd（bar 右端），bar 在箭头后面；
    //   Receding 模式下 = strokeStart（bar 左端），bar 在箭头前面。
    CGFloat newAngle = [self angleAtProgress:clampedProgress];
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) / 2.0 - self.lineWidth / 2.0;
    CGPoint newPosition = CGPointMake(center.x + radius * (CGFloat)cos(newAngle), center.y + radius * (CGFloat)sin(newAngle));
    CGFloat newRotation = newAngle + (CGFloat)M_PI;

    self.arrowHeadView.bounds = CGRectMake(0, 0, 14, 13);  // 按设计稿尺寸

    CGFloat oldAngle = self.lastArrowAngle;
    BOOL canAnimate = animated && !isnan(oldAngle) && fabs(newAngle - oldAngle) > 0.0005;

    if (canAnimate) {
        // 沿弧线方向：θ 递增 → clockwise=YES，θ 递减 → clockwise=NO（取最短弧段）。
        BOOL clockwise = (newAngle > oldAngle);
        UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:center
                                                                radius:radius
                                                            startAngle:oldAngle
                                                              endAngle:newAngle
                                                             clockwise:clockwise];

        CFTimeInterval duration = 0.45;
        CAMediaTimingFunction *timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

        CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        positionAnimation.path = arcPath.CGPath;
        positionAnimation.duration = duration;
        positionAnimation.timingFunction = timing;
        positionAnimation.calculationMode = kCAAnimationPaced; // 等弧长速率

        CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.fromValue = @(oldAngle + M_PI);
        rotationAnimation.toValue = @(newRotation);
        rotationAnimation.duration = duration;
        rotationAnimation.timingFunction = timing;

        // 先落定到目标值，再加动画避免回弹
        self.arrowHeadView.layer.position = newPosition;
        self.arrowHeadView.transform = CGAffineTransformMakeRotation(newRotation);

        [self.arrowHeadView.layer addAnimation:positionAnimation forKey:@"posAlongArc"];
        [self.arrowHeadView.layer addAnimation:rotationAnimation forKey:@"rotateAlongTangent"];
    } else {
        self.arrowHeadView.center = newPosition;
        self.arrowHeadView.transform = CGAffineTransformMakeRotation(newRotation);
    }

    self.lastArrowAngle = newAngle;
}

#pragma mark - Setters

- (UIColor *)endTailMidColor {
    CGFloat progressRed = 0, progressGreen = 0, progressBlue = 0, progressAlpha = 0;
    CGFloat tailRed = 0, tailGreen = 0, tailBlue = 0, tailAlpha = 0;
    if (![self.progressColor getRed:&progressRed green:&progressGreen blue:&progressBlue alpha:&progressAlpha] ||
        ![self.endTailColor getRed:&tailRed green:&tailGreen blue:&tailBlue alpha:&tailAlpha]) {
        return self.endTailColor ?: [UIColor fst_progressCream];
    }

    CGFloat mix = 0.55;
    return [UIColor colorWithRed:progressRed + (tailRed - progressRed) * mix
                           green:progressGreen + (tailGreen - progressGreen) * mix
                            blue:progressBlue + (tailBlue - progressBlue) * mix
                           alpha:progressAlpha + (tailAlpha - progressAlpha) * mix];
}

- (void)updateEndTailGradientColors {
    UIColor *startColor = self.progressColor ?: [UIColor fst_primaryGreen];
    UIColor *middleColor = [self endTailMidColor];
    UIColor *endColor = self.endTailColor ?: [UIColor fst_progressCream];
    self.endTailGradientLayer.colors = @[
        (__bridge id)startColor.CGColor,
        (__bridge id)middleColor.CGColor,
        (__bridge id)endColor.CGColor,
    ];
    self.endTailGradientLayer.locations = @[@0.0, @0.58, @1.0];
}

- (void)updateEndTailGradientDirection {
    if (CGRectIsEmpty(self.bounds)) return;
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) / 2.0 - self.lineWidth / 2.0;
    CGFloat startProgress = MAX(0, MIN(1.0, 1.0 - self.endTailFraction));
    CGFloat startAngle = [self angleAtProgress:startProgress];
    CGFloat endAngle = [self angleAtProgress:1.0];
    CGPoint startPosition = CGPointMake(center.x + radius * (CGFloat)cos(startAngle),
                                        center.y + radius * (CGFloat)sin(startAngle));
    CGPoint endPosition = CGPointMake(center.x + radius * (CGFloat)cos(endAngle),
                                      center.y + radius * (CGFloat)sin(endAngle));
    CGFloat width = MAX(1.0, self.bounds.size.width);
    CGFloat height = MAX(1.0, self.bounds.size.height);
    self.endTailGradientLayer.startPoint = CGPointMake(startPosition.x / width, startPosition.y / height);
    self.endTailGradientLayer.endPoint = CGPointMake(endPosition.x / width, endPosition.y / height);
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    self.trackLayer.lineWidth = lineWidth;
    self.progressLayer.lineWidth = lineWidth;
    self.endTailMaskLayer.lineWidth = lineWidth;
    [self setNeedsLayout];
}

- (void)setTrackColor:(UIColor *)trackColor {
    _trackColor = trackColor;
    self.trackLayer.strokeColor = trackColor.CGColor;
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    self.progressLayer.strokeColor = progressColor.CGColor;
    [self updateEndTailGradientColors];
    if (!self.arrowHeadTintColor) {
        self.arrowHeadView.tintColor = progressColor;
    }
}

- (void)setShowsEndTail:(BOOL)showsEndTail {
    _showsEndTail = showsEndTail;
    self.endTailGradientLayer.hidden = !showsEndTail;
}

- (void)setEndTailColor:(UIColor *)endTailColor {
    _endTailColor = endTailColor;
    [self updateEndTailGradientColors];
}

- (void)setEndTailFraction:(CGFloat)endTailFraction {
    _endTailFraction = MAX(0, MIN(1.0, endTailFraction));
    self.endTailMaskLayer.strokeStart = 1.0 - _endTailFraction;
    self.endTailMaskLayer.strokeEnd = 1.0;
    [self updateEndTailGradientDirection];
}

- (void)setArcStartAngle:(CGFloat)arcStartAngle {
    _arcStartAngle = arcStartAngle;
    [self setNeedsLayout];
}

- (void)setArcEndAngle:(CGFloat)arcEndAngle {
    _arcEndAngle = arcEndAngle;
    [self setNeedsLayout];
}

- (void)setProgress:(CGFloat)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    CGFloat clamped = MAX(0, MIN(1.0, progress));
    _progress = progress;

    CGFloat targetStrokeStart = 0.0;
    CGFloat targetStrokeEnd = 1.0;
    if (self.fillStyle == FSTRingFillStyleForward) {
        targetStrokeStart = 0.0;
        targetStrokeEnd = clamped;
    } else {  // FSTRingFillStyleRecedingFromStart
        targetStrokeStart = clamped;
        targetStrokeEnd = 1.0;
    }

    if (animated) {
        CABasicAnimation *startAnim = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        startAnim.fromValue = @(self.progressLayer.strokeStart);
        startAnim.toValue = @(targetStrokeStart);
        startAnim.duration = 0.25;
        [self.progressLayer addAnimation:startAnim forKey:@"strokeStartAnim"];

        CABasicAnimation *endAnim = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        endAnim.fromValue = @(self.progressLayer.strokeEnd);
        endAnim.toValue = @(targetStrokeEnd);
        endAnim.duration = 0.25;
        [self.progressLayer addAnimation:endAnim forKey:@"strokeEndAnim"];
        self.progressLayer.strokeStart = targetStrokeStart;
        self.progressLayer.strokeEnd = targetStrokeEnd;
    } else {
        // animated:NO 必须瞬切：CALayer 的 strokeStart/strokeEnd 默认隐式动画 0.25s，
        // 在切换 fillStyle（Elapsed↔Remaining）时会产生不必要的圆环过渡动画。
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.progressLayer.strokeStart = targetStrokeStart;
        self.progressLayer.strokeEnd = targetStrokeEnd;
        [CATransaction commit];
    }
    [self updateArrowHeadAnimated:animated];
}

- (void)setCompleted:(BOOL)completed {
    _completed = completed;
    self.progressLayer.lineWidth = completed ? (self.lineWidth + 4) : self.lineWidth;
    self.progressLayer.strokeColor = completed ? [UIColor fst_primaryGreen].CGColor
                                               : self.progressColor.CGColor;
    self.endTailMaskLayer.lineWidth = self.progressLayer.lineWidth;
}

@end
