//
//  FSTFastingIdleReadyView.m
//  Fasting
//

#import "FSTFastingIdleReadyView.h"
#import "FSTBreakingFastCardView.h"
#import "FSTFastingTimesRow.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

// Title
static const CGFloat kTitleTop    = 12;
static const CGFloat kTitleHeight = 30;

// BreakingFast Card
static const CGFloat kCardTopOffset = 14;
static const CGFloat kCardHeight    = 56;

// ReadyRing
static const CGFloat kRingDiameter     = 292;
static const CGFloat kRingTopAfterCard = 22;
static const CGFloat kRingTopWhenReady = 18;

// TimesRow
static const CGFloat kTimesRowVisualOffset = -12;
static const CGFloat kTimesRowHeight       = 60;

// Primary buttons (Start / LogMeal)
static const CGFloat kStartTopOffset     = 26;
static const CGFloat kButtonSideInset    = 34;
static const CGFloat kButtonHeight       = 60;
static const CGFloat kButtonGap          = 16;

// AddRecord row
static const CGFloat kAddRecordTopOffset = 20;
static const CGFloat kAddRecordHeight    = 56;
static const CGFloat kAddRecordRadius    = 22;

// Bottom
static const CGFloat kBottomPadding = 118;

@interface FSTFastingIdleReadyView ()
@property (nonatomic, strong) UILabel *eatingTitleLabel;
@property (nonatomic, strong) FSTBreakingFastCardView *breakingFastCardView;
@property (nonatomic, strong) FSTFastingIdleReadyRingView *readyRingView;
@property (nonatomic, strong) FSTFastingTimesRow *nextFastTimesRow;
@property (nonatomic, strong) UIButton *startFastingButton;
@property (nonatomic, strong) UIButton *logMealButton;
@property (nonatomic, strong) UIView *addRecordRow;
@property (nonatomic, assign) BOOL readyToStartLayoutApplied;
@end

@implementation FSTFastingIdleReadyView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _primaryActionMode = FSTDailyPlanReadyPrimaryActionStartFasting;
        [self buildSubviews];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 视图组装

- (void)buildSubviews {
    __weak typeof(self) weakSelf = self;

    self.eatingTitleLabel = [UILabel fst_labelWithText:@"Eating Time" font:FSTFontAvenirBold(22) color:[UIColor fst_textHeading] alignment:NSTextAlignmentCenter];

    self.breakingFastCardView = [[FSTBreakingFastCardView alloc] init];
    self.breakingFastCardView.onTapped = ^{
        if (weakSelf.onBreakingFastTapped) weakSelf.onBreakingFastTapped();
    };

    self.readyRingView = [[FSTFastingIdleReadyRingView alloc] init];
    self.readyRingView.onChangePlanTapped = ^{
        if (weakSelf.onChangePlanTapped) weakSelf.onChangePlanTapped();
    };

    self.nextFastTimesRow = [[FSTFastingTimesRow alloc] init];
    self.nextFastTimesRow.startCaption = @"Next fast starts";
    self.nextFastTimesRow.endCaption   = @"Next fast ends";
    self.nextFastTimesRow.onEditStartTapped = ^{
        if (weakSelf.onEditNextFastStartTapped) weakSelf.onEditNextFastStartTapped();
    };
    self.nextFastTimesRow.onEditEndTapped = ^{
        if (weakSelf.onEditNextFastEndTapped) weakSelf.onEditNextFastEndTapped();
    };

    self.startFastingButton = [UIButton fst_pillButtonWithTitle:@"Start Fasting" style:FSTPillButtonStyleAppCTA];
    [self.startFastingButton addTarget:self action:@selector(handleStartFastingTapped) forControlEvents:UIControlEventTouchUpInside];

    self.logMealButton = [UIButton fst_pillButtonWithTitle:@"LOG MEAL" style:FSTPillButtonStyleOrangeCTA];
    [self.logMealButton addTarget:self action:@selector(handleLogMealTapped) forControlEvents:UIControlEventTouchUpInside];

    self.addRecordRow = [self buildAddRecordRow];

    [self fst_addSubviews:@[self.eatingTitleLabel, self.breakingFastCardView, self.readyRingView,
                            self.nextFastTimesRow, self.startFastingButton, self.logMealButton, self.addRecordRow]];
}

