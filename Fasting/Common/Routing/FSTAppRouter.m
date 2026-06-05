//
//  FSTAppRouter.m
//  Fasting
//

#import "FSTAppRouter.h"
#import "FSTActiveFastingViewController.h"
#import "FSTAddRecordViewController.h"
#import "FSTQuickAddRecordViewController.h"
#import "FSTFastingHistoryViewController.h"
#import "FSTMealDiaryViewController.h"
#import "FSTMealDetailViewController.h"
#import "FSTPlanSelectViewController.h"
#import "FSTPlanConfirmViewController.h"
#import "FSTSendFeedbackViewController.h"
#import "FSTShareCardViewController.h"
#import "FSTWeightInputViewController.h"
#import "FSTRootTabBarController.h"
#import "FSTPlan.h"
#import "FSTFastingRecord.h"

@implementation FSTAppRouter

#pragma mark - 系统弹窗

+ (void)showAlertFrom:(UIViewController *)vc
                title:(NSString *)title
              message:(NSString *)message
          buttonTitle:(NSString *)buttonTitle {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:buttonTitle ?: @"Got it"
                                              style:UIAlertActionStyleDefault
                                            handler:nil]];
    [vc presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Plan 选择 / 浏览

+ (void)presentPlanPickerFrom:(UIViewController *)vc
                       onPick:(void (^)(FSTPlan *plan))onPick {
    FSTPlanSelectViewController *picker = [[FSTPlanSelectViewController alloc] init];
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    picker.onPlanPicked = onPick;
    [vc presentViewController:picker animated:YES completion:nil];
}

+ (void)presentPlanBrowserFrom:(UIViewController *)vc {
    FSTPlanSelectViewController *picker = [[FSTPlanSelectViewController alloc] init];
    picker.dismissesOnPlanPicked = NO;  // 不 dismiss；改为内嵌 nav 上 push PlanConfirm

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:picker];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    nav.navigationBarHidden = YES;

    __weak UINavigationController *weakNav = nav;
    picker.onPlanPicked = ^(FSTPlan *plan) {
        FSTPlanConfirmViewController *confirm = [[FSTPlanConfirmViewController alloc] initWithPlan:plan];
        // Start Fasting 后已写入 session（startFastingWithPlan / markScheduledReady），
        // dismiss 模态由这里收尾；主 app 的 IdleVC viewWillAppear 自动 push ActiveFasting。
        confirm.onFastingStarted = ^{
            [weakNav dismissViewControllerAnimated:YES completion:nil];
        };
        [weakNav pushViewController:confirm animated:YES];
    };

    [vc presentViewController:nav animated:YES completion:nil];
}

+ (void)pushPlanConfirmFrom:(UIViewController *)vc plan:(FSTPlan *)plan {
    FSTPlanConfirmViewController *confirm = [[FSTPlanConfirmViewController alloc] initWithPlan:plan];
    [vc.navigationController pushViewController:confirm animated:YES];
}

#pragma mark - 断食主页 push

+ (void)pushActiveFastingFrom:(UIViewController *)vc promptForStartTime:(BOOL)prompt {
    [self pushActiveFastingFrom:vc promptForStartTime:prompt animated:YES];
}

+ (void)pushActiveFastingFrom:(UIViewController *)vc
           promptForStartTime:(BOOL)prompt
                     animated:(BOOL)animated {
    FSTActiveFastingViewController *active = [[FSTActiveFastingViewController alloc] init];
    active.promptsForStartTimeOnFirstAppear = prompt;
    [vc.navigationController pushViewController:active animated:animated];
}

#pragma mark - 记录补录 / 历史 / 日记 / 详情 / 反馈 push

+ (void)pushQuickAddRecordFrom:(UIViewController *)vc {
    FSTQuickAddRecordViewController *record = [[FSTQuickAddRecordViewController alloc] init];
    record.hidesBottomBarWhenPushed = YES;
    [vc.navigationController pushViewController:record animated:YES];
}

+ (void)pushAddRecordFrom:(UIViewController *)vc
                startDate:(NSDate *)startDate
                  endDate:(NSDate *)endDate {
    FSTAddRecordViewController *addRecord = [[FSTAddRecordViewController alloc] initWithStartDate:startDate endDate:endDate];
    addRecord.hidesBottomBarWhenPushed = YES;
    [vc.navigationController pushViewController:addRecord animated:YES];
}

+ (void)pushAddRecordFrom:(UIViewController *)vc
            editingRecord:(FSTFastingRecord *)record {
    FSTAddRecordViewController *addRecord = [[FSTAddRecordViewController alloc] initWithRecord:record];
    addRecord.hidesBottomBarWhenPushed = YES;
    [vc.navigationController pushViewController:addRecord animated:YES];
}

+ (void)pushFastingHistoryFrom:(UIViewController *)vc {
    FSTFastingHistoryViewController *history = [[FSTFastingHistoryViewController alloc] init];
    history.hidesBottomBarWhenPushed = YES;
    [vc.navigationController pushViewController:history animated:YES];
}

+ (void)pushMealDiaryFrom:(UIViewController *)vc {
    FSTMealDiaryViewController *diary = [[FSTMealDiaryViewController alloc] init];
    diary.hidesBottomBarWhenPushed = YES;
    [vc.navigationController pushViewController:diary animated:YES];
}

+ (void)pushMealDetailFrom:(UIViewController *)vc
                    record:(FSTMealRecord *)record
         returnsToTimeline:(BOOL)returnsToTimeline {
    FSTMealDetailViewController *detail = [[FSTMealDetailViewController alloc] initWithMealRecord:record
                                                                             returnsToTimelineTab:returnsToTimeline];
    detail.hidesBottomBarWhenPushed = YES;
    [vc.navigationController pushViewController:detail animated:YES];
}

+ (void)pushFeedbackFrom:(UIViewController *)vc {
    FSTSendFeedbackViewController *feedback = [[FSTSendFeedbackViewController alloc] init];
    feedback.hidesBottomBarWhenPushed = YES;
    [vc.navigationController pushViewController:feedback animated:YES];
}

#pragma mark - 分享 / 体重输入 present

+ (void)presentShareFrom:(UIViewController *)vc ringSnapshot:(UIImage *)ringSnapshot {
    FSTShareCardViewController *share = [[FSTShareCardViewController alloc] initWithRingSnapshot:ringSnapshot];
    [vc presentViewController:share animated:YES completion:nil];
}

+ (void)presentWeightInputFrom:(UIViewController *)vc
                      weightKg:(CGFloat)weightKg
                        onSave:(void (^)(CGFloat weightKg))onSave {
    FSTWeightInputViewController *weight = [[FSTWeightInputViewController alloc] init];
    weight.weightKg = weightKg;
    weight.onSave = onSave;
    weight.modalPresentationStyle = UIModalPresentationOverFullScreen;
    weight.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [vc presentViewController:weight animated:YES completion:nil];
}

#pragma mark - 完成断食 flow

+ (void)finishFlowFrom:(UIViewController *)vc
               updates:(dispatch_block_t)updates
              fallback:(dispatch_block_t)fallback {
    FSTRootTabBarController *tab = (FSTRootTabBarController *)vc.tabBarController;
    if ([tab isKindOfClass:[FSTRootTabBarController class]]) {
        [tab fst_finishFlowReturningToTimelineWithUpdates:updates];
    } else if (fallback) {
        fallback();
    }
}

@end
