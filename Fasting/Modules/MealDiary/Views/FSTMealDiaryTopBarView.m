//
//  FSTMealDiaryTopBarView.m
//  Fasting
//

#import "FSTMealDiaryTopBarView.h"
#import "FSTTheme.h"

@interface FSTMealDiaryTopBarView ()
@property (nonatomic, strong) UILabel *dateLabel;
@end

@implementation FSTMealDiaryTopBarView

- (instancetype)init {
    if ((self = [super init])) {
        _selectedDate = [NSDate date];
        self.backgroundColor = [UIColor whiteColor];
        [self buildSubviews];
        [self refreshDateLabel];
    }
    return self;
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    _selectedDate = selectedDate;
    [self refreshDateLabel];
}

/// 构建：返回按钮 + 中央日期胶囊 + 右侧筛选按钮 + 红点。
- (void)buildSubviews {
    UIButton *backButton = [UIButton fst_iconButtonWithSystemName:@"arrow.left" size:44];
    [backButton addTarget:self action:@selector(emitBackTapped) forControlEvents:UIControlEventTouchUpInside];

    UIControl *dateChip = [UIControl new];
    [dateChip addTarget:self action:@selector(emitDateChipTapped) forControlEvents:UIControlEventTouchUpInside];

    UILabel *calendarIconLabel = [UILabel new];
    calendarIconLabel.text = @"📅";
    calendarIconLabel.font = [UIFont systemFontOfSize:22];
    calendarIconLabel.textAlignment = NSTextAlignmentCenter;

    self.dateLabel = [UILabel new];
    self.dateLabel.font = FSTFontBold(22);
    self.dateLabel.textColor = [UIColor fst_textPrimary];

    UIImageSymbolConfiguration *symbolConfiguration = [UIImageSymbolConfiguration configurationWithPointSize:14 weight:UIImageSymbolWeightSemibold];
    UIImageView *chevronIconView = [[UIImageView alloc] initWithImage:[[UIImage systemImageNamed:@"chevron.down"] imageWithConfiguration:symbolConfiguration]];
    chevronIconView.tintColor = [UIColor fst_textPrimary];
    chevronIconView.contentMode = UIViewContentModeScaleAspectFit;

    [dateChip addSubview:calendarIconLabel];
    [dateChip addSubview:self.dateLabel];
    [dateChip addSubview:chevronIconView];

    UIButton *filterButton = [UIButton fst_iconButtonWithSystemName:@"line.3.horizontal.decrease" size:44];
    [filterButton addTarget:self action:@selector(emitFilterTapped) forControlEvents:UIControlEventTouchUpInside];

    UIView *redDotView = [UIView new];
    redDotView.backgroundColor = [UIColor fst_redDot];
    redDotView.layer.cornerRadius = 4;
    redDotView.userInteractionEnabled = NO;
    [filterButton addSubview:redDotView];

    for (UIView *subview in @[backButton, dateChip, filterButton]) [self addSubview:subview];

    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(22);
        make.bottom.equalTo(self).offset(-12);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [dateChip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(backButton);
        make.height.equalTo(@44);
    }];
    [calendarIconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dateChip);
        make.centerY.equalTo(dateChip);
    }];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(calendarIconLabel.mas_right).offset(8);
        make.centerY.equalTo(dateChip);
    }];
    [chevronIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.dateLabel.mas_right).offset(6);
        make.right.equalTo(dateChip);
        make.centerY.equalTo(dateChip);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    [filterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-22);
        make.centerY.equalTo(backButton);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(filterButton).offset(9);
        make.right.equalTo(filterButton).offset(-9);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    }];
}

- (void)refreshDateLabel {
    self.dateLabel.text = FSTFormatRelativeDay(self.selectedDate ?: [NSDate date]);
}

- (void)emitBackTapped { if (self.onBackTapped) self.onBackTapped(); }
- (void)emitDateChipTapped { if (self.onDateChipTapped) self.onDateChipTapped(); }
- (void)emitFilterTapped { if (self.onFilterTapped) self.onFilterTapped(); }

@end
