//
//  FSTPlanConfirmRootView.m
//  Fasting
//

#import "FSTPlanConfirmRootView.h"
#import "FSTPlanPrepCardView.h"
#import "FSTPlanDetailPopoverView.h"
#import "FSTTheme.h"

@interface FSTPlanConfirmRootView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIImageView *chevronImageView;
@property (nonatomic, strong) UIControl *disclosureControl;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) FSTPlanPrepCardView *prepCardView;
@property (nonatomic, strong) FSTPlanDetailPopoverView *detailPopover;
@property (nonatomic, assign) BOOL detailExpanded;
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

    self.detailPopover = [[FSTPlanDetailPopoverView alloc] init];
    self.detailPopover.alpha = 0;  // 初始收起
    [self.contentView addSubview:self.detailPopover];
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

    // 「方案名 + chevron」整块做展开/收起详情卡的点击区：透明 UIControl 盖在上层，
    // titleLabel / chevron 默认 userInteractionEnabled = NO，触摸会落到本 control。
    self.disclosureControl = [[UIControl alloc] init];
    [self.disclosureControl addTarget:self action:@selector(handleToggleDetailTapped)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.disclosureControl];
    [self.disclosureControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel);
        make.right.equalTo(self.chevronImageView);
        make.top.equalTo(titleLabel).offset(-8);
        make.bottom.equalTo(titleLabel).offset(8);
    }];

    // 详情卡夹在标题与时间轴之间；收起时高度 0（被 popover 自身裁剪）。
    // 收起态间距 18 + 0 + 40 = 58，与改前 timeline 紧贴标题的视觉一致。
    [self.detailPopover mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(18);
        make.left.right.equalTo(self.contentView).inset(30);
        make.height.equalTo(@0);
    }];

    [timelineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.detailPopover.mas_bottom).offset(40);
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

- (void)handleToggleDetailTapped {
    self.detailExpanded = !self.detailExpanded;
    CGFloat targetHeight = self.detailExpanded ? self.detailPopover.expandedHeight : 0;
    [self.detailPopover mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(targetHeight));
    }];
    self.chevronImageView.image = [UIImage systemImageNamed:self.detailExpanded ? @"chevron.up" : @"chevron.down"];
    [UIView animateWithDuration:0.25 animations:^{
        self.detailPopover.alpha = self.detailExpanded ? 1.0 : 0.0;
        [self layoutIfNeeded];
    }];
}

#pragma mark - 数据推入

- (void)setPlanFastingHours:(NSInteger)fastingHours eatingHours:(NSInteger)eatingHours {
    [self.detailPopover setFastingHours:fastingHours eatingHours:eatingHours];
}

@end
