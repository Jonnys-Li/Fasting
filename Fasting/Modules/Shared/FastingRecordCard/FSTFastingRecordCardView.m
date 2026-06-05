//
//  FSTFastingRecordCardView.m
//  Fasting
//

#import "FSTFastingRecordCardView.h"
#import "FSTTheme.h"
#import "UIImage+FSTHelpers.h"

static CGFloat const kFSTFastingRecordCardPadding = 20.0;

static NSString *FSTFastingRecordCardLowercaseMeridiem(NSString *value) {
    return [[value stringByReplacingOccurrencesOfString:@" AM" withString:@" am"] stringByReplacingOccurrencesOfString:@" PM" withString:@" pm"];
}

static NSString *FSTFastingRecordCardFullTime(NSDate *date) {
    if (!date) return @"";
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMM d, h:mm a";
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    });
    return FSTFastingRecordCardLowercaseMeridiem([formatter stringFromDate:date]);
}

static NSString *FSTFastingRecordCardEndTime(NSDate *startDate, NSDate *endDate) {
    if (!endDate) return @"";
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if (startDate && ![calendar isDate:startDate inSameDayAsDate:endDate]) {
        return FSTFastingRecordCardFullTime(endDate);
    }
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"hh:mm a";
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    });
    return FSTFastingRecordCardLowercaseMeridiem([formatter stringFromDate:endDate]);
}

/// 把 record 的 feelingLevel 钳到合法范围并 cast 为 FSTFastingRating。
/// 两个枚举数值含义已对齐（0=Hard / 1=Ok / 2=Easy），此函数只做防御性钳制。
static FSTFastingRating FSTFastingRecordRatingFromFeelingLevel(NSInteger feelingLevel) {
    if (feelingLevel <= FSTFastingRatingHard) return FSTFastingRatingHard;
    if (feelingLevel >= FSTFastingRatingEasy) return FSTFastingRatingEasy;
    return (FSTFastingRating)feelingLevel;
}

@interface FSTFastingRecordCardView ()
@property (nonatomic, strong) UIImageView *badgeImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *streakImageView;
@property (nonatomic, strong) UIControl *moreControl;
@property (nonatomic, strong) UIImageView *chevronImageView;
@property (nonatomic, strong) UIView *dividerView;
@property (nonatomic, strong) UILabel *hoursValueLabel;
@property (nonatomic, strong) UILabel *hoursUnitLabel;
@property (nonatomic, strong) UILabel *minutesValueLabel;
@property (nonatomic, strong) UILabel *minutesUnitLabel;
@property (nonatomic, strong) UIView *ratingContainerView;
@property (nonatomic, strong) UIImageView *ratingImageView;
@property (nonatomic, strong) UIView *timelinePanelView;
@property (nonatomic, strong) UIView *startDotView;
@property (nonatomic, strong) UIImageView *connectorImageView;
@property (nonatomic, strong) UIImageView *endDotImageView;
@property (nonatomic, strong) UILabel *startLabel;
@property (nonatomic, strong) UILabel *startValueLabel;
@property (nonatomic, strong) UILabel *endLabel;
@property (nonatomic, strong) UILabel *endValueLabel;
@end

@implementation FSTFastingRecordCardView

#pragma mark - 初始化 / 构建

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor fst_timelineGreen];
        self.layer.cornerRadius = FSTRadiusL;
        self.layer.masksToBounds = YES;
        [self addTarget:self action:@selector(handleMoreTapped) forControlEvents:UIControlEventTouchUpInside];
        [self setupSubviews];
        self.titleText = @"Fasting";
        self.hoursText = @"";
        self.minutesText = @"";
        self.startTimeText = @"";
        self.endTimeText = @"";
        self.rating = FSTFastingRatingOk;
    }
    return self;
}

