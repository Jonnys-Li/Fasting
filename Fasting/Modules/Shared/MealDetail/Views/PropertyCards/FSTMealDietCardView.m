//
//  FSTMealDietCardView.m
//  Fasting
//

#import "FSTMealDietCardView.h"
#import "FSTTheme.h"

@interface FSTMealDietCardView ()
@property (nonatomic, strong) NSArray<UIControl *> *dietRows;
@property (nonatomic, strong) NSArray<NSString *> *dietNames;
@end

@implementation FSTMealDietCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _dietType = @"Not sure";
        _dietNames = @[@"Keto", @"Low-carb", @"Mixed", @"High-carb", @"Not sure"];
        [self fst_applyMealCardStyle];
        [self setupSubviews];
        [self refresh];
    }
    return self;
}

- (void)setDietType:(NSString *)dietType {
    _dietType = [dietType copy]; [self refresh];
}

- (void)setupSubviews {
    UILabel *titleLabel = [UILabel fst_labelWithText:@"Diet Type" font:FSTFontTitle() color:[UIColor fst_textPrimary]];
    [self addSubview:titleLabel];

    UIStackView *rowsStack = [[UIStackView alloc] init];
    rowsStack.axis = UILayoutConstraintAxisVertical;
    rowsStack.spacing = 12;
    [self addSubview:rowsStack];

    NSArray *itemDescriptors = @[
        @[@"🥑", @"Keto", @"High fat, moderate protein, very low carbs"],
        @[@"🥩", @"Low-carb", @"High protein and fat, low carbs"],
        @[@"🍱", @"Mixed", @"Balanced carbs, protein and fat"],
        @[@"🍕", @"High-carb", @"High carbs, moderate protein, low fat"],
        @[@"🍪", @"Not sure", @""],
    ];
    NSMutableArray *collectedRows = [NSMutableArray array];
    for (NSInteger index = 0; index < itemDescriptors.count; index++) {
        UIControl *row = [self rowWithIcon:itemDescriptors[index][0] title:itemDescriptors[index][1] subtitle:itemDescriptors[index][2] tag:index];
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
    row.layer.borderWidth = 1.2;
    row.layer.borderColor = [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.32].CGColor;
    [row addTarget:self action:@selector(handleRowTapped:) forControlEvents:UIControlEventTouchUpInside];
    [row mas_makeConstraints:^(MASConstraintMaker *make) { make.height.equalTo(@74); }];

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
        BOOL isSelected = [self.dietNames[row.tag] isEqualToString:self.dietType];
        row.alpha = isSelected ? 1.0 : 0.48;
        row.layer.borderColor = (isSelected ? [UIColor fst_primaryGreen] : [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.32]).CGColor;
        row.layer.borderWidth = isSelected ? 1.8 : 1.2;
    }
}

- (void)handleRowTapped:(UIControl *)row {
    self.dietType = self.dietNames[row.tag];
}

@end
