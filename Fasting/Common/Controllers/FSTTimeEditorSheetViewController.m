//
//  FSTTimeEditorSheetViewController.m
//  Fasting
//

#import "FSTTimeEditorSheetViewController.h"
#import "FSTTimeEditorSheetContentView.h"
#import "FSTTheme.h"

static const CGFloat kFSTTimeEditorSheetCornerRadius = 22.0;

@interface FSTTimeEditorSheetViewController ()
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, strong) NSDate *initialDate;
@property (nonatomic, strong, nullable) NSDate *minimumDate;
@property (nonatomic, strong, nullable) NSDate *maximumDate;
@property (nonatomic, copy, nullable) NSString *alignChipText;
@property (nonatomic, strong, nullable) NSDate *alignedDate;
@property (nonatomic, assign) BOOL alignSelected;
@property (nonatomic, copy) FSTTimeEditorCommitHandler onCommit;

@property (nonatomic, strong) FSTTimeEditorSheetContentView *contentView;
@end

@implementation FSTTimeEditorSheetViewController

- (instancetype)initWithTitle:(NSString *)title
                  initialDate:(NSDate *)initialDate
                  minimumDate:(nullable NSDate *)minimumDate
                  maximumDate:(nullable NSDate *)maximumDate
                alignChipText:(nullable NSString *)alignChipText
                  alignedDate:(nullable NSDate *)alignedDate
              initiallyAligned:(BOOL)initiallyAligned
                      onCommit:(FSTTimeEditorCommitHandler)onCommit {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        _titleText = [title copy];
        _initialDate = initialDate ?: [NSDate date];
        _minimumDate = minimumDate;
        _maximumDate = maximumDate;
        _alignChipText = [alignChipText copy];
        _alignedDate = alignedDate;
        _alignSelected = initiallyAligned && alignChipText.length > 0 && alignedDate != nil;
        _onCommit = [onCommit copy];
        self.containerStyle = FSTBaseModalContainerStyleBottomSheet;
        self.backdropAlpha = 0.42;
        self.containerCornerRadius = kFSTTimeEditorSheetCornerRadius;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self buildContentView];
    [self refreshAlignState];
}

#pragma mark - Content View

- (void)buildContentView {
    self.contentView = [[FSTTimeEditorSheetContentView alloc] initWithTitle:self.titleText
                                                             alignChipText:self.alignChipText];
    [self.cardContainer addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.cardContainer);
    }];

    self.contentView.datePicker.date = [self clampedDate:self.alignSelected && self.alignedDate ? self.alignedDate : self.initialDate];
    self.contentView.datePicker.minimumDate = self.minimumDate;
    self.contentView.datePicker.maximumDate = self.maximumDate;

    __weak typeof(self) weakSelf = self;
    self.contentView.onCloseTapped = ^{ [weakSelf handleCloseTapped]; };
    self.contentView.onSaveTapped  = ^{ [weakSelf handleSaveTapped]; };
    self.contentView.onAlignToggled = ^{ [weakSelf handleAlignTapped]; };
}

#pragma mark - State

- (NSDate *)clampedDate:(NSDate *)date {
    NSDate *result = date ?: [NSDate date];
    if (self.minimumDate && [result compare:self.minimumDate] == NSOrderedAscending) result = self.minimumDate;
    if (self.maximumDate && [result compare:self.maximumDate] == NSOrderedDescending) result = self.maximumDate;
    return result;
}

- (void)refreshAlignState {
    [self.contentView setAlignSelected:self.alignSelected];
    self.contentView.datePicker.userInteractionEnabled = !self.alignSelected;
    if (self.alignSelected && self.alignedDate) {
        [self.contentView.datePicker setDate:[self clampedDate:self.alignedDate] animated:YES];
    }
}

#pragma mark - Events

- (void)handleAlignTapped {
    self.alignSelected = !self.alignSelected;
    [self refreshAlignState];
}

- (void)handleCloseTapped {
    [self dismissSelfAnimated:YES completion:nil];
}

- (void)handleSaveTapped {
    NSDate *pickedDate = self.alignSelected && self.alignedDate ? [self clampedDate:self.alignedDate] : self.contentView.datePicker.date;
    if (self.onCommit) self.onCommit(pickedDate, self.alignSelected);
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
