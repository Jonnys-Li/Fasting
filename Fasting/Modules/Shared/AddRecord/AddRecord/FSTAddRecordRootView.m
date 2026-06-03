//
//  FSTAddRecordRootView.m
//  Fasting
//

#import "FSTAddRecordRootView.h"
#import "FSTVerticalCardStackView.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

static const CGFloat kHeaderHeight  = 310;
static const CGFloat kHeaderOverlap = -34;  // 卡片区上拉与 header 视觉重叠的距离

static const CGFloat kCardSpacing       = 18;
static const CGFloat kCardSideInset     = 22;
static const CGFloat kCardBottomPadding = 28;

static const CGFloat kBottomBarHeight    = 112;
static const CGFloat kButtonHeight       = 58;
static const CGFloat kButtonGap          = 14;
static const CGFloat kButtonTopInset     = 16;

@interface FSTAddRecordRootView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) FSTVerticalCardStackView *cardStack;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *saveButton;
@end

@implementation FSTAddRecordRootView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor fst_addRecordBackground];
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

    self.cardStack = [[FSTVerticalCardStackView alloc] init];
    self.cardStack.cardSpacing   = kCardSpacing;
    self.cardStack.contentInsets = UIEdgeInsetsMake(0,
                                                    kCardSideInset,
                                                    kCardBottomPadding,
                                                    kCardSideInset);
    [self.contentView addSubview:self.cardStack];

    self.bottomBar = [[UIView alloc] init];
    self.bottomBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.96];
    [self addSubview:self.bottomBar];

    self.cancelButton = [UIButton fst_pillButtonWithTitle:@"Cancel" style:FSTPillButtonStyleNeutral];
    [self.cancelButton addTarget:self action:@selector(handleCancelTapped)
                forControlEvents:UIControlEventTouchUpInside];

    self.saveButton = [UIButton fst_pillButtonWithTitle:@"Save" style:FSTPillButtonStyleAppCTA];
    [self.saveButton addTarget:self action:@selector(handleSaveTapped)
              forControlEvents:UIControlEventTouchUpInside];

    [self.bottomBar addSubview:self.cancelButton];
    [self.bottomBar addSubview:self.saveButton];
}

- (void)setupConstraints {
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@(kBottomBarHeight));
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    [self.cardStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomBar).offset(kCardSideInset);
        make.top.equalTo(self.bottomBar).offset(kButtonTopInset);
        make.height.equalTo(@(kButtonHeight));
    }];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cancelButton.mas_right).offset(kButtonGap);
        make.right.equalTo(self.bottomBar).offset(-kCardSideInset);
        make.top.equalTo(self.cancelButton);
        make.width.height.equalTo(self.cancelButton);
    }];
}

#pragma mark - Mount API

- (void)mountHeaderView:(UIView *)headerView cards:(NSArray<UIView *> *)cards {
    [self addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.equalTo(@(kHeaderHeight));
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerView.mas_bottom).offset(kHeaderOverlap);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.bottomBar.mas_top);
    }];
    self.cardStack.cards = cards;
}

#pragma mark - 事件

- (void)handleCancelTapped {
    if (self.onCancelTapped) self.onCancelTapped();
}

- (void)handleSaveTapped {
    if (self.onSaveTapped) self.onSaveTapped();
}

@end
