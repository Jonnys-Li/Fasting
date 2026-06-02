//
//  FSTPlanSelectViewController.m
//  Fasting
//
//  顶部 headerView 固定在屏幕上方，覆盖在 scrollView 之上；
//  scrollView 占满整个视图，顶部 contentInset 让初始内容落在 header 下面；
//  下滑滚动时，图片会从 header 后方滑过、被遮挡。
//

#import "FSTPlanSelectViewController.h"
#import "FSTPlanSelectListView.h"
#import "FSTPlanTagChipsBar.h"
#import "UIButton+FST.h"
#import "FSTTheme.h"

static const CGFloat FSTPlanSelectHeaderHeight = 162;  // 8pt 顶部 + 48pt 按钮行 + 12pt + 32pt+10pt+32pt 双行 chip + 12pt 底部

@interface FSTPlanSelectViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *headerView;
@end

@implementation FSTPlanSelectViewController

- (instancetype)init {
    if ((self = [super init])) {
        _showsCloseButton = YES;
        _dismissesOnPlanPicked = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildScrollContainer];
    [self buildStickyHeader];   // 后加入 -> 在 z-order 上覆盖 scrollView
}

- (void)buildScrollContainer {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:self.scrollView];

    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];

    FSTPlanSelectListView *listView = [[FSTPlanSelectListView alloc] init];
    __weak typeof(self) weakSelf = self;
    listView.onPlanPicked = ^(FSTPlan *picked) {
        if (weakSelf.onPlanPicked) weakSelf.onPlanPicked(picked);
        if (weakSelf.dismissesOnPlanPicked) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    };
    [self.contentView addSubview:listView];

    [listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.left.right.equalTo(self.contentView).inset(22);
        make.height.equalTo(listView.mas_width).multipliedBy(716.0 / 335.0).offset(48.0);
        make.bottom.equalTo(self.contentView).offset(-40);
    }];
}
- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];
    CGFloat totalInsetTop = self.view.safeAreaInsets.top + FSTPlanSelectHeaderHeight;
    self.scrollView.contentInset = UIEdgeInsetsMake(totalInsetTop, 0, 0, 0);
    self.scrollView.verticalScrollIndicatorInsets = UIEdgeInsetsMake(totalInsetTop, 0, 0, 0);
}

- (void)buildStickyHeader {
    // 顶部白条要顶到屏幕物理顶部（盖住状态栏背景），里面的控件再用 safeAreaLayoutGuide 避开灵动岛/状态栏。
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.headerView];
    UIView *headerContentView = [[UIView alloc] init];
      [self.headerView addSubview:headerContentView];

    UIButton *closeButton = nil;
    if (self.showsCloseButton) {
        closeButton = [UIButton fst_navCircleButtonWithImageNamed:@"nav_back" diameter:48];
        [closeButton addTarget:self action:@selector(handleCloseTapped) forControlEvents:UIControlEventTouchUpInside];
        [headerContentView addSubview:closeButton];
    }

    UILabel *titleLabel = [UILabel fst_labelWithText:@"Choose one to start fasting"
                                                 font:FSTFontBold(18)
                                                color:[UIColor fst_textPrimary]
                                            alignment:NSTextAlignmentCenter];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.8;
    [headerContentView addSubview:titleLabel];

    FSTPlanTagChipsBar *chipsBar = [[FSTPlanTagChipsBar alloc] init];
    [headerContentView addSubview:chipsBar];

    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(FSTPlanSelectHeaderHeight);
    }];
    [headerContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
            make.left.right.bottom.equalTo(self.headerView);
        }];
    if (closeButton) {
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headerContentView).offset(24);
            make.top.equalTo(headerContentView).offset(8);
            make.size.mas_equalTo(CGSizeMake(48, 48));
        }];
    }
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (closeButton) {
            make.centerY.equalTo(closeButton);
            make.left.greaterThanOrEqualTo(closeButton.mas_right).offset(12);
        } else {
            make.top.equalTo(headerContentView).offset(8);
            make.height.equalTo(@48);
            make.left.greaterThanOrEqualTo(headerContentView).offset(24);
        }
        make.centerX.equalTo(headerContentView);
        make.right.lessThanOrEqualTo(headerContentView).offset(-24);
    }];
    UIView *chipsTopAnchor = closeButton ?: titleLabel;
    [chipsBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(chipsTopAnchor.mas_bottom).offset(12);
        make.left.right.equalTo(headerContentView);
        make.bottom.lessThanOrEqualTo(headerContentView).offset(-12);
        make.height.mas_equalTo(74);
    }];
}

- (void)handleCloseTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
