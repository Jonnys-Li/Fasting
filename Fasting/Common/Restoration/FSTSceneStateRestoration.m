//
//  FSTSceneStateRestoration.m
//  Fasting
//

#import "FSTSceneStateRestoration.h"

#import "FSTRootTabBarController.h"

// VCs that can appear in restored nav stacks
#import "FSTActiveFastingViewController.h"
#import "FSTAddRecordViewController.h"
#import "FSTQuickAddRecordViewController.h"
#import "FSTFastingHistoryViewController.h"
#import "FSTMealDiaryViewController.h"
#import "FSTMealDetailViewController.h"
#import "FSTSendFeedbackViewController.h"
#import "FSTPlanConfirmViewController.h"

// Data lookups
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
static NSString *const kKeyPlanType  = @"planType";

// VC type tokens —— 调整时记得同步升级 FSTSceneRestorationSchemaVersion
static NSString *const kTypeActiveFasting   = @"ActiveFasting";
static NSString *const kTypeAddRecordEdit   = @"AddRecord.edit";
static NSString *const kTypeAddRecordFinish = @"AddRecord.finish";
static NSString *const kTypeQuickAddRecord  = @"QuickAddRecord";
static NSString *const kTypeFastingHistory  = @"FastingHistory";
static NSString *const kTypeMealDiary       = @"MealDiary";
static NSString *const kTypeMealDetail      = @"MealDetail";
static NSString *const kTypeSendFeedback    = @"SendFeedback";
static NSString *const kTypePlanConfirm     = @"PlanConfirm";

#pragma mark - Forward declarations (file-local helpers)

/// 把单个 VC 编码成 token；不在恢复 scope 内（modal / 私有 / 状态不可重建）返回 nil。
static NSDictionary *FSTRestorationTokenForViewController(UIViewController *vc);

/// 从 token 重建 VC；token 损坏 / 依赖数据缺失返回 nil，调用方截断这条 stack。
static UIViewController *FSTViewControllerForRestorationToken(NSDictionary *token);

static FSTFastingRecord *FSTLookupFastingRecord(NSString *recordID);
static FSTMealRecord    *FSTLookupMealRecord(NSString *recordID);

#pragma mark - FSTSceneStateRestoration

@implementation FSTSceneStateRestoration

+ (nullable NSUserActivity *)activityForRootViewController:(UIViewController *)root {
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

+ (nullable FSTRootTabBarController *)restoredRootTabBarFromActivity:(nullable NSUserActivity *)activity {
    if (!activity || ![activity.activityType isEqualToString:FSTSceneRestorationActivityType]) return nil;
    NSDictionary *userInfo = activity.userInfo;
    if (![userInfo[kKeyVersion] isEqual:@(FSTSceneRestorationSchemaVersion)]) return nil;

    FSTRootTabBarController *tabBar = [[FSTRootTabBarController alloc] init];
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
    return tabBar;
}

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
        FSTPlanType planType = planConfirm.plan.type;
        if (planType == FSTPlanTypeCustom) return nil;  // 非内置方案不恢复
        return @{kKeyType: kTypePlanConfirm, kKeyPlanType: @(planType)};
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
        return [[FSTActiveFastingViewController alloc] init];
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
        return [[FSTQuickAddRecordViewController alloc] init];
    }
    if ([type isEqualToString:kTypeFastingHistory]) {
        return [[FSTFastingHistoryViewController alloc] init];
    }
    if ([type isEqualToString:kTypeMealDiary]) {
        return [[FSTMealDiaryViewController alloc] init];
    }
    if ([type isEqualToString:kTypeMealDetail]) {
        FSTMealRecord *record = FSTLookupMealRecord(token[kKeyRecordID]);
        if (!record) return nil;
        BOOL returnsToTimeline = [token[kKeyReturns] boolValue];
        return [[FSTMealDetailViewController alloc] initWithMealRecord:record
                                                  returnsToTimelineTab:returnsToTimeline];
    }
    if ([type isEqualToString:kTypeSendFeedback]) {
        return [[FSTSendFeedbackViewController alloc] init];
    }
    if ([type isEqualToString:kTypePlanConfirm]) {
        NSNumber *planTypeNumber = token[kKeyPlanType];
        if (![planTypeNumber isKindOfClass:[NSNumber class]]) return nil;
        FSTPlanType planType = planTypeNumber.integerValue;
        FSTPlan *plan = nil;
        for (FSTPlan *candidate in [FSTPlan defaultDailyPlans]) {
            if (candidate.type == planType) { plan = candidate; break; }
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
