//
//  FSTFastingRingPanelView.m
//  Fasting
//

#import "FSTFastingRingPanelView.h"
#import "FSTRingProgressView.h"
#import "FSTPlanChipPillView.h"
#import "FSTTheme.h"
#import <CoreImage/CoreImage.h>
#import <Masonry/Masonry.h>

#pragma mark - Layout constants

// 火焰图标
static const CGFloat kFlameProgressAnchor = 0.75;
static const CGFloat kFlameSize           = 52;  // 与 @3x 源图 1x 原生尺寸一致

@interface FSTFastingRingPanelView ()
@property (nonatomic, strong, readwrite) FSTRingProgressView *ring;
@property (nonatomic, strong) UIButton *modeButton;
@property (nonatomic, strong, readwrite) UILabel *timerCaptionLabel;
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong) UIImageView *completionIconView;
@property (nonatomic, strong) UILabel *overtimeDetailLabel;
@property (nonatomic, strong) UILabel *overtimeTotalLabel;
@property (nonatomic, strong) UILabel *endCaptionLabel;
@property (nonatomic, strong) UILabel *endTimeLabel;
@property (nonatomic, strong) UILabel *percentLabel;
@property (nonatomic, strong) FSTPlanChipPillView *planChipView;
@property (nonatomic, strong) UIImageView *flameMarkerView;
@end

@implementation FSTFastingRingPanelView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupSubviews];
    }
    return self;
}

- (UIView *)ringView {
    return self.ring;
}

- (void)setTimerCaption:(NSString *)caption {
    _timerCaption = [caption copy]; self.timerCaptionLabel.text = caption;
}
- (void)setTimerText:(NSString *)text {
    _timerText    = [text copy];    self.timerLabel.text        = text;
}
- (void)setOvertimeTotalText:(NSString *)text {
    _overtimeTotalText = [text copy]; self.overtimeTotalLabel.text = text;
}
- (void)setEndText:(NSString *)text {
    _endText      = [text copy];    self.endTimeLabel.text      = text; self.endCaptionLabel.text = @"End time";
}
- (void)setPercentText:(NSString *)text {
    _percentText  = [text copy];    self.percentLabel.text      = text;
}
- (void)setPlanName:(NSString *)planName {
    _planName     = [planName copy]; self.planChipView.planName = planName;
}
- (void)setProgress:(CGFloat)progress {
    _progress     = progress;       [self.ring setProgress:progress animated:NO]; [self refreshFlameState];
}
- (void)setFlameProgress:(CGFloat)flameProgress {
    _flameProgress = flameProgress; [self refreshFlameState];
}
- (void)setDisplayMode:(FSTRingDisplayMode)mode {
    _displayMode = mode;
    [self refreshRingFillStyle];
}
- (void)setPresentationState:(FSTRingPresentationState)presentationState {
    if (_presentationState == presentationState) return;
    _presentationState = presentationState;
    [self refreshRingFillStyle];
    [self applyPresentationState];
}

/// 仅在「Active 子态 + Remaining 显示」下使用 RecedingFromStart；其余（Elapsed / Complete / Overtime）一律 Forward，
/// 因为 overtime 时进度恒为 1.0，Receding 下 1.0 是空环，必须切回 Forward 才能显示满环。
- (void)refreshRingFillStyle {
    BOOL useReceding = (self.presentationState == FSTRingPresentationActive)
                    && (self.displayMode == FSTRingDisplayRemaining);
    self.ring.fillStyle = useReceding ? FSTRingFillStyleRecedingFromStart : FSTRingFillStyleForward;
}

