//
//  FSTActiveFastingViewController.m
//  Fasting
//
//  活跃断食主页：圆环倒计时 + 血糖阶段卡 + 可编辑时间行 + 中止按钮。
//  圆环下方的 plan chip 是打开计划选择器的入口；顶部 segment 仅作视觉装饰。
//
//  UI 布局由 FSTActiveFastingRootView 承担；VC 负责 topBar 创建、计时器、
//  状态刷新（refreshUI）、事件处理与导航。
//

#import "FSTActiveFastingViewController.h"
#import "FSTActiveFastingRootView.h"
#import "FSTAddRecordViewController.h"
#import "FSTDailyPlanViewController.h"
#import "FSTModalDialogViewController.h"
#import "FSTSessionManager.h"
#import "FSTPlan.h"
#import "FSTPlanSelectViewController.h"
#import "FSTFastingSegmentControl.h"
#import "FSTFastingPhaseSummaryCard.h"
#import "FSTFastingRingPanelView.h"
#import "FSTFastingTipsSectionView.h"
#import "FSTFastingTopBar.h"
#import "FSTFastingTimesRow.h"
#import "UIButton+FST.h"
#import "UIViewController+FSTTimeEditor.h"
#import "FSTTimeEditorSheetViewController.h"
#import "UINavigationController+FSTHelpers.h"
#import "FSTTheme.h"
#import "UIColor+FST.h"
#import "FSTActiveFastingDisplayState.h"
#import "FSTFastingTimingService.h"
#import "FSTSendFeedbackViewController.h"
#import "FSTShareCardViewController.h"

static const CGFloat kFSTActiveFastingNavButtonDiameter = 46;
static const CGFloat kFSTActiveFastingPlainIconSize     = 34;
static const CGFloat kFSTActiveFastingSegmentWidth      = 140;
static const CGFloat kFSTActiveFastingSegmentHeight     = 34;
static const CGFloat kFSTActiveFastingTopBarHeight      = 80;

@interface FSTActiveFastingViewController ()
@property (nonatomic, strong) FSTFastingTopBar *topBar;
@property (nonatomic, strong) FSTFastingSegmentControl *segment;
@property (nonatomic, assign) FSTRingDisplayMode displayMode;
@property (nonatomic, assign) BOOL fastingTargetReached;
@property (nonatomic, assign) BOOL initialStartTimePromptDisplayed;
@end

@implementation FSTActiveFastingViewController

#pragma mark - 生命周期

- (void)loadView {
    self.view = [FSTActiveFastingRootView new];
}

- (FSTActiveFastingRootView *)rootView {
    return (FSTActiveFastingRootView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.displayMode = FSTRingDisplayElapsed;
    [self installTopBar];
    [self bindRootViewCallbacks];
    [self refreshUI];
    [self showInitialStartTimePromptIfNeeded];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshUI)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startRefreshTimer];
    [self refreshUI];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRefreshTimer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showInitialStartTimePromptIfNeeded];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopRefreshTimer];
}

#pragma mark - 顶栏

/// share | segment | water：share 用裸图标，water 保留白底圆形；segment 仅作视觉装饰。
/// topBar 必须 install 到 VC.view 顶层（safeArea 锚），因此不放在 RootView 内部。
- (void)installTopBar {
    UIButton *shareButton = [UIButton fst_navPlainButtonWithImageNamed:@"nav_share"
                                                                  size:CGSizeMake(kFSTActiveFastingPlainIconSize, kFSTActiveFastingPlainIconSize)];
    [shareButton addTarget:self action:@selector(handleShareTapped) forControlEvents:UIControlEventTouchUpInside];
    UIButton *waterButton = [UIButton fst_navCircleButtonWithImageNamed:@"nav_water"
                                                               diameter:kFSTActiveFastingNavButtonDiameter];

    self.segment = [FSTFastingSegmentControl new];
    self.segment.userInteractionEnabled = NO;

    self.topBar = [[FSTFastingTopBar alloc] initWithLeftButton:shareButton
                                                  rightButtons:@[waterButton]
                                                 centerContent:self.segment
                                                 contentHeight:kFSTActiveFastingTopBarHeight];
    [self.topBar installInViewController:self];

    // topBar 装好后补齐 rootView.scrollView 的顶部约束（RootView 内部仅约束了 left/right/bottom）
    [self.rootView.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBar.mas_bottom);
    }];

    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kFSTActiveFastingPlainIconSize, kFSTActiveFastingPlainIconSize));
    }];
    [waterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kFSTActiveFastingNavButtonDiameter, kFSTActiveFastingNavButtonDiameter));
    }];
    [self.segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kFSTActiveFastingSegmentWidth, kFSTActiveFastingSegmentHeight));
    }];
}

