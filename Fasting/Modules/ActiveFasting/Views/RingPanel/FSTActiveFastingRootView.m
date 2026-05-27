//
//  FSTActiveFastingRootView.m
//  Fasting
//

#import "FSTActiveFastingRootView.h"
#import "FSTFastingPhaseSummaryCard.h"
#import "FSTFastingRingPanelView.h"
#import "FSTFastingTimesRow.h"
#import "FSTFastingTipsSectionView.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

// Headline
static const CGFloat kHeadlineTopOffset = 8;
static const CGFloat kHeadlineWidth     = 155;
static const CGFloat kHeadlineHeight    = 30;

// PhaseCard
static const CGFloat kPhaseCardTopOffset = 24;
static const CGFloat kPhaseCardSideInset = 28;
static const CGFloat kPhaseCardHeight    = 56;

// RingPanel
static const CGFloat kRingPanelTopOffset = 38;

// TimesRow / StopButton（共享底部内容宽度）
static const CGFloat kBottomContentWidth   = 318;
static const CGFloat kTimesRowVisualOffset = -12;
static const CGFloat kTimesRowHeight       = 51;
static const CGFloat kStopTopOffset        = 24;
static const CGFloat kStopHeight           = 48;
static const CGFloat kStopCornerRadius     = 24;

// Tips / Feedback
static const CGFloat kTipsTopOffset     = 28;
static const CGFloat kTipsSideInset     = 20;
static const CGFloat kTipsBottomPadding = 124;  // 留给浮动 tab bar

@interface FSTActiveFastingRootView ()
@property (nonatomic, strong, readwrite) UIScrollView *scrollView;
@property (nonatomic, strong, readwrite) UIView *contentView;
@property (nonatomic, strong, readwrite) UILabel *headlineLabel;
@property (nonatomic, strong, readwrite) FSTFastingPhaseSummaryCard *phaseCard;
@property (nonatomic, strong, readwrite) FSTFastingRingPanelView *ringPanel;
@property (nonatomic, strong, readwrite) FSTFastingTimesRow *timesRow;
@property (nonatomic, strong, readwrite) UIButton *stopButton;
@property (nonatomic, strong, readwrite) FSTFastingTipsSectionView *tipsSection;
@end

@implementation FSTActiveFastingRootView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor fst_pageBackground];
        [self buildScrollContainer];
        [self buildHeaderAndPhase];
        [self buildRingPanel];
        [self buildTimesRowAndStop];
        [self buildTipsSection];
    }
    return self;
}

#pragma mark - 视图组装

/// 滚动容器：scrollView 的 left/right/bottom 锚到 self；top 由 VC 在 topBar install 完毕后补上。
- (void)buildScrollContainer {
    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
    }];
}

- (void)buildHeaderAndPhase {
    __weak typeof(self) weakSelf = self;

    self.headlineLabel = [UILabel new];
    self.headlineLabel.text          = @"You're fasting!";
    self.headlineLabel.font          = FSTFontAvenirBold(22);
    self.headlineLabel.textColor     = [UIColor fst_textHeading];
    self.headlineLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.headlineLabel];

    self.phaseCard = [FSTFastingPhaseSummaryCard new];
    [self.phaseCard addTarget:self action:@selector(handlePhaseCardTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.phaseCard];

    [self.headlineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kHeadlineTopOffset);
        make.centerX.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(kHeadlineWidth, kHeadlineHeight));
    }];
    [self.phaseCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headlineLabel.mas_bottom).offset(kPhaseCardTopOffset);
        make.left.right.equalTo(self.contentView).inset(kPhaseCardSideInset);
        make.height.equalTo(@(kPhaseCardHeight));
    }];

    (void)weakSelf;
}

- (void)buildRingPanel {
    __weak typeof(self) weakSelf = self;

    self.ringPanel = [FSTFastingRingPanelView new];
    self.ringPanel.onModeTapped = ^{
        if (weakSelf.onRingModeTapped) weakSelf.onRingModeTapped();
    };
    self.ringPanel.onPlanChipTapped = ^{
        if (weakSelf.onPlanChipTapped) weakSelf.onPlanChipTapped();
    };
    [self.contentView addSubview:self.ringPanel];

    [self.ringPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.phaseCard.mas_bottom).offset(kRingPanelTopOffset);
        make.left.right.equalTo(self.contentView);
    }];
}

