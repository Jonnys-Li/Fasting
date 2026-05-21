//
//  FSTBaseModalViewController.m
//  Fasting
//

#import "FSTBaseModalViewController.h"
#import "FSTTheme.h"

@interface FSTBaseModalViewController ()
@property (nonatomic, strong, readwrite) UIView *backdropView;
@property (nonatomic, strong, readwrite) UIView *cardContainer;
@end

@implementation FSTBaseModalViewController

- (instancetype)init {
    if ((self = [super init])) {
        [self configureDefaults];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [self configureDefaults];
    }
    return self;
}

- (void)configureDefaults {
    _dismissOnBackdropTap = YES;
    _containerStyle = FSTBaseModalContainerStyleCenteredCard;
    _backdropAlpha = 0.4;
    _backdropColor = [UIColor blackColor];
    _containerCornerRadius = 24;
    _containerClipsToBounds = YES;
    _containerHorizontalInset = 28;
    _containerVerticalOffset = 0;
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self buildBackdrop];
    [self buildCardContainer];
}

#pragma mark - 构建子视图

/// 创建并约束半透明遮罩，铺满全屏并保留背后页面可见。
- (void)buildBackdrop {
    self.backdropView = [UIView new];
    UIColor *baseColor = self.backdropColor ?: [UIColor blackColor];
    self.backdropView.backgroundColor = [baseColor colorWithAlphaComponent:self.backdropAlpha];
    [self.view addSubview:self.backdropView];
    [self.backdropView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackdropTapped)];
    [self.backdropView addGestureRecognizer:tapGesture];
}

/// 创建白色卡片容器，水平边距 28，垂直居中。
- (void)buildCardContainer {
    self.cardContainer = [UIView new];
    self.cardContainer.backgroundColor = [UIColor whiteColor];
    self.cardContainer.layer.cornerRadius = self.containerCornerRadius;
    self.cardContainer.layer.masksToBounds = self.containerClipsToBounds;
    [self.view addSubview:self.cardContainer];
    if (self.containerStyle == FSTBaseModalContainerStyleBottomSheet) {
        self.cardContainer.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
        [self.cardContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.view);
        }];
    } else {
        self.cardContainer.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        [self.cardContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view).inset(self.containerHorizontalInset);
            make.centerY.equalTo(self.view).offset(self.containerVerticalOffset);
        }];
    }
}

#pragma mark - 事件

- (void)handleBackdropTapped {
    if (!self.dismissOnBackdropTap) return;
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
