//
//  FSTFastingHistoryRootView.m
//  Fasting
//

#import "FSTFastingHistoryRootView.h"
#import "FSTFastingCardCell.h"
#import "UIButton+FST.h"
#import "UILabel+FSTStyle.h"
#import "FSTTheme.h"
#import "UIColor+FST.h"

static const CGFloat kFSTHistoryNavTopOffset  = 25;
static const CGFloat kFSTHistoryNavSideInset  = 22;
static const CGFloat kFSTHistoryNavButtonSize = 34;
static const CGFloat kFSTHistoryTodayTopGap   = 46;
static const CGFloat kFSTHistoryTableTopGap   = 22;
static const CGFloat kFSTHistoryRowHeight     = 264;

@interface FSTFastingHistoryRootView ()
@property (nonatomic, strong, readwrite) UITableView *tableView;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UILabel  *todayLabel;
@end

@implementation FSTFastingHistoryRootView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self buildNavBar];
        [self buildContent];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 视图组装

- (void)buildNavBar {
    self.backButton = [UIButton fst_navPlainButtonWithImageNamed:@"nav_back" size:CGSizeMake(kFSTHistoryNavButtonSize, kFSTHistoryNavButtonSize)];
    [self.backButton addTarget:self action:@selector(handleBackTapped) forControlEvents:UIControlEventTouchUpInside];

    self.titleLabel = [UILabel fst_subtitleLabelWithText:@"Timeline"];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;

    self.shareButton = [UIButton fst_navPlainButtonWithImageNamed:@"nav_share" size:CGSizeMake(kFSTHistoryNavButtonSize, kFSTHistoryNavButtonSize)];

    self.todayLabel = [UILabel new];
    self.todayLabel.text = @"Today";
    self.todayLabel.font = FSTFontBold(18);
    self.todayLabel.textColor = [UIColor fst_textSecondary];
    self.todayLabel.textAlignment = NSTextAlignmentCenter;

    for (UIView *v in @[self.backButton, self.titleLabel, self.shareButton, self.todayLabel]) {
        [self addSubview:v];
    }
}

- (void)buildContent {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight       = kFSTHistoryRowHeight;
    self.tableView.contentInset    = UIEdgeInsetsMake(0, 0, 24, 0);
    [self.tableView registerClass:[FSTFastingCardCell class] forCellReuseIdentifier:@"card"];
    [self addSubview:self.tableView];
}

#pragma mark - 约束

- (void)setupConstraints {
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(kFSTHistoryNavTopOffset);
        make.left.equalTo(self).offset(kFSTHistoryNavSideInset);
        make.size.mas_equalTo(CGSizeMake(kFSTHistoryNavButtonSize, kFSTHistoryNavButtonSize));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.centerX.equalTo(self);
    }];
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.right.equalTo(self).offset(-kFSTHistoryNavSideInset);
        make.size.mas_equalTo(CGSizeMake(kFSTHistoryNavButtonSize, kFSTHistoryNavButtonSize));
    }];
    [self.todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backButton.mas_bottom).offset(kFSTHistoryTodayTopGap);
        make.centerX.equalTo(self);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.todayLabel.mas_bottom).offset(kFSTHistoryTableTopGap);
        make.left.right.bottom.equalTo(self);
    }];
}

#pragma mark - 事件

- (void)handleBackTapped {
    if (self.onBackTapped) self.onBackTapped();
}

@end
