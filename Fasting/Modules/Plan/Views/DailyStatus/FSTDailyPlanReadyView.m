//
//  FSTDailyPlanReadyView.m
//  Fasting
//

#import "FSTDailyPlanReadyView.h"
#import "FSTBreakingFastCardView.h"
#import "FSTFastingTimesRow.h"
#import "FSTTheme.h"

static const CGFloat kFSTDailyPlanReadyAddRecordTopOffset = 20;
static const CGFloat kFSTDailyPlanReadyAddRecordHeight    = 56;
static const CGFloat kFSTDailyPlanReadyAddRecordRadius    = 22;

static const CGFloat kFSTDailyPlanReadyTitleTop          = 12;
static const CGFloat kFSTDailyPlanReadyTitleHeight       = 30;
static const CGFloat kFSTDailyPlanReadyCardTopOffset     = 14;
static const CGFloat kFSTDailyPlanReadyCardSideInset     = 28;
static const CGFloat kFSTDailyPlanReadyCardHeight        = 56;
static const CGFloat kFSTDailyPlanReadyRingDiameter      = 292;
static const CGFloat kFSTDailyPlanReadyRingTopAfterCard  = 22;
static const CGFloat kFSTDailyPlanReadyRingTopWhenReady  = 18;
static const CGFloat kFSTDailyPlanReadyTimesRowVisualOffset = -12;
static const CGFloat kFSTDailyPlanReadyTimesRowHeight    = 60;
static const CGFloat kFSTDailyPlanReadyStartTopOffset    = 26;
static const CGFloat kFSTDailyPlanReadyButtonSideInset   = 34;
static const CGFloat kFSTDailyPlanReadyButtonHeight      = 60;
static const CGFloat kFSTDailyPlanReadyButtonCornerRadius = 30;
static const CGFloat kFSTDailyPlanReadyButtonGap         = 16;
static const CGFloat kFSTDailyPlanReadyBottomPadding     = 118;

@interface FSTDailyPlanReadyView ()
@property (nonatomic, strong) UILabel *eatingTitleLabel;
@property (nonatomic, strong) FSTBreakingFastCardView *breakingFastCardView;
@property (nonatomic, strong) FSTDailyPlanReadyRingView *readyRingView;
@property (nonatomic, strong) FSTFastingTimesRow *nextFastTimesRow;
@property (nonatomic, strong) UIButton *startFastingButton;
@property (nonatomic, strong) UIButton *logMealButton;
@property (nonatomic, strong) UIView *addRecordRow;
@property (nonatomic, assign) BOOL readyToStartLayoutApplied;
@end

@implementation FSTDailyPlanReadyView

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

    self.breakingFastCardView = [FSTBreakingFastCardView new];
    self.breakingFastCardView.onTapped = ^{ if (weakSelf.onBreakingFastTapped) weakSelf.onBreakingFastTapped(); };

    self.readyRingView = [FSTDailyPlanReadyRingView new];
    self.readyRingView.onChangePlanTapped = ^{ if (weakSelf.onChangePlanTapped) weakSelf.onChangePlanTapped(); };

    self.nextFastTimesRow = [[FSTFastingTimesRow alloc] initWithStartCaption:@"Next fast starts"
                                                                  endCaption:@"Next fast ends"
                                                                    editable:YES
                                                         startHighlightColor:nil];
    self.nextFastTimesRow.onEditStartTapped = ^{ if (weakSelf.onEditNextFastStartTapped) weakSelf.onEditNextFastStartTapped(); };
    self.nextFastTimesRow.onEditEndTapped   = ^{ if (weakSelf.onEditNextFastEndTapped) weakSelf.onEditNextFastEndTapped(); };

    self.startFastingButton = [UIButton fst_greenPillButtonWithTitle:@"Start Fasting"];
    self.startFastingButton.layer.cornerRadius = kFSTDailyPlanReadyButtonCornerRadius;
    self.startFastingButton.titleLabel.font    = FSTFontSubhead();
    [self.startFastingButton addTarget:self action:@selector(handleStartFastingTapped) forControlEvents:UIControlEventTouchUpInside];

    self.logMealButton = [UIButton fst_yellowPillButtonWithTitle:@"LOG MEAL"];
    self.logMealButton.backgroundColor    = [UIColor fst_orangeCTA];
    self.logMealButton.layer.cornerRadius = kFSTDailyPlanReadyButtonCornerRadius;
    self.logMealButton.titleLabel.font    = FSTFontSubhead();
    [self.logMealButton addTarget:self action:@selector(handleLogMealTapped) forControlEvents:UIControlEventTouchUpInside];

    self.addRecordRow = [self buildAddRecordRow];

    [self fst_addSubviews:@[self.eatingTitleLabel, self.breakingFastCardView, self.readyRingView,
                            self.nextFastTimesRow, self.startFastingButton, self.logMealButton, self.addRecordRow]];
}

