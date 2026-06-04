//
//  FSTPlanConfirmTimelineView.m
//  Fasting
//

#import "FSTPlanConfirmTimelineView.h"
#import "FSTTheme.h"

static const CGFloat kDotSize = 14;

@interface FSTPlanConfirmTimelineView ()
@property (nonatomic, strong) UILabel *startValueLabel;
@property (nonatomic, strong) UILabel *endValueLabel;
@end

@implementation FSTPlanConfirmTimelineView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupSubviews];
        [self refresh];
    }
    return self;
}

- (void)setStartDate:(NSDate *)startDate {
    _startDate = startDate; [self refresh];
}
- (void)setEndDate:(NSDate *)endDate {
    _endDate = endDate; [self refresh];
}

/// 构建：两个圆点 + 一段连线 + 两个标题 + 时间值 + 铅笔按钮。
- (void)setupSubviews {
    UIView *startDotLabel = [self dotLabelWithColor:[UIColor fst_primaryGreen]];
    UIView *endDotLabel = [self dotLabelWithColor:[UIColor fst_redDot]];
    UIView *connectorLineView = [[UIView alloc] init];
    connectorLineView.backgroundColor = [UIColor fst_ringTrack];

    UILabel *startTitleLabel = [UILabel fst_labelWithText:@"Start" font:FSTFontBold(18) color:[UIColor fst_textSecondary]];
    UILabel *endTitleLabel = [UILabel fst_labelWithText:@"End (est.)" font:FSTFontBold(18) color:[UIColor fst_textSecondary]];

    self.startValueLabel = [self valueLabelWithHighlight:YES];
    self.endValueLabel = [self valueLabelWithHighlight:NO];

    UIButton *editButton = [UIButton fst_plainImageButtonWithImageNamed:@"edit_pencil"
                                                                   size:CGSizeMake(44, 44)
                                                              tintColor:nil];
    [editButton addTarget:self action:@selector(handleEditTapped) forControlEvents:UIControlEventTouchUpInside];

    [self fst_addSubviews:@[startDotLabel, endDotLabel, connectorLineView, startTitleLabel, endTitleLabel,
                            self.startValueLabel, self.endValueLabel, editButton]];

    [startDotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).offset(20);
        make.size.mas_equalTo(CGSizeMake(kDotSize, kDotSize));
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
        make.size.mas_equalTo(CGSizeMake(kDotSize, kDotSize));
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

- (UIView *)dotLabelWithColor:(UIColor *)color {
    return [UIView fst_circularDotWithSize:kDotSize
                               borderColor:color
                               borderWidth:3
                                   bgColor:[UIColor whiteColor]];
}

- (UILabel *)valueLabelWithHighlight:(BOOL)highlight {
    UIColor *color = highlight ? [UIColor fst_primaryGreen] : [UIColor fst_textSecondary];
    return [UILabel fst_labelWithText:nil font:FSTFontBold(17) color:color];
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
