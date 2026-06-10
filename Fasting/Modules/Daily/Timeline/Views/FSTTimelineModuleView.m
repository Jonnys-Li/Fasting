//
//  FSTTimelineModuleView.m
//  Fasting
//
//  食物日记模块卡：🍴 标题栏 + 时间轴记录行 + "+ 增加" 按钮。
//

#import "FSTTimelineModuleView.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

// Header / 容器
static const CGFloat kHeaderHeight   = 44;
static const CGFloat kHeaderTopInset = 20;
static const CGFloat kSideInset      = 22;

// 时间轴行（dot + 圆点 + 食物卡）
static const CGFloat kDotSize      = 12;
static const CGFloat kCardHeight   = 96;
static const CGFloat kFoodIconSize = 68;
static const CGFloat kFeelingSize  = 36;
static const CGFloat kChipHeight   = 34;

// Footer

@interface FSTTimelineModuleView ()
// 头部
@property (nonatomic, strong) UILabel *forkIconLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *questionBadge;
@property (nonatomic, strong) UIControl *chevronControl;
@property (nonatomic, strong) UIImageView *chevronIcon;
// 时间轴行
@property (nonatomic, strong) UIView *entryContainer;
@property (nonatomic, strong) UIView *dotView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIControl *cardView;
@property (nonatomic, strong) UILabel *foodIconLabel;
@property (nonatomic, strong) UILabel *categoryChipLabel;
@property (nonatomic, strong) UILabel *dietChipLabel;
@property (nonatomic, strong) UIImageView *feelingImageView;
// 分割线 + 增加
@property (nonatomic, strong) UIView *separatorLine;
@property (nonatomic, strong) UIButton *addButton;
// 空态
@property (nonatomic, strong) UILabel *emptyLabel;
// 数据
@property (nonatomic, assign) BOOL hasRecord;
@end

@implementation FSTTimelineModuleView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = FSTRadiusL;
        [self setupSubviews];
        [self setupConstraints];
        [self showEmptyState:YES];
    }
    return self;
}

#pragma mark - 视图组装

- (void)setupSubviews {
    // 头部：🍴 食物日记 ? >
    self.forkIconLabel = [UILabel fst_labelWithText:@"🍴" font:FSTFontRegular(28) color:[UIColor blackColor]];
    self.titleLabel    = [UILabel fst_labelWithText:@"Food Diary" font:FSTFontTitle() color:[UIColor fst_textPrimary]];
    self.questionBadge = [self questionBadgeView];

    self.chevronControl = [[UIControl alloc] init];
    self.chevronIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:16 weight:UIImageSymbolWeightSemibold]]];
    self.chevronIcon.tintColor = [UIColor fst_textSecondary];
    self.chevronIcon.userInteractionEnabled = NO;
    [self.chevronControl addSubview:self.chevronIcon];
    [self.chevronControl addTarget:self action:@selector(handleChevronTapped) forControlEvents:UIControlEventTouchUpInside];

    [self fst_addSubviews:@[self.forkIconLabel, self.titleLabel, self.questionBadge, self.chevronControl]];

    // 时间轴记录行
    self.entryContainer = [[UIView alloc] init];
    [self addSubview:self.entryContainer];

    // 时间轴圆点（边框 + 透明填充）
    self.dotView = [UIView fst_circularDotWithSize:kDotSize
                                       borderColor:[UIColor fst_mealDiaryCardBorder]
                                       borderWidth:3
                                           bgColor:nil];

    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor fst_mealDiaryCardBorder];
    self.timeLabel = [UILabel fst_labelWithText:nil font:FSTFontBody() color:[UIColor fst_textSecondary]];

    self.cardView = (UIControl *)[UIControl fst_containerWithBackground:[UIColor fst_mealDiaryCardBackground] radius:FSTRadiusCard];
    self.cardView.layer.borderWidth = 1.0;
    self.cardView.layer.borderColor = [UIColor fst_mealDiaryCardBorder].CGColor;
    [self.cardView addTarget:self action:@selector(handleEntryTapped) forControlEvents:UIControlEventTouchUpInside];

    self.foodIconLabel = [UILabel fst_labelWithText:nil font:FSTFontRegular(34) color:[UIColor blackColor]];
    self.foodIconLabel.textAlignment = NSTextAlignmentCenter;
    self.foodIconLabel.backgroundColor = [UIColor whiteColor];
    self.foodIconLabel.layer.cornerRadius = FSTRadiusM;
    self.foodIconLabel.clipsToBounds = YES;
    self.foodIconLabel.userInteractionEnabled = NO;

    self.categoryChipLabel = [self chipLabel];
    self.dietChipLabel = [self chipLabel];
    self.dietChipLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    self.feelingImageView = [[UIImageView alloc] init];
    self.feelingImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.feelingImageView.userInteractionEnabled = NO;

    [self.entryContainer fst_addSubviews:@[self.dotView, self.lineView, self.timeLabel, self.cardView]];
    [self.cardView fst_addSubviews:@[self.foodIconLabel, self.categoryChipLabel, self.dietChipLabel, self.feelingImageView]];

    // 底部：分割线 + 增加
    self.separatorLine = [UIView fst_separatorLineWithColor:[UIColor fst_mealDiaryCardBorder]];
    [self addSubview:self.separatorLine];

    self.addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    NSMutableAttributedString *addTitle = [[NSMutableAttributedString alloc]
        initWithString:@"＋ "
            attributes:@{NSFontAttributeName: FSTFontBold(18),
                         NSForegroundColorAttributeName: [UIColor fst_mealDateText]}];
    [addTitle appendAttributedString:[[NSAttributedString alloc]
        initWithString:@"Add"
            attributes:@{NSFontAttributeName: FSTFontBold(18),
                         NSForegroundColorAttributeName: [UIColor fst_mealDateText]}]];
    [self.addButton setAttributedTitle:addTitle forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(handleAddTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.addButton];

    // 空态
    self.emptyLabel = [UILabel fst_labelWithText:@"No meal records today" font:FSTFontBody() color:[UIColor fst_textSecondary]];
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.emptyLabel];
}

