//
//  FSTAddRecordTimeCardView.m
//  Fasting
//

#import "FSTAddRecordTimeCardView.h"
#import "FSTTheme.h"

@interface FSTAddRecordTimeCardView ()
@property (nonatomic, strong) UILabel *planLabel;
@property (nonatomic, strong) UILabel *startValueLabel;
@property (nonatomic, strong) UILabel *endValueLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIDatePicker *startPicker;
@property (nonatomic, strong) UIDatePicker *endPicker;
@property (nonatomic, strong) MASConstraint *startPickerHeight;
@property (nonatomic, strong) MASConstraint *endPickerHeight;
@property (nonatomic, assign) BOOL startPickerOpen;
@property (nonatomic, assign) BOOL endPickerOpen;
@end

@implementation FSTAddRecordTimeCardView

- (instancetype)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 24;
        [self buildSubviews];
        [self refreshValues];
    }
    return self;
}

- (void)setStartDate:(NSDate *)startDate { _startDate = startDate; [self refreshValues]; }
- (void)setEndDate:(NSDate *)endDate { _endDate = endDate; [self refreshValues]; }
- (void)setPlanName:(NSString *)planName {
    _planName = [planName copy];
    self.planLabel.text = [NSString stringWithFormat:@"◎  断食 %@", planName ?: @"14-10"];
}
- (void)setEditingExistingRecord:(BOOL)editing {
    _editingExistingRecord = editing;
    self.hintLabel.text = editing ? @"* 请选择停止断食(开始进食)的时间" : @"* 请选择开始断食(停止进食)的时间";
}

/// 构建：计划标签 + 开始/结束两行可折叠 + picker + 底部提示。
- (void)buildSubviews {
    self.planLabel = [UILabel new];
    self.planLabel.font = FSTFontBold(16);
    self.planLabel.textColor = [UIColor fst_textPrimary];
    [self addSubview:self.planLabel];

    UIView *startRow = [self timeRowWithTitle:@"开始" isStart:YES];
    UIView *endRow = [self timeRowWithTitle:@"结束" isStart:NO];

    self.startPicker = [self makeDatePickerWithDate:[NSDate date] action:@selector(handleStartDateChanged:)];
    self.endPicker = [self makeDatePickerWithDate:[NSDate date] action:@selector(handleEndDateChanged:)];

    self.hintLabel = [UILabel new];
    self.hintLabel.font = FSTFontBold(15);
    self.hintLabel.textColor = [UIColor fst_textSecondary];
    self.hintLabel.backgroundColor = [UIColor fst_hintBackground];
    self.hintLabel.layer.cornerRadius = 8;
    self.hintLabel.clipsToBounds = YES;

    for (UIView *subview in @[startRow, self.startPicker, endRow, self.endPicker, self.hintLabel]) {
        [self addSubview:subview];
    }

    [self.planLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(28);
        make.left.equalTo(self).offset(24);
    }];
    [startRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.planLabel.mas_bottom).offset(30);
        make.left.right.equalTo(self);
        make.height.equalTo(@56);
    }];
    [self.startPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(startRow.mas_bottom);
        make.left.right.equalTo(self);
        self.startPickerHeight = make.height.equalTo(@0);
    }];
    [endRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.startPicker.mas_bottom);
        make.left.right.equalTo(self);
        make.height.equalTo(@56);
    }];
    [self.endPicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(endRow.mas_bottom);
        make.left.right.equalTo(self);
        self.endPickerHeight = make.height.equalTo(@0);
    }];
    [self.hintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.endPicker.mas_bottom).offset(18);
        make.left.right.equalTo(self).inset(22);
        make.height.equalTo(@46);
        make.bottom.equalTo(self).offset(-22);
    }];
}

/// 一条时间行（圆点 + 标题 + 值 + 铅笔），点击切换对应 picker。
- (UIView *)timeRowWithTitle:(NSString *)title isStart:(BOOL)isStart {
    UIView *rowView = [UIView new];
    rowView.tag = isStart ? 1 : 2;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRowTapped:)];
    [rowView addGestureRecognizer:tapGesture];

    UIView *dotView = [UIView new];
    dotView.layer.borderColor = (isStart ? [UIColor fst_primaryGreen] : [UIColor fst_redDot]).CGColor;
    dotView.layer.borderWidth = 3;
    dotView.layer.cornerRadius = 5;
    dotView.clipsToBounds = YES;

    UILabel *titleLabel = [UILabel new];
    titleLabel.text = title;
    titleLabel.font = FSTFontBold(19);
    titleLabel.textColor = [UIColor fst_textPrimary];

    UILabel *valueLabel = [UILabel new];
    valueLabel.font = FSTFontBold(17);
    valueLabel.textColor = [UIColor fst_primaryGreen];
    valueLabel.textAlignment = NSTextAlignmentRight;
    if (isStart) self.startValueLabel = valueLabel; else self.endValueLabel = valueLabel;

    UIImageView *editIconView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"edit_pencil"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    editIconView.contentMode = UIViewContentModeScaleAspectFit;

    for (UIView *subview in @[dotView, titleLabel, valueLabel, editIconView]) [rowView addSubview:subview];

    [dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rowView).offset(24);
        make.centerY.equalTo(rowView);
        make.size.mas_equalTo(CGSizeMake(10, 10));
    }];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(dotView.mas_right).offset(14);
        make.centerY.equalTo(rowView);
    }];
    [editIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(rowView).offset(-24);
        make.centerY.equalTo(rowView);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(editIconView.mas_left).offset(-10);
        make.centerY.equalTo(rowView);
    }];
    return rowView;
}

- (UIDatePicker *)makeDatePickerWithDate:(NSDate *)date action:(SEL)action {
    UIDatePicker *datePicker = [UIDatePicker new];
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker.date = date ?: [NSDate date];
    if (@available(iOS 13.4, *)) datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    datePicker.clipsToBounds = YES;
    [datePicker addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    return datePicker;
}

#pragma mark - 刷新与事件

- (void)refreshValues {
    self.startValueLabel.text = [self displayDate:self.startDate];
    self.endValueLabel.text = [self displayDate:self.endDate];
    if (self.startDate) self.startPicker.date = self.startDate;
    if (self.endDate) self.endPicker.date = self.endDate;
}

- (NSString *)displayDate:(NSDate *)date {
    if (!date) return @"";
    return FSTFormatRelativeDateTime(date);
}

/// 行点击：展开对应 picker，折叠另一个。
- (void)handleRowTapped:(UITapGestureRecognizer *)tapGesture {
    BOOL isStartRow = tapGesture.view.tag == 1;
    BOOL currentlyOpen = isStartRow ? self.startPickerOpen : self.endPickerOpen;
    self.startPickerOpen = isStartRow ? !currentlyOpen : NO;
    self.endPickerOpen = isStartRow ? NO : !currentlyOpen;
    self.startPickerHeight.offset = self.startPickerOpen ? 220 : 0;
    self.endPickerHeight.offset = self.endPickerOpen ? 220 : 0;
    [UIView animateWithDuration:0.22 animations:^{ [self layoutIfNeeded]; }];
}

- (void)handleStartDateChanged:(UIDatePicker *)datePicker {
    _startDate = datePicker.date;
    [self refreshValues];
    if (self.onDatesChanged) self.onDatesChanged(self.startDate, self.endDate);
}

- (void)handleEndDateChanged:(UIDatePicker *)datePicker {
    _endDate = datePicker.date;
    [self refreshValues];
    if (self.onDatesChanged) self.onDatesChanged(self.startDate, self.endDate);
}

@end
