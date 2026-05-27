//
//  SceneDelegate.m
//  Fasting
//
//  入口分流 + scene state restoration（NSUserActivity 链路）。
//  - willConnectToSession：onboarding 未完成走 onboarding flow；完成则优先用 session.stateRestorationActivity
//    重建上次的 TabBar + nav 栈，失败则装默认 TabBar 根。
//  - stateRestorationActivityForScene：scene 进入后台 / 被回收前由系统调用，把当前 TabBar 状态
//    编码成 NSUserActivity 让系统持久化。
//
//  恢复范围：tab 选中态 + 每个 tab 的 nav 栈 + 每个 VC 的关键参数（recordID / planName / startDate / endDate）。
//  不恢复：modal sheets、半填的表单内容、scroll 位置、onboarding 中段状态、一次性 UX hint。
//

#import "SceneDelegate.h"

// Routing
#import "FSTRootTabBarController.h"
#import "FSTPlanSelectViewController.h"
#import "FSTPlanConfirmViewController.h"

// State restoration — VCs that can appear in restored nav stacks
#import "FSTActiveFastingViewController.h"
#import "FSTAddRecordViewController.h"
#import "FSTQuickAddRecordViewController.h"
#import "FSTFastingHistoryViewController.h"
#import "FSTMealDiaryViewController.h"
#import "FSTMealDetailViewController.h"
#import "FSTSendFeedbackViewController.h"

// State restoration — data lookups
#import "FSTSessionManager.h"
#import "FSTRecordsRepository.h"
#import "FSTFastingRecord.h"
#import "FSTPlan.h"

#pragma mark - Restoration constants

static NSString *const FSTSceneRestorationActivityType  = @"com.fasting.scene-state";
static const NSInteger FSTSceneRestorationSchemaVersion = 1;

// userInfo top-level keys
static NSString *const kKeyVersion  = @"version";
static NSString *const kKeyTabIndex = @"tabIndex";
static NSString *const kKeyStacks   = @"stacks";

// per-token keys
static NSString *const kKeyType      = @"type";
static NSString *const kKeyRecordID  = @"recordID";
static NSString *const kKeyReturns   = @"returnsToTimeline";
static NSString *const kKeyStartDate = @"startDate";
static NSString *const kKeyEndDate   = @"endDate";
static NSString *const kKeyPlanName  = @"planName";

// VC type tokens —— 调整时记得同步升级 schema version
static NSString *const kTypeActiveFasting   = @"ActiveFasting";
static NSString *const kTypeAddRecordEdit   = @"AddRecord.edit";
static NSString *const kTypeAddRecordFinish = @"AddRecord.finish";
static NSString *const kTypeQuickAddRecord  = @"QuickAddRecord";
static NSString *const kTypeFastingHistory  = @"FastingHistory";
static NSString *const kTypeMealDiary       = @"MealDiary";
static NSString *const kTypeMealDetail      = @"MealDetail";
static NSString *const kTypeSendFeedback    = @"SendFeedback";
static NSString *const kTypePlanConfirm     = @"PlanConfirm";

#pragma mark - Encode/decode helpers (forward declarations)

/// 把单个 VC 编码成 token；不在恢复 scope 内（modal / 私有 / 状态不可重建）返回 nil。
static NSDictionary *FSTRestorationTokenForViewController(UIViewController *vc);

/// 从 token 重建 VC；token 损坏 / 依赖数据缺失返回 nil，调用方截断这条 stack。
static UIViewController *FSTViewControllerForRestorationToken(NSDictionary *token);

static FSTFastingRecord *FSTLookupFastingRecord(NSString *recordID);
static FSTMealRecord    *FSTLookupMealRecord(NSString *recordID);

#pragma mark - SceneDelegate

