//
//  FSTSendFeedbackRootView.m
//  Fasting
//

#import "FSTSendFeedbackRootView.h"
#import "FSTTheme.h"
#import "UIColor+FST.h"

static NSString * const kFSTFeedbackPlaceholder = @"Anything you share helps us make fasting better for you.";

static const CGFloat kFSTFeedbackSideInset     = 24;
static const CGFloat kFSTFeedbackChipHeight    = 44;
static const CGFloat kFSTFeedbackChipSpacingH  = 12;
static const CGFloat kFSTFeedbackChipSpacingV  = 12;
static const CGFloat kFSTFeedbackChipRadius    = 22;
static const CGFloat kFSTFeedbackTextViewHeight = 140;
static const CGFloat kFSTFeedbackSubmitHeight  = 56;
static const CGFloat kFSTFeedbackSubmitRadius  = 28;

@interface FSTSendFeedbackRootView ()
@property (nonatomic, strong, readwrite) UITextView *textView;
@property (nonatomic, strong, readwrite) UILabel *placeholderLabel;
@property (nonatomic, strong, readwrite) UIImageView *pickedImageView;
@property (nonatomic, copy, readwrite) NSArray<NSString *> *chipTitles;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *chipContainer;
@property (nonatomic, strong) NSMutableArray<UIView *> *chipViews;
@property (nonatomic, strong) UIButton *addPictureButton;
@property (nonatomic, strong) UIButton *submitButton;
@end

@implementation FSTSendFeedbackRootView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];
        _selectedChipIndex = -1;
        _chipTitles = @[@"Fasting guide", @"App tutorial", @"Feeling unwell",
                        @"Daily plan", @"Weekly plan", @"Others"];
        _chipViews = [NSMutableArray array];
        [self buildBackButton];
        [self buildScrollAndContent];
        [self buildChipsInContainer:self.chipContainer];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - Build

- (void)buildBackButton {
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [[UIImage imageNamed:@"feedback_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.backButton setImage:backImage forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(handleBackTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backButton];
}

- (void)buildScrollAndContent {
    // Scroll view
    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    // Envelope emoji
    UILabel *envelopeLabel = [UILabel new];
    envelopeLabel.text = @"\U0001F4E9";
    envelopeLabel.font = FSTFontRegular(60);
    envelopeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:envelopeLabel];
    envelopeLabel.tag = 1001;

    // Title
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"How can we help you?";
    titleLabel.font = FSTFontTitle();
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:titleLabel];
    titleLabel.tag = 1002;

    // Chip container
    self.chipContainer = [UIView new];
    [self.contentView addSubview:self.chipContainer];

    // "Tell us more" label
    UILabel *moreLabel = [UILabel new];
    moreLabel.text = @"Tell us more (optional)";
    moreLabel.font = FSTFontBold(18);
    moreLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:moreLabel];
    moreLabel.tag = 1003;

    // Text view container
    UIView *textViewContainer = [UIView new];
    textViewContainer.backgroundColor = [UIColor fst_inputBackground];
    textViewContainer.layer.cornerRadius = 16;
    textViewContainer.layer.masksToBounds = YES;
    [self.contentView addSubview:textViewContainer];
    textViewContainer.tag = 1004;

    self.textView = [UITextView new];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = FSTFontRegular(16);
    self.textView.textColor = [UIColor blackColor];
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
    self.addPictureButton.layer.cornerRadius = FSTRadiusS;
    self.addPictureButton.layer.masksToBounds = YES;
    UIImage *addPicImage = [[UIImage imageNamed:@"feedback_add_picture"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.addPictureButton setImage:addPicImage forState:UIControlStateNormal];
    [self.addPictureButton addTarget:self action:@selector(handleAddPictureTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.addPictureButton];

    // Picked image preview
    self.pickedImageView = [UIImageView new];
    self.pickedImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.pickedImageView.layer.cornerRadius = FSTRadiusS;
    self.pickedImageView.layer.masksToBounds = YES;
    self.pickedImageView.hidden = YES;
    [self.contentView addSubview:self.pickedImageView];

    // Submit button
    self.submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.submitButton.backgroundColor = [UIColor fst_eatingTimeGreen];
    self.submitButton.layer.cornerRadius = kFSTFeedbackSubmitRadius;
    [self.submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.submitButton.titleLabel.font = FSTFontBold(18);
    [self.submitButton addTarget:self action:@selector(handleSubmitTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.submitButton];
}

#pragma mark - Chips

- (void)buildChipsInContainer:(UIView *)container {
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
    if (self.selectedChipIndex == tappedIndex) {
        self.selectedChipIndex = -1;
    } else {
        self.selectedChipIndex = tappedIndex;
    }
    [self refreshChipStates];
}

- (void)refreshChipStates {
    for (NSInteger i = 0; i < self.chipViews.count; i++) {
        UIView *chip = self.chipViews[i];
        UILabel *label = [chip viewWithTag:100];
        BOOL selected = (i == self.selectedChipIndex);
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

#pragma mark - Constraints

- (void)setupConstraints {
    UILabel *envelopeLabel = [self.contentView viewWithTag:1001];
    UILabel *titleLabel    = [self.contentView viewWithTag:1002];
    UILabel *moreLabel     = [self.contentView viewWithTag:1003];
    UIView  *textViewContainer = [self.contentView viewWithTag:1004];

    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(8);
        make.left.equalTo(self).offset(16);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backButton.mas_bottom).offset(8);
        make.left.right.bottom.equalTo(self);
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
    [self.chipContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(24);
        make.left.right.equalTo(self.contentView).inset(kFSTFeedbackSideInset);
    }];
    [moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.chipContainer.mas_bottom).offset(32);
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
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addPictureButton.mas_bottom).offset(32);
        make.left.right.equalTo(self.contentView).inset(kFSTFeedbackSideInset);
        make.height.mas_equalTo(kFSTFeedbackSubmitHeight);
        make.bottom.equalTo(self.contentView).offset(-40);
    }];
}

#pragma mark - Events

- (void)handleBackTapped {
    if (self.onBackTapped) self.onBackTapped();
}

- (void)handleSubmitTapped {
    if (self.onSubmitTapped) self.onSubmitTapped();
}

- (void)handleAddPictureTapped {
    if (self.onAddPictureTapped) self.onAddPictureTapped();
}

@end
