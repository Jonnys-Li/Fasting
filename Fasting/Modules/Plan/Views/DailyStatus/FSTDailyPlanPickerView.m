//
//  FSTDailyPlanPickerView.m
//  Fasting
//

#import "FSTDailyPlanPickerView.h"
#import "FSTPlanSelectListView.h"
#import "FSTPlan.h"
#import "FSTTheme.h"
#import "UIColor+FST.h"

static const CGFloat kFSTDailyPlanPickerSubtitleTopInset = 24;
static const CGFloat kFSTDailyPlanPickerListTopOffset    = 34;
static const CGFloat kFSTDailyPlanPickerListSideInset    = 22;
static const CGFloat kFSTDailyPlanPickerListBottomMin    = 40;
// 计划卡列表的宽高比（与 FSTPlanSelectListView 内部 2×2 网格一致）
static const CGFloat kFSTDailyPlanPickerListAspectNumerator   = 716.0;
static const CGFloat kFSTDailyPlanPickerListAspectDenominator = 335.0;
static const CGFloat kFSTDailyPlanPickerListAspectOffset      = 48.0;

@interface FSTDailyPlanPickerView ()
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) FSTPlanSelectListView *listView;
@end

@implementation FSTDailyPlanPickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self buildSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)buildSubviews {
    self.subtitleLabel = [UILabel new];
    self.subtitleLabel.text          = @"选择一个来开始吧";
    self.subtitleLabel.font          = FSTFontBold(21);
    self.subtitleLabel.textColor     = [UIColor fst_textPrimary];
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.subtitleLabel];

    self.listView = [FSTPlanSelectListView new];
    __weak typeof(self) weakSelf = self;
    self.listView.onPlanPicked = ^(FSTPlan *picked) {
        if (weakSelf.onPlanPicked) weakSelf.onPlanPicked(picked);
    };
    [self addSubview:self.listView];
}

- (void)setupConstraints {
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(kFSTDailyPlanPickerSubtitleTopInset);
        make.centerX.equalTo(self);
    }];
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subtitleLabel.mas_bottom).offset(kFSTDailyPlanPickerListTopOffset);
        make.left.right.equalTo(self).inset(kFSTDailyPlanPickerListSideInset);
        make.height.equalTo(self.listView.mas_width).multipliedBy(kFSTDailyPlanPickerListAspectNumerator / kFSTDailyPlanPickerListAspectDenominator).offset(kFSTDailyPlanPickerListAspectOffset);
        make.bottom.lessThanOrEqualTo(self).offset(-kFSTDailyPlanPickerListBottomMin);
    }];
}

@end
