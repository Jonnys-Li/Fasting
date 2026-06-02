//
//  FSTSendFeedbackRootView.m
//  Fasting
//

#import "FSTSendFeedbackRootView.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

// 通用
static const CGFloat kSideInset = 24;

// Chips
static const CGFloat kChipHeight     = 44;
static const CGFloat kChipSpacingH   = 12;
static const CGFloat kChipSpacingV   = 12;
static const CGFloat kChipRadius     = 22;

// TextView
static const CGFloat kTextViewHeight = 140;

// Submit
static const CGFloat kSubmitHeight = 56;
static const CGFloat kSubmitRadius = 28;

@interface FSTSendFeedbackRootView ()
@property (nonatomic, strong, readwrite) UIImageView *pickedImageView;
@property (nonatomic, copy, readwrite) NSArray<NSString *> *chipTitles;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *chipContainer;
@property (nonatomic, strong) NSMutableArray<UIView *> *chipViews;
@property (nonatomic, strong) UIButton *addPictureButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UILabel *envelopeLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *moreLabel;
@property (nonatomic, strong) UIView *textViewContainer;
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
    [self.backButton setImage:[UIImage fst_originalImageNamed:@"feedback_back"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(handleBackTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backButton];
}

- (void)buildScrollAndContent {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self addSubview:self.scrollView];

    self.contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];

    self.envelopeLabel = [UILabel fst_labelWithText:@"\U0001F4E9" font:FSTFontRegular(60) color:[UIColor blackColor] alignment:NSTextAlignmentCenter];
    self.titleLabel    = [UILabel fst_labelWithText:@"How can we help you?" font:FSTFontTitle() color:[UIColor blackColor] alignment:NSTextAlignmentCenter];
    self.chipContainer = [[UIView alloc] init];
    self.moreLabel     = [UILabel fst_labelWithText:@"Tell us more (optional)" font:FSTFontBold(18) color:[UIColor blackColor]];

    self.textViewContainer = [UIView fst_containerWithBackground:[UIColor fst_inputBackground] radius:16];
    self.textViewContainer.layer.masksToBounds = YES;

    self.addPictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addPictureButton.backgroundColor = [UIColor fst_chipBackground];
    self.addPictureButton.layer.cornerRadius = FSTRadiusS;
    self.addPictureButton.layer.masksToBounds = YES;
    [self.addPictureButton setImage:[UIImage fst_originalImageNamed:@"feedback_add_picture"] forState:UIControlStateNormal];
    [self.addPictureButton addTarget:self action:@selector(handleAddPictureTapped) forControlEvents:UIControlEventTouchUpInside];

    self.pickedImageView = [[UIImageView alloc] init];
    self.pickedImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.pickedImageView.layer.cornerRadius = FSTRadiusS;
    self.pickedImageView.layer.masksToBounds = YES;
    self.pickedImageView.hidden = YES;

    self.submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.submitButton.backgroundColor = [UIColor fst_eatingTimeGreen];
    self.submitButton.layer.cornerRadius = kSubmitRadius;
    [self.submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.submitButton.titleLabel.font = FSTFontBold(18);
    [self.submitButton addTarget:self action:@selector(handleSubmitTapped) forControlEvents:UIControlEventTouchUpInside];

    [self.contentView fst_addSubviews:@[self.envelopeLabel, self.titleLabel, self.chipContainer,
                                        self.moreLabel, self.textViewContainer,
                                        self.addPictureButton, self.pickedImageView, self.submitButton]];
}

#pragma mark - Chips

- (void)buildChipsInContainer:(UIView *)container {
    UIView *previousRow = nil;
    for (NSInteger row = 0; row < 3; row++) {
        UIView *rowView = [[UIView alloc] init];
        [container addSubview:rowView];

        NSInteger leftIdx = row * 2;
        UIView *leftChip  = [self buildChipWithTitle:self.chipTitles[leftIdx]     index:leftIdx];
        UIView *rightChip = [self buildChipWithTitle:self.chipTitles[leftIdx + 1] index:leftIdx + 1];
        [rowView fst_addSubviews:@[leftChip, rightChip]];

        [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (previousRow) make.top.equalTo(previousRow.mas_bottom).offset(kChipSpacingV);
            else             make.top.equalTo(container);
            make.left.right.equalTo(container);
            make.height.mas_equalTo(kChipHeight);
            if (row == 2) make.bottom.equalTo(container);
        }];
        [leftChip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(rowView);
            make.right.equalTo(rowView.mas_centerX).offset(-kChipSpacingH / 2.0);
        }];
        [rightChip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(rowView.mas_centerX).offset(kChipSpacingH / 2.0);
            make.right.top.bottom.equalTo(rowView);
        }];
        previousRow = rowView;
    }
}

