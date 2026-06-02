//
//  FSTTimeEditorSheetViewController.m
//  Fasting
//

#import "FSTTimeEditorSheetViewController.h"
#import "FSTTimeEditorSheetContentView.h"
#import "FSTTheme.h"

static const CGFloat kCornerRadius = 22.0;

@interface FSTTimeEditorSheetViewController ()
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, strong) NSDate *initialDate;
@property (nonatomic, strong, nullable) NSDate *minimumDate;
@property (nonatomic, strong, nullable) NSDate *maximumDate;
@property (nonatomic, copy, nullable) NSString *alignChipText;
@property (nonatomic, assign) NSTimeInterval alignDurationSeconds;
@property (nonatomic, assign) FSTTimeEditorAlignMode alignMode;
@property (nonatomic, strong, nullable) NSDate *alignReferenceDate;
@property (nonatomic, copy) FSTTimeEditorCommitHandler onCommit;

// 内部状态机（同 demo1）：
//   alignApplied — chip 刚被点过、picker 已被对齐；保存时此标志同步传给上游。
//   pickerWasChanged — 用户至少滚动过 picker 一次（EndFast 模式用来决定 chip 何时启用）。
@property (nonatomic, assign) BOOL alignApplied;
@property (nonatomic, assign) BOOL pickerWasChanged;

@property (nonatomic, strong) FSTTimeEditorSheetContentView *contentView;
@end

@implementation FSTTimeEditorSheetViewController

- (instancetype)initWithTitle:(NSString *)title
                  initialDate:(NSDate *)initialDate
                  minimumDate:(nullable NSDate *)minimumDate
                  maximumDate:(nullable NSDate *)maximumDate
                alignChipText:(nullable NSString *)alignChipText
         alignDurationSeconds:(NSTimeInterval)alignDurationSeconds
                    alignMode:(FSTTimeEditorAlignMode)alignMode
           alignReferenceDate:(nullable NSDate *)alignReferenceDate
                     onCommit:(FSTTimeEditorCommitHandler)onCommit {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _titleText = [title copy];
        _initialDate = initialDate ?: [NSDate date];
        _minimumDate = minimumDate;
        _maximumDate = maximumDate;
        _alignChipText = [alignChipText copy];
        _alignDurationSeconds = MAX(alignDurationSeconds, 60.0);  // 至少 1 分钟，防退化
        _alignMode = alignMode;
        _alignReferenceDate = alignReferenceDate;
        _onCommit = [onCommit copy];
        _alignApplied = NO;
        _pickerWasChanged = NO;
        self.containerStyle = FSTBaseModalContainerStyleBottomSheet;
        self.backdropAlpha = 0.42;
        self.containerCornerRadius = kCornerRadius;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildContentView];
    [self refreshAlignControlAppearance];
}

#pragma mark - Content View

- (void)buildContentView {
    self.contentView = [FSTTimeEditorSheetContentView new];
    self.contentView.titleText     = self.titleText;
    self.contentView.alignChipText = self.alignChipText;
    [self.cardContainer addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.cardContainer);
    }];

    self.contentView.datePicker.date = [self clampedDate:self.initialDate];
    self.contentView.datePicker.minimumDate = self.minimumDate;
    self.contentView.datePicker.maximumDate = self.maximumDate;

    __weak typeof(self) weakSelf = self;
    self.contentView.onCloseTapped = ^{
        [weakSelf handleCloseTapped];
    };
    self.contentView.onSaveTapped = ^{
        [weakSelf handleSaveTapped];
    };
    self.contentView.onAlignToggled = ^{
        [weakSelf handleAlignTapped];
    };
    self.contentView.onPickerValueChanged = ^{
        [weakSelf handlePickerValueChanged];
    };
}

#pragma mark - State

- (NSDate *)clampedDate:(NSDate *)date {
    NSDate *result = date ?: [NSDate date];
    if (self.minimumDate && [result compare:self.minimumDate] == NSOrderedAscending) result = self.minimumDate;
    if (self.maximumDate && [result compare:self.maximumDate] == NSOrderedDescending) result = self.maximumDate;
    return result;
}

/// chip 是否启用 — 按 mode 分流：
///   StartFast / ReferencePlusDuration：默认可点；点过一次（alignApplied=YES）后变灰，直到用户改 picker。
///   EndFast：默认变灰；用户改 picker 后才启用；点过一次后又变灰，直到再次改 picker。
- (BOOL)isAlignControlEnabled {
    if (self.alignMode == FSTTimeEditorAlignModeStartFast ||
        self.alignMode == FSTTimeEditorAlignModeReferencePlusDuration) {
        return !self.alignApplied;
    }
    return self.pickerWasChanged && !self.alignApplied;
}

/// 计算 chip 点击后 picker 应该跳到的目标时间。
///   StartFast：now - alignDurationSeconds（现在正好是完成点）。
///   EndFast / ReferencePlusDuration：alignReferenceDate（或 initialDate 兜底）+ alignDurationSeconds。
- (NSDate *)alignTargetDate {
    if (self.alignMode == FSTTimeEditorAlignModeStartFast) {
        return [[NSDate date] dateByAddingTimeInterval:-self.alignDurationSeconds];
    }
    NSDate *reference = self.alignReferenceDate ?: self.initialDate;
    return [reference dateByAddingTimeInterval:self.alignDurationSeconds];
}

- (void)refreshAlignControlAppearance {
    if (!self.contentView.alignControl) return;
    [self.contentView setAlignEnabled:[self isAlignControlEnabled]];
}

#pragma mark - Events

- (void)handleAlignTapped {
    if (![self isAlignControlEnabled] || self.alignChipText.length == 0) return;
    NSDate *target = [self alignTargetDate];
    [self.contentView.datePicker setDate:[self clampedDate:target] animated:YES];
    self.alignApplied = YES;
    [self refreshAlignControlAppearance];
}

- (void)handlePickerValueChanged {
    self.pickerWasChanged = YES;
    self.alignApplied = NO;     // 用户手动改了 picker，对齐失效
    [self refreshAlignControlAppearance];
}

- (void)handleCloseTapped {
    [self dismissSelfAnimated:YES completion:nil];
}

- (void)handleSaveTapped {
    if (self.onCommit) self.onCommit(self.contentView.datePicker.date, self.alignApplied);
    [self dismissSelfAnimated:YES completion:nil];
}

- (void)dismissSelfAnimated:(BOOL)animated completion:(void (^)(void))completion {
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:animated completion:completion];
        return;
    }

    if (self.parentViewController) {
        [self willMoveToParentViewController:nil];
        void (^removeFromParent)(void) = ^{
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            if (completion) completion();
        };
        if (animated) {
            [UIView animateWithDuration:0.18 animations:^{
                self.view.alpha = 0.0;
            } completion:^(__unused BOOL finished) {
                removeFromParent();
            }];
        } else {
            removeFromParent();
        }
        return;
    }

    if (completion) completion();
}

@end
