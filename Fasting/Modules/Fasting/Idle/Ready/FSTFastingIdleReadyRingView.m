//
//  FSTFastingIdleReadyRingView.m
//  Fasting
//
//  组装：FSTRingProgressView（浅灰 track + 奶油 progress + 琥珀 ring_head 箭头）
//  + 顶部切换按钮 + 中央 caption + HH:MM:SS value + 嵌入的计划胶囊。
//

#import "FSTFastingIdleReadyRingView.h"
#import "FSTRingProgressView.h"
#import "FSTPlanChipPillView.h"
#import "FSTTheme.h"
#import <math.h>

/// 把已用/目标比例钳到 UI 百分比：未达标上限 99（避免 99.6% 被四舍五入到 100），达标允许 100。
static NSInteger FSTRingElapsedPercent(CGFloat fraction, BOOL targetReached) {
    NSInteger percent = (NSInteger)lround(MAX(0, fraction) * 100.0);
    return targetReached ? MIN(100, MAX(0, percent)) : MIN(99, MAX(0, percent));
}

@interface FSTFastingIdleReadyRingView ()
@property (nonatomic, strong) FSTRingProgressView *ringProgressView;
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) FSTPlanChipPillView *planChipPillView;
@property (nonatomic, assign) BOOL isShowingRemaining;
@property (nonatomic, assign) BOOL centerLayoutReadyStateApplied;
@end

@implementation FSTFastingIdleReadyRingView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _presentationState = FSTDailyPlanReadyRingPresentationEatingWindow;
        [self buildSubviews];
        [self refreshDisplay];
    }
    return self;
}

#pragma mark - 外部 setters

- (void)setPresentationState:(FSTDailyPlanReadyRingPresentationState)presentationState {
    _presentationState = presentationState;
    [self refreshDisplay];
}

- (void)setElapsedText:(NSString *)elapsedText      { _elapsedText = [elapsedText copy]; [self refreshDisplay]; }
- (void)setRemainingText:(NSString *)remainingText  { _remainingText = [remainingText copy]; [self refreshDisplay]; }
- (void)setTimeSinceLastFastText:(NSString *)timeSinceLastFastText { _timeSinceLastFastText = [timeSinceLastFastText copy]; [self refreshDisplay]; }
- (void)setPlanName:(NSString *)planName            { _planName = [planName copy]; self.planChipPillView.planName = planName ?: @""; }

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self refreshDisplay];
}

/// 构建：开口弧 + 顶部切换按钮 + 中央 caption/value + 计划胶囊
- (void)buildSubviews {
    self.ringProgressView = [[FSTRingProgressView alloc] initWithFrame:CGRectZero];
    self.ringProgressView.lineWidth      = 22;
    self.ringProgressView.trackColor     = [UIColor fst_ringTrackLight];
    self.ringProgressView.arrowHeadImage = [UIImage fst_templateImageNamed:@"ring_head"];
    self.ringProgressView.fillStyle      = FSTRingFillStyleForward;
    // progressColor / arrowHeadTintColor 由 fst_applyStyle: 在 refreshDisplay 里设置。
    [self.ringProgressView setProgress:0 animated:NO];
    [self addSubview:self.ringProgressView];

    // Custom 类型 + AlwaysOriginal 避免被 system tint 染成一团色块。
    self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *toggleImage = [UIImage fst_originalImageNamed:@"ring_toggle"];
    [self.toggleButton setImage:toggleImage forState:UIControlStateNormal];
    self.toggleButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.toggleButton addTarget:self action:@selector(handleToggleTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.toggleButton];

    self.captionLabel = [UILabel fst_centerLabelWithFont:FSTFontBody() color:[UIColor fst_textSecondary]];
    self.valueLabel = [UILabel fst_centerLabelWithFont:[UIFont monospacedDigitSystemFontOfSize:32 weight:UIFontWeightBold]
                                                 color:[UIColor fst_textPrimary]];

    for (UIView *subview in @[self.captionLabel, self.valueLabel]) {
        [self addSubview:subview];
    }

    __weak typeof(self) weakSelf = self;
    self.planChipPillView = [[FSTPlanChipPillView alloc] init];
    self.planChipPillView.onTapped = ^{
        if (weakSelf.onChangePlanTapped) weakSelf.onChangePlanTapped();
    };
    [self addSubview:self.planChipPillView];

    [self.ringProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.toggleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(64);   // 设计稿 top:59，留点呼吸
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.captionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.toggleButton.mas_bottom).offset(12);
        make.centerX.equalTo(self);
    }];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.captionLabel.mas_bottom).offset(4);
        make.centerX.equalTo(self);
    }];
    [self.planChipPillView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.valueLabel.mas_bottom).offset(12);
        make.centerX.equalTo(self);
    }];
}

