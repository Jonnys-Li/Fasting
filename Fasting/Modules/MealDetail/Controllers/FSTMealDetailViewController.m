//
//  FSTMealDetailViewController.m
//  Fasting
//
//  餐食详情页：5 张卡片（时间/正餐or零食/饮食类型/味道/详情）+ 底部保存按钮。
//  状态分布在子卡片里，保存时统一向 SessionManager 写入 FSTMealRecord。
//

#import "FSTMealDetailViewController.h"
#import "FSTMealTimeCardView.h"
#import "FSTMealSlotCardView.h"
#import "FSTMealDietCardView.h"
#import "FSTMealTasteCardView.h"
#import "FSTMealDetailContentCardView.h"
#import "FSTVerticalCardStackView.h"
#import "FSTRootTabBarController.h"
#import "FSTSessionManager.h"
#import "FSTMealImageService.h"
#import "FSTTheme.h"

@interface FSTMealDetailViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) FSTMealRecord *record;
@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, strong) FSTMealTimeCardView *timeCardView;
@property (nonatomic, strong) FSTMealSlotCardView *slotCardView;
@property (nonatomic, strong) FSTMealDietCardView *dietCardView;
@property (nonatomic, strong) FSTMealTasteCardView *tasteCardView;
@property (nonatomic, strong) FSTMealDetailContentCardView *detailCardView;
@end

@implementation FSTMealDetailViewController

- (instancetype)initWithMealRecord:(FSTMealRecord *)record {
    if ((self = [super init])) {
        _record = record;
        _imagePath = record.imagePath ?: @"";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor fst_colorWithHex:0xF4F3FA];
    [self buildLayout];
    [self pushStateIntoCards];
}

#pragma mark - 布局

/// 组装：顶部返回按钮 + 标题 + 滚动卡片区 + 底部保存按钮。
- (void)buildLayout {
    UIButton *backButton = [self circleButtonWithSymbol:@"arrow.left"];
    [backButton addTarget:self action:@selector(handleBackTapped) forControlEvents:UIControlEventTouchUpInside];

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"饮食详情";
    titleLabel.font = FSTFontBold(22);
    titleLabel.textColor = [UIColor fst_textPrimary];
    titleLabel.textAlignment = NSTextAlignmentCenter;

    UIView *bottomBar = [UIView new];
    bottomBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.92];

    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    saveButton.backgroundColor = [UIColor fst_colorWithHex:0xF0D895];
    saveButton.layer.cornerRadius = 30;
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    saveButton.titleLabel.font = FSTFontBold(20);
    [saveButton addTarget:self action:@selector(handleMealSaveTapped) forControlEvents:UIControlEventTouchUpInside];

    UIScrollView *scrollView = [UIScrollView new];
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.alwaysBounceVertical = YES;
    scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

    UIView *contentView = [UIView new];

    self.timeCardView = [FSTMealTimeCardView new];
    self.slotCardView = [FSTMealSlotCardView new];
    self.dietCardView = [FSTMealDietCardView new];
    self.tasteCardView = [FSTMealTasteCardView new];
    self.detailCardView = [FSTMealDetailContentCardView new];
    __weak typeof(self) weakSelf = self;
    self.detailCardView.onImageTapped = ^{ [weakSelf handleImageTapped]; };

    FSTVerticalCardStackView *cardStack = [FSTVerticalCardStackView new];
    cardStack.cardSpacing   = 18;
    cardStack.contentInsets = UIEdgeInsetsMake(0, 24, 28, 24);
    cardStack.cards = @[self.timeCardView, self.slotCardView, self.dietCardView, self.tasteCardView, self.detailCardView];

    for (UIView *subview in @[backButton, titleLabel, bottomBar, scrollView]) [self.view addSubview:subview];
    [bottomBar addSubview:saveButton];
    [scrollView addSubview:contentView];
    [contentView addSubview:cardStack];

    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(18);
        make.left.equalTo(self.view).offset(22);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backButton);
        make.centerX.equalTo(self.view);
    }];
    [bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(@112);
    }];
    [saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bottomBar).inset(50);
        make.top.equalTo(bottomBar).offset(14);
        make.height.equalTo(@60);
    }];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backButton.mas_bottom).offset(54);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(bottomBar.mas_top);
    }];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.width.equalTo(scrollView);
    }];
    [cardStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentView);
    }];
}

- (UIButton *)circleButtonWithSymbol:(NSString *)systemSymbolName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.96];
    button.layer.cornerRadius = 24;
    [button setImage:[UIImage systemImageNamed:systemSymbolName] forState:UIControlStateNormal];
    button.tintColor = [UIColor fst_textPrimary];
    return button;
}

#pragma mark - 状态推送

- (void)pushStateIntoCards {
    self.timeCardView.date = self.record.date ?: [NSDate date];
    self.slotCardView.mealCategory = self.record.mealCategory ?: @"正餐";
    self.dietCardView.dietType = self.record.dietType ?: @"我不确定";
    self.tasteCardView.tasteLevel = self.record ? self.record.tasteLevel : 1;
    self.detailCardView.imagePath = self.imagePath;
    self.detailCardView.detailDescription = self.record.detailDescription ?: @"";

    __weak typeof(self) weakSelf = self;
    self.timeCardView.onDateChanged = ^(NSDate *date) { weakSelf.record.date = date; };
}

#pragma mark - 图片选择

- (void)handleImageTapped {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSString *filePath = [FSTMealImageService saveImage:image];
    if (filePath) {
        self.imagePath = filePath;
        self.detailCardView.imagePath = filePath;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 保存

- (void)handleBackTapped { [self.navigationController popViewControllerAnimated:YES]; }

- (void)handleMealSaveTapped {
    FSTMealRecord *record = self.record ?: [FSTMealRecord new];
    record.recordID = record.recordID.length ? record.recordID : [[NSUUID UUID] UUIDString];
    record.date = self.timeCardView.date;
    record.mealCategory = self.slotCardView.mealCategory;
    record.dietType = self.dietCardView.dietType;
    record.tasteLevel = self.tasteCardView.tasteLevel;
    record.detailDescription = self.detailCardView.detailDescription ?: @"";
    record.imagePath = self.imagePath ?: @"";
    [[FSTSessionManager sharedManager] addOrUpdateMealRecord:record];

    UINavigationController *currentNavigationController = self.navigationController;
    UITabBarController *tabBarController = currentNavigationController.tabBarController;
    if ([tabBarController isKindOfClass:[FSTRootTabBarController class]]) {
        if (tabBarController.selectedIndex == FSTTabIndexTimeline) {
            [currentNavigationController popViewControllerAnimated:YES];
        } else {
            [currentNavigationController popToRootViewControllerAnimated:NO];
            UINavigationController *timelineNavigationController = (UINavigationController *)tabBarController.viewControllers[FSTTabIndexTimeline];
            [timelineNavigationController popToRootViewControllerAnimated:NO];
            tabBarController.selectedIndex = FSTTabIndexTimeline;
        }
    } else {
        [currentNavigationController popViewControllerAnimated:YES];
    }
}

@end
