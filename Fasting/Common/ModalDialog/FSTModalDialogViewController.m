//
//  FSTModalDialogViewController.m
//  Fasting
//

#import "FSTModalDialogViewController.h"
#import "FSTModalDialogContentView.h"
#import "FSTTheme.h"

@interface FSTModalDialogViewController ()
@property (nonatomic, strong) FSTModalDialogContentView *contentView;
@end

@implementation FSTModalDialogViewController

- (instancetype)init {
    if ((self = [super init])) {
        self.containerStyle = FSTBaseModalContainerStyleCenteredCard;
        self.containerHorizontalInset = 36.0;
        self.containerCornerRadius = 24.0;
        self.containerClipsToBounds = NO;
        self.backdropAlpha = 0.46;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildContentView];
}

#pragma mark - Content View

- (void)buildContentView {
    self.contentView = [[FSTModalDialogContentView alloc] init];
    self.contentView.iconSystemName = (self.iconKind == FSTModalDialogIconKindSystemSymbol) ? self.iconName : nil;
    self.contentView.iconImageName  = (self.iconKind == FSTModalDialogIconKindAssetImage)   ? self.iconName : nil;
    self.contentView.titleText      = self.titleText;
    self.contentView.message        = self.message;
    self.contentView.primaryTitle   = self.primaryTitle;
    self.contentView.secondaryTitle = self.secondaryTitle;
    [self.cardContainer addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.cardContainer);
    }];

    __weak typeof(self) weakSelf = self;
    self.contentView.onCloseTapped = ^{
        [weakSelf handleCloseTapped];
    };
    self.contentView.onPrimaryTapped = ^{
        [weakSelf handlePrimaryTapped];
    };
    self.contentView.onSecondaryTapped = ^{
        [weakSelf handleSecondaryTapped];
    };
}

#pragma mark - Events

- (void)handleCloseTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handlePrimaryTapped {
    [self dismissWithHandler:self.primaryHandler];
}

- (void)handleSecondaryTapped {
    [self dismissWithHandler:self.secondaryHandler];
}

- (void)dismissWithHandler:(nullable FSTModalDialogActionHandler)handler {
    [self dismissViewControllerAnimated:YES completion:^{
        if (handler) handler();
    }];
}

@end
