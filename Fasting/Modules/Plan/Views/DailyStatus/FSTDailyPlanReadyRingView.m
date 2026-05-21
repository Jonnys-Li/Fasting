//
//  FSTDailyPlanReadyRingView.m
//  Fasting
//
//  组装：FSTRingProgressView（浅灰 track + 奶油 progress + 琥珀 ring_head 箭头）
//  + 顶部切换按钮 + 中央 caption + HH:MM:SS value + 嵌入的计划胶囊。
//

#import "FSTDailyPlanReadyRingView.h"
#import "FSTRingProgressView.h"
#import "FSTPlanChipPillView.h"
#import "FSTTheme.h"
#import "FSTPercentFormatter.h"

@interface FSTDailyPlanReadyRingView ()
@property (nonatomic, strong) FSTRingProgressView *ringProgressView;
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) FSTPlanChipPillView *planChipPillView;
@property (nonatomic, assign) BOOL isShowingRemaining;
@property (nonatomic, assign) BOOL centerLayoutReadyStateApplied;
@end

@implementation FSTDailyPlanReadyRingView

- (instancetype)init {
    if ((self = [super init])) {
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
    self.ringProgressView.lineWidth = 22;
    self.ringProgressView.trackColor = [UIColor fst_colorWithHex:0xEBEDEE];
    self.ringProgressView.progressColor = [UIColor fst_progressCream];
    self.ringProgressView.arrowHeadTintColor = [UIColor fst_amber];
    self.ringProgressView.arrowHeadImage = [UIImage imageNamed:@"ring_head"];
    self.ringProgressView.fillStyle = FSTRingFillStyleForward;
    [self.ringProgressView setProgress:0 animated:NO];
    [self addSubview:self.ringProgressView];

    // Custom 类型 + AlwaysOriginal 避免被 system tint 染成一团色块。
    self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *toggleImage = [[UIImage imageNamed:@"ring_toggle"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.toggleButton setImage:toggleImage forState:UIControlStateNormal];
    self.toggleButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.toggleButton addTarget:self action:@selector(handleToggleTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.toggleButton];

    self.captionLabel = [UILabel fst_centerLabelWithFont:FSTFontRegular(15) color:[UIColor fst_textSecondary]];
    self.valueLabel = [UILabel fst_centerLabelWithFont:[UIFont monospacedDigitSystemFontOfSize:32 weight:UIFontWeightBold]
                                                 color:[UIColor fst_textPrimary]];

    for (UIView *subview in @[self.captionLabel, self.valueLabel]) {
        [self addSubview:subview];
    }

    __weak typeof(self) weakSelf = self;
    self.planChipPillView = [FSTPlanChipPillView new];
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

/// 根据当前模式填充 caption（百分比） + value（HH:MM:SS）+ 喂给圆环对应的 progress。
- (void)refreshDisplay {
    CGFloat clampedProgress = MAX(0, MIN(1.0, self.progress));
    BOOL scheduledCountdown = self.presentationState == FSTDailyPlanReadyRingPresentationScheduledCountdown;
    BOOL readyToStart = self.presentationState == FSTDailyPlanReadyRingPresentationReadyToStartFasting;
    BOOL compact = scheduledCountdown || readyToStart;

    [self applyReadyToStartLayout:compact];
    self.toggleButton.hidden = compact;
    self.toggleButton.userInteractionEnabled = !compact;
    self.ringProgressView.progressColor = readyToStart ? [UIColor fst_colorWithHex:0xFF9876] : [UIColor fst_progressCream];
    self.ringProgressView.arrowHeadTintColor = readyToStart ? [UIColor whiteColor] : [UIColor fst_amber];

    if (scheduledCountdown) {
        NSInteger elapsedPercent = [FSTPercentFormatter clampedPercentForFraction:clampedProgress targetReached:clampedProgress >= 1.0];
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

    NSInteger elapsedPercent = [FSTPercentFormatter clampedPercentForFraction:clampedProgress targetReached:clampedProgress >= 1.0];
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
