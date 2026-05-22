//
//  FSTTimelineModuleView.m
//  Fasting
//
//  食物日记模块卡：🍴 标题栏 + 时间轴记录行 + "+ 增加" 按钮。
//

#import "FSTTimelineModuleView.h"
#import "FSTSessionManager.h"
#import "FSTTheme.h"

static const CGFloat kHeaderHeight      = 44;
static const CGFloat kHeaderTopInset    = 20;
static const CGFloat kSideInset         = 22;
static const CGFloat kDotSize           = 12;
static const CGFloat kCardHeight        = 96;
static const CGFloat kFoodIconSize      = 68;
static const CGFloat kFeelingSize       = 36;
static const CGFloat kChipHeight        = 34;
static const CGFloat kAddButtonHeight   = 48;

@interface FSTTimelineModuleView ()
// 头部
@property (nonatomic, strong) UILabel *forkIconLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *questionBadge;
@property (nonatomic, strong) UIControl *chevronControl;
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
@property (nonatomic, strong, nullable) FSTMealRecord *currentRecord;
@end

@implementation FSTTimelineModuleView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 22;
        [self buildHeader];
        [self buildEntryRow];
        [self buildFooter];
        [self buildEmptyState];
        [self showEmptyState:YES];
    }
    return self;
}

#pragma mark - 头部：🍴 食物日记 ? >

- (void)buildHeader {
    // 🍴 图标
    self.forkIconLabel = [UILabel new];
    self.forkIconLabel.text = @"🍴";
    self.forkIconLabel.font = [UIFont systemFontOfSize:28];
    [self addSubview:self.forkIconLabel];

    // 标题
    self.titleLabel = [UILabel new];
    self.titleLabel.text = @"食物日记";
    self.titleLabel.font = FSTFontBold(22);
    self.titleLabel.textColor = [UIColor fst_textPrimary];
    [self addSubview:self.titleLabel];

    // ? 徽标
    self.questionBadge = [self buildQuestionBadge];
    [self addSubview:self.questionBadge];

    // > 箭头
    self.chevronControl = [UIControl new];
    UIImageView *chevronIcon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right" withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:16 weight:UIImageSymbolWeightSemibold]]];
    chevronIcon.tintColor = [UIColor fst_textSecondary];
    chevronIcon.userInteractionEnabled = NO;
    [self.chevronControl addSubview:chevronIcon];
    [self.chevronControl addTarget:self action:@selector(handleChevronTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.chevronControl];

    // 约束
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
    [chevronIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.chevronControl);
    }];
}

- (UIView *)buildQuestionBadge {
    UIView *badge = [UIView new];
    badge.backgroundColor = [[UIColor fst_mealDateText] colorWithAlphaComponent:0.15];
    badge.layer.cornerRadius = 13;

    UILabel *qLabel = [UILabel new];
    qLabel.text = @"?";
    qLabel.font = FSTFontBold(15);
    qLabel.textColor = [UIColor fst_mealDateText];
    qLabel.textAlignment = NSTextAlignmentCenter;
    [badge addSubview:qLabel];
    [qLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(badge);
    }];
    return badge;
}

#pragma mark - 时间轴记录行

- (void)buildEntryRow {
    self.entryContainer = [UIView new];
    [self addSubview:self.entryContainer];

    // 时间轴圆点
    self.dotView = [UIView new];
    self.dotView.layer.borderColor = [UIColor fst_mealDiaryCardBorder].CGColor;
    self.dotView.layer.borderWidth = 3;
    self.dotView.layer.cornerRadius = kDotSize / 2.0;
    [self.entryContainer addSubview:self.dotView];

    // 时间轴连线
    self.lineView = [UIView new];
    self.lineView.backgroundColor = [UIColor fst_mealDiaryCardBorder];
    [self.entryContainer addSubview:self.lineView];

    // 时间文字
    self.timeLabel = [UILabel new];
    self.timeLabel.font = FSTFontRegular(15);
    self.timeLabel.textColor = [UIColor fst_textSecondary];
    [self.entryContainer addSubview:self.timeLabel];

    // 食物卡片
    self.cardView = [UIControl new];
    self.cardView.backgroundColor = [UIColor fst_mealDiaryCardBackground];
    self.cardView.layer.cornerRadius = 18;
    self.cardView.layer.borderWidth = 1.0;
    self.cardView.layer.borderColor = [UIColor fst_mealDiaryCardBorder].CGColor;
    [self.cardView addTarget:self action:@selector(handleEntryTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.entryContainer addSubview:self.cardView];

    // 食物图标（白底圆角方块 + emoji）
    self.foodIconLabel = [UILabel new];
    self.foodIconLabel.backgroundColor = [UIColor whiteColor];
    self.foodIconLabel.layer.cornerRadius = 14;
    self.foodIconLabel.clipsToBounds = YES;
    self.foodIconLabel.font = [UIFont systemFontOfSize:34];
    self.foodIconLabel.textAlignment = NSTextAlignmentCenter;
    self.foodIconLabel.userInteractionEnabled = NO;
    [self.cardView addSubview:self.foodIconLabel];

    // 分类胶囊
    self.categoryChipLabel = [self buildChipLabel];
    [self.cardView addSubview:self.categoryChipLabel];

    // 饮食类型胶囊
    self.dietChipLabel = [self buildChipLabel];
    self.dietChipLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.cardView addSubview:self.dietChipLabel];

    // 口味表情
    self.feelingImageView = [UIImageView new];
    self.feelingImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.feelingImageView.userInteractionEnabled = NO;
    [self.cardView addSubview:self.feelingImageView];

    // 约束
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
}

