//
//  FSTPlanConfirmViewController.m
//  Fasting
//

#import "FSTPlanConfirmViewController.h"
#import "FSTPlanConfirmRootView.h"
#import "FSTPlanConfirmTimelineView.h"
#import "FSTActiveFastingViewController.h"
#import "FSTFastingIdleViewController.h"
#import "FSTSessionManager.h"
#import "FSTAppRouter.h"
#import "FSTPlan.h"
#import "UIViewController+FSTTimeEditor.h"
#import "UINavigationController+FSTHelpers.h"
#import "FSTTheme.h"

@interface FSTPlanConfirmViewController ()
@property (nonatomic, strong) FSTPlanConfirmRootView *rootView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) FSTPlanConfirmTimelineView *timelineView;

@property (nonatomic, strong, readwrite) FSTPlan *plan;
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
    [self installRootView];
    [self bindCallbacks];
    [self refreshPlanLabels];
}

- (void)installRootView {
    self.titleLabel = [UILabel fst_labelWithText:nil
                                            font:FSTFontBold(34)
                                           color:[UIColor fst_textPrimary]
                                       alignment:NSTextAlignmentCenter];
    self.timelineView = [[FSTPlanConfirmTimelineView alloc] init];

    self.rootView = [[FSTPlanConfirmRootView alloc] init];
    [self.view addSubview:self.rootView];
    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.rootView mountTitleLabel:self.titleLabel timelineView:self.timelineView];
}

- (void)bindCallbacks {
    __weak typeof(self) weakSelf = self;
    self.rootView.onBackTapped = ^{
        [weakSelf handleBackTapped];
    };
    self.rootView.onStartTapped = ^{
        [weakSelf handleStartTapped];
    };
    self.rootView.onChangePlanTapped = ^{
        [weakSelf handleChangePlanTapped];
    };
    self.timelineView.onEditStartTapped = ^{
        [weakSelf handleEditStartTapped];
    };
}

#pragma mark - 状态

- (void)refreshPlanLabels {
    self.titleLabel.text = self.plan.name;
    NSDate *startDate = self.selectedStartDate ?: [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:self.plan.fastingHours * 3600.0];
    self.timelineView.startDate = startDate;
    self.timelineView.endDate   = endDate;
}

#pragma mark - 事件

- (void)handleBackTapped { [self.navigationController popViewControllerAnimated:YES]; }

- (void)handleChangePlanTapped {
    // 此处尚未开始断食，只换本地选中的 plan（不走 switchToPlanPreservingState:，那是 active session 用）。
    __weak typeof(self) weakSelf = self;
    [FSTAppRouter presentPlanPickerFrom:self onPick:^(FSTPlan *picked) {
        if (!picked) return;
        weakSelf.plan = picked;
        [weakSelf refreshPlanLabels];
    }];
}

- (void)handleEditStartTapped {
    NSDate *initialDate = self.selectedStartDate ?: [NSDate date];
    __weak typeof(self) weakSelf = self;
    // 无 align chip 场景，走 Category 简版接口
    [self fst_presentTimeEditorWithTitle:@"When to start fasting?"
                             initialDate:initialDate
                                onCommit:^(NSDate *pickedDate) {
        weakSelf.selectedStartDate = pickedDate ?: [NSDate date];
        [weakSelf refreshPlanLabels];
    }];
}

- (void)handleStartTapped {
    NSDate *startDate = self.selectedStartDate ?: [NSDate date];
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];

    // 预选时间在未来 → 直接预约，不弹 picker
    if ([startDate compare:[NSDate date]] == NSOrderedDescending) {
        [sessionManager switchToPlanPreservingState:self.plan];
        [sessionManager setNextFastingStartDate:startDate];
        [sessionManager markScheduledReadyWithSource:FSTScheduledReadySourcePreStart anchorDate:[NSDate date]];
        if (self.onFastingStarted) {
            self.onFastingStarted();
            return;
        }

        UIViewController *planViewController = [self.navigationController fst_firstViewControllerOfClass:[FSTFastingIdleViewController class]];
        if (planViewController) {
            [self.navigationController popToViewController:planViewController animated:YES];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        return;
    }

    [sessionManager startFastingWithPlan:self.plan startDate:startDate];
    if (self.onFastingStarted) {
        self.onFastingStarted();
        return;
    }

    FSTActiveFastingViewController *activeFastingViewController = [[FSTActiveFastingViewController alloc] init];
    [self.navigationController pushViewController:activeFastingViewController animated:YES];
}

@end
