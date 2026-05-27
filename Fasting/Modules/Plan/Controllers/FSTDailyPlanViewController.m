//
//  FSTDailyPlanViewController.m
//  Fasting
//
//  断食计划首页：两种状态。无计划时显示 4 种计划卡片让用户选；
//  已选计划但未开始时显示「准备开始断食」页面（黄色提示卡 + 空圆环 + 开始按钮）。
//
//  UI 组装由 FSTDailyPlanPickerView / FSTDailyPlanReadyView 承担；VC 负责状态分发、
//  topBar 创建、ready 态数据刷新（含定时器）、用户事件与导航（导航统一走 FSTAppRouter）。
//

#import "FSTDailyPlanViewController.h"
#import "FSTPlanConfirmViewController.h"
#import "FSTAppRouter.h"
#import "FSTModalDialogViewController.h"
#import "FSTDailyPlanPickerView.h"
#import "FSTDailyPlanReadyView.h"
#import "FSTSessionManager.h"
#import "FSTRecordsRepository.h"
#import "FSTPlan.h"
#import "FSTFastingTopBar.h"
#import "UIButton+FST.h"
#import "UIViewController+FSTTimeEditor.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

// TopBar
static const CGFloat kTopBarHeightPicker = 84;
static const CGFloat kTopBarHeightReady  = 72;

// NavButton
static const CGFloat kNavButtonDiameter = 46;

// ResetButton
static const CGFloat kResetButtonWidth  = 72;
static const CGFloat kResetButtonHeight = 38;
static const CGFloat kResetCornerRadius = 19;

@interface FSTDailyPlanViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong, nullable) FSTFastingTopBar *topBar;
@property (nonatomic, strong, nullable) FSTDailyPlanPickerView *pickerView;
@property (nonatomic, strong, nullable) FSTDailyPlanReadyView *readyView;
@property (nonatomic, assign) BOOL showingReadyState;
@end

@implementation FSTDailyPlanViewController

#pragma mark - 生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildScrollContainer];
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
    [self refreshReadyState];
}

#pragma mark - 容器

- (void)buildScrollContainer {
    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
}

- (void)anchorScrollViewToTopBar {
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBar.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
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
    self.showingReadyState = (!sessionManager.hasActiveFasting && sessionManager.currentPlan != nil);
    if (self.showingReadyState) {
        [self installReadyState];
        [self refreshReadyState];
        [self startRefreshTimer];
    } else {
        [self installPickerState];
    }
}

- (void)tearDownCurrentContent {
    [self.pickerView removeFromSuperview];
    self.pickerView = nil;
    [self.readyView removeFromSuperview];
    self.readyView = nil;
    [self.topBar removeFromSuperview];
    self.topBar = nil;
}

#pragma mark - 状态：选择计划

- (void)installPickerState {
    [self installPickerTopBar];

    self.pickerView = [FSTDailyPlanPickerView new];
    __weak typeof(self) weakSelf = self;
    self.pickerView.onPlanPicked = ^(FSTPlan *picked) { [weakSelf handlePlanTapped:picked]; };
    [self.contentView addSubview:self.pickerView];
    [self.pickerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)installPickerTopBar {
    UILabel *titleLabel = [UILabel new];
    titleLabel.text      = @"Fasting";
    titleLabel.font      = FSTFontBold(32);
    titleLabel.textColor = [UIColor fst_textPrimary];

    UIButton *waterButton = [self makeWaterButton];

    self.topBar = [[FSTFastingTopBar alloc] initWithLeftButton:nil
                                                  rightButtons:@[waterButton]
                                                 centerContent:nil
                                                 contentHeight:kTopBarHeightPicker];
    [self.topBar installInViewController:self];
    [self anchorScrollViewToTopBar];

    [waterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kNavButtonDiameter, kNavButtonDiameter));
    }];

    [self.topBar addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topBar);
        make.left.equalTo(self.topBar).offset(24);
    }];
}

#pragma mark - 状态：准备开始

- (void)installReadyState {
    [self installReadyTopBar];

    self.readyView = [FSTDailyPlanReadyView new];
    [self bindReadyViewCallbacks];
    [self.contentView addSubview:self.readyView];
    [self.readyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];

    FSTPlan *currentPlan = [FSTSessionManager sharedManager].currentPlan;
    self.readyView.planName = currentPlan.name ?: @"14-10";
}

