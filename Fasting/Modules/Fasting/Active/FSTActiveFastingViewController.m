//
//  FSTActiveFastingViewController.m
//  Fasting
//
//  活跃断食主页：圆环倒计时 + 血糖阶段卡 + 可编辑时间行 + 中止按钮。
//  圆环下方的 plan chip 是打开计划选择器的入口；顶部 segment 仅作视觉装饰。
//
//  UI 布局由 FSTActiveFastingRootView 承担；VC 负责 topBar 创建、计时器、
//  状态刷新（refreshUI）、事件处理与导航（导航统一走 FSTAppRouter）。
//

#import "FSTActiveFastingViewController.h"
#import "FSTActiveFastingRootView.h"
#import "FSTFastingIdleViewController.h"
#import "FSTModalDialogViewController.h"
#import "FSTAppRouter.h"
#import "FSTSessionManager.h"
#import "FSTPlan.h"
#import "FSTFastingSegmentControl.h"
#import "FSTFastingPhaseSummaryCard.h"
#import "FSTFastingRingPanelView.h"
#import "FSTRingProgressView.h"
#import "FSTFastingTipsSectionView.h"
#import "FSTFastingTopBar.h"
#import "FSTFastingTimesRow.h"
#import "UIViewController+FSTTimeEditor.h"
#import "FSTTimeEditorSheetViewController.h"
#import "UINavigationController+FSTHelpers.h"
#import "FSTTheme.h"
#import <math.h>

#pragma mark - Layout constants

// TopBar buttons
static const CGFloat kNavButtonDiameter = 46;
static const CGFloat kPlainIconSize     = 34;

// Segment
static const CGFloat kSegmentWidth  = 140;
static const CGFloat kSegmentHeight = 34;

// TopBar
static const CGFloat kTopBarHeight = 80;

@interface FSTActiveFastingViewController ()
@property (nonatomic, strong) FSTActiveFastingRootView *rootView;
@property (nonatomic, strong) FSTFastingPhaseSummaryCard *phaseCard;
@property (nonatomic, strong) FSTFastingRingPanelView *ringPanel;
@property (nonatomic, strong) FSTFastingTimesRow *timesRow;
@property (nonatomic, strong) UIButton *stopButton;
@property (nonatomic, strong) FSTFastingTipsSectionView *tipsSection;
@property (nonatomic, strong) FSTFastingTopBar *topBar;
@property (nonatomic, strong) FSTFastingSegmentControl *segment;
@property (nonatomic, assign) FSTRingDisplayMode displayMode;
@property (nonatomic, assign) BOOL initialStartTimePromptDisplayed;
// 缓存最近一次 refreshUI 判定的达标态；dialog / stop 等异步事件路径直接读，不再重算。
@property (nonatomic, assign) BOOL cachedTargetReached;
@end

@implementation FSTActiveFastingViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.displayMode = FSTRingDisplayElapsed;
    [self installRootView];
    [self installTopBar];
    [self bindRootViewCallbacks];
    [self refreshUI];
    [self showInitialStartTimePromptIfNeeded];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshUI)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)installRootView {
    self.phaseCard = [[FSTFastingPhaseSummaryCard alloc] init];
    self.ringPanel = [[FSTFastingRingPanelView alloc] init];
    self.timesRow  = [[FSTFastingTimesRow alloc] init];
    self.timesRow.startCaption = @"Fast starts";
    self.timesRow.endCaption   = @"Fast ends";
    self.stopButton = [UIButton fst_pillButtonWithTitle:@"END FASTING" style:FSTPillButtonStyleInactive];
    self.tipsSection = [[FSTFastingTipsSectionView alloc] init];

    self.rootView = [[FSTActiveFastingRootView alloc] init];
    [self.view addSubview:self.rootView];
    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.rootView mountPhaseCard:self.phaseCard
                        ringPanel:self.ringPanel
                         timesRow:self.timesRow
                       stopButton:self.stopButton
                      tipsSection:self.tipsSection];
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

#pragma mark - 顶栏

