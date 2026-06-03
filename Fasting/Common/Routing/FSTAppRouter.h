//
//  FSTAppRouter.h
//  Fasting
//
//  全局导航助手：消除 VC 里大量的 "[XxxViewController alloc/init + push/present]" 样板。
//  每个 + (void)xxxFrom:(UIViewController *)vc 接受一个 source VC，自己处理 push/present、
//  hidesBottomBarWhenPushed、modalPresentationStyle 等细节。
//
//  使用约定：本类不持有状态、不引用 Session — 仅做导航编排。需要传业务数据时通过参数。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FSTPlan, FSTMealRecord, FSTFastingRecord;

@interface FSTAppRouter : NSObject

+ (void)showAlertFrom:(UIViewController *)vc
                title:(NSString *)title
              message:(NSString *)message
          buttonTitle:(NSString *)buttonTitle;

+ (void)presentPlanPickerFrom:(UIViewController *)vc
                       onPick:(void (^_Nullable)(FSTPlan *plan))onPick;

/// "浏览 Plan" 完整流：picker 套 nav controller 包，点 plan card 后 push PlanConfirm；
/// PlanConfirm 内点 Start Fasting 触发 startFastingWithPlan 后 dismiss 模态，
/// 主 app 的 IdleVC 在 viewWillAppear 自动重定向到 ActiveFasting。
/// Explore tab tap 走这条入口（与"plan card 普通路由"链路对齐）。
+ (void)presentPlanBrowserFrom:(UIViewController *)vc;

+ (void)pushActiveFastingFrom:(UIViewController *)vc promptForStartTime:(BOOL)prompt;
+ (void)pushActiveFastingFrom:(UIViewController *)vc
           promptForStartTime:(BOOL)prompt
                     animated:(BOOL)animated;

+ (void)pushQuickAddRecordFrom:(UIViewController *)vc;
+ (void)pushAddRecordFrom:(UIViewController *)vc
                startDate:(NSDate *)startDate
                  endDate:(NSDate *)endDate;
+ (void)pushAddRecordFrom:(UIViewController *)vc
            editingRecord:(FSTFastingRecord *)record;
+ (void)pushFastingHistoryFrom:(UIViewController *)vc;
+ (void)pushMealDiaryFrom:(UIViewController *)vc;
+ (void)pushMealDetailFrom:(UIViewController *)vc
                    record:(FSTMealRecord *_Nullable)record
         returnsToTimeline:(BOOL)returnsToTimeline;
+ (void)pushFeedbackFrom:(UIViewController *)vc;

+ (void)presentShareFrom:(UIViewController *)vc ringSnapshot:(UIImage *_Nullable)ringSnapshot;
+ (void)presentWeightInputFrom:(UIViewController *)vc
                      weightKg:(CGFloat)weightKg
                        onSave:(void (^)(CGFloat weightKg))onSave;

/// 完成断食 flow：若 vc 处于 RootTabBarController 树下，走特殊"切到 Timeline + popToRoot"动画；
/// 否则走 fallback（通常是 finishFasting + 普通 pop）。
+ (void)finishFlowFrom:(UIViewController *)vc
               updates:(dispatch_block_t)updates
              fallback:(dispatch_block_t _Nullable)fallback;

@end

NS_ASSUME_NONNULL_END
