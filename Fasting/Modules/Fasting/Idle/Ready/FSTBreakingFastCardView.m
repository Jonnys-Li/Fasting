//
//  FSTBreakingFastCardView.m
//  Fasting
//
//  原生重建版的 Breaking fast 卡片：白底 56pt 高，圆角 12；
//  左侧食物插画 + 文字标题/副文案 + 右侧 chevron；整体响应点击。
//

#import "FSTBreakingFastCardView.h"
#import "FSTTheme.h"

@interface FSTBreakingFastCardView ()
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIImageView *chevronImageView;
@end

@implementation FSTBreakingFastCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = FSTRadiusS;
        self.layer.borderColor = [[UIColor fst_separator] CGColor];
        self.layer.borderWidth = 1;
        [self buildSubviews];

        UIControl *tapControl = [UIControl new];
        [tapControl addTarget:self action:@selector(handleTap) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tapControl];
        [tapControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)buildSubviews {
    UIImage *foodImage = [UIImage fst_originalImageNamed:@"breaking_fast_food"];
    self.iconImageView = [[UIImageView alloc] initWithImage:foodImage];
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.iconImageView];

    self.titleLabel = [UILabel fst_labelWithText:@"Breaking fast" font:FSTFontBold(16) color:[UIColor fst_textHeading]];
    self.subtitleLabel = [UILabel fst_labelWithText:@"Your fast is over;it's time to replenish..." font:FSTFontRegular(13) color:[UIColor fst_textSubtitle]];
    [self fst_addSubviews:@[self.titleLabel, self.subtitleLabel]];

    UIImageSymbolConfiguration *chevronSymbolConfiguration = [UIImageSymbolConfiguration configurationWithPointSize:13 weight:UIImageSymbolWeightSemibold];
    self.chevronImageView = [[UIImageView alloc] initWithImage:[[UIImage systemImageNamed:@"chevron.right" withConfiguration:chevronSymbolConfiguration]
                                                                 imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    self.chevronImageView.tintColor = [UIColor fst_eatingTimeGreen];
    [self addSubview:self.chevronImageView];

    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(16);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).offset(12);
        make.top.equalTo(self).offset(10);
    }];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(2);
    }];
    [self.chevronImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-16);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(10, 16));
    }];
}

- (void)setSubtitleText:(NSString *)subtitleText {
    _subtitleText = [subtitleText copy];
    self.subtitleLabel.text = subtitleText ?: @"";
}

- (void)handleTap {
    if (self.onTapped) self.onTapped();
}

@end
