//
//  FSTTimeEditorSheetViewController.m
//  Fasting
//

#import "FSTTimeEditorSheetViewController.h"
#import "FSTTheme.h"

static const CGFloat kFSTTimeEditorSheetCornerRadius = 22.0;
static const CGFloat kFSTTimeEditorCloseSize = 34.0;
static const CGFloat kFSTTimeEditorPickerHeightSimple = 245.0;
static const CGFloat kFSTTimeEditorPickerHeightAligned = 305.0;
static const CGFloat kFSTTimeEditorSaveHeight = 48.0;

@interface FSTTimeEditorSheetViewController ()
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, strong) NSDate *initialDate;
@property (nonatomic, strong, nullable) NSDate *minimumDate;
@property (nonatomic, strong, nullable) NSDate *maximumDate;
@property (nonatomic, copy, nullable) NSString *alignChipText;
@property (nonatomic, strong, nullable) NSDate *alignedDate;
@property (nonatomic, assign) BOOL alignSelected;
@property (nonatomic, copy) FSTTimeEditorCommitHandler onCommit;

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong, nullable) UIControl *alignControl;
@property (nonatomic, strong, nullable) UIImageView *alignIconView;
@property (nonatomic, strong, nullable) UILabel *alignLabel;
@end

@implementation FSTTimeEditorSheetViewController

- (instancetype)initWithTitle:(NSString *)title
                  initialDate:(NSDate *)initialDate
                  minimumDate:(nullable NSDate *)minimumDate
                  maximumDate:(nullable NSDate *)maximumDate
                alignChipText:(nullable NSString *)alignChipText
                  alignedDate:(nullable NSDate *)alignedDate
              initiallyAligned:(BOOL)initiallyAligned
                      onCommit:(FSTTimeEditorCommitHandler)onCommit {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _titleText = [title copy];
        _initialDate = initialDate ?: [NSDate date];
        _minimumDate = minimumDate;
        _maximumDate = maximumDate;
        _alignChipText = [alignChipText copy];
        _alignedDate = alignedDate;
        _alignSelected = initiallyAligned && alignChipText.length > 0 && alignedDate != nil;
        _onCommit = [onCommit copy];
        self.containerStyle = FSTBaseModalContainerStyleBottomSheet;
        self.backdropAlpha = 0.42;
        self.containerCornerRadius = kFSTTimeEditorSheetCornerRadius;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildSubviews];
    [self refreshAlignState];
}

#pragma mark - Layout

- (void)buildSubviews {
    UIView *sheetView = self.cardContainer;

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *closeImage = [[UIImage imageNamed:@"time_editor_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [closeButton setImage:closeImage forState:UIControlStateNormal];
    closeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [closeButton addTarget:self action:@selector(handleCloseTapped) forControlEvents:UIControlEventTouchUpInside];
    [sheetView addSubview:closeButton];

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = self.titleText;
    titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:24] ?: FSTFontBold(24);
    titleLabel.textColor = [UIColor fst_colorWithHex:0x272A33];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.76;
    [sheetView addSubview:titleLabel];

    self.datePicker = [UIDatePicker new];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.date = [self clampedDate:self.alignSelected && self.alignedDate ? self.alignedDate : self.initialDate];
    self.datePicker.minimumDate = self.minimumDate;
    self.datePicker.maximumDate = self.maximumDate;
    if (@available(iOS 13.4, *)) {
        self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    [sheetView addSubview:self.datePicker];

    BOOL hasAlignChip = self.alignChipText.length > 0;
    UIView *pickerTopAnchor = titleLabel;
    CGFloat pickerTopOffset = hasAlignChip ? 22.0 : 28.0;
    CGFloat pickerHeight = hasAlignChip ? kFSTTimeEditorPickerHeightAligned : kFSTTimeEditorPickerHeightSimple;
    if (hasAlignChip) {
        self.alignControl = [self buildAlignControl];
        [sheetView addSubview:self.alignControl];
        pickerTopAnchor = self.alignControl;
    }

    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.backgroundColor = [UIColor fst_eatingTimeGreen];
    saveButton.layer.cornerRadius = kFSTTimeEditorSaveHeight / 2.0;
    saveButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:20] ?: FSTFontBold(20);
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(handleSaveTapped) forControlEvents:UIControlEventTouchUpInside];
    [sheetView addSubview:saveButton];

    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sheetView).offset(34);
        make.right.equalTo(sheetView).offset(-30);
        make.size.mas_equalTo(CGSizeMake(kFSTTimeEditorCloseSize, kFSTTimeEditorCloseSize));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(sheetView).offset(82);
        make.left.right.equalTo(sheetView).inset(48);
        make.height.equalTo(@32);
    }];
    if (self.alignControl) {
        [self.alignControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel.mas_bottom).offset(20);
            make.centerX.equalTo(sheetView);
            make.height.equalTo(@34);
        }];
    }
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(pickerTopAnchor.mas_bottom).offset(pickerTopOffset);
        make.left.right.equalTo(sheetView).inset(26);
        make.height.equalTo(@(pickerHeight));
    }];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.datePicker.mas_bottom).offset(36);
        make.left.right.equalTo(sheetView).inset(32);
        make.height.equalTo(@(kFSTTimeEditorSaveHeight));
        make.bottom.equalTo(sheetView.mas_safeAreaLayoutGuideBottom).offset(-34);
    }];
}

- (UIControl *)buildAlignControl {
    UIControl *control = [UIControl new];
    control.layer.cornerRadius = 17;
    [control addTarget:self action:@selector(handleAlignTapped) forControlEvents:UIControlEventTouchUpInside];

    self.alignIconView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"time_align_clock"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    self.alignIconView.contentMode = UIViewContentModeScaleAspectFit;
    self.alignLabel = [UILabel new];
    self.alignLabel.text = self.alignChipText;
    self.alignLabel.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:16] ?: FSTFontSemibold(16);
    self.alignLabel.textAlignment = NSTextAlignmentCenter;

    [control addSubview:self.alignIconView];
    [control addSubview:self.alignLabel];
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

#pragma mark - State

- (NSDate *)clampedDate:(NSDate *)date {
    NSDate *result = date ?: [NSDate date];
    if (self.minimumDate && [result compare:self.minimumDate] == NSOrderedAscending) result = self.minimumDate;
    if (self.maximumDate && [result compare:self.maximumDate] == NSOrderedDescending) result = self.maximumDate;
    return result;
}

- (void)refreshAlignState {
    if (!self.alignControl) return;
    UIColor *backgroundColor = self.alignSelected ? [UIColor fst_colorWithHex:0x27D6A0 alpha:0.15] : [UIColor fst_colorWithHex:0xC9CDD4 alpha:0.30];
    UIColor *textColor = self.alignSelected ? [UIColor fst_colorWithHex:0x008D5A] : [UIColor fst_textSecondary];
    self.alignControl.backgroundColor = backgroundColor;
    self.alignLabel.textColor = textColor;
    self.datePicker.userInteractionEnabled = !self.alignSelected;
    if (self.alignSelected && self.alignedDate) {
        [self.datePicker setDate:[self clampedDate:self.alignedDate] animated:YES];
    }
}

#pragma mark - Events

- (void)handleAlignTapped {
    self.alignSelected = !self.alignSelected;
    [self refreshAlignState];
}

- (void)handleCloseTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleSaveTapped {
    NSDate *pickedDate = self.alignSelected && self.alignedDate ? [self clampedDate:self.alignedDate] : self.datePicker.date;
    if (self.onCommit) self.onCommit(pickedDate, self.alignSelected);
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
