//
//  FSTMealDiaryRootView.m
//  Fasting
//

#import "FSTMealDiaryRootView.h"
#import "FSTTheme.h"

@interface FSTMealDiaryRootView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *confirmButton;
@end

@implementation FSTMealDiaryRootView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 视图组装

- (void)setupSubviews {
    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    self.confirmButton = [UIButton fst_pillButtonWithTitle:@"Confirm" style:FSTPillButtonStyleYellow];
    [self.confirmButton addTarget:self action:@selector(handleConfirmTapped)
                 forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.confirmButton];
}

- (void)setupConstraints {
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self).inset(38);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-16);
        make.height.equalTo(@64);
    }];
}

#pragma mark - Mount API

- (void)mountTopBarView:(UIView *)topBarView timelineStack:(UIStackView *)timelineStack {
    [self addSubview:topBarView];
    [self.contentView addSubview:timelineStack];

    [topBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideTop).offset(72);
    }];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topBarView.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    [timelineStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(18);
        make.left.right.equalTo(self.contentView).inset(24);
        make.bottom.equalTo(self.contentView).offset(-140);
    }];
}

#pragma mark - 事件

- (void)handleConfirmTapped {
    if (self.onConfirmTapped) self.onConfirmTapped();
}

@end