- (void)setupSubviews {
    self.badgeImageView = [self originalImageViewNamed:@"tl_target_badge" fit:YES];
    self.titleLabel = [UILabel fst_labelWithText:nil font:FSTFontSubhead() color:[UIColor whiteColor]];
    self.streakImageView = [self originalImageViewNamed:@"tl_streak_bolts" fit:YES];

    self.moreControl = [[UIControl alloc] init];
    [self.moreControl addTarget:self action:@selector(handleMoreTapped) forControlEvents:UIControlEventTouchUpInside];

    self.chevronImageView = [self originalImageViewNamed:@"tl_chevron" fit:YES];

    self.dividerView = [UIView fst_separatorLineWithColor:[[UIColor whiteColor] colorWithAlphaComponent:0.2]];
    self.dividerView.userInteractionEnabled = NO;

    self.hoursValueLabel   = [self durationValueLabel];
    self.hoursUnitLabel    = [self durationUnitLabelWithText:@"hours"];
    self.minutesValueLabel = [self durationValueLabel];
    self.minutesUnitLabel  = [self durationUnitLabelWithText:@"mins"];

    self.ratingContainerView = [[UIView alloc] init];
    self.ratingContainerView.userInteractionEnabled = NO;
    self.ratingImageView = [self originalImageViewNamed:@"tl_rating_ok" fit:YES];

    self.timelinePanelView = [UIView fst_containerWithBackground:[[UIColor blackColor] colorWithAlphaComponent:0.06] radius:FSTRadiusM];
    self.timelinePanelView.userInteractionEnabled = NO;

    self.startDotView = [UIView fst_containerWithBackground:[UIColor fst_timelineInnerGreen] radius:4.0];
    self.connectorImageView = [self originalImageViewNamed:@"tl_timeline_connector" fit:NO];
    self.connectorImageView.contentMode = UIViewContentModeScaleToFill;
    self.endDotImageView = [self originalImageViewNamed:@"tl_timeline_dot" fit:YES];

    self.startLabel      = [self timelineCaptionLabelWithText:@"Start"];
    self.startValueLabel = [self timelineValueLabel];
    self.endLabel        = [self timelineCaptionLabelWithText:@"End"];
    self.endValueLabel   = [self timelineValueLabel];

    [self.moreControl addSubview:self.chevronImageView];
    [self.ratingContainerView addSubview:self.ratingImageView];
    [self.timelinePanelView fst_addSubviews:@[self.startDotView, self.connectorImageView, self.endDotImageView,
                                              self.startLabel, self.startValueLabel, self.endLabel, self.endValueLabel]];
    [self fst_addSubviews:@[self.badgeImageView, self.titleLabel, self.streakImageView, self.moreControl,
                            self.dividerView, self.hoursValueLabel, self.hoursUnitLabel,
                            self.minutesValueLabel, self.minutesUnitLabel,
                            self.ratingContainerView, self.timelinePanelView]];

    [self installConstraints];
}

#pragma mark - 子视图工厂

- (UIImageView *)originalImageViewNamed:(NSString *)name fit:(BOOL)aspectFit {
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:name]];
    if (aspectFit) view.contentMode = UIViewContentModeScaleAspectFit;
    return view;
}

- (UILabel *)durationValueLabel {
    UILabel *label = [UILabel fst_labelWithText:nil
                                           font:[UIFont monospacedDigitSystemFontOfSize:32 weight:UIFontWeightBold]
                                          color:[UIColor whiteColor]];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.75;
    return label;
}

- (UILabel *)durationUnitLabelWithText:(NSString *)text {
    return [UILabel fst_labelWithText:text font:FSTFontRegular(16) color:[UIColor whiteColor]];
}

- (UILabel *)timelineCaptionLabelWithText:(NSString *)text {
    return [UILabel fst_labelWithText:text font:FSTFontBody() color:[[UIColor whiteColor] colorWithAlphaComponent:0.75]];
}

- (UILabel *)timelineValueLabel {
    UILabel *label = [UILabel fst_labelWithText:nil font:FSTFontBold(15) color:[UIColor whiteColor]];
    label.textAlignment = NSTextAlignmentRight;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.75;
    return label;
}

#pragma mark - 约束

