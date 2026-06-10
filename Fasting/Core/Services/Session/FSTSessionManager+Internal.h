//
//  FSTSessionManager+Internal.h
//  Fasting
//
//  仅供 Session Service 群（Persistence / Lifecycle / NextFast）使用的私有接口。
//  把 readonly property 在 service 视角下打开为 readwrite，并暴露 -persist* 协助方法。
//  业务侧（VC / View）**禁止** import 本头文件。
//

#import "FSTSessionManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTSessionManager ()

@property (nonatomic, strong, readwrite, nullable) FSTPlan *currentPlan;
@property (nonatomic, assign, readwrite) BOOL hasCompletedOnboarding;
@property (nonatomic, strong, readwrite, nullable) NSDate *activeStartDate;
@property (nonatomic, strong, readwrite, nullable) NSDate *activeEndOverrideDate;
// 下两条为纯私有属性（公开头未声明 readonly 版本），故不带 readwrite；带 readwrite 的是「重开公开 readonly」的属性。
@property (nonatomic, strong, nullable) NSDate *eatingWindowAnchorDate;
@property (nonatomic, assign) BOOL pendingActiveStartDatePrompt;
@property (nonatomic, assign, readwrite) FSTScheduledReadySource scheduledReadySource;
@property (nonatomic, strong, readwrite, nullable) NSDate *scheduledReadyAnchorDate;

- (void)persistAllState;

@end

NS_ASSUME_NONNULL_END
