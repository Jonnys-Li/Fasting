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

- (instancetype)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 12;
        self.clipsToBounds = YES;
        [self buildSubviews];
        [self configureForBloodGlucoseStage];
    }
    return self;
}

- (void)buildSubviews {
    _stageIconView = [UIImageView new];
    _stageIconView.contentMode = UIViewContentModeScaleAspectFit;
    _stageIconView.userInteractionEnabled = NO;
    [self addSubview:_stageIconView];

    _levelLabel = [UILabel new];
    _levelLabel.textAlignment = NSTextAlignmentLeft;
    _levelLabel.userInteractionEnabled = NO;
    [self addSubview:_levelLabel];

    _titleLabel = [UILabel new];
    _titleLabel.userInteractionEnabled = NO;
    [self addSubview:_titleLabel];

    _chevronIconView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
    _chevronIconView.tintColor = [UIColor fst_eatingTimeGreen];
    _chevronIconView.contentMode = UIViewContentModeScaleAspectFit;
    _chevronIconView.userInteractionEnabled = NO;
    [self addSubview:_chevronIconView];

    [_stageIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.stageIconView.mas_right).offset(12);
        make.top.equalTo(self).offset(10);
        make.right.lessThanOrEqualTo(self.chevronIconView.mas_left).offset(-8);
    }];
    [_levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(3);
        make.right.lessThanOrEqualTo(self.chevronIconView.mas_left).offset(-8);
    }];
    [_chevronIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-13);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(14, 20));
    }];
}

#pragma mark - Public configuration

- (void)configureForBloodGlucoseStage {
    self.stageIconView.image = [UIImage imageNamed:@"blood_glucose_stage"];
    self.titleLabel.text = @"血糖升高";
    self.titleLabel.font = FSTFontBold(16);
    self.titleLabel.textColor = [UIColor fst_colorWithHex:0x272A33];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    self.levelLabel.text = @"Lv.1";
    self.levelLabel.font = FSTFontBold(12);
    self.levelLabel.textColor = [UIColor fst_textSecondary];
    self.levelLabel.numberOfLines = 1;
    self.levelLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (void)configureForAutophagyState {
    self.stageIconView.image = [UIImage imageNamed:@"autophagy_stage"];
    self.titleLabel.text = @"Autophagy Starts!";
    self.titleLabel.font = FSTFontBold(15);
    self.titleLabel.textColor = [UIColor fst_colorWithHex:0x272A33];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    self.levelLabel.text = @"You'll feel pretty normal during the fir...";
    self.levelLabel.font = FSTFontMedium(12);
    self.levelLabel.textColor = [UIColor fst_textSecondary];
    self.levelLabel.numberOfLines = 1;
    self.levelLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}

@end
