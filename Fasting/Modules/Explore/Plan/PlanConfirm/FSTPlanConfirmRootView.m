//
//  FSTPlanConfirmRootView.m
//  Fasting
//

#import "FSTPlanConfirmRootView.h"
#import "FSTPlanPrepCardView.h"
#import "FSTTheme.h"

@interface FSTPlanConfirmRootView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIImageView *chevronImageView;
@property (nonatomic, strong) UIControl *planSelectorControl;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) FSTPlanPrepCardView *prepCardView;
@end

@implementation FSTPlanConfirmRootView

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

    self.backButton = [UIButton fst_plainImageButtonWithImageNamed:@"nav_back" size:CGSizeMake(34, 34) tintColor:nil];
    [self.backButton addTarget:self action:@selector(handleBackTapped)
              forControlEvents:UIControlEventTouchUpInside];
    self.shareButton = [UIButton fst_plainImageButtonWithImageNamed:@"nav_share" size:CGSizeMake(34, 34) tintColor:nil];
    [self addSubview:self.backButton];
    [self addSubview:self.shareButton];

    self.chevronImageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.down"]];
    self.chevronImageView.tintColor = [UIColor fst_textSecondary];
    self.chevronImageView.backgroundColor = [UIColor fst_ringTrack];
    self.chevronImageView.layer.cornerRadius = FSTRadiusM;
    self.chevronImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.chevronImageView];

    self.startButton = [UIButton fst_pillButtonWithTitle:@"Start Fasting" style:FSTPillButtonStylePlanCTA];
    [self.startButton addTarget:self action:@selector(handleStartTapped)
              forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.startButton];

    self.prepCardView = [[FSTPlanPrepCardView alloc] init];
    [self.contentView addSubview:self.prepCardView];
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
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(30);
        make.left.equalTo(self).offset(20);
        make.size.mas_equalTo(CGSizeMake(34, 34));
    }];
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.right.equalTo(self).offset(-28);
        make.size.mas_equalTo(CGSizeMake(34, 34));
    }];
}

#pragma mark - Mount API

- (void)mountTitleLabel:(UILabel *)titleLabel timelineView:(UIView *)timelineView {
    [self.contentView addSubview:titleLabel];
    [self.contentView addSubview:timelineView];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(96);
        make.centerX.equalTo(self.contentView);
    }];
    [self.chevronImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(10);
        make.centerY.equalTo(titleLabel);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];

    // 「方案名 + chevron」整块做换方案点击区：透明 UIControl 盖在上层，
    // titleLabel / chevron 默认 userInteractionEnabled = NO，触摸会落到本 control。
    self.planSelectorControl = [[UIControl alloc] init];
    [self.planSelectorControl addTarget:self action:@selector(handleChangePlanTapped)
                       forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.planSelectorControl];
    [self.planSelectorControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel);
        make.right.equalTo(self.chevronImageView);
        make.top.equalTo(titleLabel).offset(-8);
        make.bottom.equalTo(titleLabel).offset(8);
    }];

    [timelineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(58);
        make.left.right.equalTo(self.contentView);
    }];
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(timelineView.mas_bottom).offset(54);
        make.left.right.equalTo(self.contentView).inset(46);
        make.height.equalTo(@60);
    }];
    [self.prepCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startButton.mas_bottom).offset(44);
        make.left.right.equalTo(self.contentView).inset(30);
        make.bottom.equalTo(self.contentView).offset(-120);
    }];
}

#pragma mark - 事件

- (void)handleBackTapped {
    if (self.onBackTapped) self.onBackTapped();
}

- (void)handleStartTapped {
    if (self.onStartTapped) self.onStartTapped();
}

- (void)handleChangePlanTapped {
    if (self.onChangePlanTapped) self.onChangePlanTapped();
}

@end
