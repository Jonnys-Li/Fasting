//
//  FSTFastingTipsSectionView.m
//  Fasting
//

#import "FSTFastingTipsSectionView.h"
#import "FSTTheme.h"

static const CGFloat FSTTipsSectionHInset = 18;
static const CGFloat FSTTipsSectionVInset = 22;
static const CGFloat FSTTipsCardInset = 20;

static NSString * const FSTFastingTipsPreviewText =
@"It is natural to feel a little uncomfortable during fasting because your body is making some new adjustments to start a new lifestyle...";

static NSString * const FSTFastingTipsExpandedText =
@"It is natural to feel a little\n"
@"uncomfortable during fasting because your body is making some new adjustments to start a new lifestyle...\n\n"
@"If you have these symptoms, there's usually no need to worry about:\n\n"
@"- Hungry;\n"
@"- Cravings;\n"
@"- A little irritable;\n"
@"- Slightly tired;\n"
@"- Constipation (deal it with high-fiber foods)\n\n"
@"⚠️ If you keep feeling unwell or the plan is too hard to accomplish, try lowering the difficulty level. But if symptoms you have during fasting "
@"are severe and interrupt you from finishing regular daily tasks, you should stop fasting immediately and seek medical advice.";

@interface FSTFastingTipsSectionView ()

// Stage card 切换需要持有的子视图
@property (nonatomic, strong) UIView *stageCard;
@property (nonatomic, strong) UIImageView *stageBgIcon;
@property (nonatomic, strong) UILabel *stageTitleLabel;
@property (nonatomic, strong) UILabel *stageBodyLabel;

// Fasting tips card 折叠状态
@property (nonatomic, strong) UIView *qaCard;
@property (nonatomic, strong) UIImageView *qaChevron;
@property (nonatomic, strong) UILabel *qaBodyLabel;
@property (nonatomic, assign) BOOL qaExpanded;

@end

@implementation FSTFastingTipsSectionView

- (instancetype)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 22;
        self.layer.masksToBounds = YES;
        [self buildSubviews];
        [self configureForStage:FSTTipsFastingStageDuring];
    }
    return self;
}

- (void)buildSubviews {
    UIView *header     = [self buildSectionHeader];
    UIView *lemonCard  = [self buildLemonCard];
    UIView *stageCard  = [self buildStageCard];
    UIView *qaCard     = [self buildQACard];
    [self addSubview:header];
    [self addSubview:lemonCard];
    [self addSubview:stageCard];
    [self addSubview:qaCard];

    [header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(FSTTipsSectionVInset);
        make.left.equalTo(self).offset(FSTTipsSectionHInset);
        make.right.equalTo(self).offset(-FSTTipsSectionHInset);
        make.height.mas_equalTo(28);
    }];
    [lemonCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(header.mas_bottom).offset(18);
        make.left.equalTo(self).offset(FSTTipsSectionHInset);
        make.right.equalTo(self).offset(-FSTTipsSectionHInset);
    }];
    [stageCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lemonCard.mas_bottom).offset(18);
        make.left.equalTo(self).offset(FSTTipsSectionHInset);
        make.right.equalTo(self).offset(-FSTTipsSectionHInset);
    }];
    [qaCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(stageCard.mas_bottom).offset(18);
        make.left.equalTo(self).offset(FSTTipsSectionHInset);
        make.right.equalTo(self).offset(-FSTTipsSectionHInset);
        make.bottom.equalTo(self).offset(-FSTTipsSectionVInset);
    }];
}

#pragma mark - Section header

- (UIView *)buildSectionHeader {
    UIView *header = [UIView new];

    UIImageView *smiley = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tips_section_smiley"]];
    smiley.contentMode = UIViewContentModeScaleAspectFit;
    [header addSubview:smiley];

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"Tips";
    titleLabel.font = FSTFontBold(20);
    titleLabel.textColor = [UIColor fst_textPrimary];
    [header addSubview:titleLabel];

    [smiley mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(header);
        make.centerY.equalTo(header);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(smiley.mas_right).offset(6);
        make.centerY.equalTo(smiley);
        make.right.lessThanOrEqualTo(header);
    }];
    return header;
}

#pragma mark - Lemon water card