@interface SceneDelegate ()
@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene
willConnectToSession:(UISceneSession *)session
      options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) return;
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];

    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    if (sessionManager.hasCompletedOnboarding && sessionManager.currentPlan) {
        // 完成 onboarding 才尝试恢复 nav 栈；onboarding 中段状态不恢复（重启重走引导）。
        if (![self installRestoredTabBarFromActivity:session.stateRestorationActivity]) {
            [self installRootTabBarController];
        }
    } else {
        [self installOnboardingPlanFlow];
    }
    [self.window makeKeyAndVisible];
}

#pragma mark - State preservation

/// 系统在 scene 进入后台 / 被回收前调用，把返回的 activity 持久化；
/// 下次 willConnectToSession 时在 session.stateRestorationActivity 取回。
- (nullable NSUserActivity *)stateRestorationActivityForScene:(UIScene *)scene {
    UIViewController *root = self.window.rootViewController;
    if (![root isKindOfClass:[FSTRootTabBarController class]]) return nil;
    FSTRootTabBarController *tabBar = (FSTRootTabBarController *)root;

    NSMutableArray<NSArray<NSDictionary *> *> *stacks = [NSMutableArray array];
    for (UIViewController *tab in tabBar.viewControllers) {
        NSMutableArray<NSDictionary *> *stack = [NSMutableArray array];
        if ([tab isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)tab;
            // 跳过 root：tab 根 VC 由 FSTRootTabBarController 自己构造，只编码 push 上去的层。
            for (NSUInteger i = 1; i < nav.viewControllers.count; i++) {
                NSDictionary *token = FSTRestorationTokenForViewController(nav.viewControllers[i]);
                if (!token) break;  // 中间层不可编码 → 截断这条 stack（保留前面的）
                [stack addObject:token];
            }
        }
        [stacks addObject:stack];
    }

    NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:FSTSceneRestorationActivityType];
    activity.userInfo = @{
        kKeyVersion: @(FSTSceneRestorationSchemaVersion),
        kKeyTabIndex: @(tabBar.selectedIndex),
        kKeyStacks: stacks,
    };
    return activity;
}

#pragma mark - Installers

- (void)installRootTabBarController {
    self.window.rootViewController = [FSTRootTabBarController new];
}

/// 用 NSUserActivity 重建 TabBar + 每个 tab 的 nav 栈。返回 NO 表示 activity 不可用 / schema 不匹配，
/// 调用方走默认 installRootTabBarController。
- (BOOL)installRestoredTabBarFromActivity:(nullable NSUserActivity *)activity {
    if (!activity || ![activity.activityType isEqualToString:FSTSceneRestorationActivityType]) return NO;
    NSDictionary *userInfo = activity.userInfo;
    if (![userInfo[kKeyVersion] isEqual:@(FSTSceneRestorationSchemaVersion)]) return NO;

    FSTRootTabBarController *tabBar = [FSTRootTabBarController new];
    // 触发 viewDidLoad，让 RootTabBarController 把 3 个 tab（含 nav controllers）装好。
    (void)tabBar.view;

    NSArray<NSArray<NSDictionary *> *> *stacks = userInfo[kKeyStacks];
    if (![stacks isKindOfClass:[NSArray class]]) stacks = @[];
    NSUInteger tabCount = MIN(tabBar.viewControllers.count, stacks.count);
    for (NSUInteger tabIndex = 0; tabIndex < tabCount; tabIndex++) {
        UIViewController *tab = tabBar.viewControllers[tabIndex];
        if (![tab isKindOfClass:[UINavigationController class]]) continue;
        UINavigationController *nav = (UINavigationController *)tab;
        NSArray *tokens = stacks[tabIndex];
        if (![tokens isKindOfClass:[NSArray class]]) continue;
        for (NSDictionary *token in tokens) {
            if (![token isKindOfClass:[NSDictionary class]]) break;
            UIViewController *vc = FSTViewControllerForRestorationToken(token);
            if (!vc) break;  // 单个 token 解码失败 → 截断这条 stack
            vc.hidesBottomBarWhenPushed = YES;
            [nav pushViewController:vc animated:NO];
        }
    }

    NSNumber *selectedIndex = userInfo[kKeyTabIndex];
    if ([selectedIndex isKindOfClass:[NSNumber class]] &&
        selectedIndex.unsignedIntegerValue < tabBar.viewControllers.count) {
        tabBar.selectedIndex = selectedIndex.unsignedIntegerValue;
    }

    self.window.rootViewController = tabBar;
    return YES;
}

