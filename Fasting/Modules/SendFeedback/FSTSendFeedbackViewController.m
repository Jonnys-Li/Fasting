//
//  FSTSendFeedbackViewController.m
//  Fasting
//
//  Send Feedback 页面：选择反馈类别 + 可选文字描述 + 可选图片 + 提交。
//

#import "FSTSendFeedbackViewController.h"
#import "FSTTheme.h"
#import <PhotosUI/PhotosUI.h>

static NSString * const kFSTFeedbackPlaceholder = @"Anything you share helps us make fasting better for you.";

static const CGFloat kFSTFeedbackSideInset     = 24;
static const CGFloat kFSTFeedbackChipHeight    = 44;
static const CGFloat kFSTFeedbackChipSpacingH  = 12;
static const CGFloat kFSTFeedbackChipSpacingV  = 12;
static const CGFloat kFSTFeedbackChipRadius    = 22;
static const CGFloat kFSTFeedbackTextViewHeight = 140;
static const CGFloat kFSTFeedbackSubmitHeight  = 56;
static const CGFloat kFSTFeedbackSubmitRadius  = 28;

@interface FSTSendFeedbackViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSArray<NSString *> *chipTitles;
@property (nonatomic, strong) NSMutableArray<UIView *> *chipViews;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UIButton *addPictureButton;
@property (nonatomic, strong) UIImageView *pickedImageView;
@property (nonatomic, strong) UIImage *pickedImage;
@end

@implementation FSTSendFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.selectedIndex = -1;
    self.chipTitles = @[@"Fasting guide", @"App tutorial", @"Feeling unwell", @"Daily plan", @"Weekly plan", @"Others"];
    self.chipViews = [NSMutableArray array];
    [self buildUI];
}

#pragma mark - UI

- (void)buildUI {
    // Back button
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [[UIImage imageNamed:@"feedback_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(handleBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    // Scroll view
    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    // Envelope emoji
    UILabel *envelopeLabel = [UILabel new];
    envelopeLabel.text = @"\U0001F4E9";
    envelopeLabel.font = [UIFont systemFontOfSize:60];
    envelopeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:envelopeLabel];

    // Title
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"How can we help you?";
    titleLabel.font = FSTFontBold(22);
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:titleLabel];

    // Chip container
    UIView *chipContainer = [UIView new];
    [self.contentView addSubview:chipContainer];
    [self buildChipsInContainer:chipContainer];

    // "Tell us more" label
    UILabel *moreLabel = [UILabel new];
    moreLabel.text = @"Tell us more (optional)";
    moreLabel.font = FSTFontBold(18);
    moreLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:moreLabel];

    // Text view
    UIView *textViewContainer = [UIView new];
    textViewContainer.backgroundColor = [UIColor fst_inputBackground];
    textViewContainer.layer.cornerRadius = 16;
    textViewContainer.layer.masksToBounds = YES;
    [self.contentView addSubview:textViewContainer];

    self.textView = [UITextView new];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = FSTFontRegular(16);
    self.textView.textColor = [UIColor blackColor];
    self.textView.delegate = self;
    self.textView.textContainerInset = UIEdgeInsetsMake(16, 12, 16, 12);
    [textViewContainer addSubview:self.textView];

    self.placeholderLabel = [UILabel new];
    self.placeholderLabel.text = kFSTFeedbackPlaceholder;
    self.placeholderLabel.font = FSTFontRegular(16);
    self.placeholderLabel.textColor = [UIColor fst_textSecondary];
    self.placeholderLabel.numberOfLines = 0;
    [textViewContainer addSubview:self.placeholderLabel];

    // Add picture button
    self.addPictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addPictureButton.backgroundColor = [UIColor fst_chipBackground];
    self.addPictureButton.layer.cornerRadius = 12;
    self.addPictureButton.layer.masksToBounds = YES;
    UIImage *addPicImage = [[UIImage imageNamed:@"feedback_add_picture"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.addPictureButton setImage:addPicImage forState:UIControlStateNormal];
    [self.addPictureButton addTarget:self action:@selector(handleAddPicture) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.addPictureButton];

    // Picked image preview
    self.pickedImageView = [UIImageView new];
    self.pickedImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.pickedImageView.layer.cornerRadius = 12;
    self.pickedImageView.layer.masksToBounds = YES;
    self.pickedImageView.hidden = YES;
    [self.contentView addSubview:self.pickedImageView];

    // Submit button
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.backgroundColor = [UIColor fst_eatingTimeGreen];
    submitButton.layer.cornerRadius = kFSTFeedbackSubmitRadius;
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    submitButton.titleLabel.font = FSTFontBold(18);
    [submitButton addTarget:self action:@selector(handleSubmit) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:submitButton];

    // Constraints
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(8);
        make.left.equalTo(self.view).offset(16);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(backButton.mas_bottom).offset(8);
        make.left.right.bottom.equalTo(self.view);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    [envelopeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.centerX.equalTo(self.contentView);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(envelopeLabel.mas_bottom).offset(16);
        make.left.right.equalTo(self.contentView).inset(kFSTFeedbackSideInset);
    }];
    [chipContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(24);
        make.left.right.equalTo(self.contentView).inset(kFSTFeedbackSideInset);
    }];
    [moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(chipContainer.mas_bottom).offset(32);
        make.left.right.equalTo(self.contentView).inset(kFSTFeedbackSideInset);
    }];
    [textViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(moreLabel.mas_bottom).offset(14);
        make.left.right.equalTo(self.contentView).inset(kFSTFeedbackSideInset);
        make.height.mas_equalTo(kFSTFeedbackTextViewHeight);
    }];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(textViewContainer);
    }];
    [self.placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textViewContainer).offset(16);
        make.left.equalTo(textViewContainer).offset(17);
        make.right.equalTo(textViewContainer).offset(-17);
    }];
    [self.addPictureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textViewContainer.mas_bottom).offset(16);
        make.left.equalTo(self.contentView).offset(kFSTFeedbackSideInset);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    [self.pickedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addPictureButton.mas_right).offset(12);
        make.centerY.equalTo(self.addPictureButton);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addPictureButton.mas_bottom).offset(32);
        make.left.right.equalTo(self.contentView).inset(kFSTFeedbackSideInset);
        make.height.mas_equalTo(kFSTFeedbackSubmitHeight);
        make.bottom.equalTo(self.contentView).offset(-40);
    }];
}

