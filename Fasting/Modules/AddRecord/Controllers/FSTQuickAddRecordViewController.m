//
//  FSTQuickAddRecordViewController.m
//  Fasting
//
//  快速添加断食记录：选择开始/结束时间 → 直接保存，不跳转到完整 AddRecord 表单。
//

#import "FSTQuickAddRecordViewController.h"
#import "FSTSessionManager.h"
#import "FSTFastingRecord.h"
#import "FSTRootTabBarController.h"
#import "FSTTheme.h"
#import "UIColor+FST.h"

static const CGFloat kQuickAddSideInset   = 24;
static const CGFloat kQuickAddSubmitHeight = 56;
static const CGFloat kQuickAddSubmitRadius = 28;
static const CGFloat kQuickAddDotSize      = 8;

@interface FSTQuickAddRecordViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *durationValueLabel;
@property (nonatomic, strong) UILabel *startDateLabel;
@property (nonatomic, strong) UILabel *endDateLabel;
@property (nonatomic, strong) UIDatePicker *startPicker;
@property (nonatomic, strong) UIDatePicker *endPicker;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDateFormatter *displayFormatter;
@end

@implementation FSTQuickAddRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    self.displayFormatter = [NSDateFormatter new];
    self.displayFormatter.doesRelativeDateFormatting = YES;
    self.displayFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.displayFormatter.timeStyle = NSDateFormatterShortStyle;

    // Default: starts = 24h ago, ends = now
    self.endDate   = [NSDate date];
    self.startDate = [self.endDate dateByAddingTimeInterval:-24 * 3600];

    [self buildUI];
    [self refreshDisplay];
}

#pragma mark - UI

- (void)buildUI {
    // Back button
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [[UIImage imageNamed:@"feedback_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    // Title
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"Add new record";
    titleLabel.font = FSTFontBold(18);
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];

    // Scroll view
    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    // Fast duration row
    UIView *durationRow = [self buildDurationRow];
    [self.contentView addSubview:durationRow];

    // Separator
    UIView *separator = [UIView new];
    separator.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    [self.contentView addSubview:separator];

    // Fast starts section
    UIView *startSection = [self buildStartSection];
    [self.contentView addSubview:startSection];

    // Fast ends section
    UIView *endSection = [self buildEndSection];
    [self.contentView addSubview:endSection];

    // Save button
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.backgroundColor = [UIColor fst_eatingTimeGreen];
    saveButton.layer.cornerRadius = kQuickAddSubmitRadius;
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.titleLabel.font = FSTFontBold(18);
    [saveButton addTarget:self action:@selector(handleSave) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:saveButton];

    // Constraints
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(8);
        make.left.equalTo(self.view).offset(16);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backButton);
        make.centerX.equalTo(self.view);
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backButton.mas_bottom).offset(16);
        make.left.right.bottom.equalTo(self.view);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    [durationRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(16);
        make.left.right.equalTo(self.contentView).inset(kQuickAddSideInset);
        make.height.mas_equalTo(44);
    }];
    [separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(durationRow.mas_bottom);
        make.left.right.equalTo(self.contentView).inset(kQuickAddSideInset);
        make.height.mas_equalTo(1);
    }];
    [startSection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(separator.mas_bottom).offset(24);
        make.left.right.equalTo(self.contentView).inset(kQuickAddSideInset);
    }];
    [endSection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(startSection.mas_bottom).offset(24);
        make.left.right.equalTo(self.contentView).inset(kQuickAddSideInset);
    }];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(endSection.mas_bottom).offset(40);
        make.left.right.equalTo(self.contentView).inset(kQuickAddSideInset);
        make.height.mas_equalTo(kQuickAddSubmitHeight);
        make.bottom.equalTo(self.contentView).offset(-40);
    }];
}

#pragma mark - Subview builders

