//
//  FSTShareCardViewController.m
//  Fasting
//
//  分享卡弹窗：半透明遮罩 + 白色圆角卡片（圆环截图 + 品牌行）+ Save / Share 按钮。
//

#import "FSTShareCardViewController.h"
#import "FSTTheme.h"
#import "UIColor+FST.h"

static const CGFloat kFSTShareCardWidth          = 320;
static const CGFloat kFSTShareCardCornerRadius   = 24;
static const CGFloat kFSTShareCardPadding        = 24;
static const CGFloat kFSTShareBrandIconSize      = 28;
static const CGFloat kFSTShareButtonHeight       = 48;
static const CGFloat kFSTShareButtonCornerRadius = 24;
static const CGFloat kFSTShareButtonSpacing      = 16;

@interface FSTShareCardViewController ()
@property (nonatomic, strong) UIImage *ringSnapshot;
@property (nonatomic, strong) UIImage *shareImage;
@property (nonatomic, strong) UIView *cardView;
@end

@implementation FSTShareCardViewController

- (instancetype)initWithRingSnapshot:(UIImage *)snapshot {
    if ((self = [super init])) {
        _ringSnapshot = snapshot;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];

    UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDismiss)];
    bgTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:bgTap];

    [self buildCard];
    [self buildButtons];
    [self renderShareImage];
}

#pragma mark - Card

- (void)buildCard {
    self.cardView = [UIView new];
    self.cardView.backgroundColor = [UIColor whiteColor];
    self.cardView.layer.cornerRadius = kFSTShareCardCornerRadius;
    self.cardView.layer.masksToBounds = YES;
    [self.view addSubview:self.cardView];

    // Ring snapshot
    UIImageView *ringImageView = [[UIImageView alloc] initWithImage:self.ringSnapshot];
    ringImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.cardView addSubview:ringImageView];

    // Brand row: app icon + "Fasting Tracker"
    UIView *brandRow = [self buildBrandRow];
    [self.cardView addSubview:brandRow];

    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-40);
        make.width.mas_equalTo(kFSTShareCardWidth);
    }];
    [ringImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cardView).offset(kFSTShareCardPadding);
        make.centerX.equalTo(self.cardView);
        make.width.mas_equalTo(kFSTShareCardWidth - kFSTShareCardPadding * 2);
        make.height.equalTo(ringImageView.mas_width);
    }];
    [brandRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ringImageView.mas_bottom).offset(16);
        make.centerX.equalTo(self.cardView);
        make.bottom.equalTo(self.cardView).offset(-kFSTShareCardPadding);
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
        make.top.equalTo(self.cardView.mas_bottom).offset(20);
        make.left.equalTo(self.cardView);
        make.right.equalTo(self.cardView.mas_centerX).offset(-kFSTShareButtonSpacing / 2.0);
        make.height.mas_equalTo(kFSTShareButtonHeight);
    }];
    [shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(saveButton);
        make.left.equalTo(self.cardView.mas_centerX).offset(kFSTShareButtonSpacing / 2.0);
        make.right.equalTo(self.cardView);
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
    // Render the card view to an image for saving/sharing
    [self.view layoutIfNeeded];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.cardView layoutIfNeeded];
        UIGraphicsBeginImageContextWithOptions(self.cardView.bounds.size, NO, 0);
        [self.cardView drawViewHierarchyInRect:self.cardView.bounds afterScreenUpdates:YES];
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

- (void)handleDismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
