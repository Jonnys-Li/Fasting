//
//  FSTFastingIdleViewController.m
//  Fasting
//
//  断食计划首页：两种状态。无计划时显示 4 种计划卡片让用户选；
//  已选计划但未开始时显示「准备开始断食」页面（黄色提示卡 + 空圆环 + 开始按钮）。
//
//  滚动容器由 FSTFastingIdleRootView 承载，picker / ready 两态 body 分别由
//  FSTFastingIdlePickerView / FSTFastingIdleReadyView 组装；VC 负责状态分发、
//  topBar 创建、ready 态数据刷新（含定时器）、用户事件与导航（导航统一走 FSTAppRouter）。
//

#import "FSTFastingIdleViewController.h"
#import "FSTFastingIdleRootView.h"
#import "FSTAppRouter.h"
#import "FSTModalDialogViewController.h"
#import "FSTFastingIdlePickerView.h"
#import "FSTFastingIdleReadyView.h"
#import "FSTDailyPlanReadyDisplayState.h"
#import "FSTSessionManager.h"
#import "FSTRecordsRepository.h"
#import "FSTPlan.h"
#import "FSTFastingTopBar.h"
#import "UIViewController+FSTTimeEditor.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

// TopBar
static const CGFloat kTopBarHeightPicker = 84;
static const CGFloat kTopBarHeightReady  = 72;

// NavButton
static const CGFloat kNavButtonDiameter = 46;

// ResetButton（样式走 FSTPillButtonStyleResetChip，这里只定尺寸）
static const CGFloat kResetButtonWidth  = 72;
static const CGFloat kResetButtonHeight = 38;

@interface FSTFastingIdleViewController ()
@property (nonatomic, strong) FSTFastingIdleRootView *rootView;
@property (nonatomic, strong, nullable) FSTFastingTopBar *topBar;
@property (nonatomic, strong, nullable) FSTFastingIdlePickerView *pickerView;
@property (nonatomic, strong, nullable) FSTFastingIdleReadyView *readyView;
@property (nonatomic, assign) BOOL showingReadyState;
@end

@implementation FSTFastingIdleViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rootView = [[FSTFastingIdleRootView alloc] init];
    [self.view addSubview:self.rootView];
    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self reloadRootContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 入口分流：
    // (1) 已有 active 断食 — 跳过本页直接 push 到 Active 页（无动画，让用户从 App 重启时无缝回到正在进行的断食）。
    //     同时消费 pendingActiveStartDatePrompt token：若 SessionManager 标记过"该弹起始时间编辑"，本次进入时会触发一次。
    // (2) 在本页停留 — 重新组装内容（PickerView vs ReadyView 二选一）。
    // topViewController 判断防止 push 链路下重复执行。
    if ([[FSTSessionManager sharedManager] hasActiveFasting] && self.navigationController.topViewController == self) {
        [FSTAppRouter pushActiveFastingFrom:self
                          promptForStartTime:[[FSTSessionManager sharedManager] consumeActiveStartDatePromptRequest]
                                    animated:NO];
    } else if (self.navigationController.topViewController == self) {
        [self reloadRootContent];
    }
    if (self.showingReadyState) [self startRefreshTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopRefreshTimer];
}

- (void)refreshTimerDidFire {
    [self refreshUI];
}

#pragma mark - 状态切换

/// 根据是否有计划，渲染"计划选择列表"或"准备开始"两种状态。
/// 根据当前 session 状态切换子视图（两套互斥的 UI）：
///   - showingReadyState=YES — 已有 currentPlan 但没在断食：装载 ReadyView（圆环+CTA），并启动每秒刷新；
///   - showingReadyState=NO  — 未选 plan：装载 PickerView 让用户选 4 选 1。
/// 注意：hasActiveFasting=YES 这条分支不会在这里处理；那是 viewWillAppear 的 push 到 Active 页负责的。
/// 这个方法只解决"本 VC 自己渲染什么"，外部跳转由调用栈决定。
- (void)reloadRootContent {
    [self stopRefreshTimer];
    [self tearDownCurrentContent];

    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    FSTRecordsRepository *recordsRepository = [FSTRecordsRepository sharedRepository];
    // 兜底：currentPlan 残留但无任何 history / 预约 时回到 Picker，避免落到 "Eating Time" 误导首次用户。
    BOOL hasFastingHistory = recordsRepository.latestFastingEndDate != nil;
    BOOL hasMealHistory    = recordsRepository.latestMealDate      != nil;
    BOOL hasScheduledFast  = sessionManager.scheduledReadySource != FSTScheduledReadySourceNone;
    BOOL hasMeaningfulState = hasFastingHistory || hasMealHistory || hasScheduledFast;

    self.showingReadyState = (!sessionManager.hasActiveFasting
                              && sessionManager.currentPlan != nil
                              && hasMeaningfulState);
    if (self.showingReadyState) {
        [self installReadyState];
        [self refreshUI];
        [self startRefreshTimer];
    } else {
        [self installPickerState];
    }
}

