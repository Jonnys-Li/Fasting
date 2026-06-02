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

@interface FSTModalDialogContentView ()
@property (nonatomic, strong) UIView *iconBackground;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIStackView *buttonStack;
@property (nonatomic, strong) UIButton *secondaryButton;
@property (nonatomic, strong) UIButton *primaryButton;
@end

@implementation FSTModalDialogContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 视图组装

- (void)setupSubviews {
    self.iconBackground = [UIView new];
    self.iconBackground.backgroundColor = [UIColor fst_dialogIconBackground];
    self.iconBackground.layer.cornerRadius = kIconSize / 2.0;
    self.iconBackground.layer.masksToBounds = YES;
    [self addSubview:self.iconBackground];

    self.iconView = [UIImageView new];
    self.iconView.contentMode = UIViewContentModeScaleAspectFit;
    [self.iconBackground addSubview:self.iconView];

    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.closeButton.backgroundColor = [UIColor fst_dialogCloseBackground];
    self.closeButton.layer.cornerRadius = kCloseSize / 2.0;
    UIImageSymbolConfiguration *closeConfiguration =
        [UIImageSymbolConfiguration configurationWithPointSize:19
                                                        weight:UIImageSymbolWeightBold];
    [self.closeButton setImage:[UIImage systemImageNamed:@"xmark" withConfiguration:closeConfiguration]
                      forState:UIControlStateNormal];
    self.closeButton.tintColor = [UIColor fst_dialogCloseTint];
    [self.closeButton addTarget:self action:@selector(handleCloseTapped)
               forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];

    self.titleLabel = [UILabel fst_centerLabelWithFont:FSTFontBold(24)
                                                 color:[UIColor fst_dialogTitle]];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.78;
    [self addSubview:self.titleLabel];

    self.messageLabel = [UILabel fst_centerLabelWithFont:FSTFontSemibold(18)
                                                   color:[UIColor fst_textSecondary]];
    self.messageLabel.numberOfLines = 0;
    [self addSubview:self.messageLabel];

    self.buttonStack = [UIStackView new];
    self.buttonStack.axis = UILayoutConstraintAxisHorizontal;
    self.buttonStack.alignment = UIStackViewAlignmentFill;
    self.buttonStack.distribution = UIStackViewDistributionFillEqually;
    self.buttonStack.spacing = 0.0;
    [self addSubview:self.buttonStack];

    self.secondaryButton = [UIButton fst_pillButtonWithTitle:@"" style:FSTPillButtonStyleModalSecondary];
    [self.secondaryButton addTarget:self action:@selector(handleSecondaryTapped)
                   forControlEvents:UIControlEventTouchUpInside];
    self.secondaryButton.hidden = YES;
    [self.buttonStack addArrangedSubview:self.secondaryButton];

    self.primaryButton = [UIButton fst_pillButtonWithTitle:@"" style:FSTPillButtonStyleModalPrimary];
    [self.primaryButton addTarget:self action:@selector(handlePrimaryTapped)
                 forControlEvents:UIControlEventTouchUpInside];
    [self.buttonStack addArrangedSubview:self.primaryButton];
}

- (void)setupConstraints {
    [self.iconBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(-kIconSize / 2.0);
        make.size.mas_equalTo(CGSizeMake(kIconSize, kIconSize));
    }];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.iconBackground);
        make.size.mas_equalTo(CGSizeMake(kIconGlyphSize, kIconGlyphSize));
    }];
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kCloseInset);
        make.right.equalTo(self).offset(-kCloseInset);
        make.size.mas_equalTo(CGSizeMake(kCloseSize, kCloseSize));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kTitleTopOffset);
        make.left.right.equalTo(self).inset(kTitleHInset);
    }];
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(kMessageTopGap);
        make.left.right.equalTo(self).inset(kMessageHInset);
    }];
    [self.buttonStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.messageLabel.mas_bottom).offset(kButtonTopGap);
        make.left.right.equalTo(self).inset(kButtonHInset);
        make.height.equalTo(@(kButtonHeight));
        make.bottom.equalTo(self).offset(-kBottomInset);
    }];
}

#pragma mark - 属性同步

- (void)setIconSystemName:(NSString *)iconSystemName {
    _iconSystemName = [iconSystemName copy];
    [self refreshIcon];
}

- (void)setIconImageName:(NSString *)iconImageName {
    _iconImageName = [iconImageName copy];
    [self refreshIcon];
}

- (void)refreshIcon {
    if (self.iconImageName.length > 0) {
        self.iconView.image = [UIImage imageNamed:self.iconImageName];
        self.iconView.tintColor = nil;
    } else if (self.iconSystemName.length > 0) {
        UIImageSymbolConfiguration *configuration =
            [UIImageSymbolConfiguration configurationWithPointSize:36
                                                            weight:UIImageSymbolWeightMedium];
        self.iconView.image = [UIImage systemImageNamed:self.iconSystemName withConfiguration:configuration];
        self.iconView.tintColor = [UIColor fst_dialogIconTint];
    } else {
        self.iconView.image = nil;
    }
}

- (void)setTitleText:(NSString *)titleText {
    _titleText = [titleText copy];
    self.titleLabel.text = titleText;
}

- (void)setMessage:(NSString *)message {
    _message = [message copy];
    self.messageLabel.text = message;
}

- (void)setPrimaryTitle:(NSString *)primaryTitle {
    _primaryTitle = [primaryTitle copy];
    [self.primaryButton setTitle:primaryTitle forState:UIControlStateNormal];
}

- (void)setSecondaryTitle:(NSString *)secondaryTitle {
    _secondaryTitle = [secondaryTitle copy];
    BOOL hasSecondary = secondaryTitle.length > 0;
    [self.secondaryButton setTitle:secondaryTitle forState:UIControlStateNormal];
    self.secondaryButton.hidden = !hasSecondary;
    self.buttonStack.spacing = hasSecondary ? kButtonSpacing : 0.0;
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
