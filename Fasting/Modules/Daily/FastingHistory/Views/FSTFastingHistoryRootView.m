//
//  FSTFastingHistoryRootView.m
//  Fasting
//

#import "FSTFastingHistoryRootView.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

// NavBar
static const CGFloat kNavTopOffset  = 25;
static const CGFloat kNavSideInset  = 22;
static const CGFloat kNavButtonSize = 34;

// 内容
static const CGFloat kTodayTopGap = 46;
static const CGFloat kTableTopGap = 22;

@interface FSTFastingHistoryRootView ()
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UILabel  *todayLabel;
@end

@implementation FSTFastingHistoryRootView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _todayText = @"Today";
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)setTodayText:(NSString *)todayText {
    _todayText = [todayText copy];
    self.todayLabel.text = _todayText ?: @"";
}

#pragma mark - 视图组装

- (void)setupSubviews {
    self.backButton = [UIButton fst_navPlainButtonWithImageNamed:@"nav_back" size:CGSizeMake(kNavButtonSize, kNavButtonSize)];
    [self.backButton addTarget:self action:@selector(handleBackTapped)
              forControlEvents:UIControlEventTouchUpInside];

    self.titleLabel = [UILabel fst_subtitleLabelWithText:@"Timeline"];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;

    self.shareButton = [UIButton fst_navPlainButtonWithImageNamed:@"nav_share" size:CGSizeMake(kNavButtonSize, kNavButtonSize)];

    self.todayLabel = [UILabel fst_labelWithText:self.todayText
                                            font:FSTFontBold(18)
                                           color:[UIColor fst_textSecondary]
                                       alignment:NSTextAlignmentCenter];

    for (UIView *v in @[self.backButton, self.titleLabel, self.shareButton, self.todayLabel]) {
        [self addSubview:v];
    }
}

- (void)setupConstraints {
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(kNavTopOffset);
        make.left.equalTo(self).offset(kNavSideInset);
        make.size.mas_equalTo(CGSizeMake(kNavButtonSize, kNavButtonSize));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.centerX.equalTo(self);
    }];
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.right.equalTo(self).offset(-kNavSideInset);
        make.size.mas_equalTo(CGSizeMake(kNavButtonSize, kNavButtonSize));
    }];
    [self.todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backButton.mas_bottom).offset(kTodayTopGap);
        make.centerX.equalTo(self);
    }];
}

#pragma mark - Mount API

- (void)mountTableView:(UITableView *)tableView {
    [self addSubview:tableView];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.todayLabel.mas_bottom).offset(kTableTopGap);
        make.left.right.bottom.equalTo(self);
    }];
}

#pragma mark - 事件

- (void)handleBackTapped {
    if (self.onBackTapped) self.onBackTapped();
}

@end
