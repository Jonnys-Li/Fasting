//
//  FSTQuickAddRecordRootView.m
//  Fasting
//

#import "FSTQuickAddRecordRootView.h"
#import "FSTTheme.h"
#import "UIColor+FST.h"

static const CGFloat kQuickAddSideInset    = 24;
static const CGFloat kQuickAddSubmitHeight = 56;
static const CGFloat kQuickAddSubmitRadius = 28;
static const CGFloat kQuickAddDotSize      = 8;

@interface FSTQuickAddRecordRootView ()
@property (nonatomic, strong, readwrite) UILabel *durationValueLabel;
@property (nonatomic, strong, readwrite) UILabel *startDateLabel;
@property (nonatomic, strong, readwrite) UILabel *endDateLabel;
@property (nonatomic, strong, readwrite) UIDatePicker *startPicker;
@property (nonatomic, strong, readwrite) UIDatePicker *endPicker;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *durationRow;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UIView *startSection;
@property (nonatomic, strong) UIView *endSection;
@property (nonatomic, strong) UIButton *saveButton;
@end

@implementation FSTQuickAddRecordRootView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];
        [self buildNavBar];
        [self buildScrollContent];
        [self buildDurationRow];
        [self buildSeparator];
        [self buildStartSection];
        [self buildEndSection];
        [self buildSaveButton];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 视图组装

- (void)buildNavBar {
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [[UIImage imageNamed:@"feedback_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.backButton setImage:backImage forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(handleBackTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backButton];

    self.titleLabel = [UILabel new];
    self.titleLabel.text = @"Add new record";
    self.titleLabel.font = FSTFontBold(18);
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];
}

- (void)buildScrollContent {
    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];
}

- (void)buildDurationRow {
    self.durationRow = [UIView new];
    [self.contentView addSubview:self.durationRow];

    UILabel *durationTitle = [UILabel new];
    durationTitle.text = @"Fast duration";
    durationTitle.font = FSTFontMedium(16);
    durationTitle.textColor = [UIColor blackColor];
    [self.durationRow addSubview:durationTitle];

    self.durationValueLabel = [UILabel new];
    self.durationValueLabel.font = FSTFontBold(16);
    self.durationValueLabel.textColor = [UIColor blackColor];
    self.durationValueLabel.textAlignment = NSTextAlignmentRight;
    [self.durationRow addSubview:self.durationValueLabel];

    [durationTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(self.durationRow);
    }];
    [self.durationValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.centerY.equalTo(self.durationRow);
    }];
}

- (void)buildSeparator {
    self.separator = [UIView new];
    self.separator.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    [self.contentView addSubview:self.separator];
}

- (void)buildStartSection {
    self.startSection = [UIView new];
    [self.contentView addSubview:self.startSection];

    // Header row: green dot + "Fast starts" + date text + pencil
    UIView *headerRow = [UIView new];
    [self.startSection addSubview:headerRow];

    UIView *dot = [UIView new];
    dot.backgroundColor = [UIColor fst_eatingTimeGreen];
    dot.layer.cornerRadius = kQuickAddDotSize / 2.0;
    [headerRow addSubview:dot];

    UILabel *label = [UILabel new];
    label.text = @"Fast starts";
    label.font = FSTFontMedium(16);
    label.textColor = [UIColor blackColor];
    [headerRow addSubview:label];

    self.startDateLabel = [UILabel new];
    self.startDateLabel.font = FSTFontBold(15);
    self.startDateLabel.textColor = [UIColor fst_eatingTimeGreen];
    [headerRow addSubview:self.startDateLabel];

    UIImageView *pencil = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"edit_pencil"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    pencil.contentMode = UIViewContentModeScaleAspectFit;
    [headerRow addSubview:pencil];

    [dot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerRow);
        make.centerY.equalTo(headerRow);
        make.size.mas_equalTo(CGSizeMake(kQuickAddDotSize, kQuickAddDotSize));
    }];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dot.mas_right).offset(8);
        make.centerY.equalTo(headerRow);
    }];
    [pencil mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headerRow);
        make.centerY.equalTo(headerRow);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    [self.startDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(pencil.mas_left).offset(-6);
        make.centerY.equalTo(headerRow);
    }];

    // Date picker
    self.startPicker = [UIDatePicker new];
    self.startPicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.startPicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    self.startPicker.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    self.startPicker.layer.cornerRadius = 16;
    self.startPicker.layer.masksToBounds = YES;
    [self.startPicker addTarget:self action:@selector(handleStartPickerChanged) forControlEvents:UIControlEventValueChanged];
    [self.startSection addSubview:self.startPicker];

    [headerRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.startSection);
        make.height.mas_equalTo(32);
    }];
    [self.startPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerRow.mas_bottom).offset(12);
        make.left.right.bottom.equalTo(self.startSection);
    }];
}