/// share | segment | water：share 用裸图标，water 保留白底圆形；segment 仅作视觉装饰。
/// topBar 必须 install 到 VC.view 顶层（safeArea 锚），因此不放在 RootView 内部。
- (void)installTopBar {
    UIButton *shareButton = [UIButton fst_plainImageButtonWithImageNamed:@"nav_share"
                                                                  size:CGSizeMake(kPlainIconSize, kPlainIconSize)
                                                             tintColor:nil];
    [shareButton addTarget:self action:@selector(handleShareTapped) forControlEvents:UIControlEventTouchUpInside];
    UIButton *waterButton = [UIButton fst_navCircleButtonWithImageNamed:@"nav_water"
                                                               diameter:kNavButtonDiameter];

    self.segment = [[FSTFastingSegmentControl alloc] init];
    self.segment.userInteractionEnabled = NO;

    self.topBar = [[FSTFastingTopBar alloc] init];
    self.topBar.leftButton    = shareButton;
    self.topBar.rightButtons  = @[waterButton];
    self.topBar.centerContent = self.segment;
    self.topBar.contentHeight = kTopBarHeight;
    [self.topBar installInViewController:self];
    [self.rootView anchorContentBelowTopBar:self.topBar];

    [self.segment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kSegmentWidth, kSegmentHeight));
    }];
}

#pragma mark - RootView 回调接线

- (void)bindRootViewCallbacks {
    __weak typeof(self) weakSelf = self;
    [self.phaseCard addTarget:self action:@selector(showPhaseDialog) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self action:@selector(handleStopTapped) forControlEvents:UIControlEventTouchUpInside];

    self.ringPanel.onModeTapped = ^{
        [weakSelf handleModeTapped];
    };
    self.ringPanel.onPlanChipTapped = ^{
        [weakSelf presentPlanPicker];
    };
    self.timesRow.onEditStartTapped = ^{
        [weakSelf handleEditActiveStartTapped];
    };
    self.timesRow.onEditEndTapped = ^{
        [weakSelf handleEditActiveEndTapped];
    };
    self.rootView.onSendFeedbackTapped = ^{
        [weakSelf handleSendFeedbackTapped];
    };
}

#pragma mark - 刷新

- (void)refreshTimerDidFire {
    [self refreshUI];
}

/// 每秒 / 每次通知触发：根据 sessionManager 当前状态推导整页 UI 数据并下发到子视图。
/// 设计：本方法是状态判定的单一权威，VC 其他事件方法只读 cachedXxx 缓存（dialog 等异步路径）。
- (void)refreshUI {
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    // 兜底：sessionInvalid（plan 已被外部清除瞬态）— 直接 pop 避免后续读 nil 字段崩。
    if (![sessionManager hasActiveFasting]) {
        [self.navigationController popToRootViewControllerAnimated:NO];
        return;
    }

    // Timing 派生：保证 target 钳到 ≥1 防除零；fraction 未达标钳到 99 防四舍五入到 100%。
    NSTimeInterval safeElapsed = MAX(0, sessionManager.elapsedSeconds);
    NSTimeInterval safeTarget  = MAX(1, sessionManager.activeTargetDurationSeconds);
    NSTimeInterval remaining   = MAX(0, safeTarget - safeElapsed);
    NSTimeInterval overtime    = MAX(0, safeElapsed - safeTarget);
    CGFloat fraction        = (CGFloat)(safeElapsed / safeTarget);
    CGFloat clampedFraction = MIN(1.0, fraction);
    BOOL targetReached  = safeElapsed >= safeTarget;
    BOOL inOvertime     = (NSInteger)floor(overtime) > 0;
    NSInteger elapsedPercent   = FSTRingElapsedPercent(fraction, targetReached);
    NSInteger remainingPercent = targetReached ? 0 : (100 - elapsedPercent);
    NSInteger overtimePercent  = inOvertime ? MAX(101, (NSInteger)ceil(fraction * 100.0)) : elapsedPercent;

    BOOL isRemainingMode = (self.displayMode == FSTRingDisplayRemaining);
    NSInteger displayedPercent = isRemainingMode ? remainingPercent : elapsedPercent;

    // 圆环三态判定优先级：overtime > complete > active（红覆盖绿）。
    FSTRingPresentationState ringState = inOvertime ? FSTRingPresentationOvertime
                                       : (targetReached ? FSTRingPresentationComplete : FSTRingPresentationActive);

    NSDate *startDate = sessionManager.activeStartDate ?: [NSDate date];
    NSDate *endDate   = [sessionManager activeExpectedEndDate] ?: [startDate dateByAddingTimeInterval:safeTarget];

    NSString *timerCaption = (ringState != FSTRingPresentationActive)
        ? @"Time exceeded"
        : [NSString stringWithFormat:@"%@ %ld%%", isRemainingMode ? @"Remaining time" : @"Elapsed time", (long)displayedPercent];
    NSString *timerText;
    if (ringState == FSTRingPresentationComplete) {
        timerText = @"100%";
    } else if (ringState == FSTRingPresentationOvertime) {
        timerText = [NSString stringWithFormat:@"+%@", FSTFormatHHMMSS(overtime)];
    } else {
        timerText = FSTFormatHHMMSS(isRemainingMode ? remaining : safeElapsed);
    }

    self.ringPanel.presentationState  = ringState;
    self.ringPanel.timerCaption       = timerCaption;
    self.ringPanel.timerText          = timerText;
    self.ringPanel.overtimeDetailText = inOvertime ? [NSString stringWithFormat:@"Elapsed time (%ld%%)", (long)overtimePercent] : nil;
    self.ringPanel.overtimeTotalText  = inOvertime ? FSTFormatHHMMSS(safeElapsed) : nil;
    self.ringPanel.endText            = FSTFormatRelativeDateTime(endDate);
    self.ringPanel.percentText        = [NSString stringWithFormat:@"%ld%%", (long)displayedPercent];
    self.ringPanel.planName           = sessionManager.currentPlan.name ?: @"14-10";
    self.ringPanel.progress           = targetReached ? 1.0 : clampedFraction;
    self.ringPanel.flameProgress      = clampedFraction;
    self.ringPanel.displayMode        = self.displayMode;

    if (targetReached) [self.phaseCard configureForAutophagyState];
    else               [self.phaseCard configureForBloodGlucoseStage];
    [self.tipsSection configureForStage:targetReached ? FSTTipsFastingStageAfter : FSTTipsFastingStageDuring];

    // Stop button — 用户视角：未达标=END（灰底确认弹窗）vs 达标=COMPLETE（绿底直跳 AddRecord）。
    self.stopButton.backgroundColor = targetReached ? [UIColor fst_eatingTimeGreen] : [UIColor fst_buttonInactive];
    [self.stopButton setTitle:targetReached ? @"COMPLETE FASTING" : @"END FASTING" forState:UIControlStateNormal];
    [self.stopButton setTitleColor:targetReached ? [UIColor whiteColor] : [UIColor fst_textHeading] forState:UIControlStateNormal];

    self.timesRow.startText = FSTFormatRelativeDateTime(startDate);
    self.timesRow.endText   = FSTFormatRelativeDateTime(endDate);

    self.cachedTargetReached = targetReached;
}

