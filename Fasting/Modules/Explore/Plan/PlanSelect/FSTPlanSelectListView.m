//
//  FSTPlanSelectListView.m
//  Fasting
//

#import "FSTPlanSelectListView.h"
#import "FSTTheme.h"

#import <Masonry/Masonry.h>

static const CGFloat FSTPlanSelectCellImageAspect = 179.0 / 335.0;
static const CGFloat FSTPlanSelectCellSpacing = 16.0;

@interface FSTPlanSelectListView ()
@property (nonatomic, strong) NSArray<FSTPlan *> *plans;
@property (nonatomic, copy) NSArray<NSString *> *assetNames;
@end

@implementation FSTPlanSelectListView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self prepareData];
        [self setupSubviews];
    }
    return self;
}

#pragma mark - 数据

- (void)prepareData {
    _plans = [FSTPlan defaultDailyPlans];
    _assetNames = @[
        @"plan_select_14_10_cell",
        @"plan_select_16_8_cell",
        @"plan_select_18_6_cell",
        @"plan_select_20_4_cell",
    ];
}

#pragma mark - 子视图

// 静态 4 张方案卡用竖直 stack 承载，不再套 UITableView——避免与外层 scrollView 嵌套滚动（R12），
// 行高用图片宽高比约束表达，无需 layoutSubviews 手动 reload（R8）。
- (void)setupSubviews {
    self.backgroundColor = UIColor.clearColor;

    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = FSTPlanSelectCellSpacing;
    stack.alignment = UIStackViewAlignmentFill;
    stack.distribution = UIStackViewDistributionFill;
    [self addSubview:stack];
    [stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    NSUInteger count = MIN(self.plans.count, self.assetNames.count);
    for (NSUInteger index = 0; index < count; index++) {
        [stack addArrangedSubview:[self planRowAtIndex:index]];
    }
}

- (UIControl *)planRowAtIndex:(NSUInteger)index {
    UIControl *row = [[UIControl alloc] init];
    row.tag = (NSInteger)index;
    [row addTarget:self action:@selector(handleRowTapped:) forControlEvents:UIControlEventTouchUpInside];

    // 图片资源自带圆角，contentMode 为 AspectFit 不会溢出，不需要 clipsToBounds（R11）。
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage fst_originalImageNamed:self.assetNames[index]];
    [row addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(row);
        make.height.equalTo(imageView.mas_width).multipliedBy(FSTPlanSelectCellImageAspect);
    }];
    return row;
}

#pragma mark - 事件

- (void)handleRowTapped:(UIControl *)sender {
    NSUInteger index = (NSUInteger)sender.tag;
    if (index >= self.plans.count) return;
    if (self.onPlanPicked) self.onPlanPicked(self.plans[index]);
}

@end