- (void)tearDownCurrentContent {
    self.rootView.bodyView = nil;
    self.pickerView = nil;
    self.readyView = nil;
    [self.topBar removeFromSuperview];
    self.topBar = nil;
}

#pragma mark - 状态：选择计划

- (void)installPickerState {
    [self installPickerTopBar];

    self.pickerView = [[FSTFastingIdlePickerView alloc] init];
    __weak typeof(self) weakSelf = self;
    self.pickerView.onPlanPicked = ^(FSTPlan *picked) {
        [weakSelf handlePlanTapped:picked];
    };
    self.rootView.bodyView = self.pickerView;
}

- (void)installPickerTopBar {
    UILabel *titleLabel = [UILabel fst_labelWithText:@"Fasting" font:FSTFontBold(32) color:[UIColor fst_textPrimary]];

    UIButton *waterButton = [self makeWaterButton];

    self.topBar = [[FSTFastingTopBar alloc] init];
    self.topBar.leftContent   = titleLabel;
    self.topBar.rightButtons  = @[waterButton];
    self.topBar.contentHeight = kTopBarHeightPicker;
    [self.topBar installInViewController:self];
    [self.rootView anchorContentBelowTopBar:self.topBar];

    [waterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kNavButtonDiameter, kNavButtonDiameter));
    }];
}

#pragma mark - 状态：准备开始

- (void)installReadyState {
    [self installReadyTopBar];

    self.readyView = [[FSTFastingIdleReadyView alloc] init];
    [self bindReadyViewCallbacks];
    self.rootView.bodyView = self.readyView;

    FSTPlan *currentPlan = [FSTSessionManager sharedManager].currentPlan;
    self.readyView.planName = currentPlan.name ?: @"14-10";
}

- (void)installReadyTopBar {
    UIButton *resetButton = [UIButton fst_pillButtonWithTitle:@"Reset" style:FSTPillButtonStyleResetChip];
    [resetButton addTarget:self action:@selector(handleResetTapped) forControlEvents:UIControlEventTouchUpInside];

    UIButton *waterButton = [self makeWaterButton];
    UIButton *bellButton  = [self makeBellButton];

    self.topBar = [[FSTFastingTopBar alloc] init];
    self.topBar.leftButton    = resetButton;
    self.topBar.rightButtons  = @[waterButton, bellButton];
    self.topBar.contentHeight = kTopBarHeightReady;
    [self.topBar installInViewController:self];
    [self.rootView anchorContentBelowTopBar:self.topBar];

    [resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kResetButtonWidth, kResetButtonHeight));
    }];
    [waterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kNavButtonDiameter, kNavButtonDiameter));
    }];
    [bellButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kNavButtonDiameter, kNavButtonDiameter));
    }];
}

- (void)bindReadyViewCallbacks {
    __weak typeof(self) weakSelf = self;
    self.readyView.onBreakingFastTapped = ^{
        [weakSelf handleBreakingFastTapped];
    };
    self.readyView.onChangePlanTapped = ^{
        [weakSelf handleSoftChangePlanTapped];
    };
    self.readyView.onEditNextFastStartTapped = ^{
        [weakSelf handleEditNextFastStartTapped];
    };
    self.readyView.onEditNextFastEndTapped = ^{
        [weakSelf handleEditNextFastEndTapped];
    };
    self.readyView.onStartFastingTapped = ^{
        [weakSelf handleReadyStartTapped];
    };
    self.readyView.onAbortPlanTapped = ^{
        [weakSelf handleAbortScheduledReadyTapped];
    };
    self.readyView.onLogMealTapped = ^{
        [weakSelf handleAteTapped];
    };
    self.readyView.onAddRecordTapped = ^{
        [weakSelf handleAddRecordTapped];
    };
    self.readyView.onSendFeedbackTapped = ^{
        [weakSelf handleSendFeedbackTapped];
    };
}

