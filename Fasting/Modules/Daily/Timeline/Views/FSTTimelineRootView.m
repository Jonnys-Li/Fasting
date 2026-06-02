//
//  FSTTimelineRootView.m
//  Fasting
//

#import "FSTTimelineRootView.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

static const CGFloat kTitleTopInset = 26;

static const CGFloat kCardTopOffset     = 34;
static const CGFloat kCardSideInset     = 24;
static const CGFloat kFastingCardHeight = 244;

static const CGFloat kModuleSpacing = 20;
static const CGFloat kBottomPadding = 120;

@interface FSTTimelineRootView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation FSTTimelineRootView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor fst_pageBackground];
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupSubviews {
    self.scrollView = [UIScrollView new];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    [self addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    self.titleLabel = [UILabel fst_titleLabelWithText:@"Timeline"];
    [self.contentView addSubview:self.titleLabel];
}

- (void)setupConstraints {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(kTitleTopInset);
        make.centerX.equalTo(self.contentView);
    }];
}

#pragma mark - Mount API

- (void)mountFastingModuleView:(UIView *)fastingModuleView mealModuleView:(UIView *)mealModuleView {
    [self.contentView addSubview:fastingModuleView];
    [self.contentView addSubview:mealModuleView];

    [fastingModuleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(kCardTopOffset);
        make.left.right.equalTo(self.contentView).inset(kCardSideInset);
        make.height.equalTo(@(kFastingCardHeight));
    }];
    [mealModuleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fastingModuleView.mas_bottom).offset(kModuleSpacing);
        make.left.right.equalTo(fastingModuleView);
        make.bottom.equalTo(self.contentView).offset(-kBottomPadding);
    }];
}

@end