- (void)installReadyTopBar {
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    resetButton.backgroundColor    = [UIColor whiteColor];
    resetButton.layer.cornerRadius = kResetCornerRadius;
    resetButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    resetButton.contentVerticalAlignment   = UIControlContentVerticalAlignmentCenter;

    NSMutableParagraphStyle *resetParagraphStyle = [NSMutableParagraphStyle new];
    resetParagraphStyle.alignment         = NSTextAlignmentCenter;
    resetParagraphStyle.minimumLineHeight = 22;
    resetParagraphStyle.maximumLineHeight = 22;
    UIFont *resetFont = FSTFontAvenirDemiBold(15);
    NSAttributedString *resetTitle =
        [[NSAttributedString alloc] initWithString:@"Reset"
                                        attributes:@{NSForegroundColorAttributeName: [UIColor fst_primaryGreen],
                                                     NSFontAttributeName: resetFont,
                                                     NSParagraphStyleAttributeName: resetParagraphStyle}];
    [resetButton setAttributedTitle:resetTitle forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(handleResetTapped) forControlEvents:UIControlEventTouchUpInside];

    UIButton *waterButton = [self makeWaterButton];
    UIButton *bellButton  = [self makeBellButton];

    self.topBar = [[FSTFastingTopBar alloc] initWithLeftButton:resetButton
                                                  rightButtons:@[waterButton, bellButton]
                                                 centerContent:nil
                                                 contentHeight:kTopBarHeightReady];
    [self.topBar installInViewController:self];
    [self anchorScrollViewToTopBar];

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
    self.readyView.onBreakingFastTapped      = ^{ [weakSelf handleBreakingFastTapped]; };
    self.readyView.onChangePlanTapped        = ^{ [weakSelf handleSoftChangePlanTapped]; };
    self.readyView.onEditNextFastStartTapped = ^{ [weakSelf handleEditNextFastStartTapped]; };
    self.readyView.onEditNextFastEndTapped   = ^{ [weakSelf handleEditNextFastEndTapped]; };
    self.readyView.onStartFastingTapped      = ^{ [weakSelf handleReadyStartTapped]; };
    self.readyView.onAbortPlanTapped         = ^{ [weakSelf handleAbortScheduledReadyTapped]; };
    self.readyView.onLogMealTapped           = ^{ [weakSelf handleAteTapped]; };
    self.readyView.onAddRecordTapped         = ^{ [weakSelf handleAddRecordTapped]; };
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

/// 每秒触发：根据吃窗口 / 预约状态推导 ReadyView 字段并下发。
/// 三态优先级：scheduledCountdown > readyAfterEating > 普通 eatingWindow。
/// 已到预约时刻则原地 startFasting + push 到 Active 页。
- (void)refreshReadyState {
    if (!self.showingReadyState || !self.readyView) return;
    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    FSTPlan *plan = sessionManager.currentPlan;
    NSDate *now = [NSDate date];
    NSDate *nextStartDate = [sessionManager nextFastingStartDate];

    // 自动起始已预约的断食：scheduled && nextStartDate <= now && plan 存在。
    BOOL scheduled = (sessionManager.scheduledReadySource != FSTScheduledReadySourceNone) && (nextStartDate != nil);
    if (scheduled && plan != nil && [nextStartDate compare:now] != NSOrderedDescending) {
        [sessionManager startFastingWithPlan:plan startDate:nextStartDate];
        if (self.navigationController.topViewController == self) {
            [FSTAppRouter pushActiveFastingFrom:self promptForStartTime:NO];
        }
        return;
    }

    // 吃窗口推导 — 基于 plan.eatingHours / fastingHours 与 nextStart/latestEnd 时刻。
    NSTimeInterval eatingHours  = plan.eatingHours  > 0 ? plan.eatingHours  : 10.0;
    NSTimeInterval fastingHours = plan.fastingHours > 0 ? plan.fastingHours : 14.0;
    NSTimeInterval eatingWindowSeconds  = MAX(1, eatingHours  * 3600.0);
    NSTimeInterval fastingWindowSeconds = MAX(1, fastingHours * 3600.0);
    NSDate *resolvedNextStart = nextStartDate ?: [now dateByAddingTimeInterval:eatingWindowSeconds];
    NSDate *windowStartDate   = [resolvedNextStart dateByAddingTimeInterval:-eatingWindowSeconds];
    NSDate *resolvedNextEnd   = [resolvedNextStart dateByAddingTimeInterval:fastingWindowSeconds];
    NSTimeInterval elapsed    = MAX(0, [now timeIntervalSinceDate:windowStartDate]);
    NSTimeInterval remaining  = MAX(0, [resolvedNextStart timeIntervalSinceDate:now]);
    BOOL readyToStart         = remaining <= 0.0;
    NSDate *latestFastEnd = [[FSTRecordsRepository sharedRepository] latestFastingEndDate] ?: windowStartDate;
    // 可开始态以 nextStart 为基准衡量"已超时多久"；普通态以 latestFastEnd 为基准
    NSTimeInterval timeSinceLastFast = readyToStart
        ? MAX(0, [now timeIntervalSinceDate:resolvedNextStart])
        : MAX(0, [now timeIntervalSinceDate:latestFastEnd]);
    CGFloat windowProgress = (CGFloat)MIN(1.0, elapsed / eatingWindowSeconds);

    // 三态：scheduledCountdown 优先（即便吃窗口耗尽也保留倒计时视觉）。
    BOOL scheduledCountdown = scheduled && [nextStartDate compare:now] == NSOrderedDescending;
    BOOL readyAfterEating = !scheduledCountdown && readyToStart;
    BOOL compactLayout = scheduledCountdown || readyAfterEating;
    NSDate *countdownAnchorDate = [sessionManager nextFastingStartCountdownAnchorDate];
    BOOL usesManualCountdownProgress = !scheduledCountdown &&
                                       countdownAnchorDate != nil &&
                                       [resolvedNextStart compare:countdownAnchorDate] == NSOrderedDescending;
    NSTimeInterval ringElapsed = usesManualCountdownProgress
        ? MAX(0, [now timeIntervalSinceDate:countdownAnchorDate])
        : elapsed;
    CGFloat ringProgress = windowProgress;
    if (usesManualCountdownProgress) {
        NSTimeInterval countdownTotal = MAX(1.0, [resolvedNextStart timeIntervalSinceDate:countdownAnchorDate]);
        ringProgress = (CGFloat)MIN(1.0, ringElapsed / countdownTotal);
    }

    self.readyView.titleText = scheduledCountdown ? @"Ready to start fasting!"
                             : (readyAfterEating ? @"Ready to start fasting?" : @"Eating Time");
    self.readyView.ringPresentationState = scheduledCountdown ? FSTDailyPlanReadyRingPresentationScheduledCountdown
                                         : (readyAfterEating ? FSTDailyPlanReadyRingPresentationReadyToStartFasting
                                                             : FSTDailyPlanReadyRingPresentationEatingWindow);
    self.readyView.elapsedText           = FSTFormatHHMMSS(ringElapsed);
    self.readyView.ringProgress          = scheduledCountdown
        ? [self scheduledProgressForStartDate:nextStartDate referenceDate:now]
        : ringProgress;
    self.readyView.remainingText         = FSTFormatHHMMSS(scheduledCountdown
        ? [nextStartDate timeIntervalSinceDate:now]
        : remaining);
    self.readyView.timeSinceLastFastText = FSTFormatHHMMSS(timeSinceLastFast);
    self.readyView.nextFastStartText     = FSTFormatRelativeDateTime(resolvedNextStart);
    self.readyView.nextFastEndText       = FSTFormatRelativeDateTime(resolvedNextEnd);
    self.readyView.primaryActionMode     = scheduledCountdown ? FSTDailyPlanReadyPrimaryActionAbortPlan
                                                              : FSTDailyPlanReadyPrimaryActionStartFasting;
    [self.readyView applyReadyToStartLayout:compactLayout];
}

/// ScheduledCountdown 圆环进度：从 anchorDate 到 startDate 的线性比例。
- (CGFloat)scheduledProgressForStartDate:(NSDate *)startDate referenceDate:(NSDate *)referenceDate {
    if (!startDate) return 0;
    NSDate *anchorDate = [FSTSessionManager sharedManager].scheduledReadyAnchorDate ?: referenceDate;
    NSTimeInterval total = MAX(1.0, [startDate timeIntervalSinceDate:anchorDate]);
    NSTimeInterval elapsed = MAX(0, [referenceDate timeIntervalSinceDate:anchorDate]);
    return (CGFloat)MIN(1.0, elapsed / total);
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
        [self refreshReadyState];
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
    FSTModalDialogViewController *dialog =
        [[FSTModalDialogViewController alloc] initWithIconImageName:@"breaking_fast_food"
                                                              title:@"Breaking fast"
                                                            message:@"Your fast is over. It's time to replenish with light, nutritious food."
                                                       primaryTitle:@"Got it"
                                                     secondaryTitle:nil
                                                     primaryHandler:nil
                                                   secondaryHandler:nil];
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
    FSTPlanConfirmViewController *confirmViewController = [[FSTPlanConfirmViewController alloc] initWithPlan:plan];
    [self.navigationController pushViewController:confirmViewController animated:YES];
}

@end