- (void)buildEndSection {
    self.endSection = [UIView new];
    [self.contentView addSubview:self.endSection];

    UIView *headerRow = [UIView new];
    [self.endSection addSubview:headerRow];

    UIView *dot = [UIView new];
    dot.backgroundColor = [UIColor colorWithRed:1.0 green:0.45 blue:0.45 alpha:1.0];
    dot.layer.cornerRadius = kQuickAddDotSize / 2.0;
    [headerRow addSubview:dot];

    UILabel *label = [UILabel new];
    label.text = @"Fast ends";
    label.font = FSTFontMedium(16);
    label.textColor = [UIColor blackColor];
    [headerRow addSubview:label];

    self.endDateLabel = [UILabel new];
    self.endDateLabel.font = FSTFontBold(15);
    self.endDateLabel.textColor = [UIColor fst_eatingTimeGreen];
    [headerRow addSubview:self.endDateLabel];

    UIImageView *pencil = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"edit_pencil"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    pencil.contentMode = UIViewContentModeScaleAspectFit;
    [headerRow addSubview:pencil];

    [dot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerRow);
        make.centerY.equalTo(headerRow);
        make.size.mas_equalTo(CGSizeMake(kQuickAddDotSize, kQuickAddDotSize));
    }];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dot.mas_right).offset(8);
        make.centerY.equalTo(headerRow);
    }];
    [pencil mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headerRow);
        make.centerY.equalTo(headerRow);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    [self.endDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(pencil.mas_left).offset(-6);
        make.centerY.equalTo(headerRow);
    }];

    self.endPicker = [UIDatePicker new];
    self.endPicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.endPicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    self.endPicker.backgroundColor = [UIColor colorWithRed:0.96 green:0.97 blue:0.98 alpha:1.0];
    self.endPicker.layer.cornerRadius = 16;
    self.endPicker.layer.masksToBounds = YES;
    [self.endPicker addTarget:self action:@selector(handleEndPickerChanged) forControlEvents:UIControlEventValueChanged];
    [self.endSection addSubview:self.endPicker];

    [headerRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.endSection);
        make.height.mas_equalTo(32);
    }];
    [self.endPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerRow.mas_bottom).offset(12);
        make.left.right.bottom.equalTo(self.endSection);
    }];
}

- (void)buildSaveButton {
    self.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveButton.backgroundColor = [UIColor fst_eatingTimeGreen];
    self.saveButton.layer.cornerRadius = kQuickAddSubmitRadius;
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.saveButton.titleLabel.font = FSTFontBold(18);
    [self.saveButton addTarget:self action:@selector(handleSaveTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.saveButton];
}

#pragma mark - 约束

- (void)setupConstraints {
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(8);
        make.left.equalTo(self).offset(16);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.centerX.equalTo(self);
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backButton.mas_bottom).offset(16);
        make.left.right.bottom.equalTo(self);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    [self.durationRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(16);
        make.left.right.equalTo(self.contentView).inset(kQuickAddSideInset);
        make.height.mas_equalTo(44);
    }];
    [self.separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.durationRow.mas_bottom);
        make.left.right.equalTo(self.contentView).inset(kQuickAddSideInset);
        make.height.mas_equalTo(1);
    }];
    [self.startSection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.separator.mas_bottom).offset(24);
        make.left.right.equalTo(self.contentView).inset(kQuickAddSideInset);
    }];
    [self.endSection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startSection.mas_bottom).offset(24);
        make.left.right.equalTo(self.contentView).inset(kQuickAddSideInset);
    }];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.endSection.mas_bottom).offset(40);
        make.left.right.equalTo(self.contentView).inset(kQuickAddSideInset);
        make.height.mas_equalTo(kQuickAddSubmitHeight);
        make.bottom.equalTo(self.contentView).offset(-40);
    }];
}

#pragma mark - 事件

- (void)handleBackTapped {
    if (self.onBackTapped) self.onBackTapped();
}

- (void)handleSaveTapped {
    if (self.onSaveTapped) self.onSaveTapped();
}

- (void)handleStartPickerChanged {
    if (self.onStartPickerChanged) self.onStartPickerChanged();
}

- (void)handleEndPickerChanged {
    if (self.onEndPickerChanged) self.onEndPickerChanged();
}

@end
