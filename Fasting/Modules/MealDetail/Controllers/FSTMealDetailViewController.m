//
//  FSTMealDetailViewController.m
//  Fasting
//
//  餐食详情页：5 张卡片（时间/正餐or零食/饮食类型/味道/详情）+ 底部保存按钮。
//  状态分布在子卡片里，保存时统一向 FSTRecordsRepository 写入 FSTMealRecord。
//

#import "FSTMealDetailViewController.h"
#import "FSTMealDetailRootView.h"
#import "FSTMealTimeCardView.h"
#import "FSTMealSlotCardView.h"
#import "FSTMealDietCardView.h"
#import "FSTMealTasteCardView.h"
#import "FSTMealDetailContentCardView.h"
#import "FSTRootTabBarController.h"
#import "FSTRecordsRepository.h"
#import "FSTMealImageService.h"

@interface FSTMealDetailViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) FSTMealRecord *record;
@property (nonatomic, copy) NSString *imagePath;
@end

@implementation FSTMealDetailViewController

- (instancetype)initWithMealRecord:(FSTMealRecord *)record {
    if ((self = [super init])) {
        _record = [record copy] ?: [FSTMealRecord new];
        _imagePath = record.imagePath ?: @"";
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)loadView {
    self.view = [FSTMealDetailRootView new];
}

- (FSTMealDetailRootView *)rootView {
    return (FSTMealDetailRootView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;
    self.rootView.onBackTapped = ^{ [weakSelf.navigationController popViewControllerAnimated:YES]; };
    self.rootView.onSaveTapped = ^{ [weakSelf handleMealSaveTapped]; };
    self.rootView.detailCardView.onImageTapped = ^{ [weakSelf handleImageTapped]; };

    [self pushStateIntoCards];
}

#pragma mark - 状态推送

- (void)pushStateIntoCards {
    FSTMealDetailRootView *root = self.rootView;
    root.timeCardView.date = self.record.date ?: [NSDate date];
    root.slotCardView.mealCategory = self.record.mealCategory ?: @"Meal";
    root.dietCardView.dietType = self.record.dietType ?: @"Not sure";
    root.tasteCardView.tasteLevel = self.record.tasteLevel;
    root.detailCardView.imagePath = self.imagePath;
    root.detailCardView.detailDescription = self.record.detailDescription ?: @"";
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
        self.rootView.detailCardView.imagePath = filePath;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 保存

- (void)handleMealSaveTapped {
    FSTMealDetailRootView *root = self.rootView;
    FSTMealRecord *record = self.record ?: [FSTMealRecord new];
    record.recordID = record.recordID.length ? record.recordID : [[NSUUID UUID] UUIDString];
    record.date = root.timeCardView.date;
    record.mealCategory = root.slotCardView.mealCategory;
    record.dietType = root.dietCardView.dietType;
    record.tasteLevel = root.tasteCardView.tasteLevel;
    record.detailDescription = root.detailCardView.detailDescription ?: @"";
    record.imagePath = self.imagePath ?: @"";
    UINavigationController *currentNavigationController = self.navigationController;
    FSTRootTabBarController *tabBarController = (FSTRootTabBarController *)currentNavigationController.tabBarController;
    if (![tabBarController isKindOfClass:[FSTRootTabBarController class]]) {
        [[FSTRecordsRepository sharedRepository] addOrUpdateMealRecord:record];
        [currentNavigationController popViewControllerAnimated:YES];
        return;
    }

    if (tabBarController.selectedIndex == FSTTabIndexTimeline) {
        [[FSTRecordsRepository sharedRepository] addOrUpdateMealRecord:record];
        [currentNavigationController popViewControllerAnimated:YES];
        return;
    }

    [tabBarController fst_finishFlowReturningToTimelineWithUpdates:^{
        [[FSTRecordsRepository sharedRepository] addOrUpdateMealRecord:record];
        UINavigationController *timelineNav = (UINavigationController *)tabBarController.viewControllers[FSTTabIndexTimeline];
        [timelineNav popToRootViewControllerAnimated:NO];
    }];
}

@end
