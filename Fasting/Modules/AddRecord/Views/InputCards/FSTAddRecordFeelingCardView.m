//
//  FSTAddRecordFeelingCardView.m
//  Fasting
//

#import "FSTAddRecordFeelingCardView.h"
#import "FSTTheme.h"
#import "UIImage+FSTHelpers.h"

@interface FSTAddRecordFeelingCardView ()
@property (nonatomic, strong) NSArray<UIControl *> *feelingButtons;
@end

@implementation FSTAddRecordFeelingCardView

- (instancetype)init {
    if ((self = [super init])) {
        _feelingLevel = 1;
        [self buildSubviews];
        [self refreshSelection];
    }
    return self;
}

- (void)setFeelingLevel:(NSInteger)level {
    _feelingLevel = level;
    [self refreshSelection];
}

/// 构建：标题 + 3 个等宽感受按钮的水平 stack。
- (void)buildSubviews {
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"How did it feel?";
    titleLabel.font = FSTFontSubhead();
    titleLabel.textColor = [UIColor fst_textPrimary];
    [self addSubview:titleLabel];

    UIStackView *buttonsStack = [UIStackView new];
    buttonsStack.axis = UILayoutConstraintAxisHorizontal;
    buttonsStack.distribution = UIStackViewDistributionFillEqually;
    buttonsStack.spacing = 8;
    [self addSubview:buttonsStack];

    NSMutableArray *collectedButtons = [NSMutableArray array];
    NSArray *items = @[@[@"tl_rating_hard", @"Hard"], @[@"tl_rating_ok", @"OK"], @[@"tl_rating_easy", @"Easy"]];
    for (NSInteger index = 0; index < items.count; index++) {
        UIControl *button = [self feelingButtonWithImageName:items[index][0] title:items[index][1] index:index];
        [buttonsStack addArrangedSubview:button];
        [collectedButtons addObject:button];
    }
    self.feelingButtons = collectedButtons;

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(28);
        make.centerX.equalTo(self);
    }];
    [buttonsStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(30);
        make.left.right.equalTo(self).inset(22);
        make.height.equalTo(@96);
        make.bottom.equalTo(self).offset(-28);
    }];
}

- (UIControl *)feelingButtonWithImageName:(NSString *)imageName title:(NSString *)title index:(NSInteger)index {
    UIControl *button = [UIControl new];
    button.tag = index;
    [button addTarget:self action:@selector(handleFeelingTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIImageView *feelingImageView = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:imageName]];
    feelingImageView.contentMode = UIViewContentModeScaleAspectFit;
    [button addSubview:feelingImageView];

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = title;
    titleLabel.font = FSTFontBold(16);
    titleLabel.textColor = [UIColor fst_textSecondary];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [button addSubview:titleLabel];

    [feelingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button);
        make.centerX.equalTo(button);
        make.size.mas_equalTo(CGSizeMake(54, 54));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(feelingImageView.mas_bottom).offset(16);
        make.left.right.equalTo(button);
    }];
    return button;
}

- (void)refreshSelection {
    for (UIControl *button in self.feelingButtons) {
        button.alpha = button.tag == self.feelingLevel ? 1.0 : 0.38;
    }
}

- (void)handleFeelingTapped:(UIControl *)sender {
    self.feelingLevel = sender.tag;
}

@end
