//
//  FSTMealDiaryViewController.m
//  Fasting
//
//  食物日记列表页：展示某一天的饮食记录。顶部固定栏、垂直时间轴、
//  底部黄色"确认"按钮。点击行进入餐食详情编辑。
//

#import "FSTMealDiaryViewController.h"
#import "FSTMealDiaryTopBarView.h"
#import "FSTMealDiaryEntryRowView.h"
#import "FSTMealDetailViewController.h"
#import "FSTSessionManager.h"
#import "FSTFastingRecord.h"
#import "FSTTheme.h"

@interface FSTMealDiaryViewController ()
@property (nonatomic, strong) FSTMealDiaryTopBarView *topBarView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *timelineStack;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSArray<FSTMealRecord *> *dayRecords;
@end

@implementation FSTMealDiaryViewController

- (instancetype)init {
    if ((self = [super init])) {
        _selectedDate = [NSDate date];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildTopBar];
    [self buildScrollContent];
    [self buildConfirmButton];
    [self reloadDayRecords];
    [self rebuildTimeline];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRecordsChanged) name:FSTRecordsDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadDayRecords];
    [self rebuildTimeline];
}

#pragma mark - 子视图构建

/// 顶部固定栏：使用独立 FSTMealDiaryTopBarView 组件并接线事件。
- (void)buildTopBar {
    self.topBarView = [FSTMealDiaryTopBarView new];
    self.topBarView.selectedDate = self.selectedDate;
    __weak typeof(self) weakSelf = self;
    self.topBarView.onBackTapped = ^{ [weakSelf.navigationController popViewControllerAnimated:YES]; };
    self.topBarView.onDateChipTapped = ^{ [weakSelf showDatePicker]; };
    [self.view addSubview:self.topBarView];

    [self.topBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(72);
    }];
}

/// 滚动容器及垂直 stack。
- (void)buildScrollContent {
    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];

    UIView *contentView = [UIView new];
    [self.scrollView addSubview:contentView];

    self.timelineStack = [UIStackView new];
    self.timelineStack.axis = UILayoutConstraintAxisVertical;
    self.timelineStack.spacing = 18;
    [contentView addSubview:self.timelineStack];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBarView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    [self.timelineStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(18);
        make.left.right.equalTo(contentView).inset(24);
        make.bottom.equalTo(contentView).offset(-140);
    }];
}

/// 底部黄色"确认"按钮。
- (void)buildConfirmButton {
    self.confirmButton = [UIButton fst_yellowPillButtonWithTitle:@"确认"];
    [self.confirmButton setTitleColor:[UIColor fst_textPrimary] forState:UIControlStateNormal];
    [self.confirmButton addTarget:self action:@selector(handleConfirmTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.confirmButton];

    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view).inset(38);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-16);
        make.height.equalTo(@64);
    }];
}

#pragma mark - 数据加载

/// 过滤所有饮食记录，挑出与 selectedDate 同一天的并按时间倒序。
- (void)reloadDayRecords {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *targetDate = self.selectedDate ?: [NSDate date];
    NSArray<FSTMealRecord *> *allRecords = [[FSTSessionManager sharedManager] allMealRecords];
    NSMutableArray<FSTMealRecord *> *matchedRecords = [NSMutableArray array];
    for (FSTMealRecord *record in allRecords) {
        if ([calendar isDate:record.date inSameDayAsDate:targetDate]) [matchedRecords addObject:record];
    }
    [matchedRecords sortUsingComparator:^NSComparisonResult(FSTMealRecord *lhs, FSTMealRecord *rhs) {
        return [rhs.date compare:lhs.date];
    }];
    self.dayRecords = matchedRecords;
    self.topBarView.selectedDate = self.selectedDate;
}

- (void)handleRecordsChanged {
    [self reloadDayRecords];
    [self rebuildTimeline];
}

#pragma mark - 时间轴渲染

/// 清空时间轴，按 dayRecords 重新生成行。空数据展示占位。
- (void)rebuildTimeline {
    for (UIView *subview in self.timelineStack.arrangedSubviews) {
        [self.timelineStack removeArrangedSubview:subview];
        [subview removeFromSuperview];
    }
    if (self.dayRecords.count == 0) {
        UILabel *emptyLabel = [UILabel fst_bodyLabelWithText:@"今天还没有饮食记录"];
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        [self.timelineStack addArrangedSubview:emptyLabel];
        return;
    }
    __weak typeof(self) weakSelf = self;
    void (^openRecord)(FSTMealRecord *) = ^(FSTMealRecord *record) {
        if (!record) return;
        FSTMealDetailViewController *detailViewController = [[FSTMealDetailViewController alloc] initWithMealRecord:record];
        detailViewController.hidesBottomBarWhenPushed = YES;
        [weakSelf.navigationController pushViewController:detailViewController animated:YES];
    };
    for (FSTMealRecord *record in self.dayRecords) {
        FSTMealDiaryEntryRowView *rowView = [[FSTMealDiaryEntryRowView alloc] initWithRecord:record];
        rowView.onCardTapped = openRecord;
        rowView.onEditTapped = openRecord;
        [self.timelineStack addArrangedSubview:rowView];
    }
}

#pragma mark - 事件

- (void)handleConfirmTapped {
    [self.navigationController popViewControllerAnimated:YES];
}

/// 弹出最近 7 天的 ActionSheet 用于选择日期。
- (void)showDatePicker {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];
    for (NSInteger dayOffset = 0; dayOffset < 7; dayOffset++) {
        NSDate *day = [calendar dateByAddingUnit:NSCalendarUnitDay value:-dayOffset toDate:today options:0];
        [actionSheet addAction:[UIAlertAction actionWithTitle:FSTFormatRelativeDay(day) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.selectedDate = day;
            [self reloadDayRecords];
            [self rebuildTimeline];
        }]];
    }
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end
