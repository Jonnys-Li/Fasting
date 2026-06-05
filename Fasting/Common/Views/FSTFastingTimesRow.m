//
//  FSTFastingTimesRow.m
//  Fasting
//

#import "FSTFastingTimesRow.h"
#import "FSTTheme.h"
#import <Masonry/Masonry.h>

#pragma mark - Layout constants

static const CGFloat kTimeWidth       = 127;
static const CGFloat kTimeHeight      = 20;
static const CGFloat kCaptionTimeGap  = 10;

static const CGFloat kPencilSize = 24;
static const CGFloat kPencilGap  = 6;

@interface FSTFastingTimesRow ()
@property (nonatomic, strong) UIView *leftColumn;
@property (nonatomic, strong) UIView *rightColumn;
@property (nonatomic, strong) UILabel *startCaptionLabel;
@property (nonatomic, strong) UILabel *endCaptionLabel;
@property (nonatomic, strong) UILabel *startTimeLabel;
@property (nonatomic, strong) UILabel *endTimeLabel;
@property (nonatomic, strong) UIButton *startEditButton;
@property (nonatomic, strong) UIButton *endEditButton;
@end

@implementation FSTFastingTimesRow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _editable = YES;
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 视图组装

- (void)setupSubviews {
    self.leftColumn  = [[UIView alloc] init];
    self.rightColumn = [[UIView alloc] init];

    self.startCaptionLabel = [UILabel fst_labelWithText:@"" font:FSTFontRegular(14) color:[UIColor fst_textSecondary]];
    self.startCaptionLabel.adjustsFontSizeToFitWidth = YES;
    self.startCaptionLabel.minimumScaleFactor = 0.82;

    self.endCaptionLabel = [UILabel fst_labelWithText:@"" font:FSTFontRegular(14) color:[UIColor fst_textSecondary]];
    self.endCaptionLabel.adjustsFontSizeToFitWidth = YES;
    self.endCaptionLabel.minimumScaleFactor = 0.82;

    self.startTimeLabel = [self timeLabelWithColor:[UIColor fst_textPrimary]];
    self.endTimeLabel   = [self timeLabelWithColor:[UIColor fst_textPrimary]];

    self.startEditButton = [UIButton fst_plainImageButtonWithImageNamed:@"edit_pencil"
                                                                   size:CGSizeMake(kPencilSize, kPencilSize)
                                                              tintColor:nil];
    [self.startEditButton addTarget:self action:@selector(handleStartEditTapped)
                   forControlEvents:UIControlEventTouchUpInside];

    self.endEditButton = [UIButton fst_plainImageButtonWithImageNamed:@"edit_pencil"
                                                                 size:CGSizeMake(kPencilSize, kPencilSize)
                                                            tintColor:nil];
    [self.endEditButton addTarget:self action:@selector(handleEndEditTapped)
                 forControlEvents:UIControlEventTouchUpInside];

    [self fst_addSubviews:@[self.leftColumn, self.rightColumn]];
    [self.leftColumn fst_addSubviews:@[self.startCaptionLabel, self.startTimeLabel, self.startEditButton]];
    [self.rightColumn fst_addSubviews:@[self.endCaptionLabel, self.endTimeLabel, self.endEditButton]];
}

- (void)setupConstraints {
    [self.leftColumn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.width.equalTo(self.rightColumn);
    }];
    [self.rightColumn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self);
        make.left.equalTo(self.leftColumn.mas_right);
    }];

    [self.startCaptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.leftColumn);
        make.right.lessThanOrEqualTo(self.leftColumn);
    }];
    [self.startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftColumn);
        make.top.equalTo(self.startCaptionLabel.mas_bottom).offset(kCaptionTimeGap);
        make.height.equalTo(@(kTimeHeight));
        make.width.lessThanOrEqualTo(@(kTimeWidth));
    }];
    [self.startEditButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.startTimeLabel.mas_right).offset(kPencilGap);
        make.centerY.equalTo(self.startTimeLabel);
        make.size.mas_equalTo(CGSizeMake(kPencilSize, kPencilSize));
        make.right.lessThanOrEqualTo(self.leftColumn);
    }];

    [self.endCaptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.rightColumn);
        make.left.greaterThanOrEqualTo(self.rightColumn);
    }];
    [self.endEditButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.rightColumn);
        make.centerY.equalTo(self.endTimeLabel);
        make.size.mas_equalTo(CGSizeMake(kPencilSize, kPencilSize));
    }];
    [self.endTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.endEditButton.mas_left).offset(-kPencilGap);
        make.top.equalTo(self.endCaptionLabel.mas_bottom).offset(kCaptionTimeGap);
        make.height.equalTo(@(kTimeHeight));
        make.width.lessThanOrEqualTo(@(kTimeWidth));
        make.left.greaterThanOrEqualTo(self.rightColumn);
    }];
}

#pragma mark - 属性同步

- (void)setStartCaption:(NSString *)startCaption {
    _startCaption = [startCaption copy];
    self.startCaptionLabel.text = startCaption;
}

- (void)setEndCaption:(NSString *)endCaption {
    _endCaption = [endCaption copy];
    self.endCaptionLabel.text = endCaption;
}

- (void)setEditable:(BOOL)editable {
    _editable = editable;
    self.startEditButton.hidden = !editable;
    self.endEditButton.hidden   = !editable;
}

- (void)setStartHighlightColor:(UIColor *)startHighlightColor {
    _startHighlightColor = startHighlightColor;
    self.startTimeLabel.textColor = startHighlightColor ?: [UIColor fst_textPrimary];
}

- (void)setStartText:(NSString *)startText {
    _startText = [startText copy];
    self.startTimeLabel.text = startText ?: @"--";
}

- (void)setEndText:(NSString *)endText {
    _endText = [endText copy];
    self.endTimeLabel.text = endText ?: @"--";
}

- (UILabel *)timeLabelWithColor:(UIColor *)color {
    UILabel *label = [UILabel fst_labelWithText:@"--" font:FSTFontAvenirDemiBold(15) color:color];
    label.textAlignment = NSTextAlignmentLeft;
    label.lineBreakMode = NSLineBreakByClipping;
    [label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    return label;
}

#pragma mark - 事件

- (void)handleStartEditTapped {
    if (self.onEditStartTapped) self.onEditStartTapped();
}
- (void)handleEndEditTapped {
    if (self.onEditEndTapped)   self.onEditEndTapped();
}

@end
