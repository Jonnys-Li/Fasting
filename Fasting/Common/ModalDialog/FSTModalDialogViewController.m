//
//  FSTModalDialogViewController.m
//  Fasting
//

#import "FSTModalDialogViewController.h"
#import "FSTModalDialogContentView.h"
#import "FSTTheme.h"

@interface FSTModalDialogViewController ()
@property (nonatomic, copy, nullable) NSString *iconSystemName;
@property (nonatomic, copy, nullable) NSString *iconImageName;
@property (nonatomic, copy) NSString *dialogTitle;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *primaryTitle;
@property (nonatomic, copy, nullable) NSString *secondaryTitle;
@property (nonatomic, copy, nullable) FSTModalDialogActionHandler primaryHandler;
@property (nonatomic, copy, nullable) FSTModalDialogActionHandler secondaryHandler;

@property (nonatomic, strong) FSTModalDialogContentView *contentView;
@end

@implementation FSTModalDialogViewController

- (instancetype)initWithIconSystemName:(nullable NSString *)systemName
                                  title:(NSString *)title
                                message:(NSString *)message
                           primaryTitle:(NSString *)primaryTitle
                         secondaryTitle:(nullable NSString *)secondaryTitle
                         primaryHandler:(nullable FSTModalDialogActionHandler)primaryHandler
                       secondaryHandler:(nullable FSTModalDialogActionHandler)secondaryHandler {
    return [self initWithIconSystemName:systemName
                          iconImageName:nil
                                  title:title
                                message:message
                           primaryTitle:primaryTitle
                         secondaryTitle:secondaryTitle
                         primaryHandler:primaryHandler
                       secondaryHandler:secondaryHandler];
}

- (instancetype)initWithIconImageName:(nullable NSString *)imageName
                                 title:(NSString *)title
                               message:(NSString *)message
                          primaryTitle:(NSString *)primaryTitle
                        secondaryTitle:(nullable NSString *)secondaryTitle
                        primaryHandler:(nullable FSTModalDialogActionHandler)primaryHandler
                      secondaryHandler:(nullable FSTModalDialogActionHandler)secondaryHandler {
    return [self initWithIconSystemName:nil
                          iconImageName:imageName
                                  title:title
                                message:message
                           primaryTitle:primaryTitle
                         secondaryTitle:secondaryTitle
                         primaryHandler:primaryHandler
                       secondaryHandler:secondaryHandler];
}

- (instancetype)initWithIconSystemName:(nullable NSString *)systemName
                         iconImageName:(nullable NSString *)imageName
                                 title:(NSString *)title
                               message:(NSString *)message
                          primaryTitle:(NSString *)primaryTitle
                        secondaryTitle:(nullable NSString *)secondaryTitle
                        primaryHandler:(nullable FSTModalDialogActionHandler)primaryHandler
                      secondaryHandler:(nullable FSTModalDialogActionHandler)secondaryHandler {
    if ((self = [super init])) {
        _iconSystemName = [systemName copy];
        _iconImageName = [imageName copy];
        _dialogTitle = [title copy];
        _message = [message copy];
        _primaryTitle = [primaryTitle copy];
        _secondaryTitle = [secondaryTitle copy];
        _primaryHandler = [primaryHandler copy];
        _secondaryHandler = [secondaryHandler copy];
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
    self.contentView = [FSTModalDialogContentView new];
    self.contentView.iconSystemName = self.iconSystemName;
    self.contentView.iconImageName  = self.iconImageName;
    self.contentView.titleText      = self.dialogTitle;
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