- (UILabel *)buildChipLabel {
    UILabel *label = [UILabel new];
    label.font = FSTFontRegular(15);
    label.textColor = [UIColor fst_textPrimary];
    label.backgroundColor = [UIColor whiteColor];
    label.layer.cornerRadius = 17;
    label.clipsToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = NO;
    return label;
}

#pragma mark - 底部：分割线 + 增加

- (void)buildFooter {
    self.separatorLine = [UIView new];
    self.separatorLine.backgroundColor = [UIColor fst_mealDiaryCardBorder];
    [self addSubview:self.separatorLine];

    self.addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    NSMutableAttributedString *addTitle = [[NSMutableAttributedString alloc]
        initWithString:@"＋ "
            attributes:@{NSFontAttributeName: FSTFontBold(18),
                         NSForegroundColorAttributeName: [UIColor fst_mealDateText]}];
    [addTitle appendAttributedString:[[NSAttributedString alloc]
        initWithString:@"增加"
            attributes:@{NSFontAttributeName: FSTFontBold(18),
                         NSForegroundColorAttributeName: [UIColor fst_mealDateText]}]];
    [self.addButton setAttributedTitle:addTitle forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(handleAddTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.addButton];

    [self.separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.entryContainer.mas_bottom).offset(14);
        make.left.right.equalTo(self).inset(kSideInset);
        make.height.equalTo(@1);
    }];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.separatorLine.mas_bottom);
        make.left.right.equalTo(self);
        make.height.equalTo(@(kAddButtonHeight));
        make.bottom.equalTo(self);
    }];
}

#pragma mark - 空态

- (void)buildEmptyState {
    self.emptyLabel = [UILabel new];
    self.emptyLabel.text = @"今天还没有饮食记录";
    self.emptyLabel.font = FSTFontRegular(15);
    self.emptyLabel.textColor = [UIColor fst_textSecondary];
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.emptyLabel];

    [self.emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.forkIconLabel.mas_bottom).offset(16);
        make.left.right.equalTo(self).inset(kSideInset);
        make.bottom.equalTo(self.separatorLine.mas_top).offset(-14);
    }];
}

- (void)showEmptyState:(BOOL)empty {
    self.entryContainer.hidden = empty;
    self.emptyLabel.hidden = !empty;
}

#pragma mark - 数据刷新

- (void)updateWithMealRecord:(FSTMealRecord *)record {
    self.currentRecord = record;
    if (!record) {
        [self showEmptyState:YES];
        return;
    }
    [self showEmptyState:NO];

    self.timeLabel.text = FSTFormatRelativeDateTime(record.date ?: [NSDate date]);
    self.foodIconLabel.text = [record.mealCategory isEqualToString:@"零食"] ? @"🍎" : @"🍽";
    self.categoryChipLabel.text = [NSString stringWithFormat:@"  %@  ", record.mealCategory ?: @"正餐"];
    self.dietChipLabel.text = [NSString stringWithFormat:@"  %@  ", record.dietType ?: @"我不确定"];

    NSString *imageName;
    switch (record.tasteLevel) {
        case 0: imageName = @"tl_rating_hard"; break;
        case 2: imageName = @"tl_rating_easy"; break;
        default: imageName = @"tl_rating_ok"; break;
    }
    self.feelingImageView.image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

#pragma mark - 事件

- (void)handleChevronTapped {
    if (self.onChevronTapped) self.onChevronTapped();
}

- (void)handleAddTapped {
    if (self.onAddTapped) self.onAddTapped();
}

- (void)handleEntryTapped {
    if (self.currentRecord && self.onEntryTapped) self.onEntryTapped(self.currentRecord);
}

@end