- (void)setupConstraints {
    // 头部
    [self.forkIconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(kSideInset);
        make.top.equalTo(self).offset(kHeaderTopInset);
        make.size.mas_equalTo(CGSizeMake(34, 34));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.forkIconLabel.mas_right).offset(8);
        make.centerY.equalTo(self.forkIconLabel);
    }];
    [self.questionBadge mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(8);
        make.centerY.equalTo(self.forkIconLabel);
        make.size.mas_equalTo(CGSizeMake(26, 26));
    }];
    [self.chevronControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-kSideInset);
        make.centerY.equalTo(self.forkIconLabel);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.chevronIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.chevronControl);
    }];

    // 时间轴记录行
    [self.entryContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.forkIconLabel.mas_bottom).offset(16);
        make.left.equalTo(self).offset(kSideInset);
        make.right.equalTo(self).offset(-kSideInset);
    }];
    [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.entryContainer);
        make.top.equalTo(self.entryContainer).offset(4);
        make.size.mas_equalTo(CGSizeMake(kDotSize, kDotSize));
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dotView.mas_bottom);
        make.centerX.equalTo(self.dotView);
        make.width.equalTo(@2);
        make.bottom.equalTo(self.cardView.mas_bottom);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.dotView.mas_right).offset(14);
        make.centerY.equalTo(self.dotView);
    }];
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLabel);
        make.right.equalTo(self.entryContainer);
        make.top.equalTo(self.timeLabel.mas_bottom).offset(10);
        make.height.equalTo(@(kCardHeight));
        make.bottom.equalTo(self.entryContainer);
    }];
    [self.foodIconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cardView).offset(14);
        make.centerY.equalTo(self.cardView);
        make.size.mas_equalTo(CGSizeMake(kFoodIconSize, kFoodIconSize));
    }];
    [self.categoryChipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.foodIconLabel.mas_right).offset(14);
        make.centerY.equalTo(self.cardView);
        make.height.equalTo(@(kChipHeight));
    }];
    [self.dietChipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.categoryChipLabel.mas_right).offset(8);
        make.right.lessThanOrEqualTo(self.feelingImageView.mas_left).offset(-10);
        make.centerY.equalTo(self.cardView);
        make.height.equalTo(@(kChipHeight));
    }];
    [self.feelingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.cardView).offset(-16);
        make.centerY.equalTo(self.cardView);
        make.size.mas_equalTo(CGSizeMake(kFeelingSize, kFeelingSize));
    }];

    // 底部：分割线 + 增加
    [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.entryContainer.mas_bottom).offset(14);
        make.left.right.equalTo(self).inset(kSideInset);
        make.height.equalTo(@1);
    }];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.separatorLine.mas_bottom);
        make.left.right.equalTo(self);
        make.height.equalTo(@(FSTControlHeightStandard));
        make.bottom.equalTo(self);
    }];

    // 空态
    [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.forkIconLabel.mas_bottom).offset(16);
        make.left.right.equalTo(self).inset(kSideInset);
        make.bottom.equalTo(self.separatorLine.mas_top).offset(-14);
    }];
}

#pragma mark - 工厂

- (UIView *)questionBadgeView {
    UIView *badge = [UIView fst_containerWithBackground:[[UIColor fst_mealDateText] colorWithAlphaComponent:0.15] radius:13];
    UILabel *qLabel = [UILabel fst_labelWithText:@"?" font:FSTFontBold(15) color:[UIColor fst_mealDateText]];
    qLabel.textAlignment = NSTextAlignmentCenter;
    [badge addSubview:qLabel];
    [qLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(badge);
    }];
    return badge;
}

- (UILabel *)chipLabel {
    UILabel *label = [UILabel fst_labelWithText:nil font:FSTFontBody() color:[UIColor fst_textPrimary]];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor whiteColor];
    label.layer.cornerRadius = FSTRadiusChip;
    label.clipsToBounds = YES;
    label.userInteractionEnabled = NO;
    return label;
}

#pragma mark - 空态

- (void)showEmptyState:(BOOL)empty {
    self.entryContainer.hidden = empty;
    self.emptyLabel.hidden = !empty;
}

#pragma mark - 数据刷新

- (void)updateWithMealCategory:(FSTMealCategory)category
                      dietType:(FSTDietType)dietType
                    tasteLevel:(NSInteger)tasteLevel
                      dateText:(nullable NSString *)dateText {
    self.hasRecord = YES;
    [self showEmptyState:NO];

    self.timeLabel.text = dateText ?: @"";
    self.foodIconLabel.text = FSTMealCategoryIconText(category);
    self.categoryChipLabel.text = [NSString stringWithFormat:@"  %@  ", FSTMealCategoryDisplayName(category)];
    self.dietChipLabel.text = [NSString stringWithFormat:@"  %@  ", FSTDietTypeDisplayName(dietType)];

    self.feelingImageView.image = [UIImage fst_ratingImageForLevel:tasteLevel];
}

- (void)showEmptyMealState {
    self.hasRecord = NO;
    [self showEmptyState:YES];
}

#pragma mark - 事件

- (void)handleChevronTapped {
    if (self.onChevronTapped) self.onChevronTapped();
}

- (void)handleAddTapped {
    if (self.onAddTapped) self.onAddTapped();
}

- (void)handleEntryTapped {
    if (self.hasRecord && self.onEntryTapped) self.onEntryTapped();
}

@end