- (UIView *)buildLemonCard {
    UIView *card = [UIView new];
    card.backgroundColor = [UIColor fst_tipCardYellow];
    card.layer.cornerRadius = 18;
    card.layer.masksToBounds = YES;

    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tips_lemon_bg"]];
    bg.contentMode = UIViewContentModeScaleAspectFit;
    [card addSubview:bg];

    UILabel *title = [UILabel new];
    title.attributedText = [self cellTitleAttributedString:@"Can I drink lemon water?"];
    title.numberOfLines = 1;
    [card addSubview:title];

    UILabel *body = [UILabel new];
    body.numberOfLines = 0;
    body.attributedText = [self lemonBodyAttributedString:
        @"Yes, you can. Lemon is rich in vitamin C. A glass of lemon water just contains about 6 calories.\n\n"
        @"Drinking lemon water also increases feelings of fullness, which can help suppress hunger during fasting."];
    [card addSubview:body];

    UIButton *drinkNow = [UIButton buttonWithType:UIButtonTypeCustom];
    [drinkNow setTitle:@"Drink now" forState:UIControlStateNormal];
    [drinkNow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    drinkNow.titleLabel.font = FSTFontBold(14);
    drinkNow.backgroundColor = [UIColor fst_eatingTimeGreen];
    drinkNow.layer.cornerRadius = 22;
    drinkNow.layer.masksToBounds = YES;
    [drinkNow addTarget:self action:@selector(handleDrinkNowTapped) forControlEvents:UIControlEventTouchUpInside];
    [card addSubview:drinkNow];

    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(card).offset(-4);
        make.bottom.equalTo(card).offset(-4);
        make.size.mas_equalTo(CGSizeMake(100, 95));
    }];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(card).offset(20);
        make.left.equalTo(card).offset(16);
        make.right.equalTo(card).offset(-16);
        make.height.mas_equalTo(30);
    }];
    [body mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title.mas_bottom).offset(20);
        make.left.equalTo(card).offset(16);
        make.right.equalTo(card).offset(-16);
    }];
    [drinkNow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(body.mas_bottom).offset(24);
        make.left.equalTo(card).offset(28);
        make.right.equalTo(card).offset(-28);
        make.bottom.equalTo(card).offset(-24);
        make.height.mas_equalTo(44);
    }];
    return card;
}

- (void)handleDrinkNowTapped {
    if (self.onDrinkNowTapped) self.onDrinkNowTapped();
}

#pragma mark - Stage card

- (UIView *)buildStageCard {
    UIView *card = [UIView new];
    card.layer.cornerRadius = 18;
    card.layer.masksToBounds = YES;
    _stageCard = card;

    UIImageView *bg = [UIImageView new];
    bg.contentMode = UIViewContentModeScaleAspectFit;
    [card addSubview:bg];
    _stageBgIcon = bg;

    UILabel *title = [UILabel new];
    title.numberOfLines = 1;
    [card addSubview:title];
    _stageTitleLabel = title;

    UILabel *body = [UILabel new];
    body.numberOfLines = 0;
    [card addSubview:body];
    _stageBodyLabel = body;

    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(card).offset(-8);
        make.bottom.equalTo(card).offset(-10);
        make.size.mas_equalTo(CGSizeMake(87, 85));
    }];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(card).offset(24);
        make.left.equalTo(card).offset(FSTTipsCardInset);
        make.right.equalTo(card).offset(-FSTTipsCardInset);
        make.height.mas_equalTo(30);
    }];
    [body mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title.mas_bottom).offset(14);
        make.left.equalTo(card).offset(FSTTipsCardInset);
        make.right.equalTo(card).offset(-FSTTipsCardInset);
        make.bottom.equalTo(card).offset(-24);
    }];
    return card;
}

#pragma mark - QA (Fasting tips) card

- (UIView *)buildQACard {
    UIView *card = [UIView new];
    card.backgroundColor = [UIColor fst_stageBlue];
    card.layer.cornerRadius = 18;
    card.layer.masksToBounds = YES;
    _qaCard = card;

    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tips_question_bg"]];
    bg.contentMode = UIViewContentModeScaleAspectFit;
    [card addSubview:bg];

    UILabel *title = [UILabel new];
    title.attributedText = [self cellTitleAttributedString:@"Fasting tips"];
    [card addSubview:title];

    UIImageView *chevron = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tips_chevron"]];
    chevron.contentMode = UIViewContentModeScaleAspectFit;
    chevron.transform = CGAffineTransformMakeRotation(M_PI);  // 折叠态默认朝下
    [card addSubview:chevron];
    _qaChevron = chevron;

    UILabel *body = [UILabel new];
    body.numberOfLines = 0;
    body.attributedText = [self bodyAttributedString:FSTFastingTipsPreviewText];
    [card addSubview:body];
    _qaBodyLabel = body;

    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(card).offset(-12);
        make.bottom.equalTo(card).offset(-14);
        make.size.mas_equalTo(CGSizeMake(78, 78));
    }];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(card).offset(24);
        make.left.equalTo(card).offset(FSTTipsCardInset);
        make.height.mas_equalTo(30);
    }];
    [chevron mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(card).offset(-FSTTipsCardInset);
        make.centerY.equalTo(title);
        make.size.mas_equalTo(CGSizeMake(14, 8));
    }];
    [body mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title.mas_bottom).offset(20);
        make.left.equalTo(card).offset(FSTTipsCardInset);
        make.right.equalTo(card).offset(-FSTTipsCardInset);
        make.bottom.equalTo(card).offset(-24);
    }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleQATapped)];
    [card addGestureRecognizer:tap];
    _qaExpanded = NO;
    return card;
}