#pragma mark - Chips

- (void)buildChipsInContainer:(UIView *)container {
    // Row 1: Fasting guide, App tutorial
    // Row 2: Feeling unwell, Daily plan
    // Row 3: Weekly plan, Others
    UIView *previousRow = nil;
    for (NSInteger row = 0; row < 3; row++) {
        UIView *rowView = [UIView new];
        [container addSubview:rowView];

        NSInteger leftIdx = row * 2;
        NSInteger rightIdx = leftIdx + 1;

        UIView *leftChip = [self buildChipWithTitle:self.chipTitles[leftIdx] index:leftIdx];
        UIView *rightChip = [self buildChipWithTitle:self.chipTitles[rightIdx] index:rightIdx];
        [rowView addSubview:leftChip];
        [rowView addSubview:rightChip];

        [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (previousRow) {
                make.top.equalTo(previousRow.mas_bottom).offset(kFSTFeedbackChipSpacingV);
            } else {
                make.top.equalTo(container);
            }
            make.left.right.equalTo(container);
            make.height.mas_equalTo(kFSTFeedbackChipHeight);
            if (row == 2) {
                make.bottom.equalTo(container);
            }
        }];

        [leftChip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(rowView);
            make.right.equalTo(rowView.mas_centerX).offset(-kFSTFeedbackChipSpacingH / 2.0);
        }];
        [rightChip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(rowView.mas_centerX).offset(kFSTFeedbackChipSpacingH / 2.0);
            make.right.top.bottom.equalTo(rowView);
        }];

        previousRow = rowView;
    }
}

- (UIView *)buildChipWithTitle:(NSString *)title index:(NSInteger)index {
    UIControl *chip = [UIControl new];
    chip.backgroundColor = [UIColor fst_chipBackground];
    chip.layer.cornerRadius = kFSTFeedbackChipRadius;
    chip.layer.borderWidth = 1.5;
    chip.layer.borderColor = [UIColor clearColor].CGColor;
    chip.tag = index;
    [chip addTarget:self action:@selector(handleChipTapped:) forControlEvents:UIControlEventTouchUpInside];

    UILabel *label = [UILabel new];
    label.text = title;
    label.font = FSTFontMedium(15);
    label.textColor = [UIColor fst_textHeading];
    label.textAlignment = NSTextAlignmentCenter;
    label.tag = 100;
    label.userInteractionEnabled = NO;
    [chip addSubview:label];

    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(chip);
        make.left.greaterThanOrEqualTo(chip).offset(12);
        make.right.lessThanOrEqualTo(chip).offset(-12);
    }];

    [self.chipViews addObject:chip];
    return chip;
}

- (void)handleChipTapped:(UIControl *)sender {
    NSInteger tappedIndex = sender.tag;
    if (self.selectedIndex == tappedIndex) {
        self.selectedIndex = -1;
    } else {
        self.selectedIndex = tappedIndex;
    }
    [self refreshChipStates];
}

- (void)refreshChipStates {
    for (NSInteger i = 0; i < self.chipViews.count; i++) {
        UIView *chip = self.chipViews[i];
        UILabel *label = [chip viewWithTag:100];
        BOOL selected = (i == self.selectedIndex);
        if (selected) {
            chip.backgroundColor = [UIColor whiteColor];
            chip.layer.borderColor = [UIColor fst_eatingTimeGreen].CGColor;
            label.textColor = [UIColor fst_eatingTimeGreen];
        } else {
            chip.backgroundColor = [UIColor fst_chipBackground];
            chip.layer.borderColor = [UIColor clearColor].CGColor;
            label.textColor = [UIColor fst_textHeading];
        }
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    self.placeholderLabel.hidden = textView.text.length > 0;
}

#pragma mark - Events

- (void)handleBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleAddPicture {
    UIImagePickerController *picker = [UIImagePickerController new];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)handleSubmit {
    NSLog(@"Feedback submitted: category=%@, text=%@, hasImage=%d",
          self.selectedIndex >= 0 ? self.chipTitles[self.selectedIndex] : @"(none)",
          self.textView.text,
          self.pickedImage != nil);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    if (image) {
        self.pickedImage = image;
        self.pickedImageView.image = image;
        self.pickedImageView.hidden = NO;
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