- (void)setOvertimeDetailText:(NSString *)text {
    _overtimeDetailText = [text copy];
    if (!text.length) {
        self.overtimeDetailLabel.attributedText = nil;
        return;
    }
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{
        NSFontAttributeName: FSTFontRegular(18),
        NSForegroundColorAttributeName: [UIColor fst_textCaption],
    }];
    NSRange percentRange = [text rangeOfString:@"("];
    if (percentRange.location != NSNotFound) {
        NSRange highlightRange = NSMakeRange(percentRange.location, text.length - percentRange.location);
        [attributedText addAttributes:@{
            NSFontAttributeName: FSTFontBold(18),
            NSForegroundColorAttributeName: [UIColor fst_warningOrange],
        } range:highlightRange];
    }
    self.overtimeDetailLabel.attributedText = attributedText;
}

- (void)setupSubviews {
    self.ring = [[FSTRingProgressView alloc] initWithFrame:CGRectZero];
    self.ring.lineWidth      = 22;
    self.ring.trackColor     = [UIColor fst_ringTrackLight];
    self.ring.arrowHeadImage = [UIImage fst_templateImageNamed:@"ring_head"];
    // progressColor / arrowHeadTintColor 由 fst_applyStyle: 在 applyPresentationState 里设置。
    [self addSubview:self.ring];

    self.modeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *toggleImage = [UIImage fst_originalImageNamed:@"ring_toggle"];
    [self.modeButton setImage:toggleImage forState:UIControlStateNormal];
    self.modeButton.imageView.contentMode      = UIViewContentModeScaleAspectFit;
    [self.modeButton addTarget:self action:@selector(emitModeTapped) forControlEvents:UIControlEventTouchUpInside];

    self.timerCaptionLabel = [UILabel fst_labelWithText:nil font:FSTFontBold(16)
                                                        color:[UIColor fst_textSecondary]];
    self.timerCaptionLabel.textAlignment = NSTextAlignmentCenter;
    self.timerLabel        = [UILabel fst_labelWithText:nil font:[UIFont monospacedDigitSystemFontOfSize:32 weight:UIFontWeightBold]
                                                        color:[UIColor fst_textHeading]];
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    self.completionIconView = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:@"congratulations"]];
    self.completionIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.completionIconView.hidden = YES;
    self.overtimeDetailLabel = [UILabel fst_labelWithText:nil font:FSTFontRegular(18)
                                                          color:[UIColor fst_textCaption]];
    self.overtimeDetailLabel.textAlignment = NSTextAlignmentCenter;
    self.overtimeDetailLabel.hidden = YES;
    self.overtimeTotalLabel = [UILabel fst_labelWithText:nil font:[UIFont monospacedDigitSystemFontOfSize:28 weight:UIFontWeightBold]
                                                         color:[UIColor fst_textHeading]];
    self.overtimeTotalLabel.textAlignment = NSTextAlignmentCenter;
    self.overtimeTotalLabel.hidden = YES;
    self.endCaptionLabel   = [UILabel fst_labelWithText:nil font:FSTFontRegular(16)
                                                        color:[UIColor fst_textSecondary]];
    self.endCaptionLabel.textAlignment = NSTextAlignmentCenter;
    self.endTimeLabel      = [UILabel fst_labelWithText:nil font:FSTFontBold(18)
                                                        color:[UIColor fst_textPrimary]];
    self.endTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.percentLabel      = [UILabel fst_labelWithText:nil font:FSTFontRegular(18)
                                                        color:[UIColor fst_textSecondary]];
    self.percentLabel.textAlignment = NSTextAlignmentCenter;

    self.planChipView = [[FSTPlanChipPillView alloc] init];
    __weak typeof(self) weakSelf = self;
    self.planChipView.onTapped = ^{
        if (weakSelf.onPlanChipTapped) weakSelf.onPlanChipTapped();
    };

    // 火焰里程碑：固定锚在弧上 0.75 处，使用 elapsed 进度判断彩色状态。
    // 灰态用运行时去饱和方式生成，确保两态像素位置完全重合。
    self.flameMarkerView = [[UIImageView alloc] init];
    self.flameMarkerView.contentMode = UIViewContentModeScaleAspectFit;
    [self.ring addSubview:self.flameMarkerView];
    [self refreshFlameState];

    for (UIView *subview in @[self.modeButton, self.completionIconView, self.timerCaptionLabel, self.timerLabel, self.overtimeDetailLabel, self.overtimeTotalLabel, self.planChipView]) {
        [self addSubview:subview];
    }

    [self setupConstraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self positionFlameMarker];
}

