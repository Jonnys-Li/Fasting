//
//  SceneDelegate.m
//  Fasting
//

#import "SceneDelegate.h"
#import "FSTRootTabBarController.h"
#import "FSTPlanSelectViewController.h"
#import "FSTPlanConfirmViewController.h"
#import "FSTSessionManager.h"

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
        [self installRootTabBarController];
    } else {
        [self installOnboardingPlanFlow];
    }
    [self.window makeKeyAndVisible];
}

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
