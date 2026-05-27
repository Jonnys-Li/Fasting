//
//  SceneDelegate.m
//  Fasting
//
//  Scene 生命周期与启动路由：
//    - onboarding 未完成 → 走 Plan 选择 + 确认引导流。
//    - onboarding 完成 → 优先用 session.stateRestorationActivity 恢复上次的 TabBar；失败装默认 TabBar。
//
//  Scene state restoration 的编/解码不在这里，下沉到 FSTSceneStateRestoration（NSUserActivity ↔ TabBar）。
//

#import "SceneDelegate.h"

#import "FSTRootTabBarController.h"
#import "FSTPlanSelectViewController.h"
#import "FSTPlanConfirmViewController.h"
#import "FSTSessionManager.h"
#import "FSTSceneStateRestoration.h"

@interface SceneDelegate ()
@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene
willConnectToSession:(UISceneSession *)session
      options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) return;
    self.window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];

    FSTSessionManager *sessionManager = [FSTSessionManager sharedManager];
    if (sessionManager.hasCompletedOnboarding && sessionManager.currentPlan) {
        // 完成 onboarding 才尝试恢复 nav 栈；onboarding 中段状态不恢复（重启重走引导）。
        FSTRootTabBarController *restored =
            [FSTSceneStateRestoration restoredRootTabBarFromActivity:session.stateRestorationActivity];
        self.window.rootViewController = restored ?: [FSTRootTabBarController new];
    } else {
        [self installOnboardingPlanFlow];
    }
    [self.window makeKeyAndVisible];
}

/// 系统在 scene 进入后台 / 被回收前调用，把返回的 activity 持久化；
/// 下次 willConnectToSession 时在 session.stateRestorationActivity 取回。
- (nullable NSUserActivity *)stateRestorationActivityForScene:(UIScene *)scene {
    return [FSTSceneStateRestoration activityForRootViewController:self.window.rootViewController];
}

#pragma mark - Installers

- (void)installRootTabBarController {
    self.window.rootViewController = [FSTRootTabBarController new];
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
