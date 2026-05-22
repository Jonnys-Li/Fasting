//
//  FSTPlanPrepCardView.m
//  Fasting
//

#import "FSTPlanPrepCardView.h"
#import "FSTTheme.h"

@implementation FSTPlanPrepCardView

- (instancetype)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor fst_planPrepBackground];
        self.layer.cornerRadius = 14;
        [self buildSubviews];
    }
    return self;
}

- (void)buildSubviews {
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"💡 断食准备";
    titleLabel.font = FSTFontBold(18);
    titleLabel.textColor = [UIColor fst_textPrimary];
    titleLabel.textAlignment = NSTextAlignmentCenter;

    UILabel *bodyLabel = [UILabel new];
    bodyLabel.text = @"•  吃足够的蛋白质，比如肉，鱼，豆腐和坚果。\n\n•  吃高纤维食物，比如坚果，豆类，水果和蔬菜。\n\n•  喝大量的水。\n\n•  吃天然的食物来帮助在用餐期间控制食欲。";
    bodyLabel.font = FSTFontBold(16);
    bodyLabel.textColor = [UIColor fst_planPrepBody];
    bodyLabel.numberOfLines = 0;

    [self addSubview:titleLabel];
    [self addSubview:bodyLabel];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(34);
        make.centerX.equalTo(self);
    }];
    [bodyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(30);
        make.left.right.equalTo(self).inset(28);
        make.bottom.equalTo(self).offset(-34);
    }];
}

@end
