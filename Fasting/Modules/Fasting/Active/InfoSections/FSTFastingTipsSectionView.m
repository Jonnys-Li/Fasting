//
//  FSTFastingTipsSectionView.m
//  Fasting
//

#import "FSTFastingTipsSectionView.h"
#import "FSTFastingStageCard.h"
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
// Sub-cards（compact 切换需要 lemonCard 作 stageCard.top 锚点）。
@property (nonatomic, strong) UIView *lemonCard;
@property (nonatomic, strong) FSTFastingStageCard *stageCard;
// Fasting tips card 折叠状态
@property (nonatomic, strong) UIView *qaCard;
@property (nonatomic, strong) UIImageView *qaChevron;
@property (nonatomic, strong) UILabel *qaBodyLabel;
@property (nonatomic, assign) BOOL qaExpanded;
@end

@implementation FSTFastingTipsSectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = FSTRadiusL;
        self.layer.masksToBounds = YES;
        [self setupSubviews];
        [self configureForStage:FSTTipsFastingStageDuring];
    }
    return self;
}

- (void)setupSubviews {
    UIView *header     = [self buildSectionHeader];
    self.lemonCard     = [self buildLemonCard];
    self.stageCard     = [[FSTFastingStageCard alloc] init];
    [self buildQACard];     // 内部自赋 self.qaCard / qaChevron / qaBodyLabel
    [self fst_addSubviews:@[header, self.lemonCard, self.stageCard, self.qaCard]];

    [header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(FSTTipsSectionVInset);
        make.left.equalTo(self).offset(FSTTipsSectionHInset);
        make.right.equalTo(self).offset(-FSTTipsSectionHInset);
        make.height.mas_equalTo(28);
    }];
    [self pinCard:self.lemonCard belowAnchor:header.mas_bottom];
    // stageCard 与 qaCard 的约束由 -applyConstraintsForCompact: 统一管理（支持 compact 双向切换）。
    [self applyConstraintsForCompact:NO];
}

- (void)applyConstraintsForCompact:(BOOL)compact {
    [self.stageCard mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lemonCard.mas_bottom).offset(18);
        make.left.equalTo(self).offset(FSTTipsSectionHInset);
        make.right.equalTo(self).offset(-FSTTipsSectionHInset);
        if (compact) make.bottom.equalTo(self).offset(-FSTTipsSectionVInset);
    }];
    [self.qaCard mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(FSTTipsSectionHInset);
        make.right.equalTo(self).offset(-FSTTipsSectionHInset);
        if (compact) {
            make.top.equalTo(self.stageCard.mas_bottom);
            make.height.mas_equalTo(0);
        } else {
            make.top.equalTo(self.stageCard.mas_bottom).offset(18);
            make.bottom.equalTo(self).offset(-FSTTipsSectionVInset);
        }
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
    title.numberOfLines = 0;

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

#pragma mark - QA (Fasting tips) card

- (void)buildQACard {
    self.qaCard = [UIView fst_containerWithBackground:[UIColor fst_stageBlue] radius:FSTRadiusCard];
    self.qaCard.layer.masksToBounds = YES;

    UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tips_question_bg"]];
    bg.contentMode = UIViewContentModeScaleAspectFit;

    UILabel *title = [[UILabel alloc] init];
    title.attributedText = [self cellTitleAttributedString:@"Fasting tips"];
    title.numberOfLines = 0;

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
        // 在同一动画上下文中调 onExpansionChanged，让 RootView 同步改 contentOffset，
        // "展开 + 滚动"视觉同步（一步动作，不是先展开再滚屏）。
        if (self.onExpansionChanged) self.onExpansionChanged(self.qaExpanded);
    }];
}

#pragma mark - Public stage configuration

/// 透传到内嵌 stageCard。
- (void)configureForStage:(FSTTipsFastingStage)stage {
    [self.stageCard configureForStage:stage];
}

#pragma mark - Compact mode

- (void)setCompact:(BOOL)compact {
    if (_compact == compact) return;
    _compact = compact;
    self.qaCard.hidden = compact;
    [self applyConstraintsForCompact:compact];
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
