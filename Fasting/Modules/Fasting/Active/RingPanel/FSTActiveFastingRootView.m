//
//  FSTActiveFastingRootView.m
//  Fasting
//

#import "FSTActiveFastingRootView.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

static const CGFloat kHeadlineTopOffset = 8;
static const CGFloat kHeadlineWidth     = 155;
static const CGFloat kHeadlineHeight    = 30;

static const CGFloat kPhaseCardTopOffset = 24;
static const CGFloat kPhaseCardHeight    = 56;

static const CGFloat kRingPanelTopOffset = 38;

static const CGFloat kBottomContentWidth   = 318;
static const CGFloat kTimesRowVisualOffset = -12;
static const CGFloat kTimesRowHeight       = 51;
static const CGFloat kStopTopOffset        = 24;

static const CGFloat kTipsTopOffset     = 28;
static const CGFloat kTipsSideInset     = 20;
static const CGFloat kTipsBottomPadding = 124;  // 留给浮动 tab bar

@interface FSTActiveFastingRootView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *headlineLabel;
@property (nonatomic, strong) UIView *feedbackRow;
@end

@implementation FSTActiveFastingRootView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor fst_pageBackground];
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 视图组装

- (void)setupSubviews {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];

    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];

    self.headlineLabel = [UILabel fst_labelWithText:@"You're fasting!"
                                                font:FSTFontAvenirBold(22)
                                               color:[UIColor fst_textHeading]
                                           alignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.headlineLabel];
}

- (void)setupConstraints {
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
    }];
    [self.headlineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kHeadlineTopOffset);
        make.centerX.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(kHeadlineWidth, kHeadlineHeight));
    }];
}

#pragma mark - Mount API

- (void)mountPhaseCard:(UIControl *)phaseCard
             ringPanel:(UIView *)ringPanel
              timesRow:(UIView *)timesRow
            stopButton:(UIButton *)stopButton
           tipsSection:(UIView *)tipsSection {
    [self.contentView addSubview:phaseCard];
    [self.contentView addSubview:ringPanel];
    [self.contentView addSubview:timesRow];
    [self.contentView addSubview:stopButton];
    [self.contentView addSubview:tipsSection];

    [phaseCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headlineLabel.mas_bottom).offset(kPhaseCardTopOffset);
        make.left.right.equalTo(self.contentView).inset(FSTSpacingCardHorizontal);
        make.height.equalTo(@(kPhaseCardHeight));
    }];
    [ringPanel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(phaseCard.mas_bottom).offset(kRingPanelTopOffset);
        make.left.right.equalTo(self.contentView);
    }];
    [timesRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ringPanel.mas_bottom).offset(kTimesRowVisualOffset);
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(@(kBottomContentWidth));
        make.height.equalTo(@(kTimesRowHeight));
    }];
    [stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timesRow.mas_bottom).offset(kStopTopOffset);
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(@(kBottomContentWidth));
        make.height.equalTo(@(FSTControlHeightStandard));
    }];
    [tipsSection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(stopButton.mas_bottom).offset(kTipsTopOffset);
        make.left.equalTo(self.contentView).offset(kTipsSideInset);
        make.right.equalTo(self.contentView).offset(-kTipsSideInset);
    }];

    // Send feedback 行 — 独立于 Tips 白色卡片之外，由 RootView 自管。
    self.feedbackRow = [self buildFeedbackRow];
    [self.contentView addSubview:self.feedbackRow];
    [self.feedbackRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsSection.mas_bottom).offset(20);
        make.left.equalTo(self.contentView).offset(kTipsSideInset);
        make.right.equalTo(self.contentView).offset(-kTipsSideInset);
        make.height.mas_equalTo(56);
        make.bottom.equalTo(self.contentView).offset(-kTipsBottomPadding);
    }];
}

- (void)anchorContentBelowTopBar:(UIView *)topBar {
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topBar.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];
}

#pragma mark - Send feedback

- (UIView *)buildFeedbackRow {
    UIView *row = [[UIView alloc] init];
    row.backgroundColor = [UIColor whiteColor];
    row.layer.cornerRadius = FSTRadiusL;

    UILabel *emojiLabel = [UILabel fst_labelWithText:@"\U0001F4E9" font:FSTFontRegular(28) color:[UIColor blackColor]];
    UILabel *textLabel = [UILabel fst_labelWithText:@"Send feedback" font:FSTFontMedium(17) color:[UIColor blackColor]];

    UIImageView *chevron = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:@"feedback_chevron"]];
    chevron.contentMode = UIViewContentModeScaleAspectFit;

    [row fst_addSubviews:@[emojiLabel, textLabel, chevron]];

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

@end
