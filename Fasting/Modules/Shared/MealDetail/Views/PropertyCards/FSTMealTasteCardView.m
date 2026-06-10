//
//  FSTMealTasteCardView.m
//  Fasting
//

#import "FSTMealTasteCardView.h"
#import "FSTMealPropertyCardSelection.h"
#import "FSTTheme.h"

@interface FSTMealTasteCardView ()
@property (nonatomic, strong) NSArray<UIControl *> *tasteButtons;
@end

@implementation FSTMealTasteCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _tasteLevel = 1;
        [self fst_applyMealCardStyle];
        [self setupSubviews];
        [self refresh];
    }
    return self;
}

- (void)setTasteLevel:(NSInteger)tasteLevel {
    _tasteLevel = tasteLevel; [self refresh];
}

- (void)setupSubviews {
    UILabel *titleLabel = [UILabel fst_labelWithText:@"How was the food?" font:FSTFontTitle() color:[UIColor fst_textPrimary]];
    [self addSubview:titleLabel];

    UIStackView *buttonsStack = [[UIStackView alloc] init];
    buttonsStack.axis = UILayoutConstraintAxisHorizontal;
    buttonsStack.distribution = UIStackViewDistributionFillEqually;
    [self addSubview:buttonsStack];

    NSMutableArray *collectedButtons = [NSMutableArray array];
    NSArray *itemDescriptors = @[@[@"tl_rating_hard", @"Bad"], @[@"tl_rating_ok", @"OK"], @[@"tl_rating_easy", @"Delicious"]];
    for (NSInteger index = 0; index < itemDescriptors.count; index++) {
        UIControl *button = [self faceButtonWithImageName:itemDescriptors[index][0] title:itemDescriptors[index][1] tag:index];
        [buttonsStack addArrangedSubview:button];
        [collectedButtons addObject:button];
    }
    self.tasteButtons = collectedButtons;

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(28);
        make.left.equalTo(self).offset(26);
    }];
    [buttonsStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(30);
        make.left.right.equalTo(self).inset(20);
        make.height.equalTo(@108);
        make.bottom.equalTo(self).offset(-28);
    }];
}

- (UIControl *)faceButtonWithImageName:(NSString *)imageName title:(NSString *)title tag:(NSInteger)tag {
    UIControl *button = [[UIControl alloc] init];
    button.tag = tag;
    button.layer.cornerRadius = 16;
    [button addTarget:self action:@selector(handleTasteTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIImageView *faceImageView = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:imageName]];
    faceImageView.contentMode = UIViewContentModeScaleAspectFit;
    [button addSubview:faceImageView];

    UILabel *titleLabel = [UILabel fst_labelWithText:title font:FSTFontBold(17) color:[UIColor fst_textSecondary]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [button addSubview:titleLabel];

    [faceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button);
        make.centerX.equalTo(button);
        make.size.mas_equalTo(CGSizeMake(56, 56));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(faceImageView.mas_bottom).offset(14);
        make.left.right.equalTo(button);
    }];
    return button;
}

- (void)refresh {
    for (UIControl *button in self.tasteButtons) {
        FSTApplyMealCardSelectionStyle(button, button.tag == self.tasteLevel);
    }
}

- (void)handleTasteTapped:(UIControl *)button {
    self.tasteLevel = button.tag;
}

@end