#pragma mark - 切换 / 刷新文案

- (void)handleToggleTapped {
    if (self.presentationState != FSTDailyPlanReadyRingPresentationEatingWindow) return;
    self.isShowingRemaining = !self.isShowingRemaining;
    [self refreshDisplay];
}

/// 把 panel 三态 enum 翻译到 ring 视觉态 enum。
- (FSTRingStyle)ringStyleForPresentation {
    switch (self.presentationState) {
        case FSTDailyPlanReadyRingPresentationEatingWindow:        return FSTRingStyleEatingWindow;
        case FSTDailyPlanReadyRingPresentationScheduledCountdown:  return FSTRingStyleScheduledCountdown;
        case FSTDailyPlanReadyRingPresentationReadyToStartFasting: return FSTRingStyleReadyToStartFasting;
    }
}

/// 根据当前模式填充 caption（百分比） + value（HH:MM:SS）+ 喂给圆环对应的 progress。
- (void)refreshDisplay {
    CGFloat clampedProgress = MAX(0, MIN(1.0, self.progress));
    BOOL scheduledCountdown = self.presentationState == FSTDailyPlanReadyRingPresentationScheduledCountdown;
    BOOL readyToStart = self.presentationState == FSTDailyPlanReadyRingPresentationReadyToStartFasting;
    BOOL compact = scheduledCountdown || readyToStart;

    [self applyReadyToStartLayout:compact];
    self.toggleButton.hidden = compact;
    self.toggleButton.userInteractionEnabled = !compact;
    [self.ringProgressView fst_applyStyle:[self ringStyleForPresentation]];

    if (scheduledCountdown) {
        NSInteger elapsedPercent = FSTRingElapsedPercent(clampedProgress, clampedProgress >= 1.0);
        NSInteger remainingPercent = clampedProgress >= 1.0 ? 0 : (100 - elapsedPercent);
        self.ringProgressView.fillStyle = FSTRingFillStyleRecedingFromStart;
        self.captionLabel.text = [NSString stringWithFormat:@"Remaining time %ld%%", (long)remainingPercent];
        self.valueLabel.text = self.remainingText ?: @"--:--:--";
        [self.ringProgressView setProgress:clampedProgress animated:YES];
        return;
    }

    if (readyToStart) {
        self.ringProgressView.fillStyle = FSTRingFillStyleForward;
        self.captionLabel.text = @"Time since last fast";
        self.valueLabel.text = self.timeSinceLastFastText ?: self.elapsedText ?: @"--:--:--";
        // Ready-to-start 表示上一段 eating window 已走完：Forward + progress=1 → 满环，箭头落在右侧终点。
        [self.ringProgressView setProgress:1.0 animated:YES];
        return;
    }

    NSInteger elapsedPercent = FSTRingElapsedPercent(clampedProgress, clampedProgress >= 1.0);
    self.ringProgressView.fillStyle = self.isShowingRemaining ? FSTRingFillStyleRecedingFromStart : FSTRingFillStyleForward;
    if (self.isShowingRemaining) {
        self.captionLabel.text = [NSString stringWithFormat:@"Remaining time %ld%%", (long)(100 - elapsedPercent)];
        self.valueLabel.text = self.remainingText ?: @"--:--:--";
    } else {
        self.captionLabel.text = [NSString stringWithFormat:@"Elapsed time %ld%%", (long)elapsedPercent];
        self.valueLabel.text = self.elapsedText ?: @"--:--:--";
    }
    // progress 始终表示 elapsed；Elapsed 用 Forward 增长，Remaining 用 Receding 从箭头侧回缩。
    [self.ringProgressView setProgress:clampedProgress animated:YES];
}

/// readyToStart=YES：无 toggle 时的紧凑布局。
- (void)applyReadyToStartLayout:(BOOL)readyToStart {
    if (self.centerLayoutReadyStateApplied == readyToStart) return;
    self.centerLayoutReadyStateApplied = readyToStart;

    if (readyToStart) {
        [self.captionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(88);
            make.centerX.equalTo(self);
        }];
        [self.valueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.captionLabel.mas_bottom).offset(10);
            make.centerX.equalTo(self);
        }];
        [self.planChipPillView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.valueLabel.mas_bottom).offset(16);
            make.centerX.equalTo(self);
        }];
    } else {
        [self.captionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.toggleButton.mas_bottom).offset(12);
            make.centerX.equalTo(self);
        }];
        [self.valueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.captionLabel.mas_bottom).offset(4);
            make.centerX.equalTo(self);
        }];
        [self.planChipPillView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.valueLabel.mas_bottom).offset(12);
            make.centerX.equalTo(self);
        }];
    }
}

@end
