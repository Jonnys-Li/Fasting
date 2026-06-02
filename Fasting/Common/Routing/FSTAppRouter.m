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
#import "FSTSendFeedbackViewController.h"
#import "FSTShareCardViewController.h"
#import "FSTWeightInputViewController.h"
#import "FSTRootTabBarController.h"
#import "FSTPlan.h"
#import "FSTFastingRecord.h"

@implementation FSTAppRouter

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

+ (void)presentPlanPickerFrom:(UIViewController *)vc
                       onPick:(void (^)(FSTPlan *plan))onPick {
    FSTPlanSelectViewController *picker = [[FSTPlanSelectViewController alloc] init];
    picker.modalPresentationStyle = UIModalPresentationFullScreen;
    picker.onPlanPicked = onPick;
    [vc presentViewController:picker animated:YES completion:nil];
}

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