- (void)installOnboardingPlanFlow {
    FSTPlanSelectViewController *planSelectViewController = [FSTPlanSelectViewController new];
    planSelectViewController.showsCloseButton = NO;
    planSelectViewController.dismissesOnPlanPicked = NO;

    UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:planSelectViewController];
    navigationController.navigationBarHidden = YES;

    __weak typeof(self) weakSelf = self;
    __weak UINavigationController *weakNavigationController = navigationController;
    planSelectViewController.onPlanPicked = ^(FSTPlan *picked) {
        FSTPlanConfirmViewController *confirmViewController =
            [[FSTPlanConfirmViewController alloc] initWithPlan:picked];
        confirmViewController.onFastingStarted = ^{
            [weakSelf installRootTabBarController];
        };
        [weakNavigationController pushViewController:confirmViewController animated:YES];
    };

    self.window.rootViewController = navigationController;
}

- (void)sceneDidDisconnect:(UIScene *)scene {}
- (void)sceneDidBecomeActive:(UIScene *)scene {}
- (void)sceneWillResignActive:(UIScene *)scene {}
- (void)sceneWillEnterForeground:(UIScene *)scene {}
- (void)sceneDidEnterBackground:(UIScene *)scene {}

@end

#pragma mark - Encoder

static NSDictionary *FSTRestorationTokenForViewController(UIViewController *vc) {
    if ([vc isKindOfClass:[FSTActiveFastingViewController class]]) {
        return @{kKeyType: kTypeActiveFasting};
    }
    if ([vc isKindOfClass:[FSTAddRecordViewController class]]) {
        FSTAddRecordViewController *addRecord = (FSTAddRecordViewController *)vc;
        if (addRecord.editingRecord) {
            NSString *recordID = addRecord.editingRecord.recordID;
            if (!recordID.length) return nil;
            return @{kKeyType: kTypeAddRecordEdit, kKeyRecordID: recordID};
        }
        return @{
            kKeyType:      kTypeAddRecordFinish,
            kKeyStartDate: addRecord.startDate ?: [NSDate date],
            kKeyEndDate:   addRecord.endDate   ?: [NSDate date],
        };
    }
    if ([vc isKindOfClass:[FSTQuickAddRecordViewController class]]) {
        return @{kKeyType: kTypeQuickAddRecord};
    }
    if ([vc isKindOfClass:[FSTFastingHistoryViewController class]]) {
        return @{kKeyType: kTypeFastingHistory};
    }
    if ([vc isKindOfClass:[FSTMealDiaryViewController class]]) {
        return @{kKeyType: kTypeMealDiary};
    }
    if ([vc isKindOfClass:[FSTMealDetailViewController class]]) {
        FSTMealDetailViewController *mealDetail = (FSTMealDetailViewController *)vc;
        // 只恢复"编辑已有"态。新建场景（recordID 为空草稿）不恢复——半填内容丢失可接受。
        NSString *recordID = mealDetail.mealRecord.recordID;
        if (!recordID.length) return nil;
        return @{
            kKeyType:     kTypeMealDetail,
            kKeyRecordID: recordID,
            kKeyReturns:  @(mealDetail.returnsToTimelineTab),
        };
    }
    if ([vc isKindOfClass:[FSTSendFeedbackViewController class]]) {
        return @{kKeyType: kTypeSendFeedback};
    }
    if ([vc isKindOfClass:[FSTPlanConfirmViewController class]]) {
        FSTPlanConfirmViewController *planConfirm = (FSTPlanConfirmViewController *)vc;
        NSString *planName = planConfirm.plan.name;
        if (!planName.length) return nil;
        return @{kKeyType: kTypePlanConfirm, kKeyPlanName: planName};
    }
    return nil;  // 其他（含各类 modal sheet）不在恢复 scope 内
}

