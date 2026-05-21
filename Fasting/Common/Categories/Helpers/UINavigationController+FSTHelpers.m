//
//  UINavigationController+FSTHelpers.m
//  Fasting
//

#import "UINavigationController+FSTHelpers.h"

@implementation UINavigationController (FSTHelpers)

- (nullable __kindof UIViewController *)fst_firstViewControllerOfClass:(Class)cls {
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController isKindOfClass:cls]) return viewController;
    }
    return nil;
}

@end
