//
//  FSTDailyPlanPickerView.m
//  Fasting
//

#import "FSTDailyPlanPickerView.h"
#import "FSTPlanSelectListView.h"
#import "FSTPlan.h"
#import "FSTTheme.h"

#pragma mark - Layout constants

// Subtitle
static const CGFloat kSubtitleTopInset = 24;

// List 容器
static const CGFloat kListTopOffset = 34;
static const CGFloat kListSideInset = 22;
static const CGFloat kListBottomMin = 40;

// 计划卡列表的宽高比（与 FSTPlanSelectListView 内部 2×2 网格一致）
static const CGFloat kListAspectNumerator   = 716.0;
static const CGFloat kListAspectDenominator = 335.0;
static const CGFloat kListAspectOffset      = 48.0;

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
    self.subtitleLabel.text          = @"Choose one to start";
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
        make.top.equalTo(self).offset(kSubtitleTopInset);
        make.centerX.equalTo(self);
    }];
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subtitleLabel.mas_bottom).offset(kListTopOffset);
        make.left.right.equalTo(self).inset(kListSideInset);
        make.height.equalTo(self.listView.mas_width).multipliedBy(kListAspectNumerator / kListAspectDenominator).offset(kListAspectOffset);
        make.bottom.lessThanOrEqualTo(self).offset(-kListBottomMin);
    }];
}

@end