#pragma mark - RootView 回调接线

- (void)bindRootViewCallbacks {
    __weak typeof(self) weakSelf = self;
    FSTActiveFastingRootView *rootView = self.rootView;
    rootView.onPhaseCardTapped = ^{ [weakSelf showPhaseDialog]; };
    rootView.onRingModeTapped  = ^{ [weakSelf handleModeTapped]; };
    rootView.onPlanChipTapped  = ^{ [weakSelf presentPlanPicker]; };
    rootView.onEditStartTapped = ^{ [weakSelf handleEditActiveStartTapped]; };
    rootView.onEditEndTapped   = ^{ [weakSelf handleEditActiveEndTapped]; };
    rootView.onStopTapped      = ^{ [weakSelf handleStopTapped]; };
    rootView.onSendFeedbackTapped = ^{ [weakSelf handleSendFeedbackTapped]; };
}

#pragma mark - 刷新

- (void)refreshTimerDidFire {
    [self refreshUI];
}

- (void)refreshUI {
    FSTActiveFastingDisplayState *state = [FSTActiveFastingDisplayState currentStateWithDisplayMode:self.displayMode];
    if (state.sessionInvalid) {
        [self.navigationController popToRootViewControllerAnimated:NO];
        return;
    }
    self.fastingTargetReached = state.targetReached;
    [self applyDisplayState:state];
}

- (void)applyDisplayState:(FSTActiveFastingDisplayState *)state {
    FSTActiveFastingRootView *rootView = self.rootView;

    rootView.ringPanel.presentationState = state.ringState;
    rootView.ringPanel.timerCaption      = state.timerCaption;
    rootView.ringPanel.timerText         = state.timerText;
    rootView.ringPanel.overtimeDetailText = state.overtimeDetailText;
    rootView.ringPanel.overtimeTotalText  = state.overtimeTotalText;
    rootView.ringPanel.endText           = state.endText;
    rootView.ringPanel.percentText       = state.percentText;
    rootView.ringPanel.planName          = state.planName;
    rootView.ringPanel.progress          = state.ringProgress;
    rootView.ringPanel.flameProgress     = state.flameProgress;
    rootView.ringPanel.displayMode       = self.displayMode;

    if (state.showAutophagyPhase) {
        [rootView.phaseCard configureForAutophagyState];
    } else {
        [rootView.phaseCard configureForBloodGlucoseStage];
    }
    [rootView.tipsSection configureForStage:state.tipsStage];

    rootView.stopButton.backgroundColor = state.stopButtonBackgroundColor;
    [rootView.stopButton setTitle:state.stopButtonTitle forState:UIControlStateNormal];
    [rootView.stopButton setTitleColor:state.stopButtonTitleColor forState:UIControlStateNormal];

    rootView.timesRow.startText = state.startText;
    rootView.timesRow.endText   = state.endTimeText;
}

#pragma mark - 事件

- (void)handleModeTapped {
    self.displayMode = self.displayMode == FSTRingDisplayElapsed ? FSTRingDisplayRemaining : FSTRingDisplayElapsed;
    [self refreshUI];
}

- (void)showPhaseDialog {
    BOOL targetReached = [self isCurrentFastingTargetReached];
    NSString *title = targetReached ? @"Autophagy Starts!" : @"Blood Glucose Rise";
    NSString *message = targetReached
        ? @"Fasting goal reached. Your body is entering the autophagy phase."
        : @"Blood sugar fluctuation is normal in early fasting. Keep going with your plan.";
    NSString *iconName = targetReached ? @"autophagy_stage" : @"blood_glucose_stage";
    FSTModalDialogViewController *dialog =
        [[FSTModalDialogViewController alloc] initWithIconImageName:iconName
                                                              title:title
                                                            message:message
                                                       primaryTitle:@"Got it"
                                                     secondaryTitle:nil
                                                     primaryHandler:nil
                                                   secondaryHandler:nil];
    [self presentViewController:dialog animated:YES completion:nil];
}

