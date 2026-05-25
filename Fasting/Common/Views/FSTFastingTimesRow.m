//
//  FSTFastingTimesRow.m
//  Fasting
//

#import "FSTFastingTimesRow.h"
#import "FSTTheme.h"
#import <Masonry/Masonry.h>

static const CGFloat kFSTFastingTimesRowPencilSize = 24;
static const CGFloat kFSTFastingTimesRowTimeWidth = 127;
static const CGFloat kFSTFastingTimesRowTimeHeight = 20;
static const CGFloat kFSTFastingTimesRowCaptionTimeGap = 10;
static const CGFloat kFSTFastingTimesRowPencilGap = 6;

@interface FSTFastingTimesRow ()
@property (nonatomic, copy) NSString *startCaption;
@property (nonatomic, copy) NSString *endCaption;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, strong, nullable) UIColor *startHighlightColor;

@property (nonatomic, strong) UILabel *startTimeLabel;
@property (nonatomic, strong) UILabel *endTimeLabel;
@end

@implementation FSTFastingTimesRow

- (instancetype)initWithStartCaption:(NSString *)startCaption
                          endCaption:(NSString *)endCaption
                            editable:(BOOL)editable
                 startHighlightColor:(nullable UIColor *)startHighlightColor {
    if ((self = [super initWithFrame:CGRectZero])) {
        _startCaption        = [startCaption copy];
        _endCaption          = [endCaption copy];
        _editable            = editable;
        _startHighlightColor = startHighlightColor;
        [self buildSubviews];
    }
    return self;
}

- (void)setStartText:(nullable NSString *)startText {
    _startText = [startText copy];
    self.startTimeLabel.text = startText ?: @"--";
}

- (void)setEndText:(nullable NSString *)endText {
    _endText = [endText copy];
    self.endTimeLabel.text = endText ?: @"--";
}

#pragma mark - 布局

- (void)buildSubviews {
    self.startTimeLabel = [self timeLabelWithColor:self.startHighlightColor ?: [UIColor fst_textPrimary]];
    self.endTimeLabel   = [self timeLabelWithColor:[UIColor fst_textPrimary]];

    UIView *leftColumn  = [self columnWithCaption:self.startCaption
                                        timeLabel:self.startTimeLabel
                                        alignLeft:YES
                                       editAction:@selector(handleStartEditTapped)];
    UIView *rightColumn = [self columnWithCaption:self.endCaption
                                        timeLabel:self.endTimeLabel
                                        alignLeft:NO
                                       editAction:@selector(handleEndEditTapped)];

    [self addSubview:leftColumn];
    [self addSubview:rightColumn];

    [leftColumn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.width.equalTo(rightColumn);
    }];
    [rightColumn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self);
        make.left.equalTo(leftColumn.mas_right);
    }];
}

- (UIView *)columnWithCaption:(NSString *)caption
                    timeLabel:(UILabel *)timeLabel
                    alignLeft:(BOOL)alignLeft
                   editAction:(SEL)editAction {
    UIView *column = [UIView new];

    UILabel *captionLabel = [UILabel new];
    captionLabel.text      = caption;
    captionLabel.font      = FSTFontRegular(14);
    captionLabel.textColor = [UIColor fst_textSecondary];
    captionLabel.adjustsFontSizeToFitWidth = YES;
    captionLabel.minimumScaleFactor = 0.82;
    [column addSubview:captionLabel];
    [column addSubview:timeLabel];

    UIButton *editButton = nil;
    if (self.editable) {
        editButton = [self editButton];
        [editButton addTarget:self action:editAction forControlEvents:UIControlEventTouchUpInside];
        [column addSubview:editButton];
    }

    [captionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(column);
        if (alignLeft) {
            make.left.equalTo(column);
            make.right.lessThanOrEqualTo(column);
        } else {
            make.right.equalTo(column);
            make.left.greaterThanOrEqualTo(column);
        }
    }];

    if (alignLeft) {
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(column);
            make.top.equalTo(captionLabel.mas_bottom).offset(kFSTFastingTimesRowCaptionTimeGap);
            make.height.equalTo(@(kFSTFastingTimesRowTimeHeight));
            make.width.lessThanOrEqualTo(@(kFSTFastingTimesRowTimeWidth));
        }];
        if (editButton) {
            [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(timeLabel.mas_right).offset(kFSTFastingTimesRowPencilGap);
                make.centerY.equalTo(timeLabel);
                make.size.mas_equalTo(CGSizeMake(kFSTFastingTimesRowPencilSize, kFSTFastingTimesRowPencilSize));
                make.right.lessThanOrEqualTo(column);
            }];
        }
    } else {
        if (editButton) {
            [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(column);
                make.centerY.equalTo(timeLabel);
                make.size.mas_equalTo(CGSizeMake(kFSTFastingTimesRowPencilSize, kFSTFastingTimesRowPencilSize));
            }];
            [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(editButton.mas_left).offset(-kFSTFastingTimesRowPencilGap);
                make.top.equalTo(captionLabel.mas_bottom).offset(kFSTFastingTimesRowCaptionTimeGap);
                make.height.equalTo(@(kFSTFastingTimesRowTimeHeight));
                make.width.lessThanOrEqualTo(@(kFSTFastingTimesRowTimeWidth));
                make.left.greaterThanOrEqualTo(column);
            }];
        } else {
            [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(column);
                make.top.equalTo(captionLabel.mas_bottom).offset(kFSTFastingTimesRowCaptionTimeGap);
                make.height.equalTo(@(kFSTFastingTimesRowTimeHeight));
                make.width.lessThanOrEqualTo(@(kFSTFastingTimesRowTimeWidth));
                make.left.greaterThanOrEqualTo(column);
            }];
        }
    }

    return column;
}

- (UILabel *)timeLabelWithColor:(UIColor *)color {
    UILabel *label = [UILabel new];
    label.font      = FSTFontAvenirDemiBold(15);
    label.textColor = color;
    label.text      = @"--";
    label.textAlignment = NSTextAlignmentLeft;
    label.adjustsFontSizeToFitWidth = NO;
    label.lineBreakMode             = NSLineBreakByClipping;
    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    return label;
}

- (UIButton *)editButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *pencilImage = [[UIImage imageNamed:@"edit_pencil"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [button setImage:pencilImage forState:UIControlStateNormal];
    button.imageView.contentMode      = UIViewContentModeScaleAspectFit;
    return button;
}

#pragma mark - 事件

- (void)handleStartEditTapped { if (self.onEditStartTapped) self.onEditStartTapped(); }
- (void)handleEndEditTapped   { if (self.onEditEndTapped)   self.onEditEndTapped();   }

@end