#pragma mark - 事件

- (void)handleModeTapped {
    self.displayMode = self.displayMode == FSTRingDisplayElapsed ? FSTRingDisplayRemaining : FSTRingDisplayElapsed;
    [self refreshUI];
}

/// 文案 / 图标由达标态当场派生——refreshUI 只缓存 cachedTargetReached 一个判定，不缓存字符串。
- (void)showPhaseDialog {
    BOOL targetReached = self.cachedTargetReached;
    FSTModalDialogViewController *dialog = [[FSTModalDialogViewController alloc] init];
    dialog.iconKind     = FSTModalDialogIconKindAssetImage;
    dialog.iconName     = targetReached ? @"autophagy_stage" : @"blood_glucose_stage";
    dialog.titleText    = targetReached ? @"Autophagy Starts!" : @"Blood Glucose Rise";
    dialog.message      = targetReached
        ? @"Fasting goal reached. Your body is entering the autophagy phase."
        : @"Blood sugar fluctuation is normal in early fasting. Keep going with your plan.";
    dialog.primaryTitle = @"Got it";
    [self presentViewController:dialog animated:YES completion:nil];
}

/// 底部按钮的双分支处理 — 用户视角的语义差异：
///   已达标（targetReached=YES）→ "COMPLETE FASTING"，是正向完成，直接进入 AddRecord 填感受/体重保存；
///   未达标（targetReached=NO） → "END FASTING"，是放弃，先弹确认 dialog（避免误触损失正在进行的断食）。
/// 注意 primary 按钮是 "否"（不放弃）；secondary 才是 "是"（放弃） — 设计上让默认动作偏保守。
- (void)handleStopTapped {
    if (self.cachedTargetReached) {
        [self proceedToFinishFasting];
        return;
    }

    __weak typeof(self) weakSelf = self;
    FSTModalDialogViewController *dialog = [[FSTModalDialogViewController alloc] init];
    dialog.iconKind         = FSTModalDialogIconKindSystemSymbol;
    dialog.iconName         = @"flag.fill";
    dialog.titleText        = @"Stop fasting?";
    dialog.message          = @"Goal not yet reached. End early?";
    dialog.primaryTitle     = @"No";
    dialog.secondaryTitle   = @"Yes";
    dialog.secondaryHandler = ^{
        [weakSelf proceedToFinishFasting];
    };
    [self presentViewController:dialog animated:YES completion:nil];
}

