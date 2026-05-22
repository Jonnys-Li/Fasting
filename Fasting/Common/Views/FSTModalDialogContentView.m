//
//  FSTModalDialogContentView.m
//  Fasting
//

#import "FSTModalDialogContentView.h"
#import "FSTTheme.h"

static const CGFloat kFSTDialogIconSize     = 82.0;
static const CGFloat kFSTDialogCloseSize    = 38.0;
static const CGFloat kFSTDialogButtonHeight = 58.0;

@implementation FSTModalDialogContentView

#pragma mark - 初始化

- (instancetype)initWithIconSystemName:(nullable NSString *)systemName
                         iconImageName:(nullable NSString *)imageName
                                 title:(NSString *)title
                               message:(NSString *)message
                          primaryTitle:(NSString *)primaryTitle
                        secondaryTitle:(nullable NSString *)secondaryTitle {
    if ((self = [super initWithFrame:CGRectZero])) {
        [self buildSubviewsWithIconSystemName:systemName
                                iconImageName:imageName
                                        title:title
                                      message:message
                                 primaryTitle:primaryTitle
                               secondaryTitle:secondaryTitle];
    }
    return self;
}

#pragma mark - 视图组装

- (void)buildSubviewsWithIconSystemName:(nullable NSString *)systemName
                          iconImageName:(nullable NSString *)imageName
                                  title:(NSString *)title
                                message:(NSString *)message
                           primaryTitle:(NSString *)primaryTitle
                         secondaryTitle:(nullable NSString *)secondaryTitle {

    // — Icon background circle
    UIView *iconBackground = [UIView new];
    iconBackground.backgroundColor = [UIColor fst_dialogIconBackground];
    iconBackground.layer.cornerRadius = kFSTDialogIconSize / 2.0;
    iconBackground.layer.masksToBounds = YES;
    [self addSubview:iconBackground];

    UIImageView *iconView = [UIImageView new];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    if (imageName.length > 0) {
        iconView.image = [UIImage imageNamed:imageName];
    } else if (systemName.length > 0) {
        UIImageSymbolConfiguration *configuration =
            [UIImageSymbolConfiguration configurationWithPointSize:36
                                                            weight:UIImageSymbolWeightMedium];
        iconView.image = [UIImage systemImageNamed:systemName withConfiguration:configuration];
        iconView.tintColor = [UIColor fst_dialogIconTint];
    }
    [iconBackground addSubview:iconView];

    // — Close button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.backgroundColor = [UIColor fst_dialogCloseBackground];
    closeButton.layer.cornerRadius = kFSTDialogCloseSize / 2.0;
    UIImageSymbolConfiguration *closeConfiguration =
        [UIImageSymbolConfiguration configurationWithPointSize:19
                                                        weight:UIImageSymbolWeightBold];
    [closeButton setImage:[UIImage systemImageNamed:@"xmark" withConfiguration:closeConfiguration]
                 forState:UIControlStateNormal];
    closeButton.tintColor = [UIColor fst_dialogCloseTint];
    [closeButton addTarget:self action:@selector(handleCloseTapped)
          forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];

    // — Title label
    UILabel *titleLabel = [UILabel fst_centerLabelWithFont:FSTFontBold(24)
                                                     color:[UIColor fst_dialogTitle]];
    titleLabel.text = title;
    titleLabel.numberOfLines = 2;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.78;
    [self addSubview:titleLabel];

    // — Message label
    UILabel *messageLabel = [UILabel fst_centerLabelWithFont:FSTFontSemibold(18)
                                                       color:[UIColor fst_textSecondary]];
    messageLabel.text = message;
    messageLabel.numberOfLines = 0;
    [self addSubview:messageLabel];

    // — Button stack
    UIStackView *buttonStack = [UIStackView new];
    buttonStack.axis = UILayoutConstraintAxisHorizontal;
    buttonStack.alignment = UIStackViewAlignmentFill;
    buttonStack.distribution = UIStackViewDistributionFillEqually;
    buttonStack.spacing = secondaryTitle.length > 0 ? 18.0 : 0.0;
    [self addSubview:buttonStack];

    if (secondaryTitle.length > 0) {
        UIButton *secondaryButton = [self dialogButtonWithTitle:secondaryTitle primary:NO];
        [secondaryButton addTarget:self action:@selector(handleSecondaryTapped)
                  forControlEvents:UIControlEventTouchUpInside];
        [buttonStack addArrangedSubview:secondaryButton];
    }

    UIButton *primaryButton = [self dialogButtonWithTitle:primaryTitle primary:YES];
    [primaryButton addTarget:self action:@selector(handlePrimaryTapped)
            forControlEvents:UIControlEventTouchUpInside];
    [buttonStack addArrangedSubview:primaryButton];

    // — Constraints
    [iconBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(-kFSTDialogIconSize / 2.0);
        make.size.mas_equalTo(CGSizeMake(kFSTDialogIconSize, kFSTDialogIconSize));
    }];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(iconBackground);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.size.mas_equalTo(CGSizeMake(kFSTDialogCloseSize, kFSTDialogCloseSize));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(72);
        make.left.right.equalTo(self).inset(36);
    }];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(20);
        make.left.right.equalTo(self).inset(34);
    }];
    [buttonStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(messageLabel.mas_bottom).offset(34);
        make.left.right.equalTo(self).inset(32);
        make.height.equalTo(@(kFSTDialogButtonHeight));
        make.bottom.equalTo(self).offset(-36);
    }];
}

- (UIButton *)dialogButtonWithTitle:(NSString *)title primary:(BOOL)primary {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = FSTFontBold(24);
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.minimumScaleFactor = 0.72;
    button.backgroundColor = primary ? [UIColor fst_eatingTimeGreen]
                                     : [UIColor fst_dialogSecondaryButton];
    [button setTitleColor:primary ? [UIColor whiteColor] : [UIColor fst_dialogTitle]
                 forState:UIControlStateNormal];
    button.layer.cornerRadius = kFSTDialogButtonHeight / 2.0;
    button.layer.masksToBounds = YES;
    return button;
}

#pragma mark - 事件

- (void)handleCloseTapped {
    if (self.onCloseTapped) self.onCloseTapped();
}

- (void)handlePrimaryTapped {
    if (self.onPrimaryTapped) self.onPrimaryTapped();
}

- (void)handleSecondaryTapped {
    if (self.onSecondaryTapped) self.onSecondaryTapped();
}

@end