/// 把火焰锚到圆环 anchor 比例对应的弧上点（不旋转）。
- (void)positionFlameMarker {
    CGRect ringBounds = self.ring.bounds;
    if (ringBounds.size.width <= 0) return;
    CGPoint center = CGPointMake(CGRectGetMidX(ringBounds), CGRectGetMidY(ringBounds));
    CGFloat radius = MIN(ringBounds.size.width, ringBounds.size.height) / 2.0 - self.ring.lineWidth / 2.0;
    CGFloat angle  = [self.ring angleAtProgress:kFlameProgressAnchor];
    CGPoint position = CGPointMake(center.x + radius * (CGFloat)cos(angle),
                                   center.y + radius * (CGFloat)sin(angle));
    self.flameMarkerView.bounds = CGRectMake(0, 0, kFlameSize, kFlameSize);
    self.flameMarkerView.center = position;
}

/// 真实 progress 越过 anchor → 彩色火焰；否则同一张图去饱和后的灰版。
- (void)refreshFlameState {
    BOOL shouldShowFlame = self.presentationState == FSTRingPresentationActive;
    self.flameMarkerView.hidden = !shouldShowFlame;
    if (!shouldShowFlame) return;

    BOOL crossed = self.flameProgress >= kFlameProgressAnchor;
    self.flameMarkerView.image = crossed ? [FSTFastingRingPanelView flameActiveImage]
                                         : [FSTFastingRingPanelView flameInactiveImage];
}

/// 彩色源图。
+ (UIImage *)flameActiveImage {
    static UIImage *image;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [UIImage imageNamed:@"flame_active"];
    });
    return image;
}

/// 灰态：用 CoreImage 去饱和（saturation=0）并轻微提亮，与彩色图同尺寸同位置。
+ (UIImage *)flameInactiveImage {
    static UIImage *desaturatedImage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIImage *sourceImage = [self flameActiveImage];
        CIImage *coreImage = [CIImage imageWithCGImage:sourceImage.CGImage];
        CIFilter *colorFilter = [CIFilter filterWithName:@"CIColorControls"];
        [colorFilter setValue:coreImage   forKey:kCIInputImageKey];
        [colorFilter setValue:@(0)        forKey:kCIInputSaturationKey];
        [colorFilter setValue:@(0.05)     forKey:kCIInputBrightnessKey];
        [colorFilter setValue:@(0.95)     forKey:kCIInputContrastKey];

        CIContext *ciContext = [CIContext contextWithOptions:nil];
        CGImageRef cgImage = [ciContext createCGImage:colorFilter.outputImage fromRect:coreImage.extent];
        desaturatedImage = [UIImage imageWithCGImage:cgImage scale:sourceImage.scale orientation:sourceImage.imageOrientation];
        CGImageRelease(cgImage);
    });
    return desaturatedImage;
}

- (void)setupConstraints {
    [self.ring mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(292, 292));
        make.bottom.equalTo(self);
    }];
    [self applyPresentationState];
}

/// 把 panel 三态 enum 翻译到 ring 视觉态 enum。
- (FSTRingStyle)ringStyleForPresentation {
    switch (self.presentationState) {
        case FSTRingPresentationActive:   return FSTRingStyleActiveFasting;
        case FSTRingPresentationComplete: return FSTRingStyleCompleteFasting;
        case FSTRingPresentationOvertime: return FSTRingStyleOvertimeFasting;
    }
}

