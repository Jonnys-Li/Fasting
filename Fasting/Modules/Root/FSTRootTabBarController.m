//
//  FSTRootTabBarController.m
//  Fasting
//

#import "FSTRootTabBarController.h"
#import "FSTFastingIdleViewController.h"
#import "FSTTimelineViewController.h"
#import "FSTAppRouter.h"
#import "FSTTheme.h"

static const NSTimeInterval kTabChromeSuppressionDelay = 0.12;

@interface FSTRootTabBarController ()
- (void)fst_removeAnimationsInView:(UIView *)view;
@end

@implementation FSTRootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 设计：每个 tab 两套图 —— 未选中=描边，选中=实心填充。两态都 AlwaysOriginal 防止系统再 tint。
    UIImage *dailyUnselected   = [UIImage fst_originalImageNamed:@"tab_daily"];
    UIImage *dailySelected     = [UIImage fst_originalImageNamed:@"tab_daily_selected"];
    UIImage *fastingUnselected = [UIImage fst_originalImageNamed:@"tab_fasting_unselected"];
    UIImage *fastingSelected   = [UIImage fst_originalImageNamed:@"tab_fasting"];
    UIImage *exploreUnselected = [UIImage fst_originalImageNamed:@"tab_explore"];
    UIImage *exploreSelected   = [UIImage fst_originalImageNamed:@"tab_explore_selected"];

    FSTTimelineViewController *timelineViewController = [FSTTimelineViewController new];
    UINavigationController *timelineNavigationController = [[UINavigationController alloc] initWithRootViewController:timelineViewController];
    timelineNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Daily"
                                                                            image:dailyUnselected
                                                                    selectedImage:dailySelected];
    timelineNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake(-8, 0, 4, 0);

    FSTFastingIdleViewController *dailyPlanViewController = [FSTFastingIdleViewController new];
    UINavigationController *fastingNavigationController = [[UINavigationController alloc] initWithRootViewController:dailyPlanViewController];
    fastingNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Fasting"
                                                                           image:fastingUnselected
                                                                   selectedImage:fastingSelected];
    fastingNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake(-6, 0, 2, 0);

    // Explore: 占位 controller，仅承载 tabBarItem；点击时由 delegate 拦截改为 modal 弹出 Choose Plan。
    UIViewController *explorePlaceholder = [UIViewController new];
    explorePlaceholder.view.backgroundColor = [UIColor fst_pageBackground];
    explorePlaceholder.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Explore"
                                                                  image:exploreUnselected
                                                          selectedImage:exploreSelected];
    explorePlaceholder.tabBarItem.imageInsets = UIEdgeInsetsMake(-6, 0, 2, 0);

    self.viewControllers = @[timelineNavigationController, fastingNavigationController, explorePlaceholder];
    self.selectedIndex = FSTTabIndexFasting;
    self.delegate = self;

    self.tabBar.tintColor = [UIColor fst_primaryGreen];
    self.tabBar.unselectedItemTintColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    self.tabBar.layer.cornerRadius = 32;
    self.tabBar.layer.masksToBounds = NO;
    self.tabBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.tabBar.layer.shadowOpacity = 0.12;
    self.tabBar.layer.shadowOffset = CGSizeMake(0, 8);
    self.tabBar.layer.shadowRadius = 22;

    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [UITabBarAppearance new];
        [appearance configureWithDefaultBackground];
        appearance.backgroundColor = [UIColor whiteColor];
        appearance.shadowColor = [UIColor clearColor];
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{
            NSFontAttributeName: FSTFontBold(12),
            NSForegroundColorAttributeName: [UIColor colorWithWhite:0.6 alpha:1.0],
        };
        appearance.stackedLayoutAppearance.normal.titlePositionAdjustment = UIOffsetMake(0, 8);
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{
            NSFontAttributeName: FSTFontBold(12),
            NSForegroundColorAttributeName: [UIColor fst_primaryGreen],
        };
        appearance.stackedLayoutAppearance.selected.titlePositionAdjustment = UIOffsetMake(0, 8);
        self.tabBar.standardAppearance = appearance;
        if (@available(iOS 15.0, *)) {
            self.tabBar.scrollEdgeAppearance = appearance;
        }
    }
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController
shouldSelectViewController:(UIViewController *)viewController {
    NSInteger targetIndex = [tabBarController.viewControllers indexOfObject:viewController];
    if (targetIndex == FSTTabIndexExplore) {
        UIViewController *presenter = tabBarController.selectedViewController ?: tabBarController;
        [FSTAppRouter presentPlanPickerFrom:presenter onPick:nil];
        return NO;  // 不真正切到 Explore tab，保留当前 tab 高亮
    }
    return YES;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    CGRect tabBarFrame = self.tabBar.frame;
    CGFloat horizontalInset = 20;
    CGFloat tabBarHeight = 74;
    CGFloat safeAreaBottomInset = self.view.safeAreaInsets.bottom;
    tabBarFrame.origin.x = horizontalInset;
    tabBarFrame.size.width = self.view.bounds.size.width - horizontalInset * 2;
    tabBarFrame.size.height = tabBarHeight;
    tabBarFrame.origin.y = self.view.bounds.size.height - tabBarHeight - MAX(8, safeAreaBottomInset * 0.2);
    self.tabBar.frame = tabBarFrame;
}

- (void)fst_finishFlowReturningToTimelineWithUpdates:(dispatch_block_t)updates {
    UINavigationController *fastingNav = nil;
    if (self.viewControllers.count > FSTTabIndexFasting) {
        UIViewController *vc = self.viewControllers[FSTTabIndexFasting];
        if ([vc isKindOfClass:[UINavigationController class]]) fastingNav = (UINavigationController *)vc;
    }
    // Timeline tab 自身可能有 push 上去的 detail 页（如从 Timeline 进入的 MealDetail 编辑态）。
    // finish flow 的语义是"保存后落到 Timeline 根视图看新记录"，因此切换前先把 Timeline 也 popToRoot。
    UINavigationController *timelineNav = nil;
    if (self.viewControllers.count > FSTTabIndexTimeline) {
        UIViewController *vc = self.viewControllers[FSTTabIndexTimeline];
        if ([vc isKindOfClass:[UINavigationController class]]) timelineNav = (UINavigationController *)vc;
    }

    UIView *transitionCover = [self.view snapshotViewAfterScreenUpdates:NO];
    transitionCover.frame = self.view.bounds;
    transitionCover.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    transitionCover.userInteractionEnabled = YES;
    [self.view addSubview:transitionCover];

    [UIView performWithoutAnimation:^{
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.selectedIndex = FSTTabIndexTimeline;
        [fastingNav popToRootViewControllerAnimated:NO];
        [timelineNav popToRootViewControllerAnimated:NO];
        if (updates) updates();
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
        [self fst_removeAnimationsInView:self.view];
        [CATransaction commit];
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTabChromeSuppressionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView performWithoutAnimation:^{
            [transitionCover removeFromSuperview];
        }];
    });
}

/// 递归清掉 self.view 子树残留的 layer 动画。**必须**跳过 self.tabBar——UITabBarItem 内部图标 swap 依赖
/// 系统 layer 动画完成，中途 removeAllAnimations 会让 image 卡在 nil（曾出现"切回 Fasting tab 时 Daily 图标消失"bug）。
- (void)fst_removeAnimationsInView:(UIView *)view {
    if (view == self.tabBar) return;
    [view.layer removeAllAnimations];
    for (UIView *subview in view.subviews) {
        [self fst_removeAnimationsInView:subview];
    }
}

@end