- (void)handleSendFeedbackTapped {
    [FSTAppRouter pushFeedbackFrom:self];
}

#pragma mark - 导航按钮工厂

- (UIButton *)makeWaterButton {
    return [UIButton fst_navCircleButtonWithImageNamed:@"nav_water"
                                              diameter:kNavButtonDiameter];
}

- (UIButton *)makeBellButton {
    UIButton *button = [UIButton fst_navCircleButtonWithImageNamed:@"nav_remind"
                                                          diameter:kNavButtonDiameter];
    [button addTarget:self action:@selector(handleBellTapped) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Ready 态数据刷新与定时器

/// 每秒触发：把派生展示态算成 FSTDailyPlanReadyDisplayState 一次性推入 ReadyView。
/// 预约到点（shouldAutoStartNow）则原地 startFasting + push 到 Active 页 —— 副作用留在 VC，值对象只判不做。
- (void)refreshUI {
    if (!self.showingReadyState || !self.readyView) return;
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    FSTDailyPlanReadyDisplayState *state =
        [FSTDailyPlanReadyDisplayState stateForSessionManager:sessionManager
                                            recordsRepository:[FSTRecordsRepository sharedRepository]
                                                          now:[NSDate date]];
    if (state.shouldAutoStartNow) {
        [sessionManager startFastingWithPlan:sessionManager.currentPlan startDate:state.autoStartDate];
        if (self.navigationController.topViewController == self) {
            [FSTAppRouter pushActiveFastingFrom:self promptForStartTime:NO];
        }
        return;
    }
    [self applyReadyDisplayState:state];
}

/// 把派生展示态平铺推入 ReadyView —— 无任何分支（3 路状态判断全在值对象里），仅做机械格式化。
- (void)applyReadyDisplayState:(FSTDailyPlanReadyDisplayState *)state {
    self.readyView.titleText             = state.titleText;
    self.readyView.ringPresentationState = state.presentationState;
    self.readyView.ringProgress          = state.ringProgress;
    self.readyView.elapsedText           = FSTFormatHHMMSS(state.elapsedSeconds);
    self.readyView.remainingText         = FSTFormatHHMMSS(state.remainingSeconds);
    self.readyView.timeSinceLastFastText = FSTFormatHHMMSS(state.timeSinceLastFastSeconds);
    self.readyView.nextFastStartText     = FSTFormatRelativeDateTime(state.nextFastStartDate);
    self.readyView.nextFastEndText       = FSTFormatRelativeDateTime(state.nextFastEndDate);
    self.readyView.primaryActionMode     = state.primaryActionMode;
    [self.readyView applyReadyToStartLayout:state.compactLayout];
    [self.readyView applyTipsStage:state.tipsStage];
}

#pragma mark - 事件

- (void)handleResetTapped {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Change Plan"
                                                                              message:@"Current progress will be cleared. Continue?"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [[FSTSessionManager sharedManager] clearCurrentPlan];
        [self reloadRootContent];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)handleSoftChangePlanTapped {
    __weak typeof(self) weakSelf = self;
    [FSTAppRouter presentPlanPickerFrom:self onPick:^(FSTPlan *picked) {
        [[FSTSessionManager sharedManager] switchToPlanPreservingState:picked];
        [weakSelf reloadRootContent];
    }];
}

- (void)handleEditNextFastStartTapped {
    __weak typeof(self) weakSelf = self;
    [self fst_presentTimeEditorWithTitle:@"Next fast starts"
                             initialDate:[NSDate date]    // 默认吸附到现在，不用滚到今天
                                onCommit:^(NSDate *pickedDate) {
        [weakSelf applyPickedNextFastStartDate:pickedDate];
    }];
}

- (void)handleEditNextFastEndTapped {
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    NSTimeInterval fastingWindowSeconds = MAX(1, (sessionManager.currentPlan.fastingHours ?: 14) * 3600.0);
    NSDate *currentStartDate = [sessionManager nextFastingStartDate] ?: [NSDate date];
    NSDate *initialDate = [currentStartDate dateByAddingTimeInterval:fastingWindowSeconds];
    __weak typeof(self) weakSelf = self;
    [self fst_presentTimeEditorWithTitle:@"Next fast ends"
                             initialDate:initialDate
                                onCommit:^(NSDate *pickedDate) {
        // 用户实际改动的是 endDate，把它转换回 startDate 再走统一分支
        NSDate *newStartDate = [pickedDate dateByAddingTimeInterval:-fastingWindowSeconds];
        [weakSelf applyPickedNextFastStartDate:newStartDate];
    }];
}

/// next-fast start 时间统一落地：未来值在 ready 子态内更新；过去值跳转到 Active 页起新断食。
- (void)applyPickedNextFastStartDate:(NSDate *)pickedDate {
    if (!pickedDate) return;
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    if ([pickedDate compare:[NSDate date]] == NSOrderedAscending) {
        FSTPlan *currentPlan = sessionManager.currentPlan;
        if (!currentPlan) return;
        [sessionManager setNextFastingStartDate:nil];
        [sessionManager startFastingWithPlan:currentPlan startDate:pickedDate];
        [FSTAppRouter pushActiveFastingFrom:self promptForStartTime:NO];
    } else {
        FSTScheduledReadySource source = sessionManager.scheduledReadySource;
        [sessionManager setNextFastingStartDate:pickedDate];
        if (source != FSTScheduledReadySourceNone) {
            [sessionManager markScheduledReadyWithSource:source anchorDate:[NSDate date]];
        }
        [self refreshUI];
    }
}

- (void)handleBellTapped {
    [FSTAppRouter showAlertFrom:self title:@"Reminder" message:@"Reminder feature coming soon." buttonTitle:@"Got it"];
}

- (void)handleAteTapped {
    // Plan tab 进入：保存后切到 Timeline 让新 meal 立刻可见。
    [FSTAppRouter pushMealDetailFrom:self record:nil returnsToTimeline:YES];
}

- (void)handleAddRecordTapped {
    [FSTAppRouter pushQuickAddRecordFrom:self];
}

- (void)handleBreakingFastTapped {
    // 复用 FSTModalDialogViewController（与 ActiveFasting 的 phaseDialog 同款居中卡片），
    // 图标用现成的 breaking_fast_food 资源（FSTBreakingFastCardView 也在用）。
    FSTModalDialogViewController *dialog = [[FSTModalDialogViewController alloc] init];
    dialog.iconKind     = FSTModalDialogIconKindAssetImage;
    dialog.iconName     = @"breaking_fast_food";
    dialog.titleText    = @"Breaking fast";
    dialog.message      = @"Your fast is over. It's time to replenish with light, nutritious food.";
    dialog.primaryTitle = @"Got it";
    [self presentViewController:dialog animated:YES completion:nil];
}

- (void)handleAbortScheduledReadyTapped {
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    FSTScheduledReadySource source = sessionManager.scheduledReadySource;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Abort plan?"
                                                                              message:@"Do you want to end this scheduled fast?"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:@"End" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        FSTSessionManager *manager = [FSTSessionManager sharedManager];
        if (source == FSTScheduledReadySourcePreStart) {
            [manager clearCurrentPlan];
        } else if (source == FSTScheduledReadySourceFromActiveSession) {
            // 与 PreStart 行为对齐：Abort plan 的语义就是"放弃这次计划"，应回到 Plan Picker，
            // 而不是转入"普通进食窗口"（原 beginEatingWindowFromDate: 行为与设计意图不符）。
            [manager clearCurrentPlan];
        } else {
            [manager clearScheduledReadyState];
        }
        [weakSelf reloadRootContent];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)handleReadyStartTapped {
    FSTPlan *currentPlan = [FSTSessionManager sharedManager].currentPlan;
    if (!currentPlan) {
        [self reloadRootContent];
        return;
    }
    [[FSTSessionManager sharedManager] startFastingWithPlan:currentPlan startDate:[NSDate date]];
    [FSTAppRouter pushActiveFastingFrom:self promptForStartTime:YES];
}

- (void)handlePlanTapped:(FSTPlan *)plan {
    [FSTAppRouter pushPlanConfirmFrom:self plan:plan];
}

@end
