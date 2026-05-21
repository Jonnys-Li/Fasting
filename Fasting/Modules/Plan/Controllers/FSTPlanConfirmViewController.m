//
//  FSTPlanConfirmViewController.m
//  Fasting
//

#import "FSTPlanConfirmViewController.h"
#import "FSTPlanConfirmTimelineView.h"
#import "FSTPlanRecommendBoardView.h"
#import "FSTPlanPrepCardView.h"
#import "FSTActiveFastingViewController.h"
#import "FSTDailyPlanViewController.h"
#import "FSTSessionManager.h"
#import "UIButton+FSTNavCircle.h"
#import "UIViewController+FSTTimeEditor.h"
#import "UINavigationController+FSTHelpers.h"
#import "FSTTheme.h"

@interface FSTPlanConfirmViewController ()
@property (nonatomic, strong) FSTPlan *plan;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) FSTPlanConfirmTimelineView *timelineView;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) FSTPlanRecommendBoardView *recommendBoardView;
@property (nonatomic, strong) FSTPlanPrepCardView *prepCardView;
@property (nonatomic, strong) NSDate *selectedStartDate;
@end

@implementation FSTPlanConfirmViewController

- (instancetype)initWithPlan:(FSTPlan *)plan {
    if ((self = [super init])) {
        _plan = plan;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedStartDate = [NSDate date];
    [self buildScrollContainer];
    [self buildHeader];
    [self buildBody];
    [self refreshPlanLabels];
}

#pragma mark - 构建 UI

- (void)buildScrollContainer {
    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self.view);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
}

- (void)buildHeader {
    UIButton *backButton = [UIButton fst_navPlainButtonWithImageNamed:@"nav_back" size:CGSizeMake(34, 34)];
    [backButton addTarget:self action:@selector(handleBackTapped) forControlEvents:UIControlEventTouchUpInside];
    UIButton *shareButton = [UIButton fst_navPlainButtonWithImageNamed:@"nav_share" size:CGSizeMake(34, 34)];
    [self.view addSubview:backButton];
    [self.view addSubview:shareButton];

    self.titleLabel = [UILabel new];
    self.titleLabel.font = FSTFontBold(34);
    self.titleLabel.textColor = [UIColor fst_textPrimary];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.titleLabel];

    UIImageView *chevronImageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.down"]];
    chevronImageView.tintColor = [UIColor fst_textSecondary];
    chevronImageView.backgroundColor = [UIColor fst_ringTrack];
    chevronImageView.layer.cornerRadius = 14;
    chevronImageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:chevronImageView];

    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(30);
        make.left.equalTo(self.view).offset(20);
        make.size.mas_equalTo(CGSizeMake(34, 34));
    }];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backButton);
        make.right.equalTo(self.view).offset(-28);
        make.size.mas_equalTo(CGSizeMake(34, 34));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(96);
        make.centerX.equalTo(self.contentView);
    }];
    [chevronImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(10);
        make.centerY.equalTo(self.titleLabel);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
}

/// 时间轴 + 开始按钮 + 推荐 + 准备提示，依次纵向排列。
- (void)buildBody {
    self.timelineView = [FSTPlanConfirmTimelineView new];
    __weak typeof(self) weakSelf = self;
    self.timelineView.onEditStartTapped = ^{ [weakSelf handleEditStartTapped]; };
    self.startButton = [UIButton fst_greenPillButtonWithTitle:@"开始断食"];
    self.startButton.layer.cornerRadius = 30;
    self.startButton.layer.shadowColor = [UIColor fst_primaryGreen].CGColor;
    self.startButton.layer.shadowOpacity = 0.22;
    self.startButton.layer.shadowOffset = CGSizeMake(0, 10);
    self.startButton.layer.shadowRadius = 20;
    self.startButton.titleLabel.font = FSTFontBold(19);
    [self.startButton addTarget:self action:@selector(handleStartTapped) forControlEvents:UIControlEventTouchUpInside];

    self.recommendBoardView = [FSTPlanRecommendBoardView new];
    self.recommendBoardView.onCardTapped = ^(FSTPlan *selectedPlan) {
        weakSelf.plan = selectedPlan;
        [weakSelf refreshPlanLabels];
    };

    self.prepCardView = [FSTPlanPrepCardView new];

    for (UIView *subview in @[self.timelineView, self.startButton, self.recommendBoardView, self.prepCardView]) {
        [self.contentView addSubview:subview];
    }

    [self.timelineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(58);
        make.left.right.equalTo(self.contentView);
    }];
    [self.startButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timelineView.mas_bottom).offset(54);
        make.left.right.equalTo(self.contentView).inset(46);
        make.height.equalTo(@60);
    }];
    [self.recommendBoardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startButton.mas_bottom).offset(44);
        make.left.right.equalTo(self.contentView);
    }];
    [self.prepCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.recommendBoardView.mas_bottom).offset(34);
        make.left.right.equalTo(self.contentView).inset(30);
        make.bottom.equalTo(self.contentView).offset(-120);
    }];
}

#pragma mark - 状态

- (void)refreshPlanLabels {
    self.titleLabel.text = self.plan.name;
    NSDate *startDate = self.selectedStartDate ?: [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:self.plan.fastingHours * 3600.0];
    self.timelineView.startDate = startDate;
    self.timelineView.endDate = endDate;
}

#pragma mark - 事件

- (void)handleBackTapped { [self.navigationController popViewControllerAnimated:YES]; }

- (void)handleEditStartTapped {
    NSDate *initialDate = self.selectedStartDate ?: [NSDate date];
    __weak typeof(self) weakSelf = self;
    [self fst_presentTimeEditorWithTitle:@"什么时候开始断食？"
                             initialDate:initialDate
                             minimumDate:nil
                             maximumDate:nil
                           alignChipText:nil
                             alignedDate:nil
                         initiallyAligned:NO
                                 onCommit:^(NSDate *pickedDate, BOOL aligned) {
        weakSelf.selectedStartDate = pickedDate ?: [NSDate date];
        [weakSelf refreshPlanLabels];
    }];
}

- (void)handleStartTapped {
    NSDate *startDate = self.selectedStartDate ?: [NSDate date];
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    if ([startDate compare:[NSDate date]] == NSOrderedDescending) {
        [sessionManager switchToPlanPreservingState:self.plan];
        [sessionManager setNextFastingStartDate:startDate];
        [sessionManager markScheduledReadyWithSource:FSTScheduledReadySourcePreStart anchorDate:[NSDate date]];
        if (self.onFastingStarted) {
            self.onFastingStarted();
            return;
        }

        UIViewController *planViewController = [self.navigationController fst_firstViewControllerOfClass:[FSTDailyPlanViewController class]];
        if (planViewController) {
            [self.navigationController popToViewController:planViewController animated:YES];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        return;
    }

    [sessionManager startFastingWithPlan:self.plan startDate:startDate];
    if (self.onFastingStarted) {
        [sessionManager requestActiveStartDatePrompt];
        self.onFastingStarted();
        return;
    }

    FSTActiveFastingViewController *activeFastingViewController = [FSTActiveFastingViewController new];
    activeFastingViewController.promptsForStartTimeOnFirstAppear = YES;
    [self.navigationController pushViewController:activeFastingViewController animated:YES];
}

@end
