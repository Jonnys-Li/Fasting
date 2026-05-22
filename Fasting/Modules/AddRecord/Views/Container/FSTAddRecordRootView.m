//
//  FSTAddRecordRootView.m
//  Fasting
//

#import "FSTAddRecordRootView.h"
#import "FSTAddRecordHeaderView.h"
#import "FSTAddRecordTimeCardView.h"
#import "FSTAddRecordWeightCardView.h"
#import "FSTAddRecordFeelingCardView.h"
#import "FSTAddRecordNoteCardView.h"
#import "FSTVerticalCardStackView.h"
#import "FSTTheme.h"
#import "UIColor+FST.h"

static const CGFloat kFSTAddRecordHeaderHeight       = 310;
static const CGFloat kFSTAddRecordHeaderOverlap      = -34;  // 卡片区上拉与 header 视觉重叠的距离
static const CGFloat kFSTAddRecordCardSpacing        = 18;
static const CGFloat kFSTAddRecordCardSideInset      = 22;
static const CGFloat kFSTAddRecordCardBottomPadding  = 28;
static const CGFloat kFSTAddRecordBottomBarHeight    = 112;
static const CGFloat kFSTAddRecordButtonHeight       = 58;
static const CGFloat kFSTAddRecordButtonGap          = 14;
static const CGFloat kFSTAddRecordButtonTopInset     = 16;
static const CGFloat kFSTAddRecordButtonCornerRadius = 29;

@interface FSTAddRecordRootView ()
@property (nonatomic, strong, readwrite) FSTAddRecordHeaderView *headerView;
@property (nonatomic, strong, readwrite) FSTAddRecordTimeCardView *timeCardView;
@property (nonatomic, strong, readwrite) FSTAddRecordWeightCardView *weightCardView;
@property (nonatomic, strong, readwrite) FSTAddRecordFeelingCardView *feelingCardView;
@property (nonatomic, strong, readwrite) FSTAddRecordNoteCardView *noteCardView;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) FSTVerticalCardStackView *cardStack;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;
@end

@implementation FSTAddRecordRootView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor fst_addRecordBackground];
        [self buildHeader];
        [self buildScrollAndCards];
        [self buildBottomBar];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 视图组装

- (void)buildHeader {
    self.headerView = [FSTAddRecordHeaderView new];
    [self addSubview:self.headerView];
}

- (void)buildScrollAndCards {
    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    self.timeCardView    = [FSTAddRecordTimeCardView new];
    self.weightCardView  = [FSTAddRecordWeightCardView new];
    self.feelingCardView = [FSTAddRecordFeelingCardView new];
    self.noteCardView    = [FSTAddRecordNoteCardView new];

    self.cardStack = [FSTVerticalCardStackView new];
    self.cardStack.cardSpacing   = kFSTAddRecordCardSpacing;
    self.cardStack.contentInsets = UIEdgeInsetsMake(0,
                                                    kFSTAddRecordCardSideInset,
                                                    kFSTAddRecordCardBottomPadding,
                                                    kFSTAddRecordCardSideInset);
    self.cardStack.cards = @[self.timeCardView, self.weightCardView, self.feelingCardView, self.noteCardView];
    [self.contentView addSubview:self.cardStack];
}

- (void)buildBottomBar {
    self.bottomBar = [UIView new];
    self.bottomBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.96];
    [self addSubview:self.bottomBar];

    self.cancelButton = [UIButton fst_outlineGreenPillButtonWithTitle:@"Cancel"];
    self.cancelButton.backgroundColor = [UIColor fst_addRecordCancelButton];
    [self.cancelButton setTitleColor:[UIColor fst_textPrimary] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = FSTFontSubhead();
    self.cancelButton.layer.cornerRadius = kFSTAddRecordButtonCornerRadius;
    [self.cancelButton addTarget:self action:@selector(handleCancelTapped) forControlEvents:UIControlEventTouchUpInside];

    self.saveButton = [UIButton fst_greenPillButtonWithTitle:@"Save"];
    self.saveButton.layer.cornerRadius = kFSTAddRecordButtonCornerRadius;
    self.saveButton.titleLabel.font = FSTFontSubhead();
    [self.saveButton addTarget:self action:@selector(handleSaveTapped) forControlEvents:UIControlEventTouchUpInside];

    [self.bottomBar addSubview:self.cancelButton];
    [self.bottomBar addSubview:self.saveButton];
}

#pragma mark - 约束

- (void)setupConstraints {
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(@(kFSTAddRecordHeaderHeight));
    }];

    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@(kFSTAddRecordBottomBarHeight));
    }];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom).offset(kFSTAddRecordHeaderOverlap);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.bottomBar.mas_top);
    }];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];

    [self.cardStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomBar).offset(kFSTAddRecordCardSideInset);
        make.top.equalTo(self.bottomBar).offset(kFSTAddRecordButtonTopInset);
        make.height.equalTo(@(kFSTAddRecordButtonHeight));
    }];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cancelButton.mas_right).offset(kFSTAddRecordButtonGap);
        make.right.equalTo(self.bottomBar).offset(-kFSTAddRecordCardSideInset);
        make.top.equalTo(self.cancelButton);
        make.width.height.equalTo(self.cancelButton);
    }];
}

#pragma mark - 事件

- (void)handleCancelTapped {
    if (self.onCancelTapped) self.onCancelTapped();
}

- (void)handleSaveTapped {
    if (self.onSaveTapped) self.onSaveTapped();
}

@end
