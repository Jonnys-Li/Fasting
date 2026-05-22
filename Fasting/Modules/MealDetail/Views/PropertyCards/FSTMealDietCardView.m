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

- (instancetype)init {
    if ((self = [super init])) {
        _dietType = @"我不确定";
        _dietNames = @[@"生酮饮食", @"低碳饮食", @"混合式饮食", @"高碳饮食", @"我不确定"];
        [self fst_applyMealCardStyle];
        [self buildSubviews];
        [self refresh];
    }
    return self;
}

- (void)setDietType:(NSString *)dietType { _dietType = [dietType copy]; [self refresh]; }

- (void)buildSubviews {
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"饮食类型";
    titleLabel.font = FSTFontBold(22);
    titleLabel.textColor = [UIColor fst_textPrimary];
    [self addSubview:titleLabel];

    UIStackView *rowsStack = [UIStackView new];
    rowsStack.axis = UILayoutConstraintAxisVertical;
    rowsStack.spacing = 12;
    [self addSubview:rowsStack];

    NSArray *itemDescriptors = @[
        @[@"🥑", @"生酮饮食", @"高脂肪，适量蛋白质，极少的碳水化合物"],
        @[@"🥩", @"低碳饮食", @"大量的蛋白质和脂肪，低碳水化合物"],
        @[@"🍱", @"混合式饮食", @"碳水化合物，蛋白质和脂肪均衡搭配"],
        @[@"🍕", @"高碳饮食", @"大量的碳水化合物，适量蛋白质，少量脂肪"],
        @[@"🍪", @"我不确定", @""],
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
    UIControl *row = [UIControl new];
    row.tag = tag;
    row.backgroundColor = [UIColor fst_inputBackground];
    row.layer.cornerRadius = 14;
    row.layer.borderWidth = 1.2;
    row.layer.borderColor = [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.32].CGColor;
    [row addTarget:self action:@selector(handleRowTapped:) forControlEvents:UIControlEventTouchUpInside];
    [row mas_makeConstraints:^(MASConstraintMaker *make) { make.height.equalTo(@74); }];

    UILabel *iconLabel = [UILabel new];
    iconLabel.text = icon;
    iconLabel.font = [UIFont systemFontOfSize:32];
    [row addSubview:iconLabel];

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = title;
    titleLabel.font = FSTFontBold(17);
    titleLabel.textColor = [UIColor fst_textPrimary];
    [row addSubview:titleLabel];

    UILabel *subtitleLabel = [UILabel new];
    subtitleLabel.text = subtitle;
    subtitleLabel.font = FSTFontRegular(14);
    subtitleLabel.textColor = [UIColor fst_textSecondary];
    [row addSubview:subtitleLabel];

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
