//
//  FSTFastingHistoryViewController.m
//  Fasting
//
//  断食历史列表页：用 UITableView 展示所有 FSTFastingRecord 的卡片。
//  点击进入编辑模式（FSTAddRecordViewController initWithRecord:）。
//

#import "FSTFastingHistoryViewController.h"
#import "FSTAddRecordViewController.h"
#import "FSTFastingCardCell.h"
#import "FSTFastingTimelineCardView.h"
#import "FSTSessionManager.h"
#import "UIButton+FSTNavCircle.h"
#import "FSTTheme.h"

@interface FSTFastingHistoryViewController () <UITableViewDataSource, UITableViewDelegate>
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
    [self buildLayout];
    [self reloadRecords];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRecords) name:FSTRecordsDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadRecords];
}

/// 顶部返回 + 标题 + 分享按钮 + "今天" 标签 + 列表。
- (void)buildLayout {
    UIButton *backButton = [UIButton fst_navPlainButtonWithImageNamed:@"nav_back" size:CGSizeMake(34, 34)];
    [backButton addTarget:self action:@selector(handleBackTapped) forControlEvents:UIControlEventTouchUpInside];

    UILabel *titleLabel = [UILabel fst_subtitleLabelWithText:@"时间轴"];
    titleLabel.textAlignment = NSTextAlignmentCenter;

    UIButton *shareButton = [UIButton fst_navPlainButtonWithImageNamed:@"nav_share" size:CGSizeMake(34, 34)];

    UILabel *todayLabel = [UILabel new];
    todayLabel.text = @"今天";
    todayLabel.font = FSTFontBold(18);
    todayLabel.textColor = [UIColor fst_textSecondary];
    todayLabel.textAlignment = NSTextAlignmentCenter;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = 264;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 24, 0);
    [self.tableView registerClass:[FSTFastingCardCell class] forCellReuseIdentifier:@"card"];

    for (UIView *subview in @[backButton, titleLabel, shareButton, todayLabel, self.tableView]) [self.view addSubview:subview];

    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(25);
        make.left.equalTo(self.view).offset(22);
        make.size.mas_equalTo(CGSizeMake(34, 34));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backButton);
        make.centerX.equalTo(self.view);
    }];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backButton);
        make.right.equalTo(self.view).offset(-22);
        make.size.mas_equalTo(CGSizeMake(34, 34));
    }];
    [todayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backButton.mas_bottom).offset(46);
        make.centerX.equalTo(self.view);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(todayLabel.mas_bottom).offset(22);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)reloadRecords {
    self.records = [[FSTSessionManager sharedManager] allRecords];
    [self.tableView reloadData];
}

- (void)handleBackTapped { [self.navigationController popViewControllerAnimated:YES]; }

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
