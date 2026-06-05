//
//  FSTPlanConfirmViewController.m
//  Fasting
//

#import "FSTPlanConfirmViewController.h"
#import "FSTPlanConfirmRootView.h"
#import "FSTPlanConfirmTimelineView.h"
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
                                           color:[UIColor fst_textPrimary]];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
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
    self.timelineView.onEditStartTapped = ^{
        [weakSelf handleEditStartTapped];
    };
}

#pragma mark - 状态

- (void)refreshPlanLabels {
    self.titleLabel.text = self.plan.name;
    [self.rootView setPlanFastingHours:self.plan.fastingHours eatingHours:self.plan.eatingHours];
    NSDate *startDate = self.selectedStartDate ?: [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:self.plan.fastingHours * 3600.0];
    self.timelineView.startDate = startDate;
    self.timelineView.endDate   = endDate;
}

#pragma mark - 事件

- (void)handleBackTapped {
    [self.navigationController popViewControllerAnimated:YES];
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

    // 预选时间在未来 → 直接预约，不弹 picker（与 Active 页把 Start 改到未来一致）。
    if ([startDate compare:[NSDate date]] == NSOrderedDescending) {
        [sessionManager switchToPlanPreservingState:self.plan];
        // 必须走原子方法：它内含 cancelActiveFasting，清掉可能残留的 active 起点。
        // 否则 hasActiveFasting 仍为真，IdleVC 会 push Active 而非 Ready 倒计时环（bug：未来开始没进 Ready）。
        [sessionManager scheduleFastingAtFutureDate:startDate source:FSTScheduledReadySourcePreStart];
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

    [FSTAppRouter pushActiveFastingFrom:self promptForStartTime:NO];
}

@end
