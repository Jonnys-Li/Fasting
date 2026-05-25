//
//  FSTAddRecordViewController.m
//  Fasting
//
//  添加/编辑断食记录页：负责数据状态管理与卡片回调接线，UI 与布局由 FSTAddRecordRootView 承担。
//

#import "FSTAddRecordViewController.h"
#import "FSTAddRecordRootView.h"
#import "FSTAddRecordHeaderView.h"
#import "FSTAddRecordTimeCardView.h"
#import "FSTAddRecordWeightCardView.h"
#import "FSTAddRecordFeelingCardView.h"
#import "FSTAddRecordNoteCardView.h"
#import "FSTAppRouter.h"
#import "FSTSessionManager.h"
#import "FSTFastingRecordBuilder.h"
#import "FSTRecordsRepository.h"
#import "FSTTheme.h"

@interface FSTAddRecordViewController ()
@property (nonatomic, strong) FSTFastingRecord *editingRecord;
@property (nonatomic, assign) BOOL editingExistingRecord;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) CGFloat weightKg;
@property (nonatomic, assign) CGFloat initialWeightKg;
@property (nonatomic, assign) CGFloat targetWeightKg;
@property (nonatomic, assign) NSInteger feelingLevel;
@property (nonatomic, assign) BOOL appleHealthEnabled;
@end

@implementation FSTAddRecordViewController

#pragma mark - 初始化

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    if ((self = [super init])) {
        _startDate = startDate ?: [NSDate date];
        _endDate = endDate ?: [NSDate date];
        _weightKg = _initialWeightKg = 81.2;
        _targetWeightKg = 70.0;
        _feelingLevel = 1;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (instancetype)initWithRecord:(FSTFastingRecord *)record {
    if ((self = [super init])) {
        _editingRecord = record;
        _editingExistingRecord = YES;
        _startDate = record.startDate ?: [NSDate date];
        _endDate = record.endDate ?: [NSDate date];
        _weightKg = record.weightKg > 0 ? record.weightKg : 81.2;
        _initialWeightKg = record.initialWeightKg > 0 ? record.initialWeightKg : 81.2;
        _targetWeightKg = record.targetWeightKg > 0 ? record.targetWeightKg : 70.0;
        _feelingLevel = record.feelingLevel;
        _appleHealthEnabled = record.appleHealthEnabled;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

#pragma mark - 生命周期

- (void)loadView {
    self.view = [FSTAddRecordRootView new];
}

- (FSTAddRecordRootView *)rootView {
    return (FSTAddRecordRootView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindCardCallbacks];
    [self pushStateIntoCards];
}

#pragma mark - 卡片回调接线

/// 把 RootView 上各子卡片暴露的 block 与 VC 的事件处理方法接起来。
- (void)bindCardCallbacks {
    __weak typeof(self) weakSelf = self;
    FSTAddRecordRootView *rootView = self.rootView;

    rootView.headerView.onBackTapped  = ^{ [weakSelf handleCancelTapped]; };
    rootView.headerView.onTrashTapped = ^{ [weakSelf handleTrashTapped]; };

    rootView.timeCardView.editingExistingRecord = self.editingExistingRecord;
    rootView.timeCardView.onDatesChanged = ^(NSDate *startDate, NSDate *endDate) {
        weakSelf.startDate = startDate;
        weakSelf.endDate = endDate;
        weakSelf.rootView.headerView.totalSeconds = [endDate timeIntervalSinceDate:startDate];
    };

    rootView.weightCardView.onEditTapped    = ^{ [weakSelf handleWeightEditTapped]; };
    rootView.weightCardView.onHealthChanged = ^(BOOL enabled) { weakSelf.appleHealthEnabled = enabled; };

    rootView.onCancelTapped = ^{ [weakSelf handleCancelTapped]; };
    rootView.onSaveTapped   = ^{ [weakSelf handleSaveTapped]; };
}

#pragma mark - 状态推送

/// 把 VC 持有的当前状态推送到各子卡片。VC 是状态权威，每张卡片仅作显示与局部编辑。
- (void)pushStateIntoCards {
    FSTAddRecordRootView *rootView = self.rootView;
    rootView.headerView.totalSeconds = [self.endDate timeIntervalSinceDate:self.startDate];
    rootView.timeCardView.planName   = [self planName];
    rootView.timeCardView.startDate  = self.startDate;
    rootView.timeCardView.endDate    = self.endDate;
    rootView.weightCardView.weightKg           = self.weightKg;
    rootView.weightCardView.initialWeightKg    = self.initialWeightKg;
    rootView.weightCardView.targetWeightKg     = self.targetWeightKg;
    rootView.weightCardView.usePounds          = [FSTSessionManager sharedManager].preferredWeightUnit == FSTWeightUnitLb;
    rootView.weightCardView.appleHealthEnabled = self.appleHealthEnabled;
    rootView.feelingCardView.feelingLevel = self.feelingLevel;
    rootView.noteCardView.text            = self.editingRecord.note ?: @"";
}

- (NSString *)planName {
    if (self.editingRecord.planName.length) return self.editingRecord.planName;
    return [FSTSessionManager sharedManager].currentPlan.name ?: @"14-10";
}

#pragma mark - 事件

- (void)handleCancelTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleTrashTapped {
    if (self.editingExistingRecord) {
        [[FSTRecordsRepository sharedRepository] deleteFastingRecord:self.editingRecord];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [[FSTSessionManager sharedManager] cancelActiveFasting];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)handleWeightEditTapped {
    __weak typeof(self) weakSelf = self;
    [FSTAppRouter presentWeightInputFrom:self
                                weightKg:self.weightKg > 0 ? self.weightKg : 70.0
                                  onSave:^(CGFloat newWeightKg) {
        if (newWeightKg <= 0) return;
        weakSelf.weightKg = newWeightKg;
        weakSelf.rootView.weightCardView.weightKg = newWeightKg;
    }];
}

- (void)handleSaveTapped {
    if ([self.endDate compare:self.startDate] != NSOrderedDescending) {
        [FSTAppRouter showAlertFrom:self
                              title:@"Invalid Time"
                            message:@"End time must be after start time."
                        buttonTitle:@"Got it"];
        return;
    }
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    FSTFastingRecord *record = FSTBuildFastingRecord(self.editingExistingRecord ? self.editingRecord : nil,
                                                      self.startDate, self.endDate,
                                                      self.weightKg, self.initialWeightKg, self.targetWeightKg,
                                                      self.rootView.feelingCardView.feelingLevel,
                                                      self.rootView.noteCardView.text,
                                                      self.appleHealthEnabled);

    if (self.editingExistingRecord) {
        [[FSTRecordsRepository sharedRepository] updateFastingRecord:record];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    [FSTAppRouter finishFlowFrom:self
                         updates:^{ [sessionManager finishFastingWithRecord:record]; }
                        fallback:^{
        [sessionManager finishFastingWithRecord:record];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

@end
