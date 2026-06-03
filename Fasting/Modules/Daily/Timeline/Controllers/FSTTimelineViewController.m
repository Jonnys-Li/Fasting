//
//  FSTTimelineViewController.m
//  Fasting
//
//  时间轴 Tab 主页：展示两个模块——"进食时间"（最近断食摘要）+"食物日记"（最近一条饮食）。
//  点击任一模块进入对应的列表 / 详情页（导航统一走 FSTAppRouter）。
//

#import "FSTTimelineViewController.h"
#import "FSTTimelineRootView.h"
#import "FSTFastingTimelineCardView.h"
#import "FSTTimelineModuleView.h"
#import "FSTAppRouter.h"
#import "FSTRecordsRepository.h"
#import "FSTTheme.h"

@interface FSTTimelineViewController ()
@property (nonatomic, strong) FSTTimelineRootView *rootView;
@property (nonatomic, strong) FSTFastingTimelineCardView *fastingModuleView;
@property (nonatomic, strong) FSTTimelineModuleView *mealModuleView;
@property (nonatomic, strong, nullable) FSTMealRecord *latestMealRecord;
@end

@implementation FSTTimelineViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self installRootView];
    [self bindCallbacks];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHome) name:FSTRecordsDidChangeNotification object:nil];
}

- (void)installRootView {
    self.fastingModuleView = [[FSTFastingTimelineCardView alloc] init];
    self.fastingModuleView.titleText = @"Fasting";

    self.mealModuleView = [[FSTTimelineModuleView alloc] init];

    self.rootView = [[FSTTimelineRootView alloc] init];
    [self.view addSubview:self.rootView];
    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.rootView mountFastingModuleView:self.fastingModuleView
                           mealModuleView:self.mealModuleView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshHome];
}

#pragma mark - 回调接线

- (void)bindCallbacks {
    __weak typeof(self) weakSelf = self;
    self.fastingModuleView.onMoreTapped = ^{
        [weakSelf handleMoreFastingTapped];
    };
    self.mealModuleView.onChevronTapped = ^{
        [weakSelf handleMealChevronTapped];
    };
    self.mealModuleView.onAddTapped = ^{
        [weakSelf handleMealAddTapped];
    };
    self.mealModuleView.onEntryTapped = ^{
        [weakSelf handleMealEntryTapped];
    };
}

#pragma mark - 数据刷新

/// 根据 RecordsRepository 最近一条断食/饮食记录刷新两张模块卡的摘要。
- (void)refreshHome {
    FSTRecordsRepository *repository = [FSTRecordsRepository sharedRepository];
    FSTFastingRecord *fastingRecord = [repository allRecords].firstObject;
    [self.fastingModuleView configureWithRecord:fastingRecord];

    self.latestMealRecord = [repository allMealRecords].firstObject;
    FSTMealRecord *mr = self.latestMealRecord;
    [self.mealModuleView updateWithCategory:mr.mealCategory
                                   dietType:mr.dietType
                                 tasteLevel:mr.tasteLevel
                                   dateText:mr ? FSTFormatRelativeDateTime(mr.date ?: [NSDate date]) : nil];
}

#pragma mark - 事件

- (void)handleMoreFastingTapped {
    [FSTAppRouter pushFastingHistoryFrom:self];
}

/// ">" 箭头：跳转食物日记列表页。
- (void)handleMealChevronTapped {
    [FSTAppRouter pushMealDiaryFrom:self];
}

/// "+ 增加"：新建饮食记录。
- (void)handleMealAddTapped {
    [FSTAppRouter pushMealDetailFrom:self record:nil returnsToTimeline:NO];
}

- (void)handleMealEntryTapped {
    [FSTAppRouter pushMealDetailFrom:self record:self.latestMealRecord returnsToTimeline:NO];
}

@end
