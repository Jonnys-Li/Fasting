//
//  FSTWeightInputCardView.m
//  Fasting
//

#import "FSTWeightInputCardView.h"
#import "FSTWeightUnitToggleView.h"
#import "FSTTheme.h"

@interface FSTWeightInputCardView () <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *unitSuffixLabel;
@property (nonatomic, strong) UITextField *hiddenTextField;
@property (nonatomic, strong) FSTWeightUnitToggleView *unitToggleView;
@end

@implementation FSTWeightInputCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _weightKg = 70.0;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = FSTRadiusL;
        [self setupSubviews];
        [self refreshValue];
    }
    return self;
}

- (void)setWeightKg:(CGFloat)weightKg {
    _weightKg = weightKg;
    [self refreshValue];
}

- (void)beginEditing {
    [self.hiddenTextField becomeFirstResponder];
}

#pragma mark - 构建 UI

/// 一次性创建并约束卡片里所有视图。
- (void)setupSubviews {
    UIButton *closeButton = [self buildCloseButton];
    UILabel *titleLabel = [UILabel fst_subtitleLabelWithText:@"Weight"];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    UILabel *subtitleLabel = [UILabel fst_bodyLabelWithText:FSTFormatRelativeDay([NSDate date])];
    subtitleLabel.textAlignment = NSTextAlignmentCenter;

    UIView *valueBoxView = [self buildValueBox];
    UIView *topLeftDotView = [self decoratorDot];
    UIView *bottomRightDotView = [self decoratorDot];
    UIView *underlineView = [UIView fst_separatorLineWithColor:[UIColor fst_separator]];
    UIControl *valueTapControl = [self buildValueTapZone];

    self.unitToggleView = [[FSTWeightUnitToggleView alloc] init];
    self.unitToggleView.unit = self.initialUnit;
    __weak typeof(self) weakSelf = self;
    self.unitToggleView.onUnitChanged = ^(FSTWeightUnit unit) {
        [weakSelf refreshValue];
    };

    UIButton *saveButton = [UIButton fst_pillButtonWithTitle:@"Save" style:FSTPillButtonStylePrimaryGreen];
    [saveButton addTarget:self action:@selector(handleSaveTapped) forControlEvents:UIControlEventTouchUpInside];

    [self fst_addSubviews:@[closeButton, titleLabel, subtitleLabel, valueBoxView, topLeftDotView, bottomRightDotView, self.valueLabel,
                            self.unitSuffixLabel, underlineView, valueTapControl, self.hiddenTextField,
                            self.unitToggleView, saveButton]];

    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self).inset(18);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(24);
        make.centerX.equalTo(self);
    }];
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(6);
        make.centerX.equalTo(self);
    }];
    [valueBoxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(-26);
        make.top.equalTo(subtitleLabel.mas_bottom).offset(18);
        make.size.mas_equalTo(CGSizeMake(172, 78));
    }];
    [topLeftDotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(valueBoxView.mas_left);
        make.centerY.equalTo(valueBoxView.mas_top);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
    [bottomRightDotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(valueBoxView.mas_right);
        make.centerY.equalTo(valueBoxView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) { make.center.equalTo(valueBoxView); }];
    [self.unitSuffixLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(valueBoxView.mas_right).offset(10);
        make.bottom.equalTo(valueBoxView).offset(-12);
    }];
    [underlineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(valueBoxView.mas_bottom).offset(8);
        make.left.equalTo(valueBoxView).offset(8);
        make.right.equalTo(valueBoxView).offset(-8);
        make.height.equalTo(@1);
    }];
    [valueTapControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(valueBoxView);
        make.bottom.equalTo(underlineView);
        make.right.equalTo(self.unitSuffixLabel);
    }];
    [self.hiddenTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(valueBoxView);
        make.size.mas_equalTo(CGSizeMake(1, 1));
    }];
    [self.unitToggleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(underlineView.mas_bottom).offset(30);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(160, 40));
    }];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.unitToggleView.mas_bottom).offset(30);
        make.left.right.equalTo(self).inset(24);
        make.bottom.equalTo(self).offset(-22);
        make.height.equalTo(@52);
    }];
}

