//
//  FSTPlanRecommendBoardView.m
//  Fasting
//

#import "FSTPlanRecommendBoardView.h"
#import "FSTPlan.h"
#import "FSTTheme.h"

@interface FSTPlanRecommendBoardView ()
@property (nonatomic, strong) NSArray<FSTPlan *> *plans;
@end

@implementation FSTPlanRecommendBoardView

- (instancetype)init {
    if ((self = [super init])) {
        _plans = [FSTPlan defaultDailyPlans];
        [self buildSubviews];
    }
    return self;
}

- (void)buildSubviews {
    UILabel *headingLabel = [UILabel new];
    headingLabel.text = @"更有效的周计划";
    headingLabel.font = FSTFontBold(22);
    headingLabel.textColor = [UIColor fst_textPrimary];
    [self addSubview:headingLabel];

    UIScrollView *cardsScrollView = [UIScrollView new];
    cardsScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:cardsScrollView];

    UIStackView *cardsStackView = [UIStackView new];
    cardsStackView.axis = UILayoutConstraintAxisHorizontal;
    cardsStackView.spacing = 14;
    [cardsScrollView addSubview:cardsStackView];

    NSArray<NSString *> *captions = @[@"跳过早餐", @"跳过晚餐", @"轻量入门", @"高效燃脂"];
    for (NSInteger planIndex = 0; planIndex < MIN(self.plans.count, captions.count); planIndex++) {
        FSTPlan *plan = self.plans[planIndex];
        UIControl *cardControl = [self cardControlForPlan:plan caption:captions[planIndex] index:planIndex];
        cardControl.tag = planIndex;
        [cardControl addTarget:self action:@selector(handleCardTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cardsStackView addArrangedSubview:cardControl];
    }

    [headingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).offset(30);
    }];
    [cardsScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headingLabel.mas_bottom).offset(18);
        make.left.right.equalTo(self);
        make.height.equalTo(@156);
        make.bottom.equalTo(self);
    }];
    [cardsStackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(cardsScrollView);
        make.left.equalTo(cardsScrollView).offset(30);
        make.right.equalTo(cardsScrollView).offset(-30);
        make.height.equalTo(cardsScrollView);
    }];
}

/// 单张彩色推荐卡（蓝色/橙色交替）。
- (UIControl *)cardControlForPlan:(FSTPlan *)plan caption:(NSString *)caption index:(NSInteger)index {
    UIControl *cardControl = [UIControl new];
    cardControl.layer.cornerRadius = 14;
    cardControl.clipsToBounds = YES;
    cardControl.backgroundColor = index % 2 == 0 ? [UIColor fst_colorWithHex:0x6689E8] : [UIColor fst_colorWithHex:0xF4A94F];
    [cardControl mas_makeConstraints:^(MASConstraintMaker *make) { make.width.equalTo(@260); }];

    UILabel *nameLabel = [self whiteLabelWithText:plan.name font:FSTFontBold(27)];
    UILabel *boltsLabel = [self whiteLabelWithText:@"⚡︎ ⚡︎ ⚡︎ ⚡︎" font:FSTFontBold(20)];
    boltsLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.44];
    UILabel *detailLabel = [self whiteLabelWithText:@"•7天计划" font:FSTFontBold(19)];

    UILabel *captionPillLabel = [self whiteLabelWithText:caption font:FSTFontBold(16)];
    captionPillLabel.textAlignment = NSTextAlignmentCenter;
    captionPillLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.16];
    captionPillLabel.layer.cornerRadius = 17;
    captionPillLabel.clipsToBounds = YES;

    for (UIView *subview in @[nameLabel, boltsLabel, detailLabel, captionPillLabel]) [cardControl addSubview:subview];

    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cardControl).offset(26);
        make.left.equalTo(cardControl).offset(24);
    }];
    [boltsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(nameLabel);
        make.left.equalTo(nameLabel.mas_right).offset(32);
    }];
    [detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom).offset(28);
        make.left.equalTo(cardControl).offset(24);
    }];
    [captionPillLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(detailLabel.mas_bottom).offset(16);
        make.left.equalTo(cardControl).offset(24);
        make.size.mas_equalTo(CGSizeMake(100, 34));
    }];
    return cardControl;
}

- (UILabel *)whiteLabelWithText:(NSString *)text font:(UIFont *)font {
    UILabel *whiteLabel = [UILabel new];
    whiteLabel.text = text;
    whiteLabel.font = font;
    whiteLabel.textColor = [UIColor whiteColor];
    return whiteLabel;
}

- (void)handleCardTapped:(UIControl *)cardControl {
    if (cardControl.tag < self.plans.count && self.onCardTapped) {
        self.onCardTapped(self.plans[cardControl.tag]);
    }
}

@end
