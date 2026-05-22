//
//  FSTPlanTagChipsBar.m
//  Fasting
//

#import "FSTPlanTagChipsBar.h"
#import "FSTTheme.h"

static NSString *const FSTChipDefaultSelected = @"Daily plan";

@interface FSTPlanTagChipsBar ()
@property (nonatomic, strong) NSMutableArray<UIButton *> *allChips;
@end

@implementation FSTPlanTagChipsBar

- (instancetype)init {
    if ((self = [super init])) {
        _allChips = [NSMutableArray array];
        [self buildSubviews];
    }
    return self;
}

- (void)buildSubviews {
    NSArray<NSString *> *row1Titles = @[@"All", @"7 days plan", @"28 days plan", @"Advanced plans"];
    NSArray<NSString *> *row2Titles = @[@"Popular plans", @"Daily plan", @"Custom"];

    UIScrollView *row1 = [self buildRowWithTitles:row1Titles];
    UIScrollView *row2 = [self buildRowWithTitles:row2Titles];
    [self addSubview:row1];
    [self addSubview:row2];

    [row1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(32);
    }];
    [row2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(row1.mas_bottom).offset(10);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(32);
        make.bottom.equalTo(self);
    }];

    [self applySelectionToTitle:FSTChipDefaultSelected];
}

- (UIScrollView *)buildRowWithTitles:(NSArray<NSString *> *)titles {
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentInset = UIEdgeInsetsMake(0, 22, 0, 22);

    UIStackView *stack = [UIStackView new];
    stack.axis = UILayoutConstraintAxisHorizontal;
    stack.spacing = 8;
    stack.alignment = UIStackViewAlignmentCenter;
    [scrollView addSubview:stack];

    for (NSString *title in titles) {
        UIButton *chip = [self chipButtonWithTitle:title];
        [stack addArrangedSubview:chip];
        [self.allChips addObject:chip];
    }

    [stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        make.height.equalTo(scrollView);
    }];
    return scrollView;
}

- (UIButton *)chipButtonWithTitle:(NSString *)title {
    UIButton *chip = [UIButton buttonWithType:UIButtonTypeCustom];
    [chip setTitle:title forState:UIControlStateNormal];
    chip.titleLabel.font = FSTFontMedium(13);
    chip.contentEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 14);
    chip.layer.cornerRadius = 16;
    chip.layer.masksToBounds = YES;
    [chip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(32);
    }];
    [chip addTarget:self action:@selector(handleChipTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self applyUnselectedStyle:chip];
    return chip;
}

- (void)applyUnselectedStyle:(UIButton *)chip {
    chip.backgroundColor = [UIColor fst_chipBackground];
    chip.layer.borderWidth = 0;
    [chip setTitleColor:[UIColor fst_textHeading] forState:UIControlStateNormal];
}

- (void)applySelectedStyle:(UIButton *)chip {
    chip.backgroundColor = [UIColor whiteColor];
    chip.layer.borderWidth = 1.5;
    chip.layer.borderColor = [UIColor fst_eatingTimeGreen].CGColor;
    [chip setTitleColor:[UIColor fst_textHeading] forState:UIControlStateNormal];
}

- (void)applySelectionToTitle:(NSString *)title {
    for (UIButton *chip in self.allChips) {
        if ([chip.currentTitle isEqualToString:title]) {
            [self applySelectedStyle:chip];
        } else {
            [self applyUnselectedStyle:chip];
        }
    }
}

- (void)handleChipTapped:(UIButton *)sender {
    [self applySelectionToTitle:sender.currentTitle];
    if (self.onChipTapped) {
        self.onChipTapped(sender.currentTitle);
    }
}

@end
