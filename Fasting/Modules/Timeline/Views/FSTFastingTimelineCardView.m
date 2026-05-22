//
//  FSTFastingTimelineCardView.m
//  Fasting
//

#import "FSTFastingTimelineCardView.h"
#import "FSTTheme.h"
#import "UIImage+FSTHelpers.h"

static CGFloat const kFSTFastingTimelineCardPadding = 20.0;

static NSString *FSTTimelineCardLowercaseMeridiem(NSString *value) {
    return [[value stringByReplacingOccurrencesOfString:@" AM" withString:@" am"] stringByReplacingOccurrencesOfString:@" PM" withString:@" pm"];
}

static NSString *FSTTimelineCardFullTime(NSDate *date) {
    if (!date) return @"";
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"MMM d, h:mm a";
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    });
    return FSTTimelineCardLowercaseMeridiem([formatter stringFromDate:date]);
}

static NSString *FSTTimelineCardEndTime(NSDate *startDate, NSDate *endDate) {
    if (!endDate) return @"";
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if (startDate && ![calendar isDate:startDate inSameDayAsDate:endDate]) {
        return FSTTimelineCardFullTime(endDate);
    }
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.dateFormat = @"hh:mm a";
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    });
    return FSTTimelineCardLowercaseMeridiem([formatter stringFromDate:endDate]);
}

/// 把 record 的 feelingLevel 钳到合法范围并 cast 为 FSTFastingRating。
/// 两个枚举数值含义已对齐（0=Hard / 1=Ok / 2=Easy），此函数只做防御性钳制。
static FSTFastingRating FSTTimelineRatingFromFeelingLevel(NSInteger feelingLevel) {
    if (feelingLevel <= FSTFastingRatingHard) return FSTFastingRatingHard;
    if (feelingLevel >= FSTFastingRatingEasy) return FSTFastingRatingEasy;
    return (FSTFastingRating)feelingLevel;
}

@interface FSTFastingTimelineCardView ()
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

@implementation FSTFastingTimelineCardView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor fst_timelineGreen];
        self.layer.cornerRadius = 22.0;
        self.layer.masksToBounds = YES;
        [self addTarget:self action:@selector(handleMoreTapped) forControlEvents:UIControlEventTouchUpInside];
        [self buildSubviews];
        self.titleText = @"Fasting";
        self.hoursText = @"";
        self.minutesText = @"";
        self.startTimeText = @"";
        self.endTimeText = @"";
        self.rating = FSTFastingRatingOk;
    }
    return self;
}