#pragma mark - 约束

- (void)setupConstraints {
    [self.eatingTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kTitleTop);
        make.centerX.equalTo(self);
        make.height.equalTo(@(kTitleHeight));
    }];
    [self.breakingFastCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.eatingTitleLabel.mas_bottom).offset(kCardTopOffset);
        make.left.right.equalTo(self).inset(FSTSpacingCardHorizontal);
        make.height.equalTo(@(kCardHeight));
    }];
    [self.readyRingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.breakingFastCardView.mas_bottom).offset(kRingTopAfterCard);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(kRingDiameter, kRingDiameter));
    }];
    [self.nextFastTimesRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.readyRingView.mas_bottom).offset(kTimesRowVisualOffset);
        make.left.right.equalTo(self).inset(FSTSpacingCardHorizontal);
        make.height.equalTo(@(kTimesRowHeight));
    }];
    [self.startFastingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nextFastTimesRow.mas_bottom).offset(kStartTopOffset);
        make.left.right.equalTo(self).inset(kButtonSideInset);
        make.height.equalTo(@(kButtonHeight));
    }];
    [self.logMealButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startFastingButton.mas_bottom).offset(kButtonGap);
        make.left.right.equalTo(self.startFastingButton);
        make.height.equalTo(@(kButtonHeight));
    }];
    [self.addRecordRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logMealButton.mas_bottom).offset(kAddRecordTopOffset);
        make.left.right.equalTo(self).inset(FSTSpacingCardHorizontal);
        make.height.mas_equalTo(kAddRecordHeight);
        make.bottom.equalTo(self).offset(-kBottomPadding);
    }];
}

#pragma mark - 状态推送

- (void)setPlanName:(NSString *)planName {
    _planName = [planName copy];
    NSString *resolvedName = planName.length ? planName : @"14-10";
    self.readyRingView.planName = resolvedName;
    [self refreshPrimaryActionButton];
}

- (void)setRingPresentationState:(FSTDailyPlanReadyRingPresentationState)ringPresentationState {
    _ringPresentationState = ringPresentationState;
    self.readyRingView.presentationState = ringPresentationState;
}

- (void)setTitleText:(NSString *)titleText {
    _titleText = [titleText copy];
    self.eatingTitleLabel.text = titleText;
}

- (void)setElapsedText:(NSString *)elapsedText {
    _elapsedText = [elapsedText copy];
    self.readyRingView.elapsedText = elapsedText;
}

- (void)setRingProgress:(CGFloat)ringProgress {
    _ringProgress = ringProgress;
    self.readyRingView.progress = ringProgress;
}

- (void)setRemainingText:(NSString *)remainingText {
    _remainingText = [remainingText copy];
    self.readyRingView.remainingText = remainingText;
}

- (void)setTimeSinceLastFastText:(NSString *)timeSinceLastFastText {
    _timeSinceLastFastText = [timeSinceLastFastText copy];
    self.readyRingView.timeSinceLastFastText = timeSinceLastFastText;
}

- (void)setNextFastStartText:(NSString *)nextFastStartText {
    _nextFastStartText = [nextFastStartText copy];
    self.nextFastTimesRow.startText = nextFastStartText;
}

- (void)setNextFastEndText:(NSString *)nextFastEndText {
    _nextFastEndText = [nextFastEndText copy];
    self.nextFastTimesRow.endText = nextFastEndText;
}

- (void)setPrimaryActionMode:(FSTDailyPlanReadyPrimaryActionMode)primaryActionMode {
    _primaryActionMode = primaryActionMode;
    [self refreshPrimaryActionButton];
}

