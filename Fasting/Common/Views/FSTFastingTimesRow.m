//
//  FSTFastingTimesRow.m
//  Fasting
//

#import "FSTFastingTimesRow.h"
#import "FSTTheme.h"
#import <Masonry/Masonry.h>

#pragma mark - Layout constants

// Time label
static const CGFloat kTimeWidth       = 127;
static const CGFloat kTimeHeight      = 20;
static const CGFloat kCaptionTimeGap  = 10;

// 编辑按钮（铅笔）
static const CGFloat kPencilSize = 24;
static const CGFloat kPencilGap  = 6;

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

    UILabel *captionLabel = [UILabel fst_labelWithText:caption font:FSTFontRegular(14) color:[UIColor fst_textSecondary]];
    captionLabel.adjustsFontSizeToFitWidth = YES;
    captionLabel.minimumScaleFactor = 0.82;
    [column fst_addSubviews:@[captionLabel, timeLabel]];

    UIButton *editButton = nil;
    if (self.editable) {
        editButton = [UIButton fst_plainImageButtonWithImageNamed:@"edit_pencil"
                                                             size:CGSizeMake(kPencilSize, kPencilSize)
                                                        tintColor:nil];
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
            make.top.equalTo(captionLabel.mas_bottom).offset(kCaptionTimeGap);
            make.height.equalTo(@(kTimeHeight));
            make.width.lessThanOrEqualTo(@(kTimeWidth));
        }];
        if (editButton) {
            [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(timeLabel.mas_right).offset(kPencilGap);
                make.centerY.equalTo(timeLabel);
                make.size.mas_equalTo(CGSizeMake(kPencilSize, kPencilSize));
                make.right.lessThanOrEqualTo(column);
            }];
        }
    } else {
        if (editButton) {
            [editButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(column);
                make.centerY.equalTo(timeLabel);
                make.size.mas_equalTo(CGSizeMake(kPencilSize, kPencilSize));
            }];
            [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(editButton.mas_left).offset(-kPencilGap);
                make.top.equalTo(captionLabel.mas_bottom).offset(kCaptionTimeGap);
                make.height.equalTo(@(kTimeHeight));
                make.width.lessThanOrEqualTo(@(kTimeWidth));
                make.left.greaterThanOrEqualTo(column);
            }];
        } else {
            [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(column);
                make.top.equalTo(captionLabel.mas_bottom).offset(kCaptionTimeGap);
                make.height.equalTo(@(kTimeHeight));
                make.width.lessThanOrEqualTo(@(kTimeWidth));
                make.left.greaterThanOrEqualTo(column);
            }];
        }
    }

    return column;
}

- (UILabel *)timeLabelWithColor:(UIColor *)color {
    UILabel *label = [UILabel fst_labelWithText:@"--" font:FSTFontAvenirDemiBold(15) color:color alignment:NSTextAlignmentLeft];
    label.lineBreakMode = NSLineBreakByClipping;
    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    return label;
}

#pragma mark - 事件

- (void)handleStartEditTapped { if (self.onEditStartTapped) self.onEditStartTapped(); }
- (void)handleEndEditTapped   { if (self.onEditEndTapped)   self.onEditEndTapped();   }

@end