- (void)installConstraints {
    [self.badgeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self).offset(kFSTFastingRecordCardPadding);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.badgeImageView.mas_right).offset(8);
        make.centerY.equalTo(self.badgeImageView);
    }];
    [self.moreControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-8);
        make.centerY.equalTo(self.badgeImageView);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.chevronImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.moreControl);
        make.size.mas_equalTo(CGSizeMake(8, 14));
    }];
    [self.streakImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel.mas_right).offset(12);
        make.centerY.equalTo(self.badgeImageView);
        make.size.mas_equalTo(CGSizeMake(47, 14));
        make.right.lessThanOrEqualTo(self.moreControl.mas_left).offset(-8);
    }];
    [self.dividerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.badgeImageView.mas_bottom).offset(16);
        make.left.right.equalTo(self).inset(kFSTFastingRecordCardPadding);
        make.height.equalTo(@1);
    }];
    [self.hoursValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dividerView.mas_bottom).offset(18);
        make.left.equalTo(self).offset(kFSTFastingRecordCardPadding);
        make.width.greaterThanOrEqualTo(@18);
    }];
    [self.hoursUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hoursValueLabel.mas_right).offset(5);
        make.centerY.equalTo(self.hoursValueLabel).offset(5);
    }];
    [self.minutesValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.hoursUnitLabel.mas_right).offset(16);
        make.centerY.equalTo(self.hoursValueLabel);
        make.width.greaterThanOrEqualTo(@18);
    }];
    [self.minutesUnitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.minutesValueLabel.mas_right).offset(5);
        make.centerY.equalTo(self.minutesValueLabel).offset(5);
        make.right.lessThanOrEqualTo(self.ratingContainerView.mas_left).offset(-12);
    }];
    [self.ratingContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-16);
        make.centerY.equalTo(self.hoursValueLabel).offset(2);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [self.ratingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.ratingContainerView);
        make.size.mas_equalTo(CGSizeMake(34, 34));
    }];
    [self.timelinePanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.hoursValueLabel.mas_bottom).offset(18);
        make.left.right.equalTo(self).inset(kFSTFastingRecordCardPadding);
        make.height.equalTo(@85);
        make.bottom.lessThanOrEqualTo(self).offset(-kFSTFastingRecordCardPadding);
    }];
    [self.startDotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.timelinePanelView).offset(18);
        make.centerY.equalTo(self.timelinePanelView.mas_top).offset(25);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    }];
    [self.endDotImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.startDotView);
        make.centerY.equalTo(self.timelinePanelView.mas_bottom).offset(-25);
        make.size.mas_equalTo(CGSizeMake(8, 8));
    }];
    [self.connectorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.startDotView);
        make.top.equalTo(self.startDotView.mas_bottom).offset(5);
        make.bottom.equalTo(self.endDotImageView.mas_top).offset(-5);
        make.width.equalTo(@2);
    }];
    [self.startLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.startDotView.mas_right).offset(16);
        make.centerY.equalTo(self.startDotView);
    }];
    [self.startValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.startLabel.mas_right).offset(12);
        make.right.equalTo(self.timelinePanelView).offset(-18);
        make.centerY.equalTo(self.startLabel);
    }];
    [self.endLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.startLabel);
        make.centerY.equalTo(self.endDotImageView);
    }];
    [self.endValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(self.endLabel.mas_right).offset(12);
        make.right.equalTo(self.startValueLabel);
        make.centerY.equalTo(self.endLabel);
    }];
}

#pragma mark - 数据下发

- (void)setTitleText:(NSString *)titleText {
    _titleText = [titleText copy];
    self.titleLabel.text = _titleText ?: @"";
}

- (void)setHoursText:(NSString *)hoursText {
    _hoursText = [hoursText copy];
    self.hoursValueLabel.text = _hoursText ?: @"";
    self.hoursUnitLabel.text = _hoursText.length ? @"hours" : @"";
}

- (void)setMinutesText:(NSString *)minutesText {
    _minutesText = [minutesText copy];
    self.minutesValueLabel.text = _minutesText ?: @"";
    self.minutesUnitLabel.text = _minutesText.length ? @"mins" : @"";
}

- (void)setStartTimeText:(NSString *)startTimeText {
    _startTimeText = [startTimeText copy];
    self.startValueLabel.text = _startTimeText ?: @"";
}

- (void)setEndTimeText:(NSString *)endTimeText {
    _endTimeText = [endTimeText copy];
    self.endValueLabel.text = _endTimeText ?: @"";
}

- (void)setRating:(FSTFastingRating)rating {
    _rating = rating;
    self.ratingImageView.image = [UIImage fst_ratingImageForLevel:rating];
}

- (void)configureWithRecord:(FSTFastingRecord *)record {
    if (!record) {
        self.hoursText = @"";
        self.minutesText = @"";
        self.startTimeText = @"";
        self.endTimeText = @"";
        self.rating = FSTFastingRatingOk;
        return;
    }

    NSInteger totalMinutes = MAX(1, (NSInteger)llround(record.durationSeconds / 60.0));
    self.hoursText = [NSString stringWithFormat:@"%ld", (long)(totalMinutes / 60)];
    self.minutesText = [NSString stringWithFormat:@"%ld", (long)(totalMinutes % 60)];
    self.startTimeText = FSTFastingRecordCardFullTime(record.startDate);
    self.endTimeText = FSTFastingRecordCardEndTime(record.startDate, record.endDate);
    self.rating = FSTFastingRecordRatingFromFeelingLevel(record.feelingLevel);
}

#pragma mark - 事件

- (void)handleMoreTapped {
    if (self.onMoreTapped) {
        self.onMoreTapped();
    }
}

@end
