//
//  FSTQuickAddRecordRootView.m
//  Fasting
//

#import "FSTQuickAddRecordRootView.h"
#import "FSTTimeRowView.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

static const CGFloat kSideInset = 24;

static const CGFloat kSubmitHeight = 56;
static const CGFloat kSubmitRadius = 28;

@interface FSTQuickAddRecordRootView ()
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *durationRow;
@property (nonatomic, strong) UILabel *durationTitle;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UIButton *saveButton;
@end

@implementation FSTQuickAddRecordRootView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 视图组装

- (void)setupSubviews {
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [UIImage fst_originalImageNamed:@"feedback_back"];
    [self.backButton setImage:backImage forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(handleBackTapped)
              forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backButton];

    self.titleLabel = [UILabel fst_labelWithText:@"Add new record"
                                            font:FSTFontBold(18)
                                           color:[UIColor blackColor]
                                       alignment:NSTextAlignmentCenter];
    [self addSubview:self.titleLabel];

    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    self.durationRow = [UIView new];
    [self.contentView addSubview:self.durationRow];

    self.durationTitle = [UILabel fst_labelWithText:@"Fast duration"
                                               font:FSTFontMedium(16)
                                              color:[UIColor blackColor]];
    [self.durationRow addSubview:self.durationTitle];

    self.separator = [UIView fst_separatorLineWithColor:[UIColor fst_colorWithHex:0xE5E5E5]];
    [self.contentView addSubview:self.separator];

    self.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveButton.backgroundColor = [UIColor fst_eatingTimeGreen];
    self.saveButton.layer.cornerRadius = kSubmitRadius;
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.saveButton.titleLabel.font = FSTFontBold(18);
    [self.saveButton addTarget:self action:@selector(handleSaveTapped)
              forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.saveButton];
}

- (void)setupConstraints {
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(8);
        make.left.equalTo(self).offset(16);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.centerX.equalTo(self);
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backButton.mas_bottom).offset(16);
        make.left.right.bottom.equalTo(self);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    [self.durationRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(16);
        make.left.right.equalTo(self.contentView).inset(kSideInset);
        make.height.mas_equalTo(44);
    }];
    [self.durationTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(self.durationRow);
    }];
    [self.separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.durationRow.mas_bottom);
        make.left.right.equalTo(self.contentView).inset(kSideInset);
        make.height.mas_equalTo(1);
    }];
}

#pragma mark - Mount API

- (void)mountStartRow:(FSTTimeRowView *)startRow
               endRow:(FSTTimeRowView *)endRow
   durationValueLabel:(UILabel *)durationValueLabel {
    [self.durationRow addSubview:durationValueLabel];
    [durationValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.centerY.equalTo(self.durationRow);
    }];

    [self.contentView addSubview:startRow];
    [startRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.separator.mas_bottom).offset(24);
        make.left.right.equalTo(self.contentView).inset(kSideInset);
    }];

    [self.contentView addSubview:endRow];
    [endRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(startRow.mas_bottom).offset(24);
        make.left.right.equalTo(self.contentView).inset(kSideInset);
    }];

    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(endRow.mas_bottom).offset(40);
        make.left.right.equalTo(self.contentView).inset(kSideInset);
        make.height.mas_equalTo(kSubmitHeight);
        make.bottom.equalTo(self.contentView).offset(-40);
    }];
}

#pragma mark - 事件

- (void)handleBackTapped {
    if (self.onBackTapped) self.onBackTapped();
}

- (void)handleSaveTapped {
    if (self.onSaveTapped) self.onSaveTapped();
}

@end
