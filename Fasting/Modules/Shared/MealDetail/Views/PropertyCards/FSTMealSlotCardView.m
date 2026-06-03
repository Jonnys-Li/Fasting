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

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _mealCategory = @"Meal";
        [self fst_applyMealCardStyle];
        [self buildSubviews];
        [self refresh];
    }
    return self;
}

- (void)setMealCategory:(NSString *)mealCategory { _mealCategory = [mealCategory copy]; [self refresh]; }

- (void)buildSubviews {
    UILabel *titleLabel = [UILabel fst_labelWithText:@"Meal/Snack" font:FSTFontTitle() color:[UIColor fst_textPrimary]];
    [self addSubview:titleLabel];

    UIStackView *tilesStack = [[UIStackView alloc] init];
    tilesStack.axis = UILayoutConstraintAxisHorizontal;
    tilesStack.distribution = UIStackViewDistributionFillEqually;
    tilesStack.spacing = 28;
    [self addSubview:tilesStack];

    UIControl *mealTile = [self tileWithEmoji:@"🍽️" title:@"Meal" tag:0];
    UIControl *snackTile = [self tileWithEmoji:@"🍎" title:@"Snack" tag:1];
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
    UIControl *tile = [[UIControl alloc] init];
    tile.tag = tag;
    tile.layer.cornerRadius = 16;
    tile.layer.borderWidth = 1.3;
    tile.layer.borderColor = [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.35].CGColor;
    [tile addTarget:self action:@selector(handleTileTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIView *iconBox = [[UIView alloc] init];
    iconBox.backgroundColor = [UIColor fst_mealSlotIconBackground];
    iconBox.layer.cornerRadius = FSTRadiusM;
    iconBox.userInteractionEnabled = NO;
    [tile addSubview:iconBox];

    UILabel *iconLabel = [UILabel fst_labelWithText:emoji font:FSTFontRegular(42) color:[UIColor blackColor] alignment:NSTextAlignmentCenter];
    [iconBox addSubview:iconLabel];

    UILabel *titleLabel = [UILabel fst_labelWithText:title font:FSTFontBold(19) color:[UIColor fst_textPrimary] alignment:NSTextAlignmentCenter];
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
        BOOL isSelected = (tile.tag == 0 && [self.mealCategory isEqualToString:@"Meal"]) || (tile.tag == 1 && [self.mealCategory isEqualToString:@"Snack"]);
        tile.alpha = isSelected ? 1.0 : 0.45;
        tile.layer.borderColor = (isSelected ? [UIColor fst_primaryGreen] : [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.35]).CGColor;
        tile.layer.borderWidth = isSelected ? 2.0 : 1.3;
    }
}

- (void)handleTileTapped:(UIControl *)tile {
    self.mealCategory = tile.tag == 0 ? @"Meal" : @"Snack";
}

@end
