//
//  FSTFastingIdlePickerView.m
//  Fasting
//

#import "FSTFastingIdlePickerView.h"
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

// 计划卡列表的宽高比（与 FSTPlanSelectListView 内部竖排 4 卡一致：4×179 + 3×16）
static const CGFloat kListAspectNumerator   = 716.0;
static const CGFloat kListAspectDenominator = 335.0;
static const CGFloat kListAspectOffset      = 48.0;

@interface FSTFastingIdlePickerView ()
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) FSTPlanSelectListView *listView;
@end

@implementation FSTFastingIdlePickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupSubviews {
    self.subtitleLabel = [UILabel fst_labelWithText:@"Choose one to start"
                                                font:FSTFontBold(21)
                                               color:[UIColor fst_textPrimary]
                                           alignment:NSTextAlignmentCenter];
    [self addSubview:self.subtitleLabel];

    self.listView = [[FSTPlanSelectListView alloc] init];
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
