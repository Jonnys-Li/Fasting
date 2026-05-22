//
//  FSTFastingHistoryViewController.m
//  Fasting
//
//  断食历史列表页：用 UITableView 展示所有 FSTFastingRecord 的卡片。
//  点击进入编辑模式（FSTAddRecordViewController initWithRecord:）。
//

#import "FSTFastingHistoryViewController.h"
#import "FSTFastingHistoryRootView.h"
#import "FSTAddRecordViewController.h"
#import "FSTFastingCardCell.h"
#import "FSTFastingTimelineCardView.h"
#import "FSTSessionManager.h"

@interface FSTFastingHistoryViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, copy) NSArray<FSTFastingRecord *> *records;
@end

@implementation FSTFastingHistoryViewController

- (instancetype)init {
    if ((self = [super init])) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)loadView {
    self.view = [FSTFastingHistoryRootView new];
}

- (FSTFastingHistoryRootView *)rootView {
    return (FSTFastingHistoryRootView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rootView.tableView.dataSource = self;
    self.rootView.tableView.delegate   = self;
    __weak typeof(self) weakSelf = self;
    self.rootView.onBackTapped = ^{ [weakSelf.navigationController popViewControllerAnimated:YES]; };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRecords) name:FSTRecordsDidChangeNotification object:nil];
    [self reloadRecords];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadRecords];
}

- (void)reloadRecords {
    self.records = [[FSTSessionManager sharedManager] allRecords];
    [self.rootView.tableView reloadData];
}

#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FSTFastingCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"card" forIndexPath:indexPath];
    [cell.cardView configureWithRecord:self.records[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FSTAddRecordViewController *editViewController = [[FSTAddRecordViewController alloc] initWithRecord:self.records[indexPath.row]];
    editViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editViewController animated:YES];
}

@end
