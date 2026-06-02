//
//  FSTQuickAddRecordViewController.m
//  Fasting
//
//  快速添加断食记录：选择开始/结束时间 → 直接保存，不跳转到完整 AddRecord 表单。
//

#import "FSTQuickAddRecordViewController.h"
#import "FSTQuickAddRecordRootView.h"
#import "FSTTimeRowView.h"
#import "FSTAppRouter.h"
#import "FSTSessionManager.h"
#import "FSTFastingRecord.h"
#import "FSTFastingRecordBuilder.h"
#import "FSTTheme.h"

@interface FSTQuickAddRecordViewController ()
@property (nonatomic, strong) FSTQuickAddRecordRootView *rootView;
@property (nonatomic, strong) FSTTimeRowView *startRow;
@property (nonatomic, strong) FSTTimeRowView *endRow;
@property (nonatomic, strong) UILabel *durationValueLabel;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDateFormatter *displayFormatter;
@end

@implementation FSTQuickAddRecordViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];

    self.displayFormatter = [NSDateFormatter new];
    self.displayFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    self.displayFormatter.doesRelativeDateFormatting = YES;
    self.displayFormatter.dateStyle = NSDateFormatterMediumStyle;
    self.displayFormatter.timeStyle = NSDateFormatterShortStyle;

    // Default: starts = 24h ago, ends = now
    self.endDate   = [NSDate date];
    self.startDate = [self.endDate dateByAddingTimeInterval:-24 * 3600];

    [self installRootView];
    [self bindCallbacks];
    [self refreshDisplay];
}

- (void)installRootView {
    self.startRow = [FSTTimeRowView new];
    self.startRow.title = @"Fast starts";
    self.startRow.dotColor = [UIColor fst_eatingTimeGreen];

    self.endRow = [FSTTimeRowView new];
    self.endRow.title = @"Fast ends";
    self.endRow.dotColor = [UIColor fst_colorWithHex:0xFF7373];

    self.durationValueLabel = [UILabel fst_labelWithText:nil
                                                    font:FSTFontBold(16)
                                                   color:[UIColor blackColor]
                                               alignment:NSTextAlignmentRight];

    self.rootView = [FSTQuickAddRecordRootView new];
    [self.view addSubview:self.rootView];
    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.rootView mountStartRow:self.startRow
                          endRow:self.endRow
              durationValueLabel:self.durationValueLabel];
}

#pragma mark - 回调绑定

- (void)bindCallbacks {
    __weak typeof(self) weakSelf = self;

    self.rootView.onBackTapped = ^{
        [weakSelf handleBack];
    };
    self.rootView.onSaveTapped = ^{
        [weakSelf handleSave];
    };
    self.startRow.onDateChanged = ^(NSDate *date) {
        weakSelf.startDate = date;
        [weakSelf refreshDisplay];
    };
    self.endRow.onDateChanged = ^(NSDate *date) {
        weakSelf.endDate = date;
        [weakSelf refreshDisplay];
    };
}

#pragma mark - 刷新显示

- (void)refreshDisplay {
    self.startRow.pickerDate = self.startDate;
    self.endRow.pickerDate   = self.endDate;

    self.startRow.dateText = [self.displayFormatter stringFromDate:self.startDate];
    self.endRow.dateText   = [self.displayFormatter stringFromDate:self.endDate];

    NSTimeInterval duration = [self.endDate timeIntervalSinceDate:self.startDate];
    if (duration < 0) duration = 0;
    NSInteger totalMinutes = (NSInteger)(duration / 60.0);
    NSInteger hours   = totalMinutes / 60;
    NSInteger minutes = totalMinutes % 60;
    if (hours > 0 && minutes > 0) {
        self.durationValueLabel.text = [NSString stringWithFormat:@"%ldhr %ldmin", (long)hours, (long)minutes];
    } else if (hours > 0) {
        self.durationValueLabel.text = [NSString stringWithFormat:@"%ldhr", (long)hours];
    } else {
        self.durationValueLabel.text = [NSString stringWithFormat:@"%ldmin", (long)minutes];
    }
}

#pragma mark - 操作

- (void)handleBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleSave {
    if ([self.endDate compare:self.startDate] != NSOrderedDescending) {
        [FSTAppRouter showAlertFrom:self
                              title:@"Invalid time"
                            message:@"End time must be after start time."
                        buttonTitle:@"Got it"];
        return;
    }

    FSTSessionManager *sm = [FSTSessionManager sharedManager];
    FSTFastingRecord *record = FSTBuildFastingRecord(nil,
                                                      self.startDate, self.endDate,
                                                      FSTDefaultCurrentWeightKg, FSTDefaultInitialWeightKg, FSTDefaultTargetWeightKg,
                                                      1, @"", NO);

    [FSTAppRouter finishFlowFrom:self
                         updates:^{ [sm finishFastingWithRecord:record]; }
                        fallback:^{
        [sm finishFastingWithRecord:record];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
