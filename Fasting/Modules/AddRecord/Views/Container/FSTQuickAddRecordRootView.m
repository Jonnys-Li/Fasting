//
//  FSTQuickAddRecordRootView.m
//  Fasting
//

#import "FSTQuickAddRecordRootView.h"
#import "FSTTimeRowView.h"
#import "FSTTheme.h"
#import "UILabel+FSTStyle.h"

#pragma mark - Layout constants

// 通用
static const CGFloat kSideInset = 24;

// Submit
static const CGFloat kSubmitHeight = 56;
static const CGFloat kSubmitRadius = 28;

@interface FSTQuickAddRecordRootView ()
@property (nonatomic, strong, readwrite) UILabel *durationValueLabel;
@property (nonatomic, strong, readwrite) FSTTimeRowView *startRow;
@property (nonatomic, strong, readwrite) FSTTimeRowView *endRow;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIView *durationRow;
@property (nonatomic, strong) UIView *separator;
@property (nonatomic, strong) UIButton *saveButton;
@end

@implementation FSTQuickAddRecordRootView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];
        [self buildNavBar];
        [self buildScrollContent];
        [self buildDurationRow];
        [self buildSeparator];
        [self buildTimeRows];
        [self buildSaveButton];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 视图组装

- (void)buildNavBar {
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [[UIImage imageNamed:@"feedback_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.backButton setImage:backImage forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(handleBackTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backButton];

    self.titleLabel = [UILabel fst_labelWithText:@"Add new record"
                                            font:FSTFontBold(18)
                                           color:[UIColor blackColor]
                                       alignment:NSTextAlignmentCenter];
    [self addSubview:self.titleLabel];
}

- (void)buildScrollContent {
    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];
}

- (void)buildDurationRow {
    self.durationRow = [UIView new];
    [self.contentView addSubview:self.durationRow];

    UILabel *durationTitle = [UILabel fst_labelWithText:@"Fast duration"
                                                   font:FSTFontMedium(16)
                                                  color:[UIColor blackColor]];
    [self.durationRow addSubview:durationTitle];

    self.durationValueLabel = [UILabel fst_labelWithText:nil
                                                    font:FSTFontBold(16)
                                                   color:[UIColor blackColor]
                                               alignment:NSTextAlignmentRight];
    [self.durationRow addSubview:self.durationValueLabel];

    [durationTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.centerY.equalTo(self.durationRow);
    }];
    [self.durationValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.centerY.equalTo(self.durationRow);
    }];
}

- (void)buildSeparator {
    self.separator = [UIView new];
    self.separator.backgroundColor = [UIColor fst_colorWithHex:0xE5E5E5];
    [self.contentView addSubview:self.separator];
}

- (void)buildTimeRows {
    self.startRow = [FSTTimeRowView new];
    self.startRow.title = @"Fast starts";
    self.startRow.dotColor = [UIColor fst_eatingTimeGreen];
    [self.contentView addSubview:self.startRow];

    self.endRow = [FSTTimeRowView new];
    self.endRow.title = @"Fast ends";
    self.endRow.dotColor = [UIColor fst_colorWithHex:0xFF7373];
    [self.contentView addSubview:self.endRow];
}

- (void)buildSaveButton {
    self.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveButton.backgroundColor = [UIColor fst_eatingTimeGreen];
    self.saveButton.layer.cornerRadius = kSubmitRadius;
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.saveButton.titleLabel.font = FSTFontBold(18);
    [self.saveButton addTarget:self action:@selector(handleSaveTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.saveButton];
}

#pragma mark - 约束

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
    [self.separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.durationRow.mas_bottom);
        make.left.right.equalTo(self.contentView).inset(kSideInset);
        make.height.mas_equalTo(1);
    }];
    [self.startRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.separator.mas_bottom).offset(24);
        make.left.right.equalTo(self.contentView).inset(kSideInset);
    }];
    [self.endRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startRow.mas_bottom).offset(24);
        make.left.right.equalTo(self.contentView).inset(kSideInset);
    }];
    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.endRow.mas_bottom).offset(40);
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
