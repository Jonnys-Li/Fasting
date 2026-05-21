//
//  FSTBaseViewController.m
//  Fasting
//

#import "FSTBaseViewController.h"
#import "FSTTheme.h"

@interface FSTBaseViewController ()
@property (nonatomic, strong, nullable) NSTimer *refreshTimer;
@end

@implementation FSTBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.view.backgroundColor) {
        self.view.backgroundColor = [UIColor fst_pageBackground];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDarkContent;
}

#pragma mark - Refresh Timer

- (void)startRefreshTimer {
    [self stopRefreshTimer];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                         target:self
                                                       selector:@selector(refreshTimerDidFire)
                                                       userInfo:nil
                                                        repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.refreshTimer forMode:NSRunLoopCommonModes];
}

- (void)stopRefreshTimer {
    [self.refreshTimer invalidate];
    self.refreshTimer = nil;
}

- (void)refreshTimerDidFire {}

@end