- (void)refreshPrimaryActionButton {
    if (self.primaryActionMode == FSTDailyPlanReadyPrimaryActionAbortPlan) {
        self.startFastingButton.backgroundColor = [UIColor fst_buttonInactive];
        self.startFastingButton.layer.shadowOpacity = 0;
        [self.startFastingButton setTitle:@"Abort Plan" forState:UIControlStateNormal];
        [self.startFastingButton setTitleColor:[UIColor fst_textHeading] forState:UIControlStateNormal];
        return;
    }

    NSString *resolvedName = self.planName.length ? self.planName : @"14-10";
    self.startFastingButton.backgroundColor = [UIColor fst_eatingTimeGreen];
    self.startFastingButton.layer.shadowColor = [UIColor fst_eatingTimeGreen].CGColor;
    self.startFastingButton.layer.shadowOpacity = 0.18;
    self.startFastingButton.layer.shadowOffset = CGSizeMake(0, 10);
    self.startFastingButton.layer.shadowRadius = 20;
    [self.startFastingButton setTitle:[NSString stringWithFormat:@"Start %@ Fasting", resolvedName] forState:UIControlStateNormal];
    [self.startFastingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

#pragma mark - 子状态切换

/// readyToStart=YES：breaking fast 卡隐藏 + 圆环上移到 eatingTitleLabel 之下；
/// readyToStart=NO：breaking fast 卡显示 + 圆环回到卡片之下。
- (void)applyReadyToStartLayout:(BOOL)readyToStart {
    if (self.readyToStartLayoutApplied == readyToStart) return;
    self.readyToStartLayoutApplied = readyToStart;

    self.breakingFastCardView.hidden = readyToStart;
    self.breakingFastCardView.userInteractionEnabled = !readyToStart;
    [self.readyRingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        UIView *anchor = readyToStart ? self.eatingTitleLabel : self.breakingFastCardView;
        CGFloat offset = readyToStart ? kRingTopWhenReady : kRingTopAfterCard;
        make.top.equalTo(anchor.mas_bottom).offset(offset);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(kRingDiameter, kRingDiameter));
    }];
    [self setNeedsLayout];
}

#pragma mark - 事件

- (void)handleStartFastingTapped {
    if (self.primaryActionMode == FSTDailyPlanReadyPrimaryActionAbortPlan) {
        if (self.onAbortPlanTapped) self.onAbortPlanTapped();
        return;
    }
    if (self.onStartFastingTapped) self.onStartFastingTapped();
}

- (void)handleLogMealTapped {
    if (self.onLogMealTapped) self.onLogMealTapped();
}

- (void)handleAddRecordTapped {
    if (self.onAddRecordTapped) self.onAddRecordTapped();
}

#pragma mark - Add Record Row

- (UIView *)buildAddRecordRow {
    UIView *row = [UIView fst_whiteCardWithRadius:kAddRecordRadius];

    UIImageView *plusIcon = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:@"add_record_plus"]];
    plusIcon.contentMode = UIViewContentModeScaleAspectFit;

    UILabel *textLabel = [UILabel fst_labelWithText:@"Add new record" font:FSTFontBold(17) color:[UIColor blackColor]];

    UIImageView *chevron = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:@"feedback_chevron"]];
    chevron.contentMode = UIViewContentModeScaleAspectFit;

    [row fst_addSubviews:@[plusIcon, textLabel, chevron]];

    [plusIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(row).offset(16);
        make.centerY.equalTo(row);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(plusIcon.mas_right).offset(10);
        make.centerY.equalTo(row);
    }];
    [chevron mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(row).offset(-16);
        make.centerY.equalTo(row);
        make.size.mas_equalTo(CGSizeMake(8, 14));
    }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleAddRecordTapped)];
    [row addGestureRecognizer:tap];
    return row;
}

@end
