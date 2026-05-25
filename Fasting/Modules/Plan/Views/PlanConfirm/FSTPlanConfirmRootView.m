//
//  FSTPlanConfirmRootView.m
//  Fasting
//

#import "FSTPlanConfirmRootView.h"
#import "FSTPlanConfirmTimelineView.h"
#import "FSTPlanPrepCardView.h"
#import "UIButton+FST.h"
#import "FSTTheme.h"

@interface FSTPlanConfirmRootView ()
@property (nonatomic, strong, readwrite) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) FSTPlanConfirmTimelineView *timelineView;
@property (nonatomic, strong, readwrite) UIButton *startButton;
@property (nonatomic, strong, readwrite) FSTPlanPrepCardView *prepCardView;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIImageView *chevronImageView;
@end

@implementation FSTPlanConfirmRootView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor fst_pageBackground];
        [self buildScrollContainer];
        [self buildHeader];
        [self buildBody];
    }
    return self;
}

#pragma mark - 视图组装

- (void)buildScrollContainer {
    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
}

- (void)buildHeader {
    self.backButton = [UIButton fst_navPlainButtonWithImageNamed:@"nav_back" size:CGSizeMake(34, 34)];
    [self.backButton addTarget:self action:@selector(handleBackTapped) forControlEvents:UIControlEventTouchUpInside];
    self.shareButton = [UIButton fst_navPlainButtonWithImageNamed:@"nav_share" size:CGSizeMake(34, 34)];
    [self addSubview:self.backButton];
    [self addSubview:self.shareButton];

    self.titleLabel = [UILabel new];
    self.titleLabel.font = FSTFontBold(34);
    self.titleLabel.textColor = [UIColor fst_textPrimary];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.titleLabel];

    self.chevronImageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.down"]];
    self.chevronImageView.tintColor = [UIColor fst_textSecondary];
    self.chevronImageView.backgroundColor = [UIColor fst_ringTrack];
    self.chevronImageView.layer.cornerRadius = FSTRadiusM;
    self.chevronImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.chevronImageView];

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
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(96);
        make.centerX.equalTo(self.contentView);
    }];
    [self.chevronImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(10);
        make.centerY.equalTo(self.titleLabel);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
}

/// 时间轴 + 开始按钮 + 准备提示，依次纵向排列。
- (void)buildBody {
    self.timelineView = [FSTPlanConfirmTimelineView new];
    __weak typeof(self) weakSelf = self;
    self.timelineView.onEditStartTapped = ^{
        if (weakSelf.onEditStartTapped) weakSelf.onEditStartTapped();
    };

    self.startButton = [UIButton fst_greenPillButtonWithTitle:@"Start Fasting"];
    self.startButton.layer.cornerRadius = 30;
    self.startButton.layer.shadowColor = [UIColor fst_primaryGreen].CGColor;
    self.startButton.layer.shadowOpacity = 0.22;
    self.startButton.layer.shadowOffset = CGSizeMake(0, 10);
    self.startButton.layer.shadowRadius = 20;
    self.startButton.titleLabel.font = FSTFontBold(19);
    [self.startButton addTarget:self action:@selector(handleStartTapped) forControlEvents:UIControlEventTouchUpInside];

    self.prepCardView = [FSTPlanPrepCardView new];

    for (UIView *subview in @[self.timelineView, self.startButton, self.prepCardView]) {
        [self.contentView addSubview:subview];
    }

    [self.timelineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(58);
        make.left.right.equalTo(self.contentView);
    }];
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timelineView.mas_bottom).offset(54);
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

@end