/// 右上角圆形 X 关闭按钮
- (UIButton *)buildCloseButton {
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.backgroundColor = [UIColor fst_ringTrack];
    closeButton.layer.cornerRadius = FSTRadiusM;
    UIImageSymbolConfiguration *symbolConfiguration = [UIImageSymbolConfiguration configurationWithPointSize:12 weight:UIImageSymbolWeightBold];
    [closeButton setImage:[[UIImage systemImageNamed:@"xmark"] imageWithConfiguration:symbolConfiguration] forState:UIControlStateNormal];
    closeButton.tintColor = [UIColor fst_textSecondary];
    [closeButton addTarget:self action:@selector(handleCloseTapped) forControlEvents:UIControlEventTouchUpInside];
    return closeButton;
}

/// 半透明绿色盒子，内含放大数字和单位后缀
- (UIView *)buildValueBox {
    UIView *valueBoxView = [[UIView alloc] init];
    [valueBoxView fst_applyTintedBoxWithColor:[UIColor fst_primaryGreen] alpha:0.22 radius:8];
    self.valueLabel = [UILabel fst_labelWithText:nil
                                            font:[UIFont monospacedDigitSystemFontOfSize:54 weight:UIFontWeightBold]
                                           color:[UIColor fst_textPrimary]
                                       alignment:NSTextAlignmentCenter];
    self.unitSuffixLabel = [UILabel fst_labelWithText:nil font:FSTFontSubhead() color:[UIColor fst_textSecondary]];
    return valueBoxView;
}

/// 盒子四角的小绿点装饰
- (UIView *)decoratorDot {
    UIView *dotView = [[UIView alloc] init];
    dotView.backgroundColor = [UIColor fst_primaryGreen];
    dotView.layer.cornerRadius = 6;
    return dotView;
}

/// 透明点击区 + 隐藏文本框：点击数字呼出键盘
- (UIControl *)buildValueTapZone {
    UIControl *valueTapControl = [[UIControl alloc] init];
    valueTapControl.backgroundColor = [UIColor clearColor];
    [valueTapControl addTarget:self action:@selector(handleValueTapped) forControlEvents:UIControlEventTouchUpInside];

    self.hiddenTextField = [[UITextField alloc] init];
    self.hiddenTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.hiddenTextField.alpha = 0.0;
    self.hiddenTextField.delegate = self;
    [self.hiddenTextField addTarget:self action:@selector(handleTextChanged:) forControlEvents:UIControlEventEditingChanged];
    return valueTapControl;
}

#pragma mark - 刷新与事件

/// 根据当前 weightKg 和 unit 刷新数字与单位。
- (void)refreshValue {
    BOOL isKgUnit = (self.unitToggleView.unit == FSTWeightUnitKg);
    CGFloat displayValue = isKgUnit ? self.weightKg : self.weightKg * FSTPoundsPerKilogram;
    self.valueLabel.text = [NSString stringWithFormat:@"%.1f", displayValue];
    self.unitSuffixLabel.text = isKgUnit ? @"kg" : @"lb";
    self.hiddenTextField.text = [NSString stringWithFormat:@"%.1f", displayValue];
}

- (void)handleValueTapped { [self.hiddenTextField becomeFirstResponder]; }

- (void)handleTextChanged:(UITextField *)textField {
    CGFloat enteredValue = (textField.text ?: @"").doubleValue;
    if (enteredValue <= 0) { self.valueLabel.text = @"0.0"; return; }
    BOOL isKgMode = (self.unitToggleView.unit == FSTWeightUnitKg);
    CGFloat normalizedKg = isKgMode ? enteredValue : enteredValue / FSTPoundsPerKilogram;
    _weightKg = normalizedKg;
    self.valueLabel.text = [NSString stringWithFormat:@"%.1f", isKgMode ? normalizedKg : normalizedKg * FSTPoundsPerKilogram];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length == 0) return YES;
    NSString *resultingText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([resultingText componentsSeparatedByString:@"."].count > 2) return NO;
    NSCharacterSet *allowedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    if ([string rangeOfCharacterFromSet:allowedCharacterSet.invertedSet].location != NSNotFound) return NO;
    NSRange dotRange = [resultingText rangeOfString:@"."];
    if (dotRange.location != NSNotFound && resultingText.length - dotRange.location > 2) return NO;
    return YES;
}

- (void)handleCloseTapped { if (self.onClose) self.onClose(); }

- (FSTWeightUnit)currentUnit {
    return self.unitToggleView.unit;
}

- (void)handleSaveTapped {
    if (self.onSave) self.onSave(self.weightKg);
}

@end
