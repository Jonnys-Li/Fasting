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
        self.layer.cornerRadius = FSTRadiusL;
        self.layer.masksToBounds = YES;
        [self buildSubviews];
        [self configureForStage:FSTTipsFastingStageDuring];
    }
    return self;
}

- (void)buildSubviews {
    UIView *header     = [self buildSectionHeader];
    UIView *lemonCard  = [self buildLemonCard];
    [self buildStageCard];  // 内部 self.stageCard / stageBgIcon / stageTitleLabel / stageBodyLabel 自赋值
    [self buildQACard];     // 内部 self.qaCard / qaChevron / qaBodyLabel 自赋值
    [self fst_addSubviews:@[header, lemonCard, self.stageCard, self.qaCard]];

    [header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(FSTTipsSectionVInset);
        make.left.equalTo(self).offset(FSTTipsSectionHInset);
        make.right.equalTo(self).offset(-FSTTipsSectionHInset);
        make.height.mas_equalTo(28);
    }];
    [self pinCard:lemonCard belowAnchor:header.mas_bottom];
    [self pinCard:self.stageCard belowAnchor:lemonCard.mas_bottom];
    [self.qaCard mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stageCard.mas_bottom).offset(18);
        make.left.equalTo(self).offset(FSTTipsSectionHInset);
        make.right.equalTo(self).offset(-FSTTipsSectionHInset);
        make.bottom.equalTo(self).offset(-FSTTipsSectionVInset);
    }];
}

/// 复用：3 张主卡都贴 self 左右 FSTTipsSectionHInset，距上一卡 18pt。
- (void)pinCard:(UIView *)card belowAnchor:(MASViewAttribute *)topAnchor {
    [card mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topAnchor).offset(18);
        make.left.equalTo(self).offset(FSTTipsSectionHInset);
        make.right.equalTo(self).offset(-FSTTipsSectionHInset);
    }];
}

#pragma mark - Section header

- (UIView *)buildSectionHeader {
    UIView *header = [[UIView alloc] init];

    UIImageView *smiley = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tips_section_smiley"]];
    smiley.contentMode = UIViewContentModeScaleAspectFit;

    UILabel *titleLabel = [UILabel fst_labelWithText:@"Tips"
                                                font:FSTFontSubhead()
                                               color:[UIColor fst_textPrimary]];

    [header fst_addSubviews:@[smiley, titleLabel]];

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
    UIView *card = [UIView fst_containerWithBackground:[UIColor fst_tipCardYellow] radius:FSTRadiusCard];
    card.layer.masksToBounds = YES;

    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tips_lemon_bg"]];
    bg.contentMode = UIViewContentModeScaleAspectFit;

    UILabel *title = [[UILabel alloc] init];
    title.attributedText = [self cellTitleAttributedString:@"Can I drink lemon water?"];
    title.numberOfLines = 1;

    UILabel *body = [[UILabel alloc] init];
    body.numberOfLines = 0;
    body.attributedText = [self lemonBodyAttributedString:
        @"Yes, you can. Lemon is rich in vitamin C. A glass of lemon water just contains about 6 calories.\n\n"
        @"Drinking lemon water also increases feelings of fullness, which can help suppress hunger during fasting."];

    UIButton *drinkNow = [UIButton fst_pillButtonWithTitle:@"Drink now" style:FSTPillButtonStyleTipPrompt];
    [drinkNow addTarget:self action:@selector(handleDrinkNowTapped) forControlEvents:UIControlEventTouchUpInside];

    [card fst_addSubviews:@[bg, title, body, drinkNow]];

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

- (void)buildStageCard {
    self.stageCard = [[UIView alloc] init];
    self.stageCard.layer.cornerRadius = FSTRadiusCard;
    self.stageCard.layer.masksToBounds = YES;

    self.stageBgIcon = [[UIImageView alloc] init];
    self.stageBgIcon.contentMode = UIViewContentModeScaleAspectFit;

    self.stageTitleLabel = [[UILabel alloc] init];
    self.stageTitleLabel.numberOfLines = 1;

    self.stageBodyLabel = [[UILabel alloc] init];
    self.stageBodyLabel.numberOfLines = 0;

    [self.stageCard fst_addSubviews:@[self.stageBgIcon, self.stageTitleLabel, self.stageBodyLabel]];

    [self.stageBgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.stageCard).offset(-8);
        make.bottom.equalTo(self.stageCard).offset(-10);
        make.size.mas_equalTo(CGSizeMake(87, 85));
    }];
    [self.stageTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stageCard).offset(24);
        make.left.equalTo(self.stageCard).offset(FSTTipsCardInset);
        make.right.equalTo(self.stageCard).offset(-FSTTipsCardInset);
        make.height.mas_equalTo(30);
    }];
    [self.stageBodyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.stageTitleLabel.mas_bottom).offset(14);
        make.left.equalTo(self.stageCard).offset(FSTTipsCardInset);
        make.right.equalTo(self.stageCard).offset(-FSTTipsCardInset);
        make.bottom.equalTo(self.stageCard).offset(-24);
    }];
}

#pragma mark - QA (Fasting tips) card

