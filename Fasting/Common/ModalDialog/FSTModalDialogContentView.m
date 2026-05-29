//
//  FSTModalDialogContentView.m
//  Fasting
//

#import "FSTModalDialogContentView.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

// 顶部图标 / 关闭
static const CGFloat kIconSize      = 82.0;
static const CGFloat kCloseSize     = 38.0;
static const CGFloat kIconGlyphSize = 44.0;   // 图标字形尺寸
static const CGFloat kCloseInset    = 20.0;   // 关闭按钮距顶 / 距右

// 文案（横向 inset 由标题→正文逐级收窄，为刻意的视觉收拢）
static const CGFloat kTitleTopOffset = 72.0;  // 标题距顶（避开图标）
static const CGFloat kTitleHInset    = 36.0;
static const CGFloat kMessageTopGap  = 20.0;  // 标题 ↓ 正文
static const CGFloat kMessageHInset  = 34.0;

// 底部按钮
static const CGFloat kButtonHeight  = 58.0;
static const CGFloat kButtonTopGap  = 34.0;   // 正文 ↓ 按钮
static const CGFloat kButtonHInset  = 32.0;
static const CGFloat kButtonSpacing = 18.0;   // 双按钮间距
static const CGFloat kBottomInset   = 36.0;

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
    iconBackground.layer.cornerRadius = kIconSize / 2.0;
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
    closeButton.layer.cornerRadius = kCloseSize / 2.0;
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
    buttonStack.spacing = secondaryTitle.length > 0 ? kButtonSpacing : 0.0;
    [self addSubview:buttonStack];

    if (secondaryTitle.length > 0) {
        UIButton *secondaryButton = [UIButton fst_pillButtonWithTitle:secondaryTitle style:FSTPillButtonStyleModalSecondary];
        [secondaryButton addTarget:self action:@selector(handleSecondaryTapped)
                  forControlEvents:UIControlEventTouchUpInside];
        [buttonStack addArrangedSubview:secondaryButton];
    }

    UIButton *primaryButton = [UIButton fst_pillButtonWithTitle:primaryTitle style:FSTPillButtonStyleModalPrimary];
    [primaryButton addTarget:self action:@selector(handlePrimaryTapped)
            forControlEvents:UIControlEventTouchUpInside];
    [buttonStack addArrangedSubview:primaryButton];

    // — Constraints
    [iconBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(-kIconSize / 2.0);
        make.size.mas_equalTo(CGSizeMake(kIconSize, kIconSize));
    }];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(iconBackground);
        make.size.mas_equalTo(CGSizeMake(kIconGlyphSize, kIconGlyphSize));
    }];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kCloseInset);
        make.right.equalTo(self).offset(-kCloseInset);
        make.size.mas_equalTo(CGSizeMake(kCloseSize, kCloseSize));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kTitleTopOffset);
        make.left.right.equalTo(self).inset(kTitleHInset);
    }];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(kMessageTopGap);
        make.left.right.equalTo(self).inset(kMessageHInset);
    }];
    [buttonStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(messageLabel.mas_bottom).offset(kButtonTopGap);
        make.left.right.equalTo(self).inset(kButtonHInset);
        make.height.equalTo(@(kButtonHeight));
        make.bottom.equalTo(self).offset(-kBottomInset);
    }];
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
