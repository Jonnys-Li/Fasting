//
//  FSTMealSlotCardView.m
//  Fasting
//

#import "FSTMealSlotCardView.h"
#import "FSTTheme.h"

@interface FSTMealSlotCardView ()
@property (nonatomic, strong) NSArray<UIControl *> *categoryTiles;
@end

@implementation FSTMealSlotCardView

- (instancetype)init {
    if ((self = [super init])) {
        _mealCategory = @"正餐";
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 20;
        self.layer.borderWidth = 1.2;
        self.layer.borderColor = [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.22].CGColor;
        [self buildSubviews];
        [self refresh];
    }
    return self;
}

- (void)setMealCategory:(NSString *)mealCategory { _mealCategory = [mealCategory copy]; [self refresh]; }

- (void)buildSubviews {
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"正餐/零食";
    titleLabel.font = FSTFontBold(22);
    titleLabel.textColor = [UIColor fst_textPrimary];
    [self addSubview:titleLabel];

    UIStackView *tilesStack = [UIStackView new];
    tilesStack.axis = UILayoutConstraintAxisHorizontal;
    tilesStack.distribution = UIStackViewDistributionFillEqually;
    tilesStack.spacing = 28;
    [self addSubview:tilesStack];

    UIControl *mealTile = [self tileWithEmoji:@"🍽️" title:@"正餐" tag:0];
    UIControl *snackTile = [self tileWithEmoji:@"🍎" title:@"零食" tag:1];
    [tilesStack addArrangedSubview:mealTile];
    [tilesStack addArrangedSubview:snackTile];
    self.categoryTiles = @[mealTile, snackTile];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(28);
        make.left.equalTo(self).offset(26);
    }];
    [tilesStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(26);
        make.left.right.equalTo(self).inset(26);
        make.height.equalTo(@132);
        make.bottom.equalTo(self).offset(-28);
    }];
}

/// 单个 emoji + 标题方块。
- (UIControl *)tileWithEmoji:(NSString *)emoji title:(NSString *)title tag:(NSInteger)tag {
    UIControl *tile = [UIControl new];
    tile.tag = tag;
    tile.layer.cornerRadius = 16;
    tile.layer.borderWidth = 1.3;
    tile.layer.borderColor = [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.35].CGColor;
    [tile addTarget:self action:@selector(handleTileTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIView *iconBox = [UIView new];
    iconBox.backgroundColor = [UIColor fst_mealSlotIconBackground];
    iconBox.layer.cornerRadius = 14;
    [tile addSubview:iconBox];

    UILabel *iconLabel = [UILabel new];
    iconLabel.text = emoji;
    iconLabel.font = [UIFont systemFontOfSize:42];
    iconLabel.textAlignment = NSTextAlignmentCenter;
    [iconBox addSubview:iconLabel];

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = title;
    titleLabel.font = FSTFontBold(19);
    titleLabel.textColor = [UIColor fst_textPrimary];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [tile addSubview:titleLabel];

    [iconBox mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(tile);
        make.height.equalTo(@86);
    }];
    [iconLabel mas_makeConstraints:^(MASConstraintMaker *make) { make.center.equalTo(iconBox); }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(iconBox.mas_bottom).offset(14);
        make.left.right.equalTo(tile);
    }];
    return tile;
}

- (void)refresh {
    for (UIControl *tile in self.categoryTiles) {
        BOOL isSelected = (tile.tag == 0 && [self.mealCategory isEqualToString:@"正餐"]) || (tile.tag == 1 && [self.mealCategory isEqualToString:@"零食"]);
        tile.alpha = isSelected ? 1.0 : 0.45;
        tile.layer.borderColor = (isSelected ? [UIColor fst_primaryGreen] : [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.35]).CGColor;
        tile.layer.borderWidth = isSelected ? 2.0 : 1.3;
    }
}

- (void)handleTileTapped:(UIControl *)tile {
    self.mealCategory = tile.tag == 0 ? @"正餐" : @"零食";
}

@end
