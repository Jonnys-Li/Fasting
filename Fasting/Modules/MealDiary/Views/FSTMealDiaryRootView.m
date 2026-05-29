//
//  FSTMealDiaryRootView.m
//  Fasting
//

#import "FSTMealDiaryRootView.h"
#import "FSTMealDiaryTopBarView.h"
#import "FSTTheme.h"

@interface FSTMealDiaryRootView ()
@property (nonatomic, strong, readwrite) FSTMealDiaryTopBarView *topBarView;
@property (nonatomic, strong, readwrite) UIStackView *timelineStack;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIButton *confirmButton;
@end

@implementation FSTMealDiaryRootView

#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self buildTopBar];
        [self buildScrollContent];
        [self buildConfirmButton];
        [self setupConstraints];
    }
    return self;
}

#pragma mark - 视图组装

/// 顶部固定栏：使用独立 FSTMealDiaryTopBarView 组件。
- (void)buildTopBar {
    self.topBarView = [FSTMealDiaryTopBarView new];
    [self addSubview:self.topBarView];
}

/// 滚动容器及垂直 stack。
- (void)buildScrollContent {
    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    self.timelineStack = [UIStackView new];
    self.timelineStack.axis = UILayoutConstraintAxisVertical;
    self.timelineStack.spacing = 0;
    [self.contentView addSubview:self.timelineStack];
}

/// 底部黄色"确认"按钮。
- (void)buildConfirmButton {
    self.confirmButton = [UIButton fst_pillButtonWithTitle:@"Confirm" style:FSTPillButtonStyleYellow];
    [self.confirmButton addTarget:self action:@selector(handleConfirmTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.confirmButton];
}

#pragma mark - 约束

- (void)setupConstraints {
    [self.topBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideTop).offset(72);
    }];

    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBarView.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    [self.timelineStack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(18);
        make.left.right.equalTo(self.contentView).inset(24);
        make.bottom.equalTo(self.contentView).offset(-140);
    }];

    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self).inset(38);
        make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-16);
        make.height.equalTo(@64);
    }];
}

#pragma mark - 事件

- (void)handleConfirmTapped {
    if (self.onConfirmTapped) self.onConfirmTapped();
}

@end