- (void)handleQATapped {
    self.qaExpanded = !self.qaExpanded;
    self.qaBodyLabel.attributedText = [self bodyAttributedString:self.qaExpanded ? FSTFastingTipsExpandedText : FSTFastingTipsPreviewText];
    [UIView animateWithDuration:0.25 animations:^{
        self.qaChevron.transform = self.qaExpanded
            ? CGAffineTransformIdentity
            : CGAffineTransformMakeRotation(M_PI);
        [self layoutIfNeeded];
        [self.superview layoutIfNeeded];
    }];
}

#pragma mark - Public stage configuration

- (void)configureForStage:(FSTTipsFastingStage)stage {
    switch (stage) {
        case FSTTipsFastingStagePrepare:
            self.stageCard.backgroundColor = [UIColor fst_stageBlue];
            self.stageBgIcon.hidden = YES;
            self.stageBgIcon.image = nil;
            self.stageTitleLabel.attributedText = [self cellTitleAttributedString:@"Prepare for fasting"];
            self.stageBodyLabel.attributedText = [self bodyAttributedString:
                @"🥩 Eat protein-rich foods, such as meat, fish, tofu and nuts.\n🍎 Add fiber and complex carbs from beans, fruits and vegetables.\n💧 Drink plenty of water.\n🥬 Fill yourself with natural foods to control your appetite."];
            break;
        case FSTTipsFastingStageDuring:
            self.stageCard.backgroundColor = [UIColor fst_stageGreen];
            self.stageBgIcon.hidden = NO;
            self.stageBgIcon.image = [UIImage imageNamed:@"tips_fork_ring_during"];
            self.stageTitleLabel.attributedText = [self cellTitleAttributedString:@"During fasting"];
            self.stageBodyLabel.attributedText = [self bodyAttributedString:
                @"💧 Drink water or herbal tea to stay hydrated.\n🍪 Keep your mind off food.\n🚫 Avoid high-intensity workouts."];
            break;
        case FSTTipsFastingStageAfter:
            self.stageCard.backgroundColor = [UIColor fst_stageOrange];
            self.stageBgIcon.hidden = NO;
            self.stageBgIcon.image = [UIImage imageNamed:@"tips_fork_ring_after"];
            self.stageTitleLabel.attributedText = [self cellTitleAttributedString:@"After fasting"];
            self.stageBodyLabel.attributedText = [self bodyAttributedString:
                @"🚫 Avoid overeating.\n🥗 Eat high-protein foods and vegetables.\n🛌 Take a break if you feel unwell."];
            break;
    }
}

#pragma mark - Helpers

- (NSAttributedString *)cellTitleAttributedString:(NSString *)text {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineHeightMultiple = 1.1;
    UIFont *font = FSTFontAvenirDemiBold(20);
    return [[NSAttributedString alloc] initWithString:text
                                           attributes:@{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: [UIColor fst_textHeading],
        NSParagraphStyleAttributeName: style,
    }];
}

- (NSAttributedString *)lemonBodyAttributedString:(NSString *)text {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = 7;
    return [[NSAttributedString alloc] initWithString:text
                                           attributes:@{
        NSFontAttributeName: FSTFontMedium(17),
        NSForegroundColorAttributeName: [UIColor fst_textTipBody],
        NSParagraphStyleAttributeName: style,
    }];
}

- (NSAttributedString *)bodyAttributedString:(NSString *)text {
    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
    style.lineSpacing = 6;
    return [[NSAttributedString alloc] initWithString:text
                                           attributes:@{
        NSFontAttributeName: FSTFontMedium(15),
        NSForegroundColorAttributeName: [UIColor fst_textTipBody],
        NSParagraphStyleAttributeName: style,
    }];
}

@end