- (void)proceedToFinishFasting {
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    NSDate *startDate = sessionManager.activeStartDate ?: [NSDate date];
    NSDate *endDate   = [NSDate date];
    [FSTAppRouter pushAddRecordFrom:self startDate:startDate endDate:endDate];
}

- (void)enterScheduledReadyFromFutureStartDate:(NSDate *)futureStartDate source:(FSTScheduledReadySource)source {
    if (!futureStartDate) return;
    [[FSTSessionManager sharedManager] scheduleFastingAtFutureDate:futureStartDate source:source];

    UIViewController *planViewController = [self.navigationController fst_firstViewControllerOfClass:[FSTFastingIdleViewController class]];
    if (planViewController) {
        [self.navigationController popToViewController:planViewController animated:YES];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)handleShareTapped {
    [FSTAppRouter presentShareFrom:self ringSnapshot:[self.ringPanel snapshotForSharing]];
}

- (void)handleSendFeedbackTapped {
    [FSTAppRouter pushFeedbackFrom:self];
}

- (void)presentPlanPicker {
    __weak typeof(self) weakSelf = self;
    [FSTAppRouter presentPlanPickerFrom:self onPick:^(FSTPlan *picked) {
        [[FSTSessionManager sharedManager] switchToPlanPreservingState:picked];
        [weakSelf refreshUI];
    }];
}

- (void)handleEditActiveStartTapped {
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    NSTimeInterval planDuration = MAX(1, sessionManager.targetDurationSeconds);
    NSString *alignText = [NSString stringWithFormat:@"Align with %@", sessionManager.currentPlan.name ?: @"14-10"];
    __weak typeof(self) weakSelf = self;
    // Align 行为：StartFast 模式 — chip 默认绿色可点；点 chip 把 start 拉到 (now - planDuration)
    // 让现在正好是完成点；用户改 picker 后 chip 重新可点（参考 demo1）。
    [self fst_presentTimeEditorWithTitle:@"When did you start your fast?"
                             initialDate:[NSDate date]      // 默认吸附到现在
                             minimumDate:nil
                             maximumDate:nil
                           alignChipText:alignText
                    alignDurationSeconds:planDuration
                               alignMode:FSTTimeEditorAlignModeStartFast
                      alignReferenceDate:nil
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
    NSDate *minimumDate = [startDate dateByAddingTimeInterval:60.0];
    NSString *alignText = [NSString stringWithFormat:@"Align with %@", sessionManager.currentPlan.name ?: @"14-10"];
    __weak typeof(self) weakSelf = self;
    // Align 行为：EndFast 模式 — chip 默认灰色（防误触）；用户改 picker 后 chip 启用；
    // 点 chip 把 end 拉到 (startDate + planDuration)，chip 又变灰（参考 demo1）。
    [self fst_presentTimeEditorWithTitle:@"Your fast is expected to end at"
                             initialDate:currentEnd
                             minimumDate:minimumDate
                             maximumDate:nil
                           alignChipText:alignText
                    alignDurationSeconds:planDuration
                               alignMode:FSTTimeEditorAlignModeEndFast
                      alignReferenceDate:startDate
                                onCommit:^(NSDate *pickedDate, BOOL aligned) {
        [[FSTSessionManager sharedManager] editActiveEndDate:pickedDate alignWithPlan:aligned];
        [weakSelf refreshUI];
    }];
}
#pragma mark - 跳转问题解决
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
    FSTTimeEditorSheetViewController *sheet = [[FSTTimeEditorSheetViewController alloc] init];
    sheet.titleText   = @"When to start fasting?";
    sheet.initialDate = initialDate;
    sheet.alignMode   = FSTTimeEditorAlignModeStartFast;
    sheet.onCommit = ^(NSDate *pickedDate, BOOL aligned) {
        if ([pickedDate compare:[NSDate date]] == NSOrderedDescending) {
            [weakSelf enterScheduledReadyFromFutureStartDate:pickedDate source:FSTScheduledReadySourcePreStart];
        } else {
            [[FSTSessionManager sharedManager] editActiveStartDate:pickedDate alignWithPlan:YES];
            [weakSelf refreshUI];
        }
    };
    UIViewController *hostViewController = self.tabBarController ?: self.navigationController ?: self;
    [hostViewController addChildViewController:sheet];
    [hostViewController.view addSubview:sheet.view];
    [sheet.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(hostViewController.view);
    }];
    [sheet didMoveToParentViewController:hostViewController];
}

@end
