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
#import "FSTFastingRecord.h"
#import "FSTFastingRecordBuilder.h"
#import "FSTRecordsRepository.h"
#import "FSTTheme.h"

@interface FSTAddRecordViewController ()
@property (nonatomic, strong) FSTAddRecordRootView *rootView;
@property (nonatomic, strong) FSTAddRecordHeaderView *headerView;
@property (nonatomic, strong) FSTAddRecordTimeCardView *timeCardView;
@property (nonatomic, strong) FSTAddRecordWeightCardView *weightCardView;
@property (nonatomic, strong) FSTAddRecordFeelingCardView *feelingCardView;
@property (nonatomic, strong) FSTAddRecordNoteCardView *noteCardView;

@property (nonatomic, strong, readwrite, nullable) FSTFastingRecord *editingRecord;
@property (nonatomic, assign) BOOL editingExistingRecord;
@property (nonatomic, strong, readwrite) NSDate *startDate;
@property (nonatomic, strong, readwrite) NSDate *endDate;
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
        _weightKg = FSTDefaultCurrentWeightKg;
        _initialWeightKg = FSTDefaultInitialWeightKg;
        _targetWeightKg = FSTDefaultTargetWeightKg;
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
        _weightKg = FSTWeightOrDefault(record.weightKg, FSTDefaultCurrentWeightKg);
        _initialWeightKg = FSTWeightOrDefault(record.initialWeightKg, FSTDefaultInitialWeightKg);
        _targetWeightKg = FSTWeightOrDefault(record.targetWeightKg, FSTDefaultTargetWeightKg);
        _feelingLevel = record.feelingLevel;
        _appleHealthEnabled = record.appleHealthEnabled;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self installRootView];
    [self bindCardCallbacks];
    [self pushStateIntoCards];
}

- (void)installRootView {
    self.headerView      = [[FSTAddRecordHeaderView alloc] init];
    self.timeCardView    = [[FSTAddRecordTimeCardView alloc] init];
    self.weightCardView  = [[FSTAddRecordWeightCardView alloc] init];
    self.feelingCardView = [[FSTAddRecordFeelingCardView alloc] init];
    self.noteCardView    = [[FSTAddRecordNoteCardView alloc] init];

    self.rootView = [[FSTAddRecordRootView alloc] init];
    [self.view addSubview:self.rootView];
    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.rootView mountHeaderView:self.headerView
                             cards:@[self.timeCardView, self.weightCardView,
                                     self.feelingCardView, self.noteCardView]];
}

#pragma mark - 卡片回调接线

/// 把各子卡片暴露的 block 与 VC 的事件处理方法接起来。
- (void)bindCardCallbacks {
    __weak typeof(self) weakSelf = self;

    self.headerView.onBackTapped = ^{
        [weakSelf handleCancelTapped];
    };
    self.headerView.onTrashTapped = ^{
        [weakSelf handleTrashTapped];
    };

    self.timeCardView.editingExistingRecord = self.editingExistingRecord;
    self.timeCardView.onDatesChanged = ^(NSDate *startDate, NSDate *endDate) {
        weakSelf.startDate = startDate;
        weakSelf.endDate = endDate;
        weakSelf.headerView.totalSeconds = [endDate timeIntervalSinceDate:startDate];
    };

    self.weightCardView.onEditTapped = ^{
        [weakSelf handleWeightEditTapped];
    };
    self.weightCardView.onHealthChanged = ^(BOOL enabled) {
        weakSelf.appleHealthEnabled = enabled;
    };

    self.rootView.onCancelTapped = ^{
        [weakSelf handleCancelTapped];
    };
    self.rootView.onSaveTapped = ^{
        [weakSelf handleSaveTapped];
    };
}

#pragma mark - 状态推送

/// 把 VC 持有的当前状态推送到各子卡片。VC 是状态权威，每张卡片仅作显示与局部编辑。
- (void)pushStateIntoCards {
    self.headerView.totalSeconds = [self.endDate timeIntervalSinceDate:self.startDate];
    self.timeCardView.planName   = [self planName];
    self.timeCardView.startDate  = self.startDate;
    self.timeCardView.endDate    = self.endDate;
    self.weightCardView.weightKg           = self.weightKg;
    self.weightCardView.initialWeightKg    = self.initialWeightKg;
    self.weightCardView.targetWeightKg     = self.targetWeightKg;
    self.weightCardView.usePounds          = [FSTSessionManager sharedManager].preferredWeightUnit == FSTWeightUnitLb;
    self.weightCardView.appleHealthEnabled = self.appleHealthEnabled;
    self.feelingCardView.feelingLevel = self.feelingLevel;
    self.noteCardView.text            = self.editingRecord.note ?: @"";
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
                                weightKg:FSTWeightOrDefault(self.weightKg, FSTDefaultCurrentWeightKg)
                                  onSave:^(CGFloat newWeightKg) {
        if (newWeightKg <= 0) return;
        weakSelf.weightKg = newWeightKg;
        weakSelf.weightCardView.weightKg = newWeightKg;
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
                                                      self.feelingCardView.feelingLevel,
                                                      self.noteCardView.text,
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
