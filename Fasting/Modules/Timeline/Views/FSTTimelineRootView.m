//
//  FSTTimelineRootView.m
//  Fasting
//

#import "FSTTimelineRootView.h"
#import "FSTFastingTimelineCardView.h"
#import "FSTTimelineModuleView.h"
#import "FSTTheme.h"

static const CGFloat kFSTTimelineTitleTopInset       = 26;
static const CGFloat kFSTTimelineCardTopOffset       = 34;
static const CGFloat kFSTTimelineCardSideInset       = 24;
static const CGFloat kFSTTimelineFastingCardHeight   = 244;
static const CGFloat kFSTTimelineModuleSpacing       = 20;
static const CGFloat kFSTTimelineBottomPadding       = 120;

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
        make.top.equalTo(self.contentView).offset(kFSTTimelineTitleTopInset);
        make.centerX.equalTo(self.contentView);
    }];
    [self.fastingModuleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(kFSTTimelineCardTopOffset);
        make.left.right.equalTo(self.contentView).inset(kFSTTimelineCardSideInset);
        make.height.equalTo(@(kFSTTimelineFastingCardHeight));
    }];
    [self.mealModuleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fastingModuleView.mas_bottom).offset(kFSTTimelineModuleSpacing);
        make.left.right.equalTo(self.fastingModuleView);
        make.bottom.equalTo(self.contentView).offset(-kFSTTimelineBottomPadding);
    }];
}

@end