- (void)applyPresentationState {
    [self.ring fst_applyStyle:[self ringStyleForPresentation]];

    self.modeButton.hidden = self.presentationState != FSTRingPresentationActive;
    self.completionIconView.hidden = self.presentationState != FSTRingPresentationComplete;
    self.overtimeDetailLabel.hidden = self.presentationState != FSTRingPresentationOvertime;
    self.overtimeTotalLabel.hidden = self.presentationState != FSTRingPresentationOvertime;
    [self refreshFlameState];

    [self.modeButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.ring);
        make.top.equalTo(self.ring).offset(56);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.completionIconView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ring).offset(48);
        make.centerX.equalTo(self.ring);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];

    if (self.presentationState == FSTRingPresentationComplete) {
        self.timerCaptionLabel.font = FSTFontRegular(20);
        self.timerCaptionLabel.textColor = [UIColor fst_textCaption];
        self.timerLabel.font = FSTFontHeavy(58);
        self.timerLabel.textColor = [UIColor fst_textHeading];

        [self.timerCaptionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.completionIconView.mas_bottom).offset(8);
            make.centerX.equalTo(self.ring);
        }];
        [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timerCaptionLabel.mas_bottom).offset(18);
            make.centerX.equalTo(self.ring);
        }];
        [self.overtimeDetailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timerLabel.mas_bottom);
            make.centerX.equalTo(self.ring);
        }];
        [self.overtimeTotalLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timerLabel.mas_bottom);
            make.centerX.equalTo(self.ring);
        }];
        [self.planChipView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timerLabel.mas_bottom).offset(20);
            make.centerX.equalTo(self.ring);
        }];
    } else if (self.presentationState == FSTRingPresentationOvertime) {
        self.timerCaptionLabel.font = FSTFontRegular(18);
        self.timerCaptionLabel.textColor = [UIColor fst_textCaption];
        self.timerLabel.font = [UIFont monospacedDigitSystemFontOfSize:42 weight:UIFontWeightHeavy];
        self.timerLabel.textColor = [UIColor fst_textHeading];
        self.overtimeTotalLabel.font = [UIFont monospacedDigitSystemFontOfSize:28 weight:UIFontWeightBold];

        [self.timerCaptionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.ring).offset(58);
            make.centerX.equalTo(self.ring);
        }];
        [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timerCaptionLabel.mas_bottom).offset(6);
            make.centerX.equalTo(self.ring);
        }];
        [self.overtimeDetailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timerLabel.mas_bottom).offset(12);
            make.centerX.equalTo(self.ring);
        }];
        [self.overtimeTotalLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.overtimeDetailLabel.mas_bottom).offset(6);
            make.centerX.equalTo(self.ring);
        }];
        [self.planChipView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.overtimeTotalLabel.mas_bottom).offset(8);
            make.centerX.equalTo(self.ring);
        }];
    } else {
        self.timerCaptionLabel.font = FSTFontBold(16);
        self.timerCaptionLabel.textColor = [UIColor fst_textSecondary];
        self.timerLabel.font = [UIFont monospacedDigitSystemFontOfSize:32 weight:UIFontWeightBold];
        self.timerLabel.textColor = [UIColor fst_textHeading];

        [self.timerCaptionLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.modeButton.mas_bottom).offset(10);
            make.centerX.equalTo(self.ring);
        }];
        [self.timerLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timerCaptionLabel.mas_bottom).offset(8);
            make.centerX.equalTo(self.ring);
        }];
        [self.overtimeDetailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timerLabel.mas_bottom);
            make.centerX.equalTo(self.ring);
        }];
        [self.overtimeTotalLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timerLabel.mas_bottom);
            make.centerX.equalTo(self.ring);
        }];
        [self.planChipView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timerLabel.mas_bottom).offset(14);
            make.centerX.equalTo(self.ring);
        }];
    }
}

- (UIImage *)snapshotForSharing {
    BOOL wasModeHidden = self.modeButton.hidden;
    self.modeButton.hidden = YES;

    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    self.modeButton.hidden = wasModeHidden;
    return image;
}

- (void)emitModeTapped {
    if (self.onModeTapped) self.onModeTapped();
}

@end
