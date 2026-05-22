//
//  FSTModalDialogViewController.m
//  Fasting
//

#import "FSTModalDialogViewController.h"
#import "FSTTheme.h"

static const CGFloat kFSTDialogIconSize = 82.0;
static const CGFloat kFSTDialogCloseSize = 38.0;
static const CGFloat kFSTDialogButtonHeight = 58.0;

@interface FSTModalDialogViewController ()
@property (nonatomic, copy, nullable) NSString *iconSystemName;
@property (nonatomic, copy, nullable) NSString *iconImageName;
@property (nonatomic, copy) NSString *dialogTitle;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *primaryTitle;
@property (nonatomic, copy, nullable) NSString *secondaryTitle;
@property (nonatomic, copy, nullable) FSTModalDialogActionHandler primaryHandler;
@property (nonatomic, copy, nullable) FSTModalDialogActionHandler secondaryHandler;
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
    if ((self = [super initWithNibName:nil bundle:nil])) {
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
    [self buildSubviews];
}

#pragma mark - Layout

- (void)buildSubviews {
    UIView *card = self.cardContainer;

    UIView *iconBackground = [UIView new];
    iconBackground.backgroundColor = [UIColor fst_dialogIconBackground];
    iconBackground.layer.cornerRadius = kFSTDialogIconSize / 2.0;
    iconBackground.layer.masksToBounds = YES;
    [card addSubview:iconBackground];

    UIImageView *iconView = [UIImageView new];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    if (self.iconImageName.length > 0) {
        iconView.image = [UIImage imageNamed:self.iconImageName];
    } else if (self.iconSystemName.length > 0) {
        UIImageSymbolConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:36 weight:UIImageSymbolWeightMedium];
        iconView.image = [UIImage systemImageNamed:self.iconSystemName withConfiguration:configuration];
        iconView.tintColor = [UIColor fst_dialogIconTint];
    }
    [iconBackground addSubview:iconView];

    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.backgroundColor = [UIColor fst_dialogCloseBackground];
    closeButton.layer.cornerRadius = kFSTDialogCloseSize / 2.0;
    UIImageSymbolConfiguration *closeConfiguration = [UIImageSymbolConfiguration configurationWithPointSize:19 weight:UIImageSymbolWeightBold];
    [closeButton setImage:[UIImage systemImageNamed:@"xmark" withConfiguration:closeConfiguration] forState:UIControlStateNormal];
    closeButton.tintColor = [UIColor fst_dialogCloseTint];
    [closeButton addTarget:self action:@selector(handleCloseTapped) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:closeButton];

    UILabel *titleLabel = [UILabel fst_centerLabelWithFont:FSTFontBold(24) color:[UIColor fst_dialogTitle]];
    titleLabel.text = self.dialogTitle;
    titleLabel.numberOfLines = 2;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.78;
    [card addSubview:titleLabel];

    UILabel *messageLabel = [UILabel fst_centerLabelWithFont:FSTFontSemibold(18) color:[UIColor fst_textSecondary]];
    messageLabel.text = self.message;
    messageLabel.numberOfLines = 0;
    [card addSubview:messageLabel];

    UIStackView *buttonStack = [UIStackView new];
    buttonStack.axis = UILayoutConstraintAxisHorizontal;
    buttonStack.alignment = UIStackViewAlignmentFill;
    buttonStack.distribution = UIStackViewDistributionFillEqually;
    buttonStack.spacing = self.secondaryTitle.length > 0 ? 18.0 : 0.0;
    [card addSubview:buttonStack];

    if (self.secondaryTitle.length > 0) {
        UIButton *secondaryButton = [self dialogButtonWithTitle:self.secondaryTitle primary:NO];
        [secondaryButton addTarget:self action:@selector(handleSecondaryTapped) forControlEvents:UIControlEventTouchUpInside];
        [buttonStack addArrangedSubview:secondaryButton];
    }

    UIButton *primaryButton = [self dialogButtonWithTitle:self.primaryTitle primary:YES];
    [primaryButton addTarget:self action:@selector(handlePrimaryTapped) forControlEvents:UIControlEventTouchUpInside];
    [buttonStack addArrangedSubview:primaryButton];

    [iconBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(card);
        make.top.equalTo(card).offset(-kFSTDialogIconSize / 2.0);
        make.size.mas_equalTo(CGSizeMake(kFSTDialogIconSize, kFSTDialogIconSize));
    }];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(iconBackground);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(card).offset(20);
        make.right.equalTo(card).offset(-20);
        make.size.mas_equalTo(CGSizeMake(kFSTDialogCloseSize, kFSTDialogCloseSize));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(card).offset(72);
        make.left.right.equalTo(card).inset(36);
    }];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(20);
        make.left.right.equalTo(card).inset(34);
    }];
    [buttonStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(messageLabel.mas_bottom).offset(34);
        make.left.right.equalTo(card).inset(32);
        make.height.equalTo(@(kFSTDialogButtonHeight));
        make.bottom.equalTo(card).offset(-36);
    }];
}

- (UIButton *)dialogButtonWithTitle:(NSString *)title primary:(BOOL)primary {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = FSTFontBold(24);
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.minimumScaleFactor = 0.72;
    button.backgroundColor = primary ? [UIColor fst_eatingTimeGreen] : [UIColor fst_dialogSecondaryButton];
    [button setTitleColor:primary ? [UIColor whiteColor] : [UIColor fst_dialogTitle] forState:UIControlStateNormal];
    button.layer.cornerRadius = kFSTDialogButtonHeight / 2.0;
    button.layer.masksToBounds = YES;
    return button;
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
