//
//  FSTTimelineViewController.m
//  Fasting
//
//  时间轴 Tab 主页：展示两个模块——"进食时间"（最近断食摘要）+"食物日记"（最近一条饮食）。
//  点击任一模块进入对应的列表 / 详情页。
//

#import "FSTTimelineViewController.h"
#import "FSTFastingHistoryViewController.h"
#import "FSTMealDetailViewController.h"
#import "FSTMealDiaryViewController.h"
#import "FSTSessionManager.h"
#import "FSTFastingTimelineCardView.h"
#import "FSTTheme.h"
#import "FSTTimelineModuleView.h"

@interface FSTTimelineViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) FSTFastingTimelineCardView *fastingModuleView;
@property (nonatomic, strong) FSTTimelineModuleView *mealModuleView;
@end

@implementation FSTTimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildHomeLayout];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshHome) name:FSTRecordsDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshHome];
}

/// 构建：标题 + 两个模块卡纵向排列。
- (void)buildHomeLayout {
    self.scrollView = [UIScrollView new];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    UILabel *titleLabel = [UILabel fst_titleLabelWithText:@"时间轴"];
    [self.contentView addSubview:titleLabel];

    self.fastingModuleView = [FSTFastingTimelineCardView new];
    self.fastingModuleView.titleText = @"Fasting";
    __weak typeof(self) weakSelf = self;
    self.fastingModuleView.onMoreTapped = ^{
        [weakSelf handleMoreFastingTapped];
    };

    self.mealModuleView = [FSTTimelineModuleView new];
    self.mealModuleView.onChevronTapped = ^{ [weakSelf handleMealChevronTapped]; };
    self.mealModuleView.onAddTapped     = ^{ [weakSelf handleMealAddTapped]; };
    self.mealModuleView.onEntryTapped   = ^(FSTMealRecord *record) { [weakSelf handleMealEntryTapped:record]; };
    [self.contentView addSubview:self.fastingModuleView];
    [self.contentView addSubview:self.mealModuleView];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(26);
        make.centerX.equalTo(self.contentView);
    }];
    [self.fastingModuleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(34);
        make.left.right.equalTo(self.contentView).inset(24);
        make.height.equalTo(@244);
    }];
    [self.mealModuleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fastingModuleView.mas_bottom).offset(20);
        make.left.right.equalTo(self.fastingModuleView);
        make.bottom.equalTo(self.contentView).offset(-120);
    }];
}

/// 根据 SessionManager 最近一条断食/饮食记录刷新两张模块卡的摘要。
- (void)refreshHome {
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    FSTFastingRecord *fastingRecord = [sessionManager allRecords].firstObject;
    [self.fastingModuleView configureWithRecord:fastingRecord];

    FSTMealRecord *mealRecord = [sessionManager allMealRecords].firstObject;
    [self.mealModuleView updateWithMealRecord:mealRecord];
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

/// 点击食物卡片：编辑该记录。
- (void)handleMealEntryTapped:(FSTMealRecord *)record {
    FSTMealDetailViewController *detailVC = [[FSTMealDetailViewController alloc] initWithMealRecord:record];
    detailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
