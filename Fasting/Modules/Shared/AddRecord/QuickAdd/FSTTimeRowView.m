//
//  FSTTimeRowView.m
//  Fasting
//

#import "FSTTimeRowView.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

// Header row
static const CGFloat kHeaderHeight = 32;
static const CGFloat kDotSize      = 8;
static const CGFloat kPencilSize   = 18;

// Picker
static const CGFloat kPickerRadius = 16;

@interface FSTTimeRowView ()
@property (nonatomic, strong) UIView *dot;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIDatePicker *picker;
@end

@implementation FSTTimeRowView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self buildSubviews];
    }
    return self;
}

#pragma mark - 视图组装

- (void)buildSubviews {
    UIView *headerRow = [[UIView alloc] init];

    self.dot = [[UIView alloc] init];
    self.dot.layer.cornerRadius = kDotSize / 2.0;

    self.titleLabel = [UILabel fst_labelWithText:nil font:FSTFontMedium(16) color:[UIColor blackColor]];
    self.dateLabel = [UILabel fst_labelWithText:nil font:FSTFontBold(15) color:[UIColor fst_eatingTimeGreen]];

    UIImageView *pencil = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:@"edit_pencil"]];
    pencil.contentMode = UIViewContentModeScaleAspectFit;

    [headerRow fst_addSubviews:@[self.dot, self.titleLabel, self.dateLabel, pencil]];

    self.picker = [[UIDatePicker alloc] init];
    self.picker.datePickerMode = UIDatePickerModeDateAndTime;
    self.picker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    self.picker.backgroundColor = [UIColor fst_inputBackground];
    self.picker.layer.cornerRadius = kPickerRadius;
    self.picker.layer.masksToBounds = YES;
    [self.picker addTarget:self action:@selector(handlePickerChanged) forControlEvents:UIControlEventValueChanged];

    [self fst_addSubviews:@[headerRow, self.picker]];

    [headerRow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(kHeaderHeight);
    }];
    [self.dot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerRow);
        make.centerY.equalTo(headerRow);
        make.size.mas_equalTo(CGSizeMake(kDotSize, kDotSize));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.dot.mas_right).offset(8);
        make.centerY.equalTo(headerRow);
    }];
    [pencil mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(headerRow);
        make.centerY.equalTo(headerRow);
        make.size.mas_equalTo(CGSizeMake(kPencilSize, kPencilSize));
    }];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(pencil.mas_left).offset(-6);
        make.centerY.equalTo(headerRow);
    }];
    [self.picker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(headerRow.mas_bottom).offset(12);
        make.left.right.bottom.equalTo(self);
    }];
}

#pragma mark - 属性

- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.titleLabel.text = title;
}

- (void)setDotColor:(UIColor *)dotColor {
    _dotColor = dotColor;
    self.dot.backgroundColor = dotColor;
}

- (void)setDateText:(NSString *)dateText {
    _dateText = [dateText copy];
    self.dateLabel.text = dateText;
}

- (void)setPickerDate:(NSDate *)pickerDate {
    if (pickerDate) self.picker.date = pickerDate;
}

- (NSDate *)pickerDate {
    return self.picker.date;
}

#pragma mark - 事件

- (void)handlePickerChanged {
    if (self.onDateChanged) self.onDateChanged(self.picker.date);
}

@end
