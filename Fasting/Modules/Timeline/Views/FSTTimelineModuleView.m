//
//  FSTTimelineModuleView.m
//  Fasting
//
//  时间轴页里的"模块卡"：通用容器，含图标 + 标题 + 右上角动作字 + 大数字摘要 + 副文本。
//

#import "FSTTimelineModuleView.h"
#import "FSTTheme.h"

@interface FSTTimelineModuleView ()
@property (nonatomic, strong) UILabel *summaryLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation FSTTimelineModuleView

- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)iconName actionTitle:(NSString *)actionTitle {
    if ((self = [super initWithFrame:CGRectZero])) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 22;
        self.layer.borderWidth = 1.6;
        self.layer.borderColor = [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.5].CGColor;
        [self buildSubviewsWithTitle:title iconName:iconName actionTitle:actionTitle];
    }
    return self;
}

- (void)buildSubviewsWithTitle:(NSString *)title iconName:(NSString *)iconName actionTitle:(NSString *)actionTitle {
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:iconName]];
    iconView.tintColor = [UIColor fst_primaryGreen];
    [self addSubview:iconView];

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = title;
    titleLabel.font = FSTFontBold(22);
    titleLabel.textColor = [UIColor fst_textPrimary];
    [self addSubview:titleLabel];

    UILabel *actionLabel = [UILabel new];
    actionLabel.text = actionTitle;
    actionLabel.font = FSTFontBold(16);
    actionLabel.textColor = [UIColor fst_primaryGreen];
    [self addSubview:actionLabel];

    self.summaryLabel = [UILabel new];
    self.summaryLabel.font = FSTFontBold(28);
    self.summaryLabel.textColor = [UIColor fst_textPrimary];
    self.summaryLabel.numberOfLines = 2;
    [self addSubview:self.summaryLabel];

    self.detailLabel = [UILabel new];
    self.detailLabel.font = FSTFontRegular(16);
    self.detailLabel.textColor = [UIColor fst_textSecondary];
    self.detailLabel.numberOfLines = 2;
    [self addSubview:self.detailLabel];

    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self).offset(24);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconView.mas_right).offset(12);
        make.centerY.equalTo(iconView);
    }];
    [actionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-24);
        make.centerY.equalTo(iconView);
    }];
    [self.summaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(28);
        make.left.right.equalTo(self).inset(24);
    }];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.summaryLabel.mas_bottom).offset(12);
        make.left.right.equalTo(self.summaryLabel);
    }];
}

/// 外部更新摘要文字和副文本。
- (void)updateSummary:(NSString *)summary detail:(NSString *)detail {
    self.summaryLabel.text = summary ?: @"";
    self.detailLabel.text = detail ?: @"";
}

@end
