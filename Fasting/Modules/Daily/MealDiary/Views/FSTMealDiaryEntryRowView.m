//
//  FSTMealDiaryEntryRowView.m
//  Fasting
//

#import "FSTMealDiaryEntryRowView.h"
#import "FSTTheme.h"

static const CGFloat kDotSize = 12;

@interface FSTMealDiaryEntryRowView ()
@property (nonatomic, strong) UIView *dotView;
@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIControl *cardView;
@property (nonatomic, strong) UILabel *foodIconLabel;
@property (nonatomic, strong) UILabel *categoryChipLabel;
@property (nonatomic, strong) UILabel *dietChipLabel;
@property (nonatomic, strong) UIImageView *feelingImageView;
@end

@implementation FSTMealDiaryEntryRowView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 视图组装

- (void)setupSubviews {
    self.dotView = [UIView fst_circularDotWithSize:kDotSize
                                       borderColor:[UIColor fst_mealDiaryCardBorder]
                                       borderWidth:3
                                           bgColor:nil];

    self.topLineView = [UIView new];
    self.topLineView.backgroundColor = [UIColor fst_mealDiaryCardBorder];

    self.bottomLineView = [UIView new];
    self.bottomLineView.backgroundColor = [UIColor fst_mealDiaryCardBorder];

    self.timeLabel = [UILabel fst_labelWithText:@"" font:FSTFontBody() color:[UIColor fst_textSecondary]];

    self.editButton = [UIButton fst_plainImageButtonWithImageNamed:@"edit_pencil"
                                                              size:CGSizeMake(24, 24)
                                                         tintColor:[UIColor fst_editPencilGray]];
    [self.editButton addTarget:self action:@selector(emitEditTapped)
              forControlEvents:UIControlEventTouchUpInside];

    self.cardView = [UIControl new];
    self.cardView.backgroundColor = [UIColor fst_mealDiaryCardBackground];
    self.cardView.layer.cornerRadius = FSTRadiusCard;
    self.cardView.layer.borderWidth = 1.0;
    self.cardView.layer.borderColor = [UIColor fst_mealDiaryCardBorder].CGColor;
    [self.cardView addTarget:self action:@selector(emitCardTapped)
            forControlEvents:UIControlEventTouchUpInside];

    self.foodIconLabel = [UILabel fst_labelWithText:@"\U0001F37D"
                                               font:FSTFontRegular(34)
                                              color:[UIColor blackColor]
                                          alignment:NSTextAlignmentCenter];
    self.foodIconLabel.backgroundColor = [UIColor whiteColor];
    self.foodIconLabel.layer.cornerRadius = FSTRadiusM;
    self.foodIconLabel.clipsToBounds = YES;

    self.categoryChipLabel = [self pillLabelWithText:@"Meal"];
    self.dietChipLabel     = [self pillLabelWithText:@"Not sure"];

    self.feelingImageView = [UIImageView new];
    self.feelingImageView.contentMode = UIViewContentModeScaleAspectFit;

    [self fst_addSubviews:@[self.topLineView, self.bottomLineView, self.dotView,
                            self.timeLabel, self.editButton, self.cardView]];
    [self.cardView fst_addSubviews:@[self.foodIconLabel, self.categoryChipLabel,
                                     self.dietChipLabel, self.feelingImageView]];
}

- (void)setupConstraints {
    [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self).offset(22);
        make.size.mas_equalTo(CGSizeMake(kDotSize, kDotSize));
    }];
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self.dotView);
        make.width.equalTo(@2);
        make.bottom.equalTo(self.dotView.mas_top);
    }];
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dotView.mas_bottom);
        make.centerX.equalTo(self.dotView);
        make.width.equalTo(@2);
        make.bottom.equalTo(self);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.dotView.mas_right).offset(14);
        make.centerY.equalTo(self.dotView);
    }];
    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.centerY.equalTo(self.timeLabel);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    [self.cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timeLabel);
        make.right.equalTo(self);
        make.top.equalTo(self.timeLabel.mas_bottom).offset(10);
        make.height.equalTo(@96);
        make.bottom.equalTo(self).offset(-2);
    }];
    [self.foodIconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cardView).offset(14);
        make.centerY.equalTo(self.cardView);
        make.size.mas_equalTo(CGSizeMake(68, 68));
    }];
    [self.categoryChipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.foodIconLabel.mas_right).offset(14);
        make.centerY.equalTo(self.cardView);
        make.height.equalTo(@34);
    }];
    [self.dietChipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.categoryChipLabel.mas_right).offset(8);
        make.centerY.equalTo(self.cardView);
        make.height.equalTo(@34);
    }];
    [self.feelingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.cardView).offset(-16);
        make.centerY.equalTo(self.cardView);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
}

#pragma mark - 属性同步

- (void)setCategory:(NSString *)category {
    _category = [category copy];
    NSString *categoryText = category.length > 0 ? category : @"Meal";
    self.categoryChipLabel.text = [NSString stringWithFormat:@"  %@  ", categoryText];
    self.foodIconLabel.text = [categoryText isEqualToString:@"Snack"] ? @"\U0001F34E" : @"\U0001F37D";
}

- (void)setDietType:(NSString *)dietType {
    _dietType = [dietType copy];
    NSString *dietText = dietType.length > 0 ? dietType : @"Not sure";
    self.dietChipLabel.text = [NSString stringWithFormat:@"  %@  ", dietText];
}

- (void)setTasteLevel:(NSInteger)tasteLevel {
    _tasteLevel = tasteLevel;
    self.feelingImageView.image = [UIImage fst_ratingImageForLevel:tasteLevel];
}

- (void)setDateText:(NSString *)dateText {
    _dateText = [dateText copy];
    self.timeLabel.text = dateText;
}

- (void)setHidesTopLine:(BOOL)hidesTopLine {
    _hidesTopLine = hidesTopLine;
    self.topLineView.hidden = hidesTopLine;
}

- (void)setHidesBottomLine:(BOOL)hidesBottomLine {
    _hidesBottomLine = hidesBottomLine;
    self.bottomLineView.hidden = hidesBottomLine;
}

- (UILabel *)pillLabelWithText:(NSString *)text {
    UILabel *label = [UILabel fst_labelWithText:[NSString stringWithFormat:@"  %@  ", text]
                                            font:FSTFontBody()
                                           color:[UIColor fst_textPrimary]
                                       alignment:NSTextAlignmentCenter];
    label.backgroundColor = [UIColor whiteColor];
    label.layer.cornerRadius = FSTRadiusChip;
    label.clipsToBounds = YES;
    return label;
}

#pragma mark - Events

- (void)emitCardTapped { if (self.onCardTapped) self.onCardTapped(); }
- (void)emitEditTapped { if (self.onEditTapped) self.onEditTapped(); }

@end