/// 底部按钮的双分支处理 — 用户视角的语义差异：
///   已达标（targetReached=YES）→ "COMPLETE FASTING"，是正向完成，直接进入 AddRecord 填感受/体重保存；
///   未达标（targetReached=NO） → "END FASTING"，是放弃，先弹确认 dialog（避免误触损失正在进行的断食）。
/// 注意 primary 按钮是 "否"（不放弃）；secondary 才是 "是"（放弃） — 设计上让默认动作偏保守。
- (void)handleStopTapped {
    if ([self isCurrentFastingTargetReached]) {
        [self proceedToFinishFasting];
        return;
    }

    __weak typeof(self) weakSelf = self;
    FSTModalDialogViewController *dialog =
        [[FSTModalDialogViewController alloc] initWithIconSystemName:@"flag.fill"
                                                               title:@"Stop fasting?"
                                                             message:@"Goal not yet reached. End early?"
                                                        primaryTitle:@"No"
                                                      secondaryTitle:@"Yes"
                                                      primaryHandler:nil
                                                    secondaryHandler:^{
        [weakSelf proceedToFinishFasting];
    }];
    [self presentViewController:dialog animated:YES completion:nil];
}

- (BOOL)isCurrentFastingTargetReached {
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    FSTFastingTiming *timing = [FSTFastingTimingService timingForElapsedSeconds:sessionManager.elapsedSeconds
                                                         targetDurationSeconds:sessionManager.activeTargetDurationSeconds];
    return timing.targetReached || self.fastingTargetReached;
}

- (void)proceedToFinishFasting {
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    NSDate *startDate = sessionManager.activeStartDate ?: [NSDate date];
    NSDate *endDate   = [NSDate date];
    FSTAddRecordViewController *addRecordViewController = [[FSTAddRecordViewController alloc] initWithStartDate:startDate endDate:endDate];
    addRecordViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addRecordViewController animated:YES];
}

