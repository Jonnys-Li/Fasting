//
//  FSTWeightUnitToggleView.m
//  Fasting
//

#import "FSTWeightUnitToggleView.h"
#import "FSTTheme.h"

@interface FSTWeightUnitToggleView ()
@property (nonatomic, strong) UIView *selectorView;
@property (nonatomic, strong) UILabel *kgLabel;
@property (nonatomic, strong) UILabel *lbLabel;
@property (nonatomic, strong) MASConstraint *selectorLeadingConstraint;
@end

@implementation FSTWeightUnitToggleView

- (instancetype)init {
    if ((self = [super init])) {
        _unit = FSTWeightUnitKg;
        self.backgroundColor = [UIColor fst_ringTrack];
        self.layer.cornerRadius = 20;
        [self buildSubviews];
        [self refreshSelected:NO];
    }
    return self;
}

- (void)setUnit:(FSTWeightUnit)unit {
    if (_unit == unit) return;
    _unit = unit;
    [self refreshSelected:YES];
}

/// 构建：白滑块 + kg/lb 两个点击区。
- (void)buildSubviews {
    self.selectorView = [UIView new];
    self.selectorView.backgroundColor = [UIColor fst_textPrimary];
    self.selectorView.layer.cornerRadius = 17;
    [self addSubview:self.selectorView];

    UIControl *kgChipControl = [UIControl new];
    [kgChipControl addTarget:self action:@selector(handleKgChipTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:kgChipControl];

    UIControl *lbChipControl = [UIControl new];
    [lbChipControl addTarget:self action:@selector(handleLbChipTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lbChipControl];

    self.kgLabel = [self chipLabelWithText:@"kg"];
    self.lbLabel = [self chipLabelWithText:@"lb"];
    [kgChipControl addSubview:self.kgLabel];
    [lbChipControl addSubview:self.lbLabel];

    [self.selectorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(3);
        make.bottom.equalTo(self).offset(-3);
        make.width.equalTo(@77);
        self.selectorLeadingConstraint = make.left.equalTo(self).offset(3);
    }];
    [kgChipControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.5);
    }];
    [lbChipControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.5);
    }];
    [self.kgLabel mas_makeConstraints:^(MASConstraintMaker *make) { make.center.equalTo(kgChipControl); }];
    [self.lbLabel mas_makeConstraints:^(MASConstraintMaker *make) { make.center.equalTo(lbChipControl); }];
}

- (UILabel *)chipLabelWithText:(NSString *)text {
    UILabel *chipLabel = [UILabel new];
    chipLabel.text = text;
    chipLabel.font = FSTFontBold(16);
    chipLabel.textAlignment = NSTextAlignmentCenter;
    chipLabel.userInteractionEnabled = NO;
    return chipLabel;
}

/// 同步显示状态：滑块位置 + 字色。
- (void)refreshSelected:(BOOL)animated {
    BOOL isKgActive = (self.unit == FSTWeightUnitKg);
    self.selectorLeadingConstraint.offset = isKgActive ? 3 : 80;
    self.kgLabel.textColor = isKgActive ? [UIColor whiteColor] : [UIColor fst_textPrimary];
    self.lbLabel.textColor = isKgActive ? [UIColor fst_textPrimary] : [UIColor whiteColor];
    if (animated) {
        [UIView animateWithDuration:0.22 animations:^{ [self layoutIfNeeded]; }];
    }
}

- (void)handleKgChipTapped {
    if (self.unit == FSTWeightUnitKg) return;
    self.unit = FSTWeightUnitKg;
    if (self.onUnitChanged) self.onUnitChanged(FSTWeightUnitKg);
}

- (void)handleLbChipTapped {
    if (self.unit == FSTWeightUnitLb) return;
    self.unit = FSTWeightUnitLb;
    if (self.onUnitChanged) self.onUnitChanged(FSTWeightUnitLb);
}

@end
