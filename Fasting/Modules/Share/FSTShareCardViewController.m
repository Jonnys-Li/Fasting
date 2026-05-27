//
//  FSTShareCardViewController.m
//  Fasting
//
//  分享卡弹窗：复用 FSTBaseModalViewController 的遮罩 + cardContainer，
//  内容（圆环截图 + 品牌行）放进 cardContainer；Save/Share 按钮挂在 self.view 上、位于卡片下方。
//  当前实现：UI 完整保留，但 Save / Share 仅做"样子"——直接 dismiss，不真实保存到相册或弹分享菜单。
//

#import "FSTShareCardViewController.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

// Card
static const CGFloat kCardPadding   = 24;
static const CGFloat kBrandIconSize = 28;

// Buttons
static const CGFloat kButtonHeight       = 48;
static const CGFloat kButtonCornerRadius = 24;
static const CGFloat kButtonSpacing      = 16;

@interface FSTShareCardViewController ()
@property (nonatomic, strong) UIImage *ringSnapshot;
@end

@implementation FSTShareCardViewController

- (instancetype)initWithRingSnapshot:(UIImage *)snapshot {
    if ((self = [super init])) {
        _ringSnapshot = snapshot;
        self.backdropAlpha = 0.5;
        self.containerVerticalOffset = -40;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildCardContent];
    [self buildButtons];
}

#pragma mark - Card

- (void)buildCardContent {
    UIImageView *ringImageView = [[UIImageView alloc] initWithImage:self.ringSnapshot];
    ringImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.cardContainer addSubview:ringImageView];

    UIView *brandRow = [self buildBrandRow];
    [self.cardContainer addSubview:brandRow];

    [ringImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cardContainer).offset(kCardPadding);
        make.left.equalTo(self.cardContainer).offset(kCardPadding);
        make.right.equalTo(self.cardContainer).offset(-kCardPadding);
        make.height.equalTo(ringImageView.mas_width);
    }];
    [brandRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ringImageView.mas_bottom).offset(16);
        make.centerX.equalTo(self.cardContainer);
        make.bottom.equalTo(self.cardContainer).offset(-kCardPadding);
    }];
}

- (UIView *)buildBrandRow {
    UIView *row = [UIView new];

    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"share_app_icon"]];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.layer.cornerRadius = kBrandIconSize / 2.0;
    iconView.layer.masksToBounds = YES;

    UILabel *nameLabel = [UILabel fst_labelWithText:@"Fasting Tracker" font:FSTFontBold(16) color:[UIColor blackColor]];

    [row fst_addSubviews:@[iconView, nameLabel]];

    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(row);
        make.size.mas_equalTo(CGSizeMake(kBrandIconSize, kBrandIconSize));
    }];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconView.mas_right).offset(8);
        make.centerY.equalTo(iconView);
        make.right.equalTo(row);
    }];
    return row;
}

#pragma mark - Buttons

- (void)buildButtons {
    UIButton *saveButton  = [self actionButtonWithTitle:@"Save"  action:@selector(handleDismiss)];
    UIButton *shareButton = [self actionButtonWithTitle:@"Share" action:@selector(handleDismiss)];
    [self.view fst_addSubviews:@[saveButton, shareButton]];

    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cardContainer.mas_bottom).offset(20);
        make.left.equalTo(self.cardContainer);
        make.right.equalTo(self.cardContainer.mas_centerX).offset(-kButtonSpacing / 2.0);
        make.height.mas_equalTo(kButtonHeight);
    }];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(saveButton);
        make.left.equalTo(self.cardContainer.mas_centerX).offset(kButtonSpacing / 2.0);
        make.right.equalTo(self.cardContainer);
        make.height.mas_equalTo(kButtonHeight);
    }];
}

- (UIButton *)actionButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor fst_eatingTimeGreen];
    button.layer.cornerRadius = kButtonCornerRadius;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = FSTFontBold(16);
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Actions

- (void)handleDismiss {
    // 样子化：Save / Share 都直接 dismiss，不真实保存或弹分享菜单。
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