#pragma mark - Decoder

static UIViewController *FSTViewControllerForRestorationToken(NSDictionary *token) {
    NSString *type = token[kKeyType];
    if (![type isKindOfClass:[NSString class]] || !type.length) return nil;

    if ([type isEqualToString:kTypeActiveFasting]) {
        // 没有进行中的断食时恢复 ActiveFasting 没意义（页面会立刻 redirect 回 Plan）。
        if (![[FSTSessionManager sharedManager] hasActiveFasting]) return nil;
        return [FSTActiveFastingViewController new];
    }
    if ([type isEqualToString:kTypeAddRecordEdit]) {
        FSTFastingRecord *record = FSTLookupFastingRecord(token[kKeyRecordID]);
        if (!record) return nil;
        return [[FSTAddRecordViewController alloc] initWithRecord:record];
    }
    if ([type isEqualToString:kTypeAddRecordFinish]) {
        NSDate *startDate = token[kKeyStartDate];
        NSDate *endDate   = token[kKeyEndDate];
        if (![startDate isKindOfClass:[NSDate class]] || ![endDate isKindOfClass:[NSDate class]]) return nil;
        return [[FSTAddRecordViewController alloc] initWithStartDate:startDate endDate:endDate];
    }
    if ([type isEqualToString:kTypeQuickAddRecord]) {
        return [FSTQuickAddRecordViewController new];
    }
    if ([type isEqualToString:kTypeFastingHistory]) {
        return [FSTFastingHistoryViewController new];
    }
    if ([type isEqualToString:kTypeMealDiary]) {
        return [FSTMealDiaryViewController new];
    }
    if ([type isEqualToString:kTypeMealDetail]) {
        FSTMealRecord *record = FSTLookupMealRecord(token[kKeyRecordID]);
        if (!record) return nil;
        BOOL returnsToTimeline = [token[kKeyReturns] boolValue];
        return [[FSTMealDetailViewController alloc] initWithMealRecord:record
                                                  returnsToTimelineTab:returnsToTimeline];
    }
    if ([type isEqualToString:kTypeSendFeedback]) {
        return [FSTSendFeedbackViewController new];
    }
    if ([type isEqualToString:kTypePlanConfirm]) {
        NSString *planName = token[kKeyPlanName];
        if (![planName isKindOfClass:[NSString class]] || !planName.length) return nil;
        FSTPlan *plan = nil;
        for (FSTPlan *candidate in [FSTPlan defaultDailyPlans]) {
            if ([candidate.name isEqualToString:planName]) { plan = candidate; break; }
        }
        if (!plan) return nil;
        return [[FSTPlanConfirmViewController alloc] initWithPlan:plan];
    }
    return nil;
}

static FSTFastingRecord *FSTLookupFastingRecord(NSString *recordID) {
    if (![recordID isKindOfClass:[NSString class]] || !recordID.length) return nil;
    for (FSTFastingRecord *record in [[FSTRecordsRepository sharedRepository] allRecords]) {
        if ([record.recordID isEqualToString:recordID]) return record;
    }
    return nil;
}

static FSTMealRecord *FSTLookupMealRecord(NSString *recordID) {
    if (![recordID isKindOfClass:[NSString class]] || !recordID.length) return nil;
    for (FSTMealRecord *record in [[FSTRecordsRepository sharedRepository] allMealRecords]) {
        if ([record.recordID isEqualToString:recordID]) return record;
    }
    return nil;
}
