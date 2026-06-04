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

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupSubviews];
        [self refreshValues];
    }
    return self;
}

- (void)setStartDate:(NSDate *)startDate {
    _startDate = startDate; [self refreshValues];
}
- (void)setEndDate:(NSDate *)endDate {
    _endDate = endDate; [self refreshValues];
}
- (void)setPlanName:(NSString *)planName {
    _planName = [planName copy];
    self.planLabel.text = [NSString stringWithFormat:@"◎  Fasting %@", planName ?: @"14-10"];
}
- (void)setEditingExistingRecord:(BOOL)editing {
    _editingExistingRecord = editing;
    self.hintLabel.text = editing ? @"* Select when you stopped fasting" : @"* Select when you started fasting";
}

/// 构建：计划标签 + 开始/结束两行可折叠 + picker + 底部提示。
- (void)setupSubviews {
    self.planLabel = [UILabel fst_labelWithText:nil font:FSTFontBold(16) color:[UIColor fst_textPrimary]];

    UIView *startRow = [self timeRowWithTitle:@"Start" isStart:YES];
    UIView *endRow = [self timeRowWithTitle:@"End" isStart:NO];

    self.startPicker = [self makeDatePickerWithDate:[NSDate date] action:@selector(handleStartDateChanged:)];
    self.endPicker = [self makeDatePickerWithDate:[NSDate date] action:@selector(handleEndDateChanged:)];

    self.hintLabel = [UILabel fst_labelWithText:nil font:FSTFontBold(15) color:[UIColor fst_textSecondary]];
    self.hintLabel.backgroundColor = [UIColor fst_hintBackground];
    self.hintLabel.layer.cornerRadius = 8;
    self.hintLabel.clipsToBounds = YES;

    [self fst_addSubviews:@[self.planLabel, startRow, self.startPicker, endRow, self.endPicker, self.hintLabel]];

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
    UIView *rowView = [[UIView alloc] init];
    rowView.tag = isStart ? 1 : 2;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleRowTapped:)];
    [rowView addGestureRecognizer:tapGesture];

    UIView *dotView = [UIView fst_circularDotWithSize:10
                                          borderColor:(isStart ? [UIColor fst_primaryGreen] : [UIColor fst_redDot])
                                          borderWidth:3
                                              bgColor:nil];

    UILabel *titleLabel = [UILabel fst_labelWithText:title font:FSTFontBold(19) color:[UIColor fst_textPrimary]];

    UILabel *valueLabel = [UILabel fst_labelWithText:nil font:FSTFontBold(17) color:[UIColor fst_primaryGreen] alignment:NSTextAlignmentRight];
    if (isStart) self.startValueLabel = valueLabel; else self.endValueLabel = valueLabel;

    UIImageView *editIconView = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:@"edit_pencil"]];
    editIconView.contentMode = UIViewContentModeScaleAspectFit;

    [rowView fst_addSubviews:@[dotView, titleLabel, valueLabel, editIconView]];

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
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
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
