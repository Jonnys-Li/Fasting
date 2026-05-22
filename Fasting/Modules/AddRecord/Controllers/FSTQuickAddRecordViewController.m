//
//  FSTQuickAddRecordViewController.m
//  Fasting
//
//  快速添加断食记录：选择开始/结束时间 → 直接保存，不跳转到完整 AddRecord 表单。
//

#import "FSTQuickAddRecordViewController.h"
#import "FSTQuickAddRecordRootView.h"
#import "FSTSessionManager.h"
#import "FSTFastingRecord.h"
#import "FSTRootTabBarController.h"

@interface FSTQuickAddRecordViewController ()
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDateFormatter *displayFormatter;
@end

@implementation FSTQuickAddRecordViewController

#pragma mark - 根视图

- (void)loadView {
    self.view = [FSTQuickAddRecordRootView new];
}

- (FSTQuickAddRecordRootView *)rootView {
    return (FSTQuickAddRecordRootView *)self.view;
}

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

    [self bindCallbacks];
    [self refreshDisplay];
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
    self.rootView.onStartPickerChanged = ^{
        __strong typeof(weakSelf) self = weakSelf;
        self.startDate = self.rootView.startPicker.date;
        [self refreshDisplay];
    };
    self.rootView.onEndPickerChanged = ^{
        __strong typeof(weakSelf) self = weakSelf;
        self.endDate = self.rootView.endPicker.date;
        [self refreshDisplay];
    };
}

#pragma mark - 刷新显示

- (void)refreshDisplay {
    FSTQuickAddRecordRootView *rv = self.rootView;

    rv.startPicker.date = self.startDate;
    rv.endPicker.date   = self.endDate;

    rv.startDateLabel.text = [self.displayFormatter stringFromDate:self.startDate];
    rv.endDateLabel.text   = [self.displayFormatter stringFromDate:self.endDate];

    NSTimeInterval duration = [self.endDate timeIntervalSinceDate:self.startDate];
    if (duration < 0) duration = 0;
    NSInteger totalMinutes = (NSInteger)(duration / 60.0);
    NSInteger hours   = totalMinutes / 60;
    NSInteger minutes = totalMinutes % 60;
    if (hours > 0 && minutes > 0) {
        rv.durationValueLabel.text = [NSString stringWithFormat:@"%ldhr %ldmin", (long)hours, (long)minutes];
    } else if (hours > 0) {
        rv.durationValueLabel.text = [NSString stringWithFormat:@"%ldhr", (long)hours];
    } else {
        rv.durationValueLabel.text = [NSString stringWithFormat:@"%ldmin", (long)minutes];
    }
}

#pragma mark - 操作

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

    FSTRootTabBarController *tab = (FSTRootTabBarController *)self.tabBarController;
    if ([tab isKindOfClass:[FSTRootTabBarController class]]) {
        UINavigationController *fastingNav = (UINavigationController *)tab.viewControllers[FSTTabIndexFasting];
        [tab fst_switchToTimelineSuppressingTransitionChromeWithUpdates:^{
            [sm finishFastingWithRecord:record];
            [fastingNav popToRootViewControllerAnimated:NO];
        }];
    } else {
        [sm finishFastingWithRecord:record];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
