//
//  FSTPlanSelectListView.m
//  Fasting
//

#import "FSTPlanSelectListView.h"
#import "FSTTheme.h"

#import <Masonry/Masonry.h>

static NSString *const FSTPlanSelectPlanCellReuseIdentifier = @"FSTPlanSelectPlanCell";
static const CGFloat FSTPlanSelectCellImageAspect = 179.0 / 335.0;
static const CGFloat FSTPlanSelectCellSpacing = 16.0;

@interface FSTPlanSelectPlanCell : UITableViewCell
@property (nonatomic, strong) UIImageView *planImageView;
- (void)configureWithImageName:(NSString *)imageName;
@end

@implementation FSTPlanSelectPlanCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = UIColor.clearColor;
        self.contentView.backgroundColor = UIColor.clearColor;

        _planImageView = [[UIImageView alloc] init];
        _planImageView.contentMode = UIViewContentModeScaleAspectFit;
        _planImageView.clipsToBounds = YES;
        [self.contentView addSubview:_planImageView];

        [_planImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.contentView);
            make.height.equalTo(_planImageView.mas_width).multipliedBy(FSTPlanSelectCellImageAspect);
        }];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.planImageView.image = nil;
}

- (void)configureWithImageName:(NSString *)imageName {
    self.planImageView.image = [UIImage fst_originalImageNamed:imageName];
}

@end

@interface FSTPlanSelectListView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<FSTPlan *> *plans;
@property (nonatomic, copy) NSArray<NSString *> *assetNames;
@property (nonatomic, assign) CGFloat lastLaidOutWidth;
@end

@implementation FSTPlanSelectListView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _plans = [FSTPlan defaultDailyPlans];
        _assetNames = @[
            @"plan_select_14_10_cell",
            @"plan_select_16_8_cell",
            @"plan_select_18_6_cell",
            @"plan_select_20_4_cell",
        ];
        [self buildSubviews];
    }
    return self;
}

- (void)buildSubviews {
    self.backgroundColor = UIColor.clearColor;

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.scrollEnabled = NO;
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:FSTPlanSelectPlanCell.class forCellReuseIdentifier:FSTPlanSelectPlanCellReuseIdentifier];
    [self addSubview:self.tableView];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.tableView.bounds);
    if (fabs(width - self.lastLaidOutWidth) > 0.5) {
        self.lastLaidOutWidth = width;
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MIN(self.plans.count, self.assetNames.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FSTPlanSelectPlanCell *cell = [tableView dequeueReusableCellWithIdentifier:FSTPlanSelectPlanCellReuseIdentifier forIndexPath:indexPath];
    [cell configureWithImageName:self.assetNames[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(tableView.bounds);
    if (width <= 0) width = 335.0;
    CGFloat imageHeight = width * FSTPlanSelectCellImageAspect;
    BOOL isLastRow = (indexPath.row == MIN(self.plans.count, self.assetNames.count) - 1);
    return imageHeight + (isLastRow ? 0 : FSTPlanSelectCellSpacing);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row >= self.plans.count) return;
    if (self.onPlanPicked) self.onPlanPicked(self.plans[indexPath.row]);
}

@end
