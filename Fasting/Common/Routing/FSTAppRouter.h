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

/// 触发：AddRecord / QuickAdd 时间非法、Idle 提醒占位 → 去向：系统单按钮 Alert（非页面跳转）。
+ (void)showAlertFrom:(UIViewController *)vc
                title:(NSString *)title
              message:(NSString *)message
          buttonTitle:(NSString *)buttonTitle;

/// 触发：PlanConfirm / Idle ready / Active 的「换方案」→ 去向：present 全屏 FSTPlanSelectViewController；
/// 选定经 onPick 回调返回，换方案副作用由调用方处理（不在 router 内改 Session）。
+ (void)presentPlanPickerFrom:(UIViewController *)vc
                       onPick:(void (^_Nullable)(FSTPlan *plan))onPick;

/// 触发：Explore tab tap → 去向：present「picker 套 nav」的完整浏览流；点 plan card 在模态内 push PlanConfirm，
/// PlanConfirm 点 Start Fasting 触发 startFastingWithPlan 后 dismiss 模态，主 app 的 IdleVC 在 viewWillAppear
/// 自动重定向到 ActiveFasting（与「plan card 普通路由」链路对齐）。
+ (void)presentPlanBrowserFrom:(UIViewController *)vc;

/// 触发：Idle（自动重定向 / 预约到点 / ready start / 过去时间）、PlanConfirm 即时开始
/// → 去向：push FSTActiveFastingViewController；prompt=YES 时首现弹起始时间编辑。
+ (void)pushActiveFastingFrom:(UIViewController *)vc promptForStartTime:(BOOL)prompt;
+ (void)pushActiveFastingFrom:(UIViewController *)vc
           promptForStartTime:(BOOL)prompt
                     animated:(BOOL)animated;

/// 触发：Idle 点 plan card → 去向：push FSTPlanConfirmViewController（onFastingStarted=nil，
/// 靠 Idle viewWillAppear 重定向；与 presentPlanBrowserFrom: 内嵌的模态 push 是两条不同链路）。
+ (void)pushPlanConfirmFrom:(UIViewController *)vc plan:(FSTPlan *)plan;

/// 触发：Idle ready「Add Record」→ 去向：push FSTQuickAddRecordViewController。
+ (void)pushQuickAddRecordFrom:(UIViewController *)vc;
/// 触发：Active「END / COMPLETE FASTING」→ 去向：push FSTAddRecordViewController（预填本次起止时间）。
+ (void)pushAddRecordFrom:(UIViewController *)vc
                startDate:(NSDate *)startDate
                  endDate:(NSDate *)endDate;
/// 触发：FastingHistory 点已有记录 → 去向：push FSTAddRecordViewController（编辑态）。
+ (void)pushAddRecordFrom:(UIViewController *)vc
            editingRecord:(FSTFastingRecord *)record;
/// 触发：Timeline「断食历史」more → 去向：push FSTFastingHistoryViewController。
+ (void)pushFastingHistoryFrom:(UIViewController *)vc;
/// 触发：Timeline 食物日记 chevron → 去向：push FSTMealDiaryViewController。
+ (void)pushMealDiaryFrom:(UIViewController *)vc;
/// 触发：Timeline「+Add」/ 点 meal（returnsToTimeline=NO）、Idle「Log Meal」(=YES)、MealDiary 点 meal (=NO)
/// → 去向：push FSTMealDetailViewController；returnsToTimeline=YES 时保存后切 Timeline tab + 双 nav pop。
+ (void)pushMealDetailFrom:(UIViewController *)vc
                    record:(FSTMealRecord *_Nullable)record
         returnsToTimeline:(BOOL)returnsToTimeline;
/// 触发：Idle ready / Active 的反馈按钮 → 去向：push FSTSendFeedbackViewController。
+ (void)pushFeedbackFrom:(UIViewController *)vc;

/// 触发：Active 分享按钮 → 去向：present FSTShareCardViewController 模态（传入断食环形快照）。
+ (void)presentShareFrom:(UIViewController *)vc ringSnapshot:(UIImage *_Nullable)ringSnapshot;
/// 触发：AddRecord 体重卡编辑 → 去向：present 全屏覆盖 FSTWeightInputViewController；新值经 onSave 回调返回。
+ (void)presentWeightInputFrom:(UIViewController *)vc
                      weightKg:(CGFloat)weightKg
                        onSave:(void (^)(CGFloat weightKg))onSave;

/// 触发：AddRecord / QuickAdd / MealDetail 保存记录 → 去向：若 vc 处于 RootTabBarController 树下，
/// 走特殊「切到 Timeline + popToRoot」动画；否则走 fallback（通常是 finishFasting + 普通 pop）。
+ (void)finishFlowFrom:(UIViewController *)vc
               updates:(dispatch_block_t)updates
              fallback:(dispatch_block_t _Nullable)fallback;

@end

NS_ASSUME_NONNULL_END