- (void)buildQACard {
    self.qaCard = [UIView fst_containerWithBackground:[UIColor fst_stageBlue] radius:FSTRadiusCard];
    self.qaCard.layer.masksToBounds = YES;

    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tips_question_bg"]];
    bg.contentMode = UIViewContentModeScaleAspectFit;

    UILabel *title = [[UILabel alloc] init];
    title.attributedText = [self cellTitleAttributedString:@"Fasting tips"];

    self.qaChevron = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tips_chevron"]];
    self.qaChevron.contentMode = UIViewContentModeScaleAspectFit;
    self.qaChevron.transform = CGAffineTransformMakeRotation(M_PI);  // 折叠态默认朝下

    self.qaBodyLabel = [[UILabel alloc] init];
    self.qaBodyLabel.numberOfLines = 0;
    self.qaBodyLabel.attributedText = [self bodyAttributedString:FSTFastingTipsPreviewText];

    [self.qaCard fst_addSubviews:@[bg, title, self.qaChevron, self.qaBodyLabel]];

    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.qaCard).offset(-12);
        make.bottom.equalTo(self.qaCard).offset(-14);
        make.size.mas_equalTo(CGSizeMake(78, 78));
    }];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.qaCard).offset(24);
        make.left.equalTo(self.qaCard).offset(FSTTipsCardInset);
        make.height.mas_equalTo(30);
    }];
    [self.qaChevron mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.qaCard).offset(-FSTTipsCardInset);
        make.centerY.equalTo(title);
        make.size.mas_equalTo(CGSizeMake(14, 8));
    }];
    [self.qaBodyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title.mas_bottom).offset(20);
        make.left.equalTo(self.qaCard).offset(FSTTipsCardInset);
        make.right.equalTo(self.qaCard).offset(-FSTTipsCardInset);
        make.bottom.equalTo(self.qaCard).offset(-24);
    }];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleQATapped)];
    [self.qaCard addGestureRecognizer:tap];
    self.qaExpanded = NO;
}

- (void)handleQATapped {
    self.qaExpanded = !self.qaExpanded;
    self.qaBodyLabel.attributedText = [self bodyAttributedString:self.qaExpanded ? FSTFastingTipsExpandedText : FSTFastingTipsPreviewText];
    [UIView animateWithDuration:0.25 animations:^{
        self.qaChevron.transform = self.qaExpanded ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
        [self layoutIfNeeded];
        [self.superview layoutIfNeeded];
    }];
}

#pragma mark - Public stage configuration

/// 阶段配置数据：bg color / bg icon name (nil 隐藏) / title / body。
/// 三种 stage 用同一张 stageCard，只改这 4 个字段。
- (void)configureForStage:(FSTTipsFastingStage)stage {
    UIColor *bgColor;
    NSString *iconName;
    NSString *title;
    NSString *body;
    switch (stage) {
        case FSTTipsFastingStageDuring:
            bgColor  = [UIColor fst_stageGreen];
            iconName = @"tips_fork_ring_during";
            title    = @"During fasting";
            body     = @"💧 Drink water or herbal tea to stay hydrated.\n🍪 Keep your mind off food.\n🚫 Avoid high-intensity workouts.";
            break;
        case FSTTipsFastingStageAfter:
            bgColor  = [UIColor fst_stageOrange];
            iconName = @"tips_fork_ring_after";
            title    = @"After fasting";
            body     = @"🚫 Avoid overeating.\n🥗 Eat high-protein foods and vegetables.\n🛌 Take a break if you feel unwell.";
            break;
    }
    self.stageCard.backgroundColor = bgColor;
    self.stageBgIcon.hidden = (iconName == nil);
    self.stageBgIcon.image = iconName ? [UIImage imageNamed:iconName] : nil;
    self.stageTitleLabel.attributedText = [self cellTitleAttributedString:title];
    self.stageBodyLabel.attributedText  = [self bodyAttributedString:body];
}

#pragma mark - Helpers

- (NSAttributedString *)cellTitleAttributedString:(NSString *)text {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineHeightMultiple = 1.1;
    return [[NSAttributedString alloc] initWithString:text
                                           attributes:@{NSFontAttributeName: FSTFontAvenirDemiBold(20),
                                                        NSForegroundColorAttributeName: [UIColor fst_textHeading],
                                                        NSParagraphStyleAttributeName: style}];
}

- (NSAttributedString *)lemonBodyAttributedString:(NSString *)text {
    return [self bodyAttributedStringWithText:text font:FSTFontMedium(17) lineSpacing:7];
}

- (NSAttributedString *)bodyAttributedString:(NSString *)text {
    return [self bodyAttributedStringWithText:text font:FSTFontMedium(15) lineSpacing:6];
}

- (NSAttributedString *)bodyAttributedStringWithText:(NSString *)text font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = lineSpacing;
    return [[NSAttributedString alloc] initWithString:text
                                           attributes:@{NSFontAttributeName: font,
                                                        NSForegroundColorAttributeName: [UIColor fst_textTipBody],
                                                        NSParagraphStyleAttributeName: style}];
}

@end