#pragma mark - 约束

- (void)setupConstraints {
    [self.eatingTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kFSTDailyPlanReadyTitleTop);
        make.centerX.equalTo(self);
        make.height.equalTo(@(kFSTDailyPlanReadyTitleHeight));
    }];
    [self.breakingFastCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.eatingTitleLabel.mas_bottom).offset(kFSTDailyPlanReadyCardTopOffset);
        make.left.right.equalTo(self).inset(kFSTDailyPlanReadyCardSideInset);
        make.height.equalTo(@(kFSTDailyPlanReadyCardHeight));
    }];
    [self.readyRingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.breakingFastCardView.mas_bottom).offset(kFSTDailyPlanReadyRingTopAfterCard);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(kFSTDailyPlanReadyRingDiameter, kFSTDailyPlanReadyRingDiameter));
    }];
    [self.nextFastTimesRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.readyRingView.mas_bottom).offset(kFSTDailyPlanReadyTimesRowVisualOffset);
        make.left.right.equalTo(self).inset(kFSTDailyPlanReadyCardSideInset);
        make.height.equalTo(@(kFSTDailyPlanReadyTimesRowHeight));
    }];
    [self.startFastingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nextFastTimesRow.mas_bottom).offset(kFSTDailyPlanReadyStartTopOffset);
        make.left.right.equalTo(self).inset(kFSTDailyPlanReadyButtonSideInset);
        make.height.equalTo(@(kFSTDailyPlanReadyButtonHeight));
    }];
    [self.logMealButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startFastingButton.mas_bottom).offset(kFSTDailyPlanReadyButtonGap);
        make.left.right.equalTo(self.startFastingButton);
        make.height.equalTo(@(kFSTDailyPlanReadyButtonHeight));
    }];
    [self.addRecordRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logMealButton.mas_bottom).offset(kFSTDailyPlanReadyAddRecordTopOffset);
        make.left.right.equalTo(self).inset(kFSTDailyPlanReadyCardSideInset);
        make.height.mas_equalTo(kFSTDailyPlanReadyAddRecordHeight);
        make.bottom.equalTo(self).offset(-kFSTDailyPlanReadyBottomPadding);
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
        CGFloat offset = readyToStart ? kFSTDailyPlanReadyRingTopWhenReady : kFSTDailyPlanReadyRingTopAfterCard;
        make.top.equalTo(anchor.mas_bottom).offset(offset);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(kFSTDailyPlanReadyRingDiameter, kFSTDailyPlanReadyRingDiameter));
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
    UIView *row = [UIView fst_whiteCardWithRadius:kFSTDailyPlanReadyAddRecordRadius];

    UIImageView *plusIcon = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"add_record_plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    plusIcon.contentMode = UIViewContentModeScaleAspectFit;

    UILabel *textLabel = [UILabel fst_labelWithText:@"Add new record" font:FSTFontBold(17) color:[UIColor blackColor]];

    UIImageView *chevron = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"feedback_chevron"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
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
