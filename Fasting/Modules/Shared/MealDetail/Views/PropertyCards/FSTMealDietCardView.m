//
//  FSTMealDietCardView.m
//  Fasting
//

#import "FSTMealDietCardView.h"
#import "FSTMealPropertyCardSelection.h"
#import "FSTTheme.h"

@interface FSTMealDietCardView ()
@property (nonatomic, strong) NSArray<UIControl *> *dietRows;
@end

@implementation FSTMealDietCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _dietType = FSTDietTypeNotSure;
        [self fst_applyMealCardStyle];
        [self setupSubviews];
        [self refresh];
    }
    return self;
}

- (void)setDietType:(FSTDietType)dietType {
    _dietType = dietType; [self refresh];
}

- (void)setupSubviews {
    UILabel *titleLabel = [UILabel fst_labelWithText:@"Diet Type" font:FSTFontTitle() color:[UIColor fst_textPrimary]];
    [self addSubview:titleLabel];

    UIStackView *rowsStack = [[UIStackView alloc] init];
    rowsStack.axis = UILayoutConstraintAxisVertical;
    rowsStack.spacing = 12;
    [self addSubview:rowsStack];

    // 行顺序 == FSTDietType rawValue 顺序；emoji / subtitle 是本卡片私有展示描述，标题走 FSTDietTypeDisplayName。
    NSArray *itemDescriptors = @[
        @[@"🥑", @"High fat, moderate protein, very low carbs"],
        @[@"🥩", @"High protein and fat, low carbs"],
        @[@"🍱", @"Balanced carbs, protein and fat"],
        @[@"🍕", @"High carbs, moderate protein, low fat"],
        @[@"🍪", @""],
    ];
    NSMutableArray *collectedRows = [NSMutableArray array];
    for (NSInteger index = 0; index < itemDescriptors.count; index++) {
        UIControl *row = [self rowWithIcon:itemDescriptors[index][0]
                                     title:FSTDietTypeDisplayName((FSTDietType)index)
                                  subtitle:itemDescriptors[index][1]
                                       tag:index];
        [rowsStack addArrangedSubview:row];
        [collectedRows addObject:row];
    }
    self.dietRows = collectedRows;

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(28);
        make.left.equalTo(self).offset(26);
    }];
    [rowsStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(22);
        make.left.right.equalTo(self).inset(18);
        make.bottom.equalTo(self).offset(-26);
    }];
}

- (UIControl *)rowWithIcon:(NSString *)icon title:(NSString *)title subtitle:(NSString *)subtitle tag:(NSInteger)tag {
    UIControl *row = [[UIControl alloc] init];
    row.tag = tag;
    row.backgroundColor = [UIColor fst_inputBackground];
    row.layer.cornerRadius = FSTRadiusM;
    [row addTarget:self action:@selector(handleRowTapped:) forControlEvents:UIControlEventTouchUpInside];
    [row mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@74);
    }];

    UILabel *iconLabel = [UILabel fst_labelWithText:icon font:FSTFontRegular(32) color:[UIColor blackColor]];
    UILabel *titleLabel = [UILabel fst_labelWithText:title font:FSTFontBold(17) color:[UIColor fst_textPrimary]];
    UILabel *subtitleLabel = [UILabel fst_labelWithText:subtitle font:FSTFontRegular(14) color:[UIColor fst_textSecondary]];
    [row fst_addSubviews:@[iconLabel, titleLabel, subtitleLabel]];

    [iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(row).offset(18);
        make.centerY.equalTo(row);
        make.width.equalTo(@42);
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(iconLabel.mas_right).offset(18);
        make.top.equalTo(row).offset(14);
    }];
    [subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel);
        make.right.equalTo(row).offset(-16);
        make.top.equalTo(titleLabel.mas_bottom).offset(4);
    }];
    return row;
}

- (void)refresh {
    for (UIControl *row in self.dietRows) {
        FSTApplyMealCardSelectionStyle(row, row.tag == self.dietType);
    }
}

- (void)handleRowTapped:(UIControl *)row {
    self.dietType = row.tag;
}

@end
