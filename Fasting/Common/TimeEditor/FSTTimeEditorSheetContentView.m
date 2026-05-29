//
//  FSTTimeEditorSheetContentView.m
//  Fasting
//

#import "FSTTimeEditorSheetContentView.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

// Close button
static const CGFloat kCloseSize = 34.0;

// DatePicker（两种高度：纯日期 vs 带 align chip）
static const CGFloat kPickerHeightSimple  = 245.0;
static const CGFloat kPickerHeightAligned = 305.0;

// Save button

@interface FSTTimeEditorSheetContentView ()
@property (nonatomic, strong, readwrite) UIDatePicker *datePicker;
@property (nonatomic, strong, readwrite, nullable) UIControl *alignControl;
@property (nonatomic, strong, nullable) UIImageView *alignIconView;
@property (nonatomic, strong, nullable) UILabel *alignLabel;
@end

@implementation FSTTimeEditorSheetContentView

#pragma mark - 初始化

- (instancetype)initWithTitle:(NSString *)title
                alignChipText:(nullable NSString *)alignChipText {
    if ((self = [super initWithFrame:CGRectZero])) {
        [self buildSubviewsWithTitle:title alignChipText:alignChipText];
    }
    return self;
}

#pragma mark - 视图组装

- (void)buildSubviewsWithTitle:(NSString *)title
                 alignChipText:(nullable NSString *)alignChipText {

    // — Close button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *closeImage = [UIImage fst_originalImageNamed:@"time_editor_close"];
    [closeButton setImage:closeImage forState:UIControlStateNormal];
    closeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [closeButton addTarget:self action:@selector(handleCloseTapped)
          forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];

    // — Title label
    UILabel *titleLabel = [UILabel fst_labelWithText:title
                                                font:FSTFontAvenirDemiBold(24)
                                               color:[UIColor fst_textHeading]
                                           alignment:NSTextAlignmentCenter];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.76;
    [self addSubview:titleLabel];

    // — Date picker
    self.datePicker = [UIDatePicker new];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    if (@available(iOS 13.4, *)) {
        self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    [self.datePicker addTarget:self action:@selector(handlePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.datePicker];

    // — Optional align chip
    BOOL hasAlignChip = alignChipText.length > 0;
    UIView *pickerTopAnchor = titleLabel;
    CGFloat pickerTopOffset = hasAlignChip ? 22.0 : 28.0;
    CGFloat pickerHeight = hasAlignChip ? kPickerHeightAligned
                                        : kPickerHeightSimple;
    if (hasAlignChip) {
        self.alignControl = [self buildAlignControlWithText:alignChipText];
        [self addSubview:self.alignControl];
        pickerTopAnchor = self.alignControl;
    }

    // — Save button
    UIButton *saveButton = [UIButton fst_pillButtonWithTitle:@"Save" style:FSTPillButtonStyleSheetSave];
    [saveButton addTarget:self action:@selector(handleSaveTapped)
         forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:saveButton];

    // — Constraints
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(34);
        make.right.equalTo(self).offset(-30);
        make.size.mas_equalTo(CGSizeMake(kCloseSize, kCloseSize));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(82);
        make.left.right.equalTo(self).inset(48);
        make.height.equalTo(@32);
    }];
    if (self.alignControl) {
        [self.alignControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(20);
            make.centerX.equalTo(self);
            make.height.equalTo(@34);
        }];
    }
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pickerTopAnchor.mas_bottom).offset(pickerTopOffset);
        make.left.right.equalTo(self).inset(26);
        make.height.equalTo(@(pickerHeight));
    }];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.datePicker.mas_bottom).offset(36);
        make.left.right.equalTo(self).inset(32);
        make.height.equalTo(@(FSTControlHeightStandard));
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-34);
    }];
}

- (UIControl *)buildAlignControlWithText:(NSString *)text {
    UIControl *control = [UIControl new];
    control.layer.cornerRadius = FSTRadiusChip;
    [control addTarget:self action:@selector(handleAlignToggled)
      forControlEvents:UIControlEventTouchUpInside];

    self.alignIconView = [[UIImageView alloc] initWithImage:
        [UIImage fst_originalImageNamed:@"time_align_clock"]];
    self.alignIconView.contentMode = UIViewContentModeScaleAspectFit;

    self.alignLabel = [UILabel fst_labelWithText:text
                                            font:FSTFontAvenirDemiBold(16)
                                           color:[UIColor fst_textPrimary]
                                       alignment:NSTextAlignmentCenter];

    [control fst_addSubviews:@[self.alignIconView, self.alignLabel]];

    [self.alignIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(control).offset(14);
        make.centerY.equalTo(control);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    [self.alignLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.alignIconView.mas_right).offset(8);
        make.right.equalTo(control).offset(-14);
        make.centerY.equalTo(control);
    }];
    return control;
}

#pragma mark - 公开方法

/// 启用态：用绿色高亮系（fst_alignSelectedGreen 背景 + fst_alignSelectedText 文字）告诉用户可点。
/// 禁用态：用灰色（fst_alignUnselectedGray 背景 + fst_textSecondary 文字）表示当前不可点（已 applied 或 EndFast 未改 picker）。
- (void)setAlignEnabled:(BOOL)enabled {
    if (!self.alignControl) return;
    UIColor *backgroundColor = enabled
        ? [[UIColor fst_alignSelectedGreen] colorWithAlphaComponent:0.15]
        : [[UIColor fst_alignUnselectedGray] colorWithAlphaComponent:0.30];
    UIColor *textColor = enabled
        ? [UIColor fst_alignSelectedText]
        : [UIColor fst_textSecondary];
    self.alignControl.backgroundColor = backgroundColor;
    self.alignLabel.textColor = textColor;
    self.alignIconView.tintColor = textColor;
    // chip 视觉「禁用」但仍保留点击响应 —— 由 VC 端 isAlignControlEnabled 决定要不要忽略点击，
    // 这样不破坏 UIControl.enabled 的语义，避免影响其他子状态。
    self.alignControl.userInteractionEnabled = enabled;
}

#pragma mark - 事件

- (void)handleCloseTapped {
    if (self.onCloseTapped) self.onCloseTapped();
}

- (void)handleSaveTapped {
    if (self.onSaveTapped) self.onSaveTapped();
}

- (void)handleAlignToggled {
    if (self.onAlignToggled) self.onAlignToggled();
}

- (void)handlePickerValueChanged {
    if (self.onPickerValueChanged) self.onPickerValueChanged();
}

@end
