//
//  FSTMealDiaryEntryRowView.m
//  Fasting
//

#import "FSTMealDiaryEntryRowView.h"
#import "FSTTheme.h"

static const CGFloat kDotSize = 12;

@interface FSTMealDiaryEntryRowView ()
@property (nonatomic, copy) NSString *category;
@property (nonatomic, copy) NSString *dietType;
@property (nonatomic, assign) NSInteger tasteLevel;
@property (nonatomic, copy) NSString *dateText;
@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UIView *bottomLineView;
@end

@implementation FSTMealDiaryEntryRowView

- (instancetype)initWithCategory:(NSString *)category
                        dietType:(NSString *)dietType
                      tasteLevel:(NSInteger)tasteLevel
                        dateText:(NSString *)dateText {
    if ((self = [super initWithFrame:CGRectZero])) {
        _category = [category copy];
        _dietType = [dietType copy];
        _tasteLevel = tasteLevel;
        _dateText = [dateText copy];
        [self buildSubviews];
    }
    return self;
}

#pragma mark - UI

- (void)buildSubviews {
    UIView *dotView = [self buildTimelineDot];
    self.topLineView = [self buildTimelineLine];
    self.bottomLineView = [self buildTimelineLine];
    UILabel *timeLabel = [UILabel fst_labelWithText:self.dateText font:FSTFontBody() color:[UIColor fst_textSecondary]];
    UIButton *editButton = [UIButton fst_plainImageButtonWithImageNamed:@"edit_pencil"
                                                                   size:CGSizeMake(24, 24)
                                                              tintColor:[UIColor fst_editPencilGray]];
    [editButton addTarget:self action:@selector(emitEditTapped) forControlEvents:UIControlEventTouchUpInside];
    UIControl *cardView = [self buildCard];
    UILabel *foodIconLabel = [self buildFoodIcon];
    UILabel *categoryChipLabel = [self pillLabelWithText:self.category ?: @"Meal"];
    UILabel *dietChipLabel     = [self pillLabelWithText:self.dietType ?: @"Not sure"];
    UIImageView *feelingImageView = [self buildFeelingImageView];

    [self fst_addSubviews:@[self.topLineView, self.bottomLineView, dotView, timeLabel, editButton, cardView]];
    [cardView fst_addSubviews:@[foodIconLabel, categoryChipLabel, dietChipLabel, feelingImageView]];

    [dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self).offset(22);
        make.size.mas_equalTo(CGSizeMake(kDotSize, kDotSize));
    }];
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(dotView);
        make.width.equalTo(@2);
        make.bottom.equalTo(dotView.mas_top);
    }];
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(dotView.mas_bottom);
        make.centerX.equalTo(dotView);
        make.width.equalTo(@2);
        make.bottom.equalTo(self);
    }];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dotView.mas_right).offset(14);
        make.centerY.equalTo(dotView);
    }];
    [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.centerY.equalTo(timeLabel);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    [cardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(timeLabel);
        make.right.equalTo(self);
        make.top.equalTo(timeLabel.mas_bottom).offset(10);
        make.height.equalTo(@96);
        make.bottom.equalTo(self).offset(-2);
    }];
    [foodIconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cardView).offset(14);
        make.centerY.equalTo(cardView);
        make.size.mas_equalTo(CGSizeMake(68, 68));
    }];
    [categoryChipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(foodIconLabel.mas_right).offset(14);
        make.centerY.equalTo(cardView);
        make.height.equalTo(@34);
    }];
    [dietChipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(categoryChipLabel.mas_right).offset(8);
        make.centerY.equalTo(cardView);
        make.height.equalTo(@34);
    }];
    [feelingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(cardView).offset(-16);
        make.centerY.equalTo(cardView);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
}

- (UIView *)buildTimelineDot {
    return [UIView fst_circularDotWithSize:kDotSize
                               borderColor:[UIColor fst_mealDiaryCardBorder]
                               borderWidth:3
                                   bgColor:nil];
}

- (UIView *)buildTimelineLine {
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor fst_mealDiaryCardBorder];
    return lineView;
}

- (UIControl *)buildCard {
    UIControl *cardView = [UIControl new];
    cardView.backgroundColor = [UIColor fst_mealDiaryCardBackground];
    cardView.layer.cornerRadius = FSTRadiusCard;
    cardView.layer.borderWidth = 1.0;
    cardView.layer.borderColor = [UIColor fst_mealDiaryCardBorder].CGColor;
    [cardView addTarget:self action:@selector(emitCardTapped) forControlEvents:UIControlEventTouchUpInside];
    return cardView;
}

- (UILabel *)buildFoodIcon {
    UILabel *iconLabel = [UILabel fst_labelWithText:[self.category isEqualToString:@"Snack"] ? @"\U0001F34E" : @"\U0001F37D"
                                                font:FSTFontRegular(34)
                                               color:[UIColor blackColor]
                                           alignment:NSTextAlignmentCenter];
    iconLabel.backgroundColor = [UIColor whiteColor];
    iconLabel.layer.cornerRadius = FSTRadiusM;
    iconLabel.clipsToBounds = YES;
    return iconLabel;
}

- (UIImageView *)buildFeelingImageView {
    UIImageView *feelingImageView = [[UIImageView alloc] initWithImage:[UIImage fst_ratingImageForLevel:self.tasteLevel]];
    feelingImageView.contentMode = UIViewContentModeScaleAspectFit;
    return feelingImageView;
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

- (void)setHidesTopLine:(BOOL)hidesTopLine { _hidesTopLine = hidesTopLine; self.topLineView.hidden = hidesTopLine; }
- (void)setHidesBottomLine:(BOOL)hidesBottomLine { _hidesBottomLine = hidesBottomLine; self.bottomLineView.hidden = hidesBottomLine; }

#pragma mark - Events

- (void)emitCardTapped { if (self.onCardTapped) self.onCardTapped(); }
- (void)emitEditTapped { if (self.onEditTapped) self.onEditTapped(); }

@end
