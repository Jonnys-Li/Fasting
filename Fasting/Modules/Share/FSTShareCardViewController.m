//
//  FSTShareCardViewController.m
//  Fasting
//
//  分享卡弹窗：复用 FSTBaseModalViewController 的遮罩 + cardContainer，
//  内容（圆环截图 + 品牌行）放进 cardContainer；Save/Share 按钮挂在 self.view 上、位于卡片下方。
//  按钮和卡片都不在 backdropView 内，因此点击它们不会触发 backdrop tap dismiss。
//

#import "FSTShareCardViewController.h"
#import "FSTTheme.h"
#import "UIColor+FST.h"

static const CGFloat kFSTShareCardPadding        = 24;
static const CGFloat kFSTShareBrandIconSize      = 28;
static const CGFloat kFSTShareButtonHeight       = 48;
static const CGFloat kFSTShareButtonCornerRadius = 24;
static const CGFloat kFSTShareButtonSpacing      = 16;

@interface FSTShareCardViewController ()
@property (nonatomic, strong) UIImage *ringSnapshot;
@property (nonatomic, strong) UIImage *shareImage;
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
    [self renderShareImage];
}

#pragma mark - Card

- (void)buildCardContent {
    UIImageView *ringImageView = [[UIImageView alloc] initWithImage:self.ringSnapshot];
    ringImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.cardContainer addSubview:ringImageView];

    UIView *brandRow = [self buildBrandRow];
    [self.cardContainer addSubview:brandRow];

    [ringImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cardContainer).offset(kFSTShareCardPadding);
        make.left.equalTo(self.cardContainer).offset(kFSTShareCardPadding);
        make.right.equalTo(self.cardContainer).offset(-kFSTShareCardPadding);
        make.height.equalTo(ringImageView.mas_width);
    }];
    [brandRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ringImageView.mas_bottom).offset(16);
        make.centerX.equalTo(self.cardContainer);
        make.bottom.equalTo(self.cardContainer).offset(-kFSTShareCardPadding);
    }];
}

- (UIView *)buildBrandRow {
    UIView *row = [UIView new];

    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"share_app_icon"]];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    iconView.layer.cornerRadius = kFSTShareBrandIconSize / 2.0;
    iconView.layer.masksToBounds = YES;
    [row addSubview:iconView];

    UILabel *nameLabel = [UILabel new];
    nameLabel.text = @"Fasting Tracker";
    nameLabel.font = FSTFontBold(16);
    nameLabel.textColor = [UIColor blackColor];
    [row addSubview:nameLabel];

    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(row);
        make.size.mas_equalTo(CGSizeMake(kFSTShareBrandIconSize, kFSTShareBrandIconSize));
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
    UIButton *saveButton = [self actionButtonWithTitle:@"Save" action:@selector(handleSave)];
    UIButton *shareButton = [self actionButtonWithTitle:@"Share" action:@selector(handleShare)];
    [self.view addSubview:saveButton];
    [self.view addSubview:shareButton];

    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cardContainer.mas_bottom).offset(20);
        make.left.equalTo(self.cardContainer);
        make.right.equalTo(self.cardContainer.mas_centerX).offset(-kFSTShareButtonSpacing / 2.0);
        make.height.mas_equalTo(kFSTShareButtonHeight);
    }];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(saveButton);
        make.left.equalTo(self.cardContainer.mas_centerX).offset(kFSTShareButtonSpacing / 2.0);
        make.right.equalTo(self.cardContainer);
        make.height.mas_equalTo(kFSTShareButtonHeight);
    }];
}

- (UIButton *)actionButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor fst_eatingTimeGreen];
    button.layer.cornerRadius = kFSTShareButtonCornerRadius;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = FSTFontBold(16);
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

#pragma mark - Render share image

- (void)renderShareImage {
    [self.view layoutIfNeeded];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cardContainer layoutIfNeeded];
        UIGraphicsBeginImageContextWithOptions(self.cardContainer.bounds.size, NO, 0);
        [self.cardContainer drawViewHierarchyInRect:self.cardContainer.bounds afterScreenUpdates:YES];
        self.shareImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
}

#pragma mark - Actions

- (void)handleSave {
    if (!self.shareImage) return;
    UIImageWriteToSavedPhotosAlbum(self.shareImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"Save image error: %@", error.localizedDescription);
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)handleShare {
    if (!self.shareImage) return;
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[self.shareImage] applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