- (UIView *)buildDurationRow {
    UIView *row = [UIView new];

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"Fast duration";
    titleLabel.font = FSTFontMedium(16);
    titleLabel.textColor = [UIColor blackColor];
    [row addSubview:titleLabel];

    self.durationValueLabel = [UILabel new];
    self.durationValueLabel.font = FSTFontBold(16);
    self.durationValueLabel.textColor = [UIColor blackColor];
    self.durationValueLabel.textAlignment = NSTextAlignmentRight;
    [row addSubview:self.durationValueLabel];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(row);
    }];
    [self.durationValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.centerY.equalTo(row);
    }];
    return row;
}

- (UIView *)buildStartSection {
    UIView *section = [UIView new];

    // Header row: green dot + "Fast starts" + date text + pencil
    UIView *headerRow = [UIView new];
    [section addSubview:headerRow];

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
    [self.startPicker addTarget:self action:@selector(startPickerChanged) forControlEvents:UIControlEventValueChanged];
    [section addSubview:self.startPicker];

    [headerRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(section);
        make.height.mas_equalTo(32);
    }];
    [self.startPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerRow.mas_bottom).offset(12);
        make.left.right.bottom.equalTo(section);
    }];
    return section;
}

- (UIView *)buildEndSection {
    UIView *section = [UIView new];

    UIView *headerRow = [UIView new];
    [section addSubview:headerRow];

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
    [self.endPicker addTarget:self action:@selector(endPickerChanged) forControlEvents:UIControlEventValueChanged];
    [section addSubview:self.endPicker];

    [headerRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(section);
        make.height.mas_equalTo(32);
    }];
    [self.endPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerRow.mas_bottom).offset(12);
        make.left.right.bottom.equalTo(section);
    }];
    return section;
}

#pragma mark - Picker events

- (void)startPickerChanged {
    self.startDate = self.startPicker.date;
    [self refreshDisplay];
}

- (void)endPickerChanged {
    self.endDate = self.endPicker.date;
    [self refreshDisplay];
}

#pragma mark - Display refresh

- (void)refreshDisplay {
    self.startPicker.date = self.startDate;
    self.endPicker.date = self.endDate;

    self.startDateLabel.text = [self.displayFormatter stringFromDate:self.startDate];
    self.endDateLabel.text = [self.displayFormatter stringFromDate:self.endDate];

    NSTimeInterval duration = [self.endDate timeIntervalSinceDate:self.startDate];
    if (duration < 0) duration = 0;
    NSInteger totalMinutes = (NSInteger)(duration / 60.0);
    NSInteger hours = totalMinutes / 60;
    NSInteger minutes = totalMinutes % 60;
    if (hours > 0 && minutes > 0) {
        self.durationValueLabel.text = [NSString stringWithFormat:@"%ldhr %ldmin", (long)hours, (long)minutes];
    } else if (hours > 0) {
        self.durationValueLabel.text = [NSString stringWithFormat:@"%ldhr", (long)hours];
    } else {
        self.durationValueLabel.text = [NSString stringWithFormat:@"%ldmin", (long)minutes];
    }
}

#pragma mark - Actions

- (void)handleBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleSave {
    if ([self.endDate compare:self.startDate] != NSOrderedDescending) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid time"
                                                                       message:@"End time must be after start time."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    FSTSessionManager *sm = [FSTSessionManager sharedManager];
    FSTFastingRecord *record = [FSTFastingRecord new];
    record.recordID        = [[NSUUID UUID] UUIDString];
    record.planName        = sm.currentPlan.name ?: @"14-10";
    record.fastingHours    = sm.currentPlan.fastingHours;
    record.startDate       = self.startDate;
    record.endDate         = self.endDate;
    record.weightKg        = 81.2;
    record.initialWeightKg = 81.2;
    record.targetWeightKg  = 70.0;
    record.feelingLevel    = 1;
    record.note            = @"";

    [sm finishFastingWithRecord:record];

    UITabBarController *tab = self.tabBarController;
    if ([tab isKindOfClass:[FSTRootTabBarController class]]) {
        UINavigationController *fastingNav = (UINavigationController *)tab.viewControllers[FSTTabIndexFasting];
        [fastingNav popToRootViewControllerAnimated:NO];
        tab.selectedIndex = FSTTabIndexTimeline;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