- (void)enterScheduledReadyFromFutureStartDate:(NSDate *)futureStartDate source:(FSTScheduledReadySource)source {
    if (!futureStartDate) return;
    FSTSessionManager *manager = [FSTSessionManager sharedManager];
    [manager cancelActiveFasting];
    [manager setNextFastingStartDate:futureStartDate];
    [manager markScheduledReadyWithSource:source anchorDate:[NSDate date]];

    UIViewController *planViewController = [self.navigationController fst_firstViewControllerOfClass:[FSTDailyPlanViewController class]];
    if (planViewController) {
        [self.navigationController popToViewController:planViewController animated:YES];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)handleShareTapped {
    UIImage *ringSnapshot = [self.rootView.ringPanel snapshotForSharing];
    FSTShareCardViewController *shareVC = [[FSTShareCardViewController alloc] initWithRingSnapshot:ringSnapshot];
    [self presentViewController:shareVC animated:YES completion:nil];
}

- (void)handleSendFeedbackTapped {
    FSTSendFeedbackViewController *vc = [FSTSendFeedbackViewController new];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)presentPlanPicker {
    FSTPlanSelectViewController *picker = [FSTPlanSelectViewController new];
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    __weak typeof(self) weakSelf = self;
    picker.onPlanPicked = ^(FSTPlan *picked) {
        [[FSTSessionManager sharedManager] switchToPlanPreservingState:picked];
        [weakSelf refreshUI];
    };
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)handleEditActiveStartTapped {
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    NSDate *savedStartDate = sessionManager.activeStartDate ?: [NSDate date];
    NSTimeInterval planDuration = MAX(1, sessionManager.targetDurationSeconds);
    NSDate *expectedEndDate = [sessionManager activeExpectedEndDate] ?: [savedStartDate dateByAddingTimeInterval:planDuration];
    NSDate *alignedStartDate = [expectedEndDate dateByAddingTimeInterval:-planDuration];
    NSString *alignText = [NSString stringWithFormat:@"Align with %@", sessionManager.currentPlan.name ?: @"14-10"];
    __weak typeof(self) weakSelf = self;
    [self fst_presentTimeEditorWithTitle:@"When did you start your fast?"
                             initialDate:[NSDate date]      // 默认吸附到现在，不用滚到今天
                             minimumDate:nil
                             maximumDate:nil
                           alignChipText:alignText
                             alignedDate:alignedStartDate
                         initiallyAligned:NO
                                 onCommit:^(NSDate *pickedDate, BOOL aligned) {
        FSTSessionManager *manager = [FSTSessionManager sharedManager];
        if ([pickedDate compare:[NSDate date]] == NSOrderedDescending) {
            [weakSelf enterScheduledReadyFromFutureStartDate:pickedDate source:FSTScheduledReadySourceFromActiveSession];
        } else {
            [manager editActiveStartDate:pickedDate alignWithPlan:aligned];
            [weakSelf refreshUI];
        }
    }];
}

- (void)handleEditActiveEndTapped {
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    NSTimeInterval planDuration = MAX(1, sessionManager.targetDurationSeconds);
    NSDate *startDate = sessionManager.activeStartDate ?: [NSDate date];
    NSDate *currentEnd = [sessionManager activeExpectedEndDate] ?: [startDate dateByAddingTimeInterval:planDuration];
    NSDate *alignedEndDate = [startDate dateByAddingTimeInterval:planDuration];
    NSDate *minimumDate = [startDate dateByAddingTimeInterval:60.0];
    NSString *alignText = [NSString stringWithFormat:@"Align with %@", sessionManager.currentPlan.name ?: @"14-10"];
    __weak typeof(self) weakSelf = self;
    [self fst_presentTimeEditorWithTitle:@"Your fast is expected to end at"
                             initialDate:currentEnd
                             minimumDate:minimumDate
                             maximumDate:nil
                           alignChipText:alignText
                             alignedDate:alignedEndDate
                         initiallyAligned:NO
                                 onCommit:^(NSDate *pickedDate, BOOL aligned) {
        [[FSTSessionManager sharedManager] editActiveEndDate:pickedDate alignWithPlan:aligned];
        [weakSelf refreshUI];
    }];
}

- (void)showInitialStartTimePromptIfNeeded {
    // promptsForStartTimeOnFirstAppear 是一次性 token。优先在 viewDidLoad 装载 child overlay，
    // 让 picker 成为 ActiveFasting 首帧的一部分；viewDidAppear 只作为兜底，避免外部晚赋值时漏弹。
    if (!self.promptsForStartTimeOnFirstAppear || self.initialStartTimePromptDisplayed) return;
    self.promptsForStartTimeOnFirstAppear = NO;
    self.initialStartTimePromptDisplayed = YES;
    [self presentInitialStartTimePrompt];
}

- (void)presentInitialStartTimePrompt {
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    NSDate *initialDate = sessionManager.activeStartDate ?: [NSDate date];
    __weak typeof(self) weakSelf = self;
    FSTTimeEditorSheetViewController *sheet =
        [[FSTTimeEditorSheetViewController alloc] initWithTitle:@"When to start fasting?"
                                                    initialDate:initialDate
                                                    minimumDate:nil
                                                    maximumDate:nil
                                                  alignChipText:nil
                                                    alignedDate:nil
                                                initiallyAligned:NO
                                                        onCommit:^(NSDate *pickedDate, BOOL aligned) {
        if ([pickedDate compare:[NSDate date]] == NSOrderedDescending) {
            [weakSelf enterScheduledReadyFromFutureStartDate:pickedDate source:FSTScheduledReadySourcePreStart];
        } else {
            [[FSTSessionManager sharedManager] editActiveStartDate:pickedDate alignWithPlan:YES];
            [weakSelf refreshUI];
        }
    }];
    UIViewController *hostViewController = self.tabBarController ?: self.navigationController ?: self;
    [hostViewController addChildViewController:sheet];
    [hostViewController.view addSubview:sheet.view];
    [sheet.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(hostViewController.view);
    }];
    [sheet didMoveToParentViewController:hostViewController];
}

@end
