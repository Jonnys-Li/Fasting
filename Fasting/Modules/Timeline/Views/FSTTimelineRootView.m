//
//  FSTTimelineRootView.m
//  Fasting
//

#import "FSTTimelineRootView.h"
#import "FSTFastingTimelineCardView.h"
#import "FSTTimelineModuleView.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

// Title
static const CGFloat kTitleTopInset = 26;

// Fasting card
static const CGFloat kCardTopOffset     = 34;
static const CGFloat kCardSideInset     = 24;
static const CGFloat kFastingCardHeight = 244;

// 模块间 & 底部
static const CGFloat kModuleSpacing = 20;
static const CGFloat kBottomPadding = 120;

@interface FSTTimelineRootView ()
@property (nonatomic, strong, readwrite) FSTFastingTimelineCardView *fastingModuleView;
@property (nonatomic, strong, readwrite) FSTTimelineModuleView *mealModuleView;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation FSTTimelineRootView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor fst_pageBackground];
        [self buildScrollAndContent];
        [self buildModuleViews];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 视图组装

- (void)buildScrollAndContent {
    self.scrollView = [UIScrollView new];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    [self addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    self.titleLabel = [UILabel fst_titleLabelWithText:@"Timeline"];
    [self.contentView addSubview:self.titleLabel];
}

- (void)buildModuleViews {
    self.fastingModuleView = [FSTFastingTimelineCardView new];
    self.fastingModuleView.titleText = @"Fasting";
    [self.contentView addSubview:self.fastingModuleView];

    self.mealModuleView = [FSTTimelineModuleView new];
    [self.contentView addSubview:self.mealModuleView];
}

#pragma mark - 约束

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
    [self.fastingModuleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(kCardTopOffset);
        make.left.right.equalTo(self.contentView).inset(kCardSideInset);
        make.height.equalTo(@(kFastingCardHeight));
    }];
    [self.mealModuleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fastingModuleView.mas_bottom).offset(kModuleSpacing);
        make.left.right.equalTo(self.fastingModuleView);
        make.bottom.equalTo(self.contentView).offset(-kBottomPadding);
    }];
}

@end
