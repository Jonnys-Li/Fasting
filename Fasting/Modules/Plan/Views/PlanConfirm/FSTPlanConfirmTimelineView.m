//
//  FSTPlanConfirmTimelineView.m
//  Fasting
//

#import "FSTPlanConfirmTimelineView.h"
#import "FSTTheme.h"

@interface FSTPlanConfirmTimelineView ()
@property (nonatomic, strong) UILabel *startValueLabel;
@property (nonatomic, strong) UILabel *endValueLabel;
@end

@implementation FSTPlanConfirmTimelineView

- (instancetype)init {
    if ((self = [super init])) {
        [self buildSubviews];
        [self refresh];
    }
    return self;
}

- (void)setStartDate:(NSDate *)startDate { _startDate = startDate; [self refresh]; }
- (void)setEndDate:(NSDate *)endDate { _endDate = endDate; [self refresh]; }

/// 构建：两个圆点 + 一段连线 + 两个标题 + 时间值 + 铅笔按钮。
- (void)buildSubviews {
    UILabel *startDotLabel = [self dotLabelWithColor:[UIColor fst_primaryGreen]];
    UILabel *endDotLabel = [self dotLabelWithColor:[UIColor fst_redDot]];
    UIView *connectorLineView = [UIView new];
    connectorLineView.backgroundColor = [UIColor fst_ringTrack];

    UILabel *startTitleLabel = [self titleLabelWithText:@"开始"];
    UILabel *endTitleLabel = [self titleLabelWithText:@"结束(预计)"];

    self.startValueLabel = [self valueLabelWithHighlight:YES];
    self.endValueLabel = [self valueLabelWithHighlight:NO];

    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setImage:[[UIImage imageNamed:@"edit_pencil"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    editButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    editButton.adjustsImageWhenHighlighted = NO;
    [editButton addTarget:self action:@selector(handleEditTapped) forControlEvents:UIControlEventTouchUpInside];

    for (UIView *subview in @[startDotLabel, endDotLabel, connectorLineView, startTitleLabel, endTitleLabel, self.startValueLabel, self.endValueLabel, editButton]) {
        [self addSubview:subview];
    }

    [startDotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).offset(20);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
    [connectorLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(startDotLabel.mas_bottom).offset(3);
        make.centerX.equalTo(startDotLabel);
        make.width.equalTo(@2);
        make.height.equalTo(@28);
    }];
    [endDotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(connectorLineView.mas_bottom).offset(3);
        make.centerX.equalTo(startDotLabel);
        make.size.mas_equalTo(CGSizeMake(14, 14));
        make.bottom.equalTo(self);
    }];
    [startTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(startDotLabel.mas_right).offset(12);
        make.centerY.equalTo(startDotLabel);
    }];
    [endTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(endDotLabel.mas_right).offset(12);
        make.centerY.equalTo(endDotLabel);
    }];
    [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-30);
        make.centerY.equalTo(startDotLabel);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.startValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(editButton.mas_left).offset(-12);
        make.centerY.equalTo(startDotLabel);
    }];
    [self.endValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-34);
        make.centerY.equalTo(endDotLabel);
    }];
}

- (UILabel *)dotLabelWithColor:(UIColor *)color {
    UILabel *dotLabel = [UILabel new];
    dotLabel.layer.cornerRadius = 7;
    dotLabel.layer.borderWidth = 3;
    dotLabel.layer.borderColor = color.CGColor;
    dotLabel.backgroundColor = [UIColor whiteColor];
    dotLabel.clipsToBounds = YES;
    return dotLabel;
}

- (UILabel *)titleLabelWithText:(NSString *)text {
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = text;
    titleLabel.font = FSTFontBold(18);
    titleLabel.textColor = [UIColor fst_textSecondary];
    return titleLabel;
}

- (UILabel *)valueLabelWithHighlight:(BOOL)highlight {
    UILabel *valueLabel = [UILabel new];
    valueLabel.font = FSTFontBold(17);
    valueLabel.textColor = highlight ? [UIColor fst_primaryGreen] : [UIColor fst_textSecondary];
    return valueLabel;
}

- (void)refresh {
    self.startValueLabel.text = [self displayTextForDate:self.startDate];
    self.endValueLabel.text = [self displayTextForDate:self.endDate];
}

- (NSString *)displayTextForDate:(NSDate *)date {
    if (!date) return @"";
    return FSTFormatRelativeDateTime(date);
}

- (void)handleEditTapped {
    if (self.onEditStartTapped) self.onEditStartTapped();
}

@end