- (void)buildSubviews {
    self.badgeImageView = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:@"tl_target_badge"]];
    self.badgeImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.badgeImageView];

    self.titleLabel = [UILabel new];
    self.titleLabel.font = FSTFontBold(20);
    self.titleLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.titleLabel];

    self.streakImageView = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:@"tl_streak_bolts"]];
    self.streakImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.streakImageView];

    self.moreControl = [UIControl new];
    [self.moreControl addTarget:self action:@selector(handleMoreTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.moreControl];

    self.chevronImageView = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:@"tl_chevron"]];
    self.chevronImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.moreControl addSubview:self.chevronImageView];

    self.dividerView = [UIView new];
    self.dividerView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    self.dividerView.userInteractionEnabled = NO;
    [self addSubview:self.dividerView];

    self.hoursValueLabel = [self durationValueLabel];
    self.hoursUnitLabel = [self durationUnitLabelWithText:@"hours"];
    self.minutesValueLabel = [self durationValueLabel];
    self.minutesUnitLabel = [self durationUnitLabelWithText:@"mins"];
    [self addSubview:self.hoursValueLabel];
    [self addSubview:self.hoursUnitLabel];
    [self addSubview:self.minutesValueLabel];
    [self addSubview:self.minutesUnitLabel];

    self.ratingContainerView = [UIView new];
    self.ratingContainerView.userInteractionEnabled = NO;
    [self addSubview:self.ratingContainerView];

    self.ratingImageView = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:@"tl_rating_ok"]];
    self.ratingImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.ratingContainerView addSubview:self.ratingImageView];

    self.timelinePanelView = [UIView new];
    self.timelinePanelView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.06];
    self.timelinePanelView.layer.cornerRadius = 14.0;
    self.timelinePanelView.userInteractionEnabled = NO;
    [self addSubview:self.timelinePanelView];

    self.startDotView = [UIView new];
    self.startDotView.backgroundColor = [UIColor fst_timelineInnerGreen];
    self.startDotView.layer.cornerRadius = 4.0;
    [self.timelinePanelView addSubview:self.startDotView];

    self.connectorImageView = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:@"tl_timeline_connector"]];
    self.connectorImageView.contentMode = UIViewContentModeScaleToFill;
    [self.timelinePanelView addSubview:self.connectorImageView];

    self.endDotImageView = [[UIImageView alloc] initWithImage:[UIImage fst_originalImageNamed:@"tl_timeline_dot"]];
    self.endDotImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.timelinePanelView addSubview:self.endDotImageView];

    self.startLabel = [self timelineCaptionLabelWithText:@"Start"];
    self.startValueLabel = [self timelineValueLabel];
    self.endLabel = [self timelineCaptionLabelWithText:@"End"];
    self.endValueLabel = [self timelineValueLabel];
    [self.timelinePanelView addSubview:self.startLabel];
    [self.timelinePanelView addSubview:self.startValueLabel];
    [self.timelinePanelView addSubview:self.endLabel];
    [self.timelinePanelView addSubview:self.endValueLabel];

    [self installConstraints];
}

- (UILabel *)durationValueLabel {
    UILabel *label = [UILabel new];
    label.font = [UIFont monospacedDigitSystemFontOfSize:32 weight:UIFontWeightBold];
    label.textColor = [UIColor whiteColor];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.75;
    return label;
}

- (UILabel *)durationUnitLabelWithText:(NSString *)text {
    UILabel *label = [UILabel new];
    label.font = FSTFontRegular(16);
    label.textColor = [UIColor whiteColor];
    label.text = text;
    return label;
}

- (UILabel *)timelineCaptionLabelWithText:(NSString *)text {
    UILabel *label = [UILabel new];
    label.font = FSTFontRegular(15);
    label.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
    label.text = text;
    return label;
}

- (UILabel *)timelineValueLabel {
    UILabel *label = [UILabel new];
    label.font = FSTFontBold(15);
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentRight;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.75;
    return label;
}

- (void)installConstraints {
    [self.badgeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self).offset(kFSTFastingTimelineCardPadding);
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
        make.left.right.equalTo(self).inset(kFSTFastingTimelineCardPadding);
        make.height.equalTo(@1);
    }];
    [self.hoursValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dividerView.mas_bottom).offset(18);
        make.left.equalTo(self).offset(kFSTFastingTimelineCardPadding);
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
        make.left.right.equalTo(self).inset(kFSTFastingTimelineCardPadding);
        make.height.equalTo(@85);
        make.bottom.lessThanOrEqualTo(self).offset(-kFSTFastingTimelineCardPadding);
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
    NSString *imageName = @"tl_rating_easy";
    if (rating == FSTFastingRatingOk) {
        imageName = @"tl_rating_ok";
    } else if (rating == FSTFastingRatingHard) {
        imageName = @"tl_rating_hard";
    }
    self.ratingImageView.image = [UIImage fst_originalImageNamed:imageName];
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
    self.startTimeText = FSTTimelineCardFullTime(record.startDate);
    self.endTimeText = FSTTimelineCardEndTime(record.startDate, record.endDate);
    self.rating = FSTTimelineRatingFromFeelingLevel(record.feelingLevel);
}

- (void)handleMoreTapped {
    if (self.onMoreTapped) {
        self.onMoreTapped();
    }
}

@end
