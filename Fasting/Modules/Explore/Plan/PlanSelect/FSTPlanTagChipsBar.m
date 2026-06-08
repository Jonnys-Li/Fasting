//
//  FSTPlanTagChipsBar.m
//  Fasting
//

#import "FSTPlanTagChipsBar.h"
#import "FSTTheme.h"

// 默认选中 "Daily plan"：第 1 行（0-based）第 1 个 chip。用位置定位，不拿 title 判断（R9）。
static const NSUInteger FSTChipDefaultRowIndex    = 1;
static const NSUInteger FSTChipDefaultColumnIndex = 1;

@interface FSTPlanTagChipsBar ()
@property (nonatomic, copy) NSArray<NSArray<NSString *> *> *rowTitles;
@property (nonatomic, strong) NSMutableArray<UIButton *> *allChips;
@end

@implementation FSTPlanTagChipsBar

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self prepareData];          // 数据
        [self setupSubviews];        // 子视图
        [self applyDefaultSelection];// 首次刷新
    }
    return self;
}

#pragma mark - 数据

- (void)prepareData {
    self.allChips = [NSMutableArray array];
    self.rowTitles = @[
        @[@"All", @"7 days plan", @"28 days plan", @"Advanced plans"],
        @[@"Popular plans", @"Daily plan", @"Custom"],
    ];
}

#pragma mark - 子视图

- (void)setupSubviews {
    UIScrollView *row1 = [self buildRowWithTitles:self.rowTitles[0]];
    UIScrollView *row2 = [self buildRowWithTitles:self.rowTitles[1]];
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
}

- (UIScrollView *)buildRowWithTitles:(NSArray<NSString *> *)titles {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentInset = UIEdgeInsetsMake(0, 22, 0, 22);

    UIStackView *stack = [[UIStackView alloc] init];
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
    return chip;
}

#pragma mark - 选中态（使用 UIButton.selected 状态，不依赖 title — R9）

- (void)applyDefaultSelection {
    [self selectChip:[self defaultChip]];
}

- (nullable UIButton *)defaultChip {
    if (FSTChipDefaultRowIndex >= self.rowTitles.count) return nil;

    NSArray<NSString *> *targetRow = self.rowTitles[FSTChipDefaultRowIndex];
    if (FSTChipDefaultColumnIndex >= targetRow.count) return nil;

    NSUInteger flatIndex = FSTChipDefaultColumnIndex;
    for (NSUInteger row = 0; row < FSTChipDefaultRowIndex; row++) {
        flatIndex += self.rowTitles[row].count;
    }

    return flatIndex < self.allChips.count ? self.allChips[flatIndex] : nil;
}

- (void)selectChip:(nullable UIButton *)chip {
    for (UIButton *aChip in self.allChips) {
        aChip.selected = (aChip == chip);
        [self applyStyleForChip:aChip];
    }
}

- (void)applyStyleForChip:(UIButton *)chip {
    chip.backgroundColor = chip.selected ? [UIColor whiteColor] : [UIColor fst_chipBackground];
    chip.layer.borderWidth = chip.selected ? 1.5 : 0;
    chip.layer.borderColor = chip.selected ? [UIColor fst_eatingTimeGreen].CGColor : nil;
    [chip setTitleColor:[UIColor fst_textHeading] forState:UIControlStateNormal];
}
#pragma mark - 事件

- (void)handleChipTapped:(UIButton *)sender {
    [self selectChip:sender];

    if (self.onChipTapped) {
        self.onChipTapped(sender.currentTitle);
    }
}
@end
