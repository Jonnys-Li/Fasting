//
//  FSTMealDiaryEntryRowView.m
//  Fasting
//

#import "FSTMealDiaryEntryRowView.h"
#import "FSTSessionManager.h"
#import "FSTTheme.h"

@interface FSTMealDiaryEntryRowView ()
@property (nonatomic, strong) FSTMealRecord *record;
@end

@implementation FSTMealDiaryEntryRowView

- (instancetype)initWithRecord:(FSTMealRecord *)record {
    if ((self = [super initWithFrame:CGRectZero])) {
        _record = record;
        [self buildSubviews];
    }
    return self;
}

#pragma mark - 构建 UI

/// 构建一条时间轴记录行的全部子视图。
- (void)buildSubviews {
    UIView *dotView = [self buildTimelineDot];
    UIView *lineView = [self buildTimelineLine];
    UILabel *timeLabel = [self buildTimeLabel];
    UIButton *editButton = [self buildEditButton];
    UIControl *cardView = [self buildCard];
    UILabel *foodIconLabel = [self buildFoodIcon];
    UILabel *categoryChipLabel = [self pillLabelWithText:self.record.mealCategory ?: @"正餐"];
    UILabel *dietChipLabel = [self pillLabelWithText:self.record.dietType ?: @"我不确定"];
    UIImageView *feelingImageView = [self buildFeelingImageView];

    [self addSubview:dotView];
    [self addSubview:lineView];
    [self addSubview:timeLabel];
    [self addSubview:editButton];
    [self addSubview:cardView];
    [cardView addSubview:foodIconLabel];
    [cardView addSubview:categoryChipLabel];
    [cardView addSubview:dietChipLabel];
    [cardView addSubview:feelingImageView];

    [dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self).offset(4);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
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
    UIView *dotView = [UIView new];
    dotView.layer.borderColor = [UIColor fst_ringTrack].CGColor;
    dotView.layer.borderWidth = 3;
    dotView.layer.cornerRadius = 6;
    return dotView;
}

- (UIView *)buildTimelineLine {
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor fst_ringTrack];
    return lineView;
}

- (UILabel *)buildTimeLabel {
    UILabel *timeLabel = [UILabel new];
    timeLabel.text = FSTFormatRelativeDateTime(self.record.date ?: [NSDate date]);
    timeLabel.font = FSTFontRegular(15);
    timeLabel.textColor = [UIColor fst_textSecondary];
    return timeLabel;
}

- (UIButton *)buildEditButton {
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *pencilImage = [[UIImage imageNamed:@"edit_pencil"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [editButton setImage:pencilImage forState:UIControlStateNormal];
    editButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    editButton.adjustsImageWhenHighlighted = NO;
    [editButton addTarget:self action:@selector(emitEditTapped) forControlEvents:UIControlEventTouchUpInside];
    return editButton;
}

- (UIControl *)buildCard {
    UIControl *cardView = [UIControl new];
    cardView.backgroundColor = [UIColor fst_colorWithHex:0xF6F7F9];
    cardView.layer.cornerRadius = 18;
    [cardView addTarget:self action:@selector(emitCardTapped) forControlEvents:UIControlEventTouchUpInside];
    return cardView;
}

- (UILabel *)buildFoodIcon {
    UILabel *iconLabel = [UILabel new];
    iconLabel.backgroundColor = [UIColor whiteColor];
    iconLabel.layer.cornerRadius = 14;
    iconLabel.clipsToBounds = YES;
    iconLabel.text = [self.record.mealCategory isEqualToString:@"零食"] ? @"🍎" : @"🍽";
    iconLabel.font = [UIFont systemFontOfSize:34];
    iconLabel.textAlignment = NSTextAlignmentCenter;
    iconLabel.userInteractionEnabled = NO;
    return iconLabel;
}

- (UIImageView *)buildFeelingImageView {
    NSString *imageName;
    switch (self.record.tasteLevel) {
        case 0: imageName = @"tl_rating_hard"; break;
        case 2: imageName = @"tl_rating_easy"; break;
        default: imageName = @"tl_rating_ok"; break;
    }
    UIImageView *feelingImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    feelingImageView.contentMode = UIViewContentModeScaleAspectFit;
    feelingImageView.userInteractionEnabled = NO;
    return feelingImageView;
}

/// 卡片内白色胶囊 label：左右各加 2 空格用于内边距。
- (UILabel *)pillLabelWithText:(NSString *)text {
    UILabel *label = [UILabel new];
    label.text = [NSString stringWithFormat:@"  %@  ", text];
    label.font = FSTFontRegular(15);
    label.textColor = [UIColor fst_textPrimary];
    label.backgroundColor = [UIColor whiteColor];
    label.layer.cornerRadius = 17;
    label.clipsToBounds = YES;
    label.textAlignment = NSTextAlignmentCenter;
    label.userInteractionEnabled = NO;
    return label;
}

#pragma mark - 事件转发

- (void)emitCardTapped { if (self.onCardTapped) self.onCardTapped(self.record); }
- (void)emitEditTapped { if (self.onEditTapped) self.onEditTapped(self.record); }

@end
