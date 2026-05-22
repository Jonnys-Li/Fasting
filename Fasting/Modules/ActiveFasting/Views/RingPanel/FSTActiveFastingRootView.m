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
#import "UIColor+FST.h"

static const CGFloat kFSTActiveFastingHeadlineTopOffset      = 8;
static const CGFloat kFSTActiveFastingHeadlineWidth          = 155;
static const CGFloat kFSTActiveFastingHeadlineHeight         = 30;
static const CGFloat kFSTActiveFastingPhaseCardTopOffset     = 24;
static const CGFloat kFSTActiveFastingPhaseCardSideInset     = 28;
static const CGFloat kFSTActiveFastingPhaseCardHeight        = 56;
static const CGFloat kFSTActiveFastingRingPanelTopOffset     = 38;
static const CGFloat kFSTActiveFastingTimesRowVisualOffset   = -12;
static const CGFloat kFSTActiveFastingBottomContentWidth     = 318;
static const CGFloat kFSTActiveFastingTimesRowHeight         = 51;
static const CGFloat kFSTActiveFastingStopTopOffset          = 24;
static const CGFloat kFSTActiveFastingStopHeight             = 48;
static const CGFloat kFSTActiveFastingStopCornerRadius       = 24;
static const CGFloat kFSTActiveFastingTipsTopOffset          = 28;
static const CGFloat kFSTActiveFastingTipsSideInset          = 20;
static const CGFloat kFSTActiveFastingTipsBottomPadding      = 124;  // 留给浮动 tab bar

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
    self.headlineLabel.font          = [UIFont fontWithName:@"AvenirNext-Bold" size:22] ?: FSTFontBold(22);
    self.headlineLabel.textColor     = [UIColor fst_textHeading];
    self.headlineLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.headlineLabel];

    self.phaseCard = [FSTFastingPhaseSummaryCard new];
    [self.phaseCard addTarget:self action:@selector(handlePhaseCardTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.phaseCard];

    [self.headlineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kFSTActiveFastingHeadlineTopOffset);
        make.centerX.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(kFSTActiveFastingHeadlineWidth, kFSTActiveFastingHeadlineHeight));
    }];
    [self.phaseCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headlineLabel.mas_bottom).offset(kFSTActiveFastingPhaseCardTopOffset);
        make.left.right.equalTo(self.contentView).inset(kFSTActiveFastingPhaseCardSideInset);
        make.height.equalTo(@(kFSTActiveFastingPhaseCardHeight));
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
        make.top.equalTo(self.phaseCard.mas_bottom).offset(kFSTActiveFastingRingPanelTopOffset);
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
    self.stopButton.layer.cornerRadius = kFSTActiveFastingStopCornerRadius;
    [self.stopButton setTitle:@"END FASTING" forState:UIControlStateNormal];
    [self.stopButton setTitleColor:[UIColor fst_textHeading] forState:UIControlStateNormal];
    self.stopButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:16] ?: FSTFontBold(16);
    [self.stopButton addTarget:self action:@selector(handleStopTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.stopButton];

    [self.timesRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.ringPanel.mas_bottom).offset(kFSTActiveFastingTimesRowVisualOffset);
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(@(kFSTActiveFastingBottomContentWidth));
        make.height.equalTo(@(kFSTActiveFastingTimesRowHeight));
    }];
    [self.stopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timesRow.mas_bottom).offset(kFSTActiveFastingStopTopOffset);
        make.centerX.equalTo(self.contentView);
        make.width.equalTo(@(kFSTActiveFastingBottomContentWidth));
        make.height.equalTo(@(kFSTActiveFastingStopHeight));
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
        make.top.equalTo(self.stopButton.mas_bottom).offset(kFSTActiveFastingTipsTopOffset);
        make.left.equalTo(self.contentView).offset(kFSTActiveFastingTipsSideInset);
        make.right.equalTo(self.contentView).offset(-kFSTActiveFastingTipsSideInset);
        make.bottom.equalTo(self.contentView).offset(-kFSTActiveFastingTipsBottomPadding);
    }];
}

#pragma mark - 事件

- (void)handlePhaseCardTapped {
    if (self.onPhaseCardTapped) self.onPhaseCardTapped();
}

- (void)handleStopTapped {
    if (self.onStopTapped) self.onStopTapped();
}

@end
