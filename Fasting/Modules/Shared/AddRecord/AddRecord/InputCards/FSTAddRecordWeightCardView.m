//
//  FSTAddRecordWeightCardView.m
//  Fasting
//

#import "FSTAddRecordWeightCardView.h"
#import "FSTFastingRecord.h"
#import "FSTTheme.h"

@interface FSTAddRecordWeightCardView ()
@property (nonatomic, strong) UILabel *weightValueLabel;
@property (nonatomic, strong) UILabel *initialLabel;
@property (nonatomic, strong) UILabel *targetLabel;
@property (nonatomic, strong) UISwitch *healthSwitch;
@end

@implementation FSTAddRecordWeightCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _initialWeightKg = FSTDefaultInitialWeightKg;
        _targetWeightKg = FSTDefaultTargetWeightKg;
        [self setupSubviews];
        [self refreshValues];
    }
    return self;
}

- (void)setWeightKg:(CGFloat)weightKg { _weightKg = weightKg; [self refreshValues]; }
- (void)setInitialWeightKg:(CGFloat)initialWeightKg { _initialWeightKg = initialWeightKg; [self refreshValues]; }
- (void)setTargetWeightKg:(CGFloat)targetWeightKg { _targetWeightKg = targetWeightKg; [self refreshValues]; }
- (void)setAppleHealthEnabled:(BOOL)enabled { _appleHealthEnabled = enabled; self.healthSwitch.on = enabled; }

/// 构建：标题/今天/数值+编辑/进度条/初始+目标/Apple Health 行。
- (void)setupSubviews {
    UILabel *titleLabel = [UILabel fst_labelWithText:@"Current weight" font:FSTFontSubhead() color:[UIColor fst_textPrimary]];
    UILabel *todayLabel = [self mutedLabelWithText:@"Today"];

    self.weightValueLabel = [UILabel fst_labelWithText:nil font:FSTFontBold(28) color:[UIColor fst_primaryGreen] alignment:NSTextAlignmentCenter];

    UIButton *editButton = [UIButton fst_plainImageButtonWithImageNamed:@"edit_pencil"
                                                                   size:CGSizeMake(40, 40)
                                                              tintColor:nil];
    [editButton addTarget:self action:@selector(emitEditTapped) forControlEvents:UIControlEventTouchUpInside];

    UIView *progressBar = [[UIView alloc] init];
    progressBar.backgroundColor = [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.18];
    progressBar.layer.cornerRadius = 5;

    self.initialLabel = [self mutedLabelWithText:@""];
    self.targetLabel = [self mutedLabelWithText:@""];

    UIView *healthRowView = [[UIView alloc] init];
    healthRowView.backgroundColor = [UIColor fst_inputBackground];
    healthRowView.layer.cornerRadius = FSTRadiusM;

    UILabel *healthTitleLabel = [UILabel fst_labelWithText:@"▣  Apple Health" font:FSTFontBold(18) color:[UIColor fst_textPrimary]];

    self.healthSwitch = [[UISwitch alloc] init];
    [self.healthSwitch addTarget:self action:@selector(handleHealthSwitchChanged:) forControlEvents:UIControlEventValueChanged];

    [self fst_addSubviews:@[titleLabel, todayLabel, self.weightValueLabel, editButton, progressBar,
                            self.initialLabel, self.targetLabel, healthRowView]];
    [healthRowView fst_addSubviews:@[healthTitleLabel, self.healthSwitch]];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(28);
        make.centerX.equalTo(self);
    }];
    [todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(8);
        make.centerX.equalTo(self);
    }];
    [self.weightValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(todayLabel.mas_bottom).offset(18);
        make.centerX.equalTo(self);
    }];
    [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.weightValueLabel.mas_right).offset(18);
        make.centerY.equalTo(self.weightValueLabel);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    [progressBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.weightValueLabel.mas_bottom).offset(24);
        make.left.right.equalTo(self).inset(22);
        make.height.equalTo(@10);
    }];
    [self.initialLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(progressBar.mas_bottom).offset(18);
        make.left.equalTo(progressBar);
    }];
    [self.targetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.initialLabel);
        make.right.equalTo(progressBar);
    }];
    [healthRowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.initialLabel.mas_bottom).offset(26);
        make.left.right.equalTo(progressBar);
        make.height.equalTo(@62);
        make.bottom.equalTo(self).offset(-28);
    }];
    [healthTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(healthRowView).offset(20);
        make.centerY.equalTo(healthRowView);
    }];
    [self.healthSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(healthRowView).offset(-20);
        make.centerY.equalTo(healthRowView);
    }];
}

- (UILabel *)mutedLabelWithText:(NSString *)text {
    return [UILabel fst_labelWithText:text font:FSTFontBold(15) color:[UIColor fst_textSecondary]];
}

- (void)setUsePounds:(BOOL)usePounds { _usePounds = usePounds; [self refreshValues]; }

- (void)refreshValues {
    BOOL useLb = self.usePounds;
    NSString *unit = useLb ? @"lb" : @"kg";
    CGFloat factor = useLb ? FSTPoundsPerKilogram : 1.0;
    self.weightValueLabel.text = [NSString stringWithFormat:@"%.1f %@", self.weightKg * factor, unit];
    self.initialLabel.text = [NSString stringWithFormat:@"Initial: %.1f %@", self.initialWeightKg * factor, unit];
    self.targetLabel.text = [NSString stringWithFormat:@"Target: %.1f %@", self.targetWeightKg * factor, unit];
}

- (void)emitEditTapped { if (self.onEditTapped) self.onEditTapped(); }

- (void)handleHealthSwitchChanged:(UISwitch *)healthSwitch {
    _appleHealthEnabled = healthSwitch.isOn;
    if (self.onHealthChanged) self.onHealthChanged(healthSwitch.isOn);
}

@end