- (UIView *)buildChipWithTitle:(NSString *)title index:(NSInteger)index {
    UIControl *chip = [[UIControl alloc] init];
    chip.backgroundColor = [UIColor fst_chipBackground];
    chip.layer.cornerRadius = kChipRadius;
    chip.layer.borderWidth = 1.5;
    chip.layer.borderColor = [UIColor clearColor].CGColor;
    chip.tag = index;
    [chip addTarget:self action:@selector(handleChipTapped:) forControlEvents:UIControlEventTouchUpInside];

    UILabel *label = [UILabel fst_labelWithText:title font:FSTFontMedium(15) color:[UIColor fst_textHeading] alignment:NSTextAlignmentCenter];
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
    self.selectedChipIndex = (self.selectedChipIndex == tappedIndex) ? -1 : tappedIndex;
    [self refreshChipStates];
}

- (void)refreshChipStates {
    for (NSInteger i = 0; i < self.chipViews.count; i++) {
        UIView *chip = self.chipViews[i];
        UILabel *label = [chip viewWithTag:100];
        BOOL selected = (i == self.selectedChipIndex);
        chip.backgroundColor   = selected ? [UIColor whiteColor]            : [UIColor fst_chipBackground];
        chip.layer.borderColor = selected ? [UIColor fst_eatingTimeGreen].CGColor : [UIColor clearColor].CGColor;
        label.textColor        = selected ? [UIColor fst_eatingTimeGreen]   : [UIColor fst_textHeading];
    }
}

#pragma mark - Constraints

- (void)setupConstraints {
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
    [self.envelopeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.centerX.equalTo(self.contentView);
    }];
    [self pinViewToContentBelow:self.envelopeLabel anchor:self.titleLabel offset:16];
    [self pinViewToContentBelow:self.titleLabel anchor:self.chipContainer offset:24];
    [self pinViewToContentBelow:self.chipContainer anchor:self.moreLabel offset:32];
    [self.textViewContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.moreLabel.mas_bottom).offset(14);
        make.left.right.equalTo(self.contentView).inset(kSideInset);
        make.height.mas_equalTo(kTextViewHeight);
    }];
    [self.addPictureButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textViewContainer.mas_bottom).offset(16);
        make.left.equalTo(self.contentView).offset(kSideInset);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    [self.pickedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addPictureButton.mas_right).offset(12);
        make.centerY.equalTo(self.addPictureButton);
        make.size.mas_equalTo(CGSizeMake(48, 48));
    }];
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addPictureButton.mas_bottom).offset(32);
        make.left.right.equalTo(self.contentView).inset(kSideInset);
        make.height.mas_equalTo(kSubmitHeight);
        make.bottom.equalTo(self.contentView).offset(-40);
    }];
}

/// 复用：把 anchor view 钉在 above view 下方，左右贴 contentView 标准 inset。
- (void)pinViewToContentBelow:(UIView *)above anchor:(UIView *)below offset:(CGFloat)offset {
    [below mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(above.mas_bottom).offset(offset);
        make.left.right.equalTo(self.contentView).inset(kSideInset);
    }];
}

#pragma mark - Mount API

- (void)mountTextView:(UITextView *)textView placeholderLabel:(UILabel *)placeholderLabel {
    [self.textViewContainer addSubview:textView];
    [self.textViewContainer addSubview:placeholderLabel];

    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.textViewContainer);
    }];
    [placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.textViewContainer).offset(16);
        make.left.equalTo(self.textViewContainer).offset(17);
        make.right.equalTo(self.textViewContainer).offset(-17);
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
