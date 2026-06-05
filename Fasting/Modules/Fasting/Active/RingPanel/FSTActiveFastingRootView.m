//
//  FSTActiveFastingRootView.m
//  Fasting
//

#import "FSTActiveFastingRootView.h"
#import "FSTFastingFeedbackRow.h"
#import "FSTFastingTipsSectionView.h"
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
@property (nonatomic, strong) FSTFastingTipsSectionView *tipsSection;
@property (nonatomic, strong) FSTFastingFeedbackRow *feedbackRow;
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
                                               color:[UIColor fst_textHeading]];
    self.headlineLabel.textAlignment = NSTextAlignmentCenter;
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
           tipsSection:(FSTFastingTipsSectionView *)tipsSection {
    self.tipsSection = tipsSection;
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
    self.feedbackRow = [[FSTFastingFeedbackRow alloc] init];
    __weak typeof(self) weakSelf = self;
    self.feedbackRow.onTapped = ^{
        if (weakSelf.onSendFeedbackTapped) weakSelf.onSendFeedbackTapped();
    };
    [self.contentView addSubview:self.feedbackRow];
    [self.feedbackRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(tipsSection.mas_bottom).offset(20);
        make.left.equalTo(self.contentView).offset(kTipsSideInset);
        make.right.equalTo(self.contentView).offset(-kTipsSideInset);
        make.height.mas_equalTo(56);
        make.bottom.equalTo(self.contentView).offset(-kTipsBottomPadding);
    }];

    // Tips QA 折叠卡展开后把 tipsSection 底部滚到可见区底部（Bug 3）。
    tipsSection.onExpansionChanged = ^(BOOL expanded) {
        if (expanded) [weakSelf scrollToShowTipsSection];
    };
}

#pragma mark - Scroll helpers

/// 调用上下文：必须在 tipsSection.onExpansionChanged 回调中（即外层 UIView animateWithDuration 块内）
/// 执行 —— 这样 contentOffset 变更会被外层动画捕获，与"展开"动画同步呈现（一步动作）。
/// 单独调用此方法不会动画（contentOffset 同步赋值）。
- (void)scrollToShowTipsSection {
    if (!self.tipsSection) return;
    UIScrollView *sv = self.scrollView;
    [sv layoutIfNeeded];
    CGRect frame = [self.tipsSection convertRect:self.tipsSection.bounds toView:sv];
    CGFloat tipsBottom = CGRectGetMaxY(frame);
    // 让 tipsSection 底部 == scrollView 可见区底部（扣除 adjustedContentInset.bottom，因为
    // tab bar / safe area 会遮住底部那一截）。
    CGFloat bottomInset = sv.adjustedContentInset.bottom;
    CGFloat newOffsetY = tipsBottom - sv.bounds.size.height + bottomInset;
    CGFloat maxOffsetY = MAX(0, sv.contentSize.height - sv.bounds.size.height + bottomInset);
    newOffsetY = MIN(maxOffsetY, MAX(0, newOffsetY));
    if (fabs(newOffsetY - sv.contentOffset.y) < 0.5) return;
    sv.contentOffset = CGPointMake(sv.contentOffset.x, newOffsetY);
}

- (void)anchorContentBelowTopBar:(UIView *)topBar {
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topBar.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];
}

@end
