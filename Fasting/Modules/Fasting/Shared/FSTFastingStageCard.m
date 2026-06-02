//
//  FSTFastingStageCard.m
//  Fasting
//

#import "FSTFastingStageCard.h"
#import "FSTTheme.h"

static const CGFloat kCardInset = 20;

@interface FSTFastingStageCard ()
@property (nonatomic, strong) UIImageView *bgIcon;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@end

@implementation FSTFastingStageCard

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.layer.cornerRadius = FSTRadiusCard;
        self.layer.masksToBounds = YES;
        [self setupSubviews];
        [self setupConstraints];
        [self configureForStage:FSTTipsFastingStageDuring];
    }
    return self;
}

- (void)setupSubviews {
    self.bgIcon = [[UIImageView alloc] init];
    self.bgIcon.contentMode = UIViewContentModeScaleAspectFit;

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 1;

    self.bodyLabel = [[UILabel alloc] init];
    self.bodyLabel.numberOfLines = 0;

    [self fst_addSubviews:@[self.bgIcon, self.titleLabel, self.bodyLabel]];
}

- (void)setupConstraints {
    [self.bgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-8);
        make.bottom.equalTo(self).offset(-10);
        make.size.mas_equalTo(CGSizeMake(87, 85));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(24);
        make.left.equalTo(self).offset(kCardInset);
        make.right.equalTo(self).offset(-kCardInset);
        make.height.mas_equalTo(30);
    }];
    [self.bodyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(14);
        make.left.equalTo(self).offset(kCardInset);
        make.right.equalTo(self).offset(-kCardInset);
        make.bottom.equalTo(self).offset(-24);
    }];
}

#pragma mark - Public

- (void)configureForStage:(FSTTipsFastingStage)stage {
    UIColor *bgColor;
    NSString *iconName;
    NSString *title;
    NSString *body;
    switch (stage) {
        case FSTTipsFastingStagePrepare:
            bgColor  = [UIColor fst_stageBlue];
            iconName = nil;  // 无独立图（按 Image #3 Prepare 卡视觉）
            title    = @"Prepare for fasting";
            body     = @"🥩 Eat protein-rich foods, such as meat, fish, tofu and nuts.\n"
                       @"🍎 Add fiber and complex carbs from beans, fruits and vegetables.\n"
                       @"💧 Drink plenty of water.\n"
                       @"🥬 Fill yourself with natural foods to control your appetite.";
            break;
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
    self.backgroundColor    = bgColor;
    self.bgIcon.hidden      = (iconName == nil);
    self.bgIcon.image       = iconName ? [UIImage imageNamed:iconName] : nil;
    self.titleLabel.attributedText = [self cellTitleAttributedString:title];
    self.bodyLabel.attributedText  = [self bodyAttributedString:body];
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

- (NSAttributedString *)bodyAttributedString:(NSString *)text {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6;
    return [[NSAttributedString alloc] initWithString:text
                                           attributes:@{NSFontAttributeName: FSTFontMedium(15),
                                                        NSForegroundColorAttributeName: [UIColor fst_textTipBody],
                                                        NSParagraphStyleAttributeName: style}];
}

@end