- (void)buildTimesRowAndStop {
    __weak typeof(self) weakSelf = self;

    self.timesRow = [[FSTFastingTimesRow alloc] initWithStartCaption:@"Fast starts"
                                                          endCaption:@"Fast ends"
                                                            editable:YES
                                                 startHighlightColor:nil];
    self.timesRow.onEditStartTapped = ^{
        if (weakSelf.onEditStartTapped) weakSelf.onEditStartTapped();
    };
    self.timesRow.onEditEndTapped = ^{
        if (weakSelf.onEditEndTapped) weakSelf.onEditEndTapped();
    };
    [self.contentView addSubview:self.timesRow];

    self.stopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.stopButton.backgroundColor    = [UIColor fst_buttonInactive];
    self.stopButton.layer.cornerRadius = kStopCornerRadius;
    [self.stopButton setTitle:@"END FASTING" forState:UIControlStateNormal];
    [self.stopButton setTitleColor:[UIColor fst_textHeading] forState:UIControlStateNormal];
    self.stopButton.titleLabel.font = FSTFontAvenirDemiBold(16);
    [self.stopButton addTarget:self action:@selector(handleStopTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.stopButton];

    [self.timesRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ringPanel.mas_bottom).offset(kTimesRowVisualOffset);
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(@(kBottomContentWidth));
        make.height.equalTo(@(kTimesRowHeight));
    }];
    [self.stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timesRow.mas_bottom).offset(kStopTopOffset);
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(@(kBottomContentWidth));
        make.height.equalTo(@(kStopHeight));
    }];
}

- (void)buildTipsSection {
    __weak typeof(self) weakSelf = self;

    self.tipsSection = [FSTFastingTipsSectionView new];
    self.tipsSection.onDrinkNowTapped = ^{
        if (weakSelf.onDrinkNowTapped) weakSelf.onDrinkNowTapped();
    };
    [self.contentView addSubview:self.tipsSection];
    [self.tipsSection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stopButton.mas_bottom).offset(kTipsTopOffset);
        make.left.equalTo(self.contentView).offset(kTipsSideInset);
        make.right.equalTo(self.contentView).offset(-kTipsSideInset);
    }];

    // Send feedback 行 — 独立于 Tips 白色卡片之外
    UIView *feedbackRow = [self buildFeedbackRow];
    [self.contentView addSubview:feedbackRow];
    [feedbackRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipsSection.mas_bottom).offset(20);
        make.left.equalTo(self.contentView).offset(kTipsSideInset);
        make.right.equalTo(self.contentView).offset(-kTipsSideInset);
        make.height.mas_equalTo(56);
        make.bottom.equalTo(self.contentView).offset(-kTipsBottomPadding);
    }];
}

#pragma mark - Send feedback

- (UIView *)buildFeedbackRow {
    UIView *row = [UIView new];
    row.backgroundColor = [UIColor whiteColor];
    row.layer.cornerRadius = FSTRadiusL;

    UILabel *emojiLabel = [UILabel new];
    emojiLabel.text = @"\U0001F4E9";
    emojiLabel.font = FSTFontRegular(28);
    [row addSubview:emojiLabel];

    UILabel *textLabel = [UILabel new];
    textLabel.text = @"Send feedback";
    textLabel.font = FSTFontMedium(17);
    textLabel.textColor = [UIColor blackColor];
    [row addSubview:textLabel];

    UIImageView *chevron = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"feedback_chevron"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    chevron.contentMode = UIViewContentModeScaleAspectFit;
    [row addSubview:chevron];

    [emojiLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(row).offset(16);
        make.centerY.equalTo(row);
    }];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(emojiLabel.mas_right).offset(10);
        make.centerY.equalTo(row);
    }];
    [chevron mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(row).offset(-16);
        make.centerY.equalTo(row);
        make.size.mas_equalTo(CGSizeMake(8, 14));
    }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFeedbackTapped)];
    [row addGestureRecognizer:tap];
    return row;
}

- (void)handleFeedbackTapped {
    if (self.onSendFeedbackTapped) self.onSendFeedbackTapped();
}

#pragma mark - 事件

- (void)handlePhaseCardTapped {
    if (self.onPhaseCardTapped) self.onPhaseCardTapped();
}

- (void)handleStopTapped {
    if (self.onStopTapped) self.onStopTapped();
}

@end
