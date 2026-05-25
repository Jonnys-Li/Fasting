//
//  FSTMealDiaryViewController.m
//  Fasting
//
//  食物日记列表页：展示某一天的饮食记录。顶部固定栏、垂直时间轴、
//  底部黄色"确认"按钮。点击行进入餐食详情编辑。
//

#import "FSTMealDiaryViewController.h"
#import "FSTMealDiaryRootView.h"
#import "FSTMealDiaryTopBarView.h"
#import "FSTMealDiaryEntryRowView.h"
#import "FSTMealDetailViewController.h"
#import "FSTRecordsRepository.h"
#import "FSTFastingRecord.h"
#import "FSTTheme.h"

@interface FSTMealDiaryViewController ()
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

- (void)loadView {
    self.view = [FSTMealDiaryRootView new];
}

- (FSTMealDiaryRootView *)rootView {
    return (FSTMealDiaryRootView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    self.rootView.topBarView.selectedDate = self.selectedDate;
    self.rootView.topBarView.onBackTapped = ^{ [weakSelf.navigationController popViewControllerAnimated:YES]; };
    self.rootView.topBarView.onDateChipTapped = ^{ [weakSelf showDatePicker]; };
    self.rootView.onConfirmTapped = ^{ [weakSelf handleConfirmTapped]; };

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

#pragma mark - 数据加载

/// 过滤所有饮食记录，挑出与 selectedDate 同一天的并按时间倒序。
- (void)reloadDayRecords {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *targetDate = self.selectedDate ?: [NSDate date];
    NSArray<FSTMealRecord *> *allRecords = [[FSTRecordsRepository sharedRepository] allMealRecords];
    NSMutableArray<FSTMealRecord *> *matchedRecords = [NSMutableArray array];
    for (FSTMealRecord *record in allRecords) {
        if ([calendar isDate:record.date inSameDayAsDate:targetDate]) [matchedRecords addObject:record];
    }
    [matchedRecords sortUsingComparator:^NSComparisonResult(FSTMealRecord *lhs, FSTMealRecord *rhs) {
        return [rhs.date compare:lhs.date];
    }];
    self.dayRecords = matchedRecords;
    self.rootView.topBarView.selectedDate = self.selectedDate;
}

- (void)handleRecordsChanged {
    [self reloadDayRecords];
    [self rebuildTimeline];
}

#pragma mark - 时间轴渲染

/// 清空时间轴，按 dayRecords 重新生成行。空数据展示占位。
- (void)rebuildTimeline {
    UIStackView *stack = self.rootView.timelineStack;
    for (UIView *subview in stack.arrangedSubviews) {
        [stack removeArrangedSubview:subview];
        [subview removeFromSuperview];
    }
    if (self.dayRecords.count == 0) {
        UILabel *emptyLabel = [UILabel fst_bodyLabelWithText:@"No meal records today"];
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        [stack addArrangedSubview:emptyLabel];
        return;
    }
    __weak typeof(self) weakSelf = self;
    for (NSUInteger i = 0; i < self.dayRecords.count; i++) {
        FSTMealRecord *record = self.dayRecords[i];
        FSTMealDiaryEntryRowView *rowView = [[FSTMealDiaryEntryRowView alloc]
            initWithCategory:record.mealCategory ?: @"Meal"
                    dietType:record.dietType ?: @"Not sure"
                  tasteLevel:record.tasteLevel
                    dateText:FSTFormatRelativeDateTime(record.date ?: [NSDate date])];
        rowView.onCardTapped = ^{
            [weakSelf openMealRecord:record];
        };
        rowView.onEditTapped = ^{
            [weakSelf openMealRecord:record];
        };
        rowView.hidesTopLine = (i == 0);
        [stack addArrangedSubview:rowView];
    }
}

#pragma mark - 事件

- (void)openMealRecord:(FSTMealRecord *)record {
    if (!record) return;
    FSTMealDetailViewController *detailViewController = [[FSTMealDetailViewController alloc] initWithMealRecord:record];
    detailViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

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
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

@end
