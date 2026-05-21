//
//  FSTMealTasteCardView.m
//  Fasting
//

#import "FSTMealTasteCardView.h"
#import "FSTTheme.h"

@interface FSTMealTasteCardView ()
@property (nonatomic, strong) NSArray<UIControl *> *tasteButtons;
@end

@implementation FSTMealTasteCardView

- (instancetype)init {
    if ((self = [super init])) {
        _tasteLevel = 1;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 20;
        self.layer.borderWidth = 1.2;
        self.layer.borderColor = [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.22].CGColor;
        [self buildSubviews];
        [self refresh];
    }
    return self;
}

- (void)setTasteLevel:(NSInteger)tasteLevel { _tasteLevel = tasteLevel; [self refresh]; }

- (void)buildSubviews {
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"食物的味道";
    titleLabel.font = FSTFontBold(22);
    titleLabel.textColor = [UIColor fst_textPrimary];
    titleLabel.userInteractionEnabled = NO;
    [self addSubview:titleLabel];

    UIStackView *buttonsStack = [UIStackView new];
    buttonsStack.axis = UILayoutConstraintAxisHorizontal;
    buttonsStack.distribution = UIStackViewDistributionFillEqually;
    [self addSubview:buttonsStack];

    NSMutableArray *collectedButtons = [NSMutableArray array];
    NSArray *itemDescriptors = @[@[@"tl_rating_hard", @"糟糕"], @[@"tl_rating_ok", @"还可以"], @[@"tl_rating_easy", @"美味"]];
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
    UIControl *button = [UIControl new];
    button.tag = tag;
    button.layer.cornerRadius = 16;
    button.layer.borderWidth = 1.2;
    button.layer.borderColor = [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.28].CGColor;
    [button addTarget:self action:@selector(handleTasteTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIImageView *faceImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    faceImageView.contentMode = UIViewContentModeScaleAspectFit;
    faceImageView.userInteractionEnabled = NO;
    [button addSubview:faceImageView];

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = title;
    titleLabel.font = FSTFontBold(17);
    titleLabel.textColor = [UIColor fst_textSecondary];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.userInteractionEnabled = NO;
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
        BOOL isSelected = button.tag == self.tasteLevel;
        button.alpha = isSelected ? 1.0 : 0.45;
        button.layer.borderColor = (isSelected ? [UIColor fst_primaryGreen] : [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.28]).CGColor;
        button.layer.borderWidth = isSelected ? 1.8 : 1.2;
    }
}

- (void)handleTasteTapped:(UIControl *)button { self.tasteLevel = button.tag; }

@end
