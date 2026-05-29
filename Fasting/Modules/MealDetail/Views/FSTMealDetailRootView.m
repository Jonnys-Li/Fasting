//
//  FSTMealDetailRootView.m
//  Fasting
//

#import "FSTMealDetailRootView.h"
#import "FSTMealTimeCardView.h"
#import "FSTMealSlotCardView.h"
#import "FSTMealDietCardView.h"
#import "FSTMealTasteCardView.h"
#import "FSTMealDetailContentCardView.h"
#import "FSTVerticalCardStackView.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

// BackButton
static const CGFloat kBackButtonSize = 48;
static const CGFloat kBackButtonTop  = 18;
static const CGFloat kBackButtonLeft = 22;

// Scroll
static const CGFloat kScrollTopOffset = 54;

// Card stack
static const CGFloat kCardSpacing       = 18;
static const CGFloat kCardSideInset     = 24;
static const CGFloat kCardBottomPadding = 28;

// BottomBar / SaveButton
static const CGFloat kBottomBarHeight   = 112;
static const CGFloat kSaveButtonHeight  = 60;
static const CGFloat kSaveButtonInset   = 50;
static const CGFloat kSaveButtonTop     = 14;
static const CGFloat kSaveButtonRadius  = 30;

@interface FSTMealDetailRootView ()
@property (nonatomic, strong, readwrite) FSTMealTimeCardView *timeCardView;
@property (nonatomic, strong, readwrite) FSTMealSlotCardView *slotCardView;
@property (nonatomic, strong, readwrite) FSTMealDietCardView *dietCardView;
@property (nonatomic, strong, readwrite) FSTMealTasteCardView *tasteCardView;
@property (nonatomic, strong, readwrite) FSTMealDetailContentCardView *detailCardView;

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) FSTVerticalCardStackView *cardStack;
@property (nonatomic, strong) UIView *bottomBar;
@property (nonatomic, strong) UIButton *saveButton;
@end

@implementation FSTMealDetailRootView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor fst_mealDetailBackground];
        [self buildTopBar];
        [self buildScrollAndCards];
        [self buildBottomBar];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 视图组装

- (void)buildTopBar {
    self.backButton = [self circleButtonWithSymbol:@"arrow.left"];
    [self.backButton addTarget:self action:@selector(handleBackTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backButton];

    self.titleLabel = [UILabel fst_labelWithText:@"Meal Details" font:FSTFontTitle() color:[UIColor fst_textPrimary] alignment:NSTextAlignmentCenter];
    [self addSubview:self.titleLabel];
}

- (void)buildScrollAndCards {
    self.scrollView = [UIScrollView new];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    self.timeCardView   = [FSTMealTimeCardView new];
    self.slotCardView   = [FSTMealSlotCardView new];
    self.dietCardView   = [FSTMealDietCardView new];
    self.tasteCardView  = [FSTMealTasteCardView new];
    self.detailCardView = [FSTMealDetailContentCardView new];

    self.cardStack = [FSTVerticalCardStackView new];
    self.cardStack.cardSpacing   = kCardSpacing;
    self.cardStack.contentInsets = UIEdgeInsetsMake(0,
                                                    kCardSideInset,
                                                    kCardBottomPadding,
                                                    kCardSideInset);
    self.cardStack.cards = @[self.timeCardView, self.slotCardView, self.dietCardView, self.tasteCardView, self.detailCardView];
    [self.contentView addSubview:self.cardStack];
}

- (void)buildBottomBar {
    self.bottomBar = [UIView new];
    self.bottomBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.92];
    [self addSubview:self.bottomBar];

    self.saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.saveButton.backgroundColor = [UIColor fst_mealSaveButton];
    self.saveButton.layer.cornerRadius = kSaveButtonRadius;
    [self.saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [self.saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.saveButton.titleLabel.font = FSTFontSubhead();
    [self.saveButton addTarget:self action:@selector(handleSaveTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar addSubview:self.saveButton];
}

#pragma mark - 工具方法

- (UIButton *)circleButtonWithSymbol:(NSString *)systemSymbolName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [UIColor colorWithWhite:1 alpha:0.96];
    button.layer.cornerRadius = FSTRadiusXL;
    [button setImage:[UIImage systemImageNamed:systemSymbolName] forState:UIControlStateNormal];
    button.tintColor = [UIColor fst_textPrimary];
    return button;
}

#pragma mark - 约束

- (void)setupConstraints {
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(kBackButtonTop);
        make.left.equalTo(self).offset(kBackButtonLeft);
        make.size.mas_equalTo(CGSizeMake(kBackButtonSize, kBackButtonSize));
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.centerX.equalTo(self);
    }];

    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.equalTo(@(kBottomBarHeight));
    }];

    [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.bottomBar).inset(kSaveButtonInset);
        make.top.equalTo(self.bottomBar).offset(kSaveButtonTop);
        make.height.equalTo(@(kSaveButtonHeight));
    }];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backButton.mas_bottom).offset(kScrollTopOffset);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.bottomBar.mas_top);
    }];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];

    [self.cardStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
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
