//
//  FSTWeightInputViewController.m
//  Fasting
//
//  体重输入弹窗的容器控制器：包装一个 FSTWeightInputCardView，
//  负责半透明遮罩、点击空白处关闭、把保存事件转给外部 onSave 回调。
//

#import "FSTWeightInputViewController.h"
#import "FSTWeightInputCardView.h"
#import "FSTSessionManager.h"
#import "FSTTheme.h"

@interface FSTWeightInputViewController ()
@property (nonatomic, strong) FSTWeightInputCardView *inputCardView;
@end

@implementation FSTWeightInputViewController

- (instancetype)init {
    if ((self = [super init])) {
        _weightKg = 70.0;
        self.backdropAlpha = 0.45;
        self.containerCornerRadius = 22;
        self.containerVerticalOffset = -40;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.inputCardView = [FSTWeightInputCardView new];
    self.inputCardView.initialUnit = [FSTSessionManager sharedManager].preferredWeightUnit;
    self.inputCardView.weightKg = self.weightKg;
    __weak typeof(self) weakSelf = self;
    self.inputCardView.onClose = ^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    };
    self.inputCardView.onSave = ^(CGFloat enteredWeightKg) {
        [FSTSessionManager sharedManager].preferredWeightUnit = weakSelf.inputCardView.currentUnit;
        void (^saveCallback)(CGFloat) = weakSelf.onSave;
        [weakSelf dismissViewControllerAnimated:YES completion:^{
            if (saveCallback) saveCallback(enteredWeightKg);
        }];
    };
    [self.cardContainer addSubview:self.inputCardView];
    [self.inputCardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.cardContainer);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.inputCardView beginEditing];
}

@end
