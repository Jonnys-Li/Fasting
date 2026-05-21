//
//  FSTRootTabBarController.m
//  Fasting
//

#import "FSTRootTabBarController.h"
#import "FSTDailyPlanViewController.h"
#import "FSTTimelineViewController.h"
#import "FSTPlanSelectViewController.h"
#import "FSTTheme.h"

@implementation FSTRootTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 设计：每个 tab 两套图 —— 未选中=描边，选中=实心填充。两态都 AlwaysOriginal 防止系统再 tint。
    UIImage *dailyUnselected   = [[UIImage imageNamed:@"tab_daily"]              imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *dailySelected     = [[UIImage imageNamed:@"tab_daily_selected"]     imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *fastingUnselected = [[UIImage imageNamed:@"tab_fasting_unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *fastingSelected   = [[UIImage imageNamed:@"tab_fasting"]            imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *exploreUnselected = [[UIImage imageNamed:@"tab_explore"]            imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImage *exploreSelected   = [[UIImage imageNamed:@"tab_explore_selected"]   imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    FSTTimelineViewController *timelineViewController = [FSTTimelineViewController new];
    UINavigationController *timelineNavigationController = [[UINavigationController alloc] initWithRootViewController:timelineViewController];
    timelineNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Daily"
                                                                            image:dailyUnselected
                                                                    selectedImage:dailySelected];
    timelineNavigationController.tabBarItem.imageInsets = UIEdgeInsetsMake(-8, 0, 4, 0);


    FSTDailyPlanViewController *dailyPlanViewController = [FSTDailyPlanViewController new];
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
        FSTPlanSelectViewController *picker = [FSTPlanSelectViewController new];
        picker.modalPresentationStyle = UIModalPresentationFullScreen;
        UIViewController *presenter = tabBarController.selectedViewController ?: tabBarController;
        [presenter presentViewController:picker animated:YES completion:nil];
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

@end
