//
//  FSTFastingHistoryViewController.m
//  Fasting
//
//  断食历史列表页：用 UITableView 展示所有 FSTFastingRecord 的卡片。
//  点击进入编辑模式（FSTAddRecordViewController initWithRecord:）。
//

#import "FSTFastingHistoryViewController.h"
#import "FSTFastingHistoryRootView.h"
#import "FSTAppRouter.h"
#import "FSTFastingCardCell.h"
#import "FSTRecordsRepository.h"
#import "FSTTheme.h"

static const CGFloat kRowHeight = 264;

@interface FSTFastingHistoryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) FSTFastingHistoryRootView *rootView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<FSTFastingRecord *> *records;
@end

@implementation FSTFastingHistoryViewController

- (instancetype)init {
    if ((self = [super init])) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self installRootView];
    [self bindCallbacks];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRecords) name:FSTRecordsDidChangeNotification object:nil];
    [self reloadRecords];
}

- (void)installRootView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight       = kRowHeight;
    self.tableView.contentInset    = UIEdgeInsetsMake(0, 0, 24, 0);
    [self.tableView registerClass:[FSTFastingCardCell class] forCellReuseIdentifier:@"card"];
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;

    self.rootView = [[FSTFastingHistoryRootView alloc] init];
    [self.view addSubview:self.rootView];
    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.rootView mountTableView:self.tableView];
}

- (void)bindCallbacks {
    __weak typeof(self) weakSelf = self;
    self.rootView.onBackTapped = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadRecords];
}

- (void)reloadRecords {
    self.records = [[FSTRecordsRepository sharedRepository] allRecords];
    [self.tableView reloadData];
    [self refreshDateHeader];
}

/// 顶部「相对日期」label 跟随当前最上方可见 record 的最新日期切换文案
/// （Today / Yesterday / Tomorrow / May 12 等）。
- (void)refreshDateHeader {
    NSIndexPath *topVisible = self.tableView.indexPathsForVisibleRows.firstObject;
    if (!topVisible || topVisible.row >= (NSInteger)self.records.count) {
        self.rootView.todayText = @"Today";
        return;
    }
    NSDate *date = self.records[topVisible.row].endDate ?: self.records[topVisible.row].startDate ?: [NSDate date];
    self.rootView.todayText = FSTFormatRelativeDay(date);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self refreshDateHeader];
}

#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FSTFastingCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"card" forIndexPath:indexPath];
    [cell configureWithRecord:self.records[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [FSTAppRouter pushAddRecordFrom:self editingRecord:self.records[indexPath.row]];
}

@end
