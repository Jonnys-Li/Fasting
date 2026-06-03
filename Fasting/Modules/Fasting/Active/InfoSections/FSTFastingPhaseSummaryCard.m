//
//  FSTFastingPhaseSummaryCard.m
//  Fasting
//

#import "FSTFastingPhaseSummaryCard.h"
#import "FSTTheme.h"

@interface FSTFastingPhaseSummaryCard ()
@property (nonatomic, strong) UIImageView *stageIconView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *levelLabel;
@property (nonatomic, strong) UIImageView *chevronIconView;
@end

@implementation FSTFastingPhaseSummaryCard

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = FSTRadiusS;
        self.clipsToBounds = YES;
        [self setupSubviews];
        [self configureForBloodGlucoseStage];
    }
    return self;
}

- (void)setupSubviews {
    self.stageIconView = [[UIImageView alloc] init];
    self.stageIconView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.stageIconView];

    self.levelLabel = [[UILabel alloc] init];
    self.levelLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.levelLabel];

    self.titleLabel = [[UILabel alloc] init];
    [self addSubview:self.titleLabel];

    self.chevronIconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    self.chevronIconView.tintColor = [UIColor fst_eatingTimeGreen];
    self.chevronIconView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.chevronIconView];

    [self.stageIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.stageIconView.mas_right).offset(12);
        make.top.equalTo(self).offset(10);
        make.right.lessThanOrEqualTo(self.chevronIconView.mas_left).offset(-8);
    }];
    [self.levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(3);
        make.right.lessThanOrEqualTo(self.chevronIconView.mas_left).offset(-8);
    }];
    [self.chevronIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-13);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(14, 20));
    }];
}

#pragma mark - Public configuration

- (void)configureForBloodGlucoseStage {
    [self configureWithIcon:@"blood_glucose_stage"
                      title:@"Blood Glucose Rise"
                  titleFont:FSTFontBold(16)
                   subtitle:@"You’ll feel pretty normal during the fir..."
               subtitleFont:FSTFontBold(12)];
}

- (void)configureForAutophagyState {
    [self configureWithIcon:@"autophagy_stage"
                      title:@"Autophagy Starts!"
                  titleFont:FSTFontBold(15)
                   subtitle:@"You'll feel pretty normal during the fir..."
               subtitleFont:FSTFontMedium(12)];
}

#pragma mark - Private

- (void)configureWithIcon:(NSString *)iconName
                    title:(NSString *)title
                titleFont:(UIFont *)titleFont
                 subtitle:(NSString *)subtitle
             subtitleFont:(UIFont *)subtitleFont {
    self.stageIconView.image = [UIImage imageNamed:iconName];
    self.titleLabel.text = title;
    self.titleLabel.font = titleFont;
    self.titleLabel.textColor = [UIColor fst_textHeading];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    self.levelLabel.text = subtitle;
    self.levelLabel.font = subtitleFont;
    self.levelLabel.textColor = [UIColor fst_textSecondary];
    self.levelLabel.numberOfLines = 1;
    self.levelLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}

@end
