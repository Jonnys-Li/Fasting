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

// Picker 顶部偏移（无 chip 略大，有 chip 略小）
static const CGFloat kPickerTopOffsetSimple  = 28.0;
static const CGFloat kPickerTopOffsetAligned = 22.0;

@interface FSTTimeEditorSheetContentView ()
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong, readwrite) UIDatePicker *datePicker;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong, readwrite, nullable) UIControl *alignControl;
@property (nonatomic, strong, nullable) UIImageView *alignIconView;
@property (nonatomic, strong, nullable) UILabel *alignLabel;
@end

@implementation FSTTimeEditorSheetContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 视图组装

- (void)setupSubviews {
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *closeImage = [UIImage fst_originalImageNamed:@"time_editor_close"];
    [self.closeButton setImage:closeImage forState:UIControlStateNormal];
    self.closeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.closeButton addTarget:self action:@selector(handleCloseTapped)
               forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];

    self.titleLabel = [UILabel fst_labelWithText:@""
                                            font:FSTFontAvenirDemiBold(24)
                                           color:[UIColor fst_textHeading]
                                       alignment:NSTextAlignmentCenter];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.76;
    [self addSubview:self.titleLabel];

    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    if (@available(iOS 13.4, *)) {
        self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    [self.datePicker addTarget:self action:@selector(handlePickerValueChanged)
              forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.datePicker];

    self.saveButton = [UIButton fst_pillButtonWithTitle:@"Save" style:FSTPillButtonStyleSheetSave];
    [self.saveButton addTarget:self action:@selector(handleSaveTapped)
              forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.saveButton];
}

- (void)setupConstraints {
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(34);
        make.right.equalTo(self).offset(-30);
        make.size.mas_equalTo(CGSizeMake(kCloseSize, kCloseSize));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(82);
        make.left.right.equalTo(self).inset(48);
        make.height.equalTo(@32);
    }];
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(kPickerTopOffsetSimple);
        make.left.right.equalTo(self).inset(26);
        make.height.equalTo(@(kPickerHeightSimple));
    }];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.datePicker.mas_bottom).offset(36);
        make.left.right.equalTo(self).inset(32);
        make.height.equalTo(@(FSTControlHeightStandard));
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-34);
    }];
}

#pragma mark - 属性同步

- (void)setTitleText:(NSString *)titleText {
    _titleText = [titleText copy];
    self.titleLabel.text = titleText;
}

- (void)setAlignChipText:(NSString *)alignChipText {
    _alignChipText = [alignChipText copy];
    if (alignChipText.length > 0) {
        if (!self.alignControl) {
            [self installAlignChip];
        }
        self.alignLabel.text = alignChipText;
    } else if (self.alignControl) {
        [self.alignControl removeFromSuperview];
        self.alignControl = nil;
        self.alignIconView = nil;
        self.alignLabel = nil;
        [self.datePicker mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(kPickerTopOffsetSimple);
            make.left.right.equalTo(self).inset(26);
            make.height.equalTo(@(kPickerHeightSimple));
        }];
    }
}

- (void)installAlignChip {
    UIControl *control = [[UIControl alloc] init];
    control.layer.cornerRadius = FSTRadiusChip;
    [control addTarget:self action:@selector(handleAlignToggled)
      forControlEvents:UIControlEventTouchUpInside];

    self.alignIconView = [[UIImageView alloc] initWithImage:
        [UIImage fst_originalImageNamed:@"time_align_clock"]];
    self.alignIconView.contentMode = UIViewContentModeScaleAspectFit;

    self.alignLabel = [UILabel fst_labelWithText:@""
                                            font:FSTFontAvenirDemiBold(16)
                                           color:[UIColor fst_textPrimary]
                                       alignment:NSTextAlignmentCenter];

    [control fst_addSubviews:@[self.alignIconView, self.alignLabel]];
    [self addSubview:control];
    self.alignControl = control;

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
    [self.alignControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(20);
        make.centerX.equalTo(self);
        make.height.equalTo(@34);
    }];
    [self.datePicker mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.alignControl.mas_bottom).offset(kPickerTopOffsetAligned);
        make.left.right.equalTo(self).inset(26);
        make.height.equalTo(@(kPickerHeightAligned));
    }];
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
