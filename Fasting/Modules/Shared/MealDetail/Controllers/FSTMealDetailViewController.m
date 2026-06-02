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
#import "FSTAppRouter.h"
#import "FSTRecordsRepository.h"
#import "FSTTheme.h"

/// 把 UIImage 压缩到 0.82 质量并写入 Documents/meal-images/{UUID}.jpg；返回完整路径或 nil。
/// 0.82 = 食物照片体积/画质的最优拐点（再高肉眼难分辨但文件大幅增长）。
static NSString *FSTMealDetailSaveImage(UIImage *image) {
    if (!image) return nil;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.82);
    if (!imageData) return nil;
    NSString *directory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/meal-images"];
    [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *filePath = [directory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [[NSUUID UUID] UUIDString]]];
    return [imageData writeToFile:filePath atomically:YES] ? filePath : nil;
}

@interface FSTMealDetailViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) FSTMealDetailRootView *rootView;
@property (nonatomic, strong) FSTMealTimeCardView *timeCardView;
@property (nonatomic, strong) FSTMealSlotCardView *slotCardView;
@property (nonatomic, strong) FSTMealDietCardView *dietCardView;
@property (nonatomic, strong) FSTMealTasteCardView *tasteCardView;
@property (nonatomic, strong) FSTMealDetailContentCardView *detailCardView;

@property (nonatomic, strong, readwrite) FSTMealRecord *mealRecord;
@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, assign, readwrite) BOOL returnsToTimelineTab;
@end

@implementation FSTMealDetailViewController

- (instancetype)initWithMealRecord:(FSTMealRecord *)record {
    return [self initWithMealRecord:record returnsToTimelineTab:NO];
}

- (instancetype)initWithMealRecord:(FSTMealRecord *)record returnsToTimelineTab:(BOOL)returnsToTimelineTab {
    if ((self = [super init])) {
        _mealRecord = [record copy] ?: [FSTMealRecord new];
        _imagePath = record.imagePath ?: @"";
        _returnsToTimelineTab = returnsToTimelineTab;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self installRootView];
    [self bindCallbacks];
    [self pushStateIntoCards];
}

- (void)installRootView {
    self.timeCardView   = [FSTMealTimeCardView new];
    self.slotCardView   = [FSTMealSlotCardView new];
    self.dietCardView   = [FSTMealDietCardView new];
    self.tasteCardView  = [FSTMealTasteCardView new];
    self.detailCardView = [FSTMealDetailContentCardView new];

    self.rootView = [FSTMealDetailRootView new];
    [self.view addSubview:self.rootView];
    [self.rootView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.rootView mountCards:@[self.timeCardView, self.slotCardView,
                                self.dietCardView, self.tasteCardView,
                                self.detailCardView]];
}

- (void)bindCallbacks {
    __weak typeof(self) weakSelf = self;
    self.rootView.onBackTapped = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    self.rootView.onSaveTapped = ^{
        [weakSelf handleMealSaveTapped];
    };
    self.detailCardView.onImageTapped = ^{
        [weakSelf handleImageTapped];
    };
}

#pragma mark - 状态推送

- (void)pushStateIntoCards {
    self.timeCardView.date          = self.mealRecord.date ?: [NSDate date];
    self.slotCardView.mealCategory  = self.mealRecord.mealCategory ?: @"Meal";
    self.dietCardView.dietType      = self.mealRecord.dietType ?: @"Not sure";
    self.tasteCardView.tasteLevel   = self.mealRecord.tasteLevel;
    self.detailCardView.imagePath   = self.imagePath;
    self.detailCardView.detailDescription = self.mealRecord.detailDescription ?: @"";
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
    NSString *filePath = FSTMealDetailSaveImage(image);
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

- (void)handleMealSaveTapped {
    FSTMealRecord *record = self.mealRecord ?: [FSTMealRecord new];
    record.recordID = record.recordID.length ? record.recordID : [[NSUUID UUID] UUIDString];
    record.date              = self.timeCardView.date;
    record.mealCategory      = self.slotCardView.mealCategory;
    record.dietType          = self.dietCardView.dietType;
    record.tasteLevel        = self.tasteCardView.tasteLevel;
    record.detailDescription = self.detailCardView.detailDescription ?: @"";
    record.imagePath         = self.imagePath ?: @"";

    FSTRecordsRepository *repository = [FSTRecordsRepository sharedRepository];

    // 默认：保存后只 pop 一层，留在当前 tab。涵盖 MealDiary 编辑、Timeline 自身新建/编辑两类入口。
    if (!self.returnsToTimelineTab) {
        [repository addOrUpdateMealRecord:record];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }

    // returnsToTimelineTab=YES：从 Plan tab 等非 Timeline tab 进入，保存后切到 Timeline 让新记录立刻可见。
    [FSTAppRouter finishFlowFrom:self updates:^{
        [repository addOrUpdateMealRecord:record];
    } fallback:^{
        [repository addOrUpdateMealRecord:record];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

@end
