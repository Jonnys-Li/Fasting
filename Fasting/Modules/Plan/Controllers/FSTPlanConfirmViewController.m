//
//  FSTPlanConfirmViewController.m
//  Fasting
//

#import "FSTPlanConfirmViewController.h"
#import "FSTPlanConfirmRootView.h"
#import "FSTPlanConfirmTimelineView.h"
#import "FSTActiveFastingViewController.h"
#import "FSTDailyPlanViewController.h"
#import "FSTSessionManager.h"
#import "UIViewController+FSTTimeEditor.h"
#import "UINavigationController+FSTHelpers.h"

@interface FSTPlanConfirmViewController ()
@property (nonatomic, strong) FSTPlan *plan;
@property (nonatomic, strong) NSDate *selectedStartDate;
@end

@implementation FSTPlanConfirmViewController

- (instancetype)initWithPlan:(FSTPlan *)plan {
    if ((self = [super init])) {
        _plan = plan;
    }
    return self;
}

- (void)loadView {
    self.view = [FSTPlanConfirmRootView new];
}

- (FSTPlanConfirmRootView *)rootView {
    return (FSTPlanConfirmRootView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedStartDate = [NSDate date];

    __weak typeof(self) weakSelf = self;
    self.rootView.onBackTapped = ^{ [weakSelf handleBackTapped]; };
    self.rootView.onStartTapped = ^{ [weakSelf handleStartTapped]; };
    self.rootView.onEditStartTapped = ^{ [weakSelf handleEditStartTapped]; };

    [self refreshPlanLabels];
}

#pragma mark - 状态

- (void)refreshPlanLabels {
    self.rootView.titleLabel.text = self.plan.name;
    NSDate *startDate = self.selectedStartDate ?: [NSDate date];
    NSDate *endDate = [startDate dateByAddingTimeInterval:self.plan.fastingHours * 3600.0];
    self.rootView.timelineView.startDate = startDate;
    self.rootView.timelineView.endDate = endDate;
}

#pragma mark - 事件

- (void)handleBackTapped { [self.navigationController popViewControllerAnimated:YES]; }

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
        self.onFastingStarted();
        return;
    }

    FSTActiveFastingViewController *activeFastingViewController = [FSTActiveFastingViewController new];
    [self.navigationController pushViewController:activeFastingViewController animated:YES];
}

@end
