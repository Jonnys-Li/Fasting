//
//  FSTPlanPrepCardView.m
//  Fasting

#import "FSTPlanPrepCardView.h"
#import "FSTTheme.h"

@implementation FSTPlanPrepCardView

- (instancetype)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor fst_stageBlue];
        self.layer.cornerRadius = FSTRadiusCard;
        [self buildSubviews];
    }
    return self;
}

- (void)buildSubviews {
    UILabel *titleLabel = [[UILabel alloc] init];
    NSMutableParagraphStyle *titleStyle = [[NSMutableParagraphStyle alloc] init];
    titleStyle.lineHeightMultiple = 1.1;
    titleLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Prepare for fasting"
                                                               attributes:@{
        NSFontAttributeName: FSTFontAvenirDemiBold(20),
        NSForegroundColorAttributeName: [UIColor fst_textHeading],
        NSParagraphStyleAttributeName: titleStyle,
    }];

    UILabel *bodyLabel = [[UILabel alloc] init];
    bodyLabel.numberOfLines = 0;
    NSMutableParagraphStyle *bodyStyle = [[NSMutableParagraphStyle alloc] init];
    bodyStyle.lineSpacing = 6;
    bodyLabel.attributedText = [[NSAttributedString alloc] initWithString:
        @"\U0001F969 Eat protein-rich foods, such as meat, fish, tofu and nuts.\n"
        @"\U0001F34E Add fiber and complex carbs from beans, fruits and vegetables.\n"
        @"\U0001F4A7 Drink plenty of water.\n"
        @"\U0001F96C Fill yourself with natural foods to control your appetite."
                                                              attributes:@{
        NSFontAttributeName: FSTFontMedium(15),
        NSForegroundColorAttributeName: [UIColor fst_textTipBody],
        NSParagraphStyleAttributeName: bodyStyle,
    }];

    [self addSubview:titleLabel];
    [self addSubview:bodyLabel];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(24);
        make.left.right.equalTo(self).inset(20);
        make.height.mas_equalTo(30);
    }];
    [bodyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(14);
        make.left.right.equalTo(self).inset(20);
        make.bottom.equalTo(self).offset(-24);
    }];
}

@end
