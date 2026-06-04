//
//  FSTMealTimeCardView.m
//  Fasting
//

#import "FSTMealTimeCardView.h"
#import "FSTTheme.h"

@interface FSTMealTimeCardView ()
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) MASConstraint *datePickerHeightConstraint;
@property (nonatomic, assign) BOOL datePickerExpanded;
@end

@implementation FSTMealTimeCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _date = [NSDate date];
        [self fst_applyMealCardStyle];
        [self setupSubviews];
        [self refresh];
    }
    return self;
}

- (void)setDate:(NSDate *)date {
    _date = date; [self refresh]; if (date) self.datePicker.date = date;
}


- (void)setupSubviews {
    UILabel *titleLabel = [UILabel fst_labelWithText:@"Time" font:FSTFontTitle() color:[UIColor fst_textPrimary]];

    self.dateLabel = [UILabel fst_labelWithText:nil font:FSTFontBold(17) color:[UIColor fst_mealDateText] alignment:NSTextAlignmentRight];

    UIImageView *editIconView = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:@"edit_pencil"]];
    editIconView.contentMode = UIViewContentModeScaleAspectFit;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleToggleTapped)];
    tapGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tapGesture];

    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.date = self.date;
    self.datePicker.clipsToBounds = YES;
    if (@available(iOS 13.4, *)) self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    [self.datePicker addTarget:self action:@selector(handleDatePickerChanged:) forControlEvents:UIControlEventValueChanged];

    [self fst_addSubviews:@[titleLabel, self.dateLabel, editIconView, self.datePicker]];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(28);
        make.left.equalTo(self).offset(26);
    }];
    [editIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-28);
        make.centerY.equalTo(titleLabel);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(editIconView.mas_left).offset(-8);
        make.centerY.equalTo(titleLabel);
    }];
    [self.datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(8);
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
        self.datePickerHeightConstraint = make.height.equalTo(@0);
    }];
}

- (void)refresh {
    self.dateLabel.text = self.date ? FSTFormatRelativeDateTime(self.date) : @"--";
}

- (void)handleToggleTapped {
    self.datePickerExpanded = !self.datePickerExpanded;
    self.datePickerHeightConstraint.offset = self.datePickerExpanded ? 220 : 0;
    [UIView animateWithDuration:0.22 animations:^{ [self.superview layoutIfNeeded]; }];
}

- (void)handleDatePickerChanged:(UIDatePicker *)datePicker {
    _date = datePicker.date;
    [self refresh];
    if (self.onDateChanged) self.onDateChanged(datePicker.date);
}

@end
