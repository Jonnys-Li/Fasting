//
//  FSTTimelineViewController.m
//  Fasting
//
//  时间轴 Tab 主页：展示两个模块——"进食时间"（最近断食摘要）+"食物日记"（最近一条饮食）。
//  点击任一模块进入对应的列表 / 详情页。
//

#import "FSTTimelineViewController.h"
#import "FSTTimelineRootView.h"
#import "FSTFastingTimelineCardView.h"
#import "FSTTimelineModuleView.h"
#import "FSTFastingHistoryViewController.h"
#import "FSTMealDetailViewController.h"
#import "FSTMealDiaryViewController.h"
#import "FSTSessionManager.h"
#import "FSTTheme.h"

@interface FSTTimelineViewController ()
@property (nonatomic, strong, nullable) FSTMealRecord *latestMealRecord;
@end

@implementation FSTTimelineViewController

#pragma mark - 生命周期

- (void)loadView {
    self.view = [FSTTimelineRootView new];
}

- (FSTTimelineRootView *)rootView {
    return (FSTTimelineRootView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindCallbacks];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHome) name:FSTRecordsDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshHome];
}

#pragma mark - 回调接线

- (void)bindCallbacks {
    __weak typeof(self) weakSelf = self;
    self.rootView.fastingModuleView.onMoreTapped = ^{
        [weakSelf handleMoreFastingTapped];
    };
    self.rootView.mealModuleView.onChevronTapped = ^{ [weakSelf handleMealChevronTapped]; };
    self.rootView.mealModuleView.onAddTapped     = ^{ [weakSelf handleMealAddTapped]; };
    self.rootView.mealModuleView.onEntryTapped   = ^{ [weakSelf handleMealEntryTapped]; };
}

#pragma mark - 数据刷新

/// 根据 SessionManager 最近一条断食/饮食记录刷新两张模块卡的摘要。
- (void)refreshHome {
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    FSTFastingRecord *fastingRecord = [sessionManager allRecords].firstObject;
    [self.rootView.fastingModuleView configureWithRecord:fastingRecord];

    self.latestMealRecord = [sessionManager allMealRecords].firstObject;
    FSTMealRecord *mr = self.latestMealRecord;
    [self.rootView.mealModuleView updateWithCategory:mr.mealCategory
                                            dietType:mr.dietType
                                          tasteLevel:mr.tasteLevel
                                            dateText:mr ? FSTFormatRelativeDateTime(mr.date ?: [NSDate date]) : nil];
}

#pragma mark - 事件

- (void)handleMoreFastingTapped {
    FSTFastingHistoryViewController *historyViewController = [FSTFastingHistoryViewController new];
    historyViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:historyViewController animated:YES];
}

/// ">" 箭头：跳转食物日记列表页。
- (void)handleMealChevronTapped {
    FSTMealDiaryViewController *diaryViewController = [FSTMealDiaryViewController new];
    diaryViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:diaryViewController animated:YES];
}

/// "+ 增加"：新建饮食记录。
- (void)handleMealAddTapped {
    FSTMealDetailViewController *detailVC = [[FSTMealDetailViewController alloc] initWithMealRecord:nil];
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)handleMealEntryTapped {
    FSTMealDetailViewController *detailVC = [[FSTMealDetailViewController alloc] initWithMealRecord:self.latestMealRecord];
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
