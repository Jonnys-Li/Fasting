//
//  FSTFastingIdleRootView.m
//  Fasting
//

#import "FSTFastingIdleRootView.h"
#import "FSTTheme.h"

@interface FSTFastingIdleRootView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@end

@implementation FSTFastingIdleRootView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor fst_pageBackground];
        [self buildScrollContainer];
    }
    return self;
}

#pragma mark - 视图组装

/// 滚动容器：contentView edges 贴 scrollView 且等宽（竖直滚动）。
/// scrollView 的四边留给 -anchorContentBelowTopBar: 在 topBar install 后补上。
- (void)buildScrollContainer {
    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:self.scrollView];

    self.contentView = [UIView new];
    [self.scrollView addSubview:self.contentView];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
}

#pragma mark - 内容切换

- (void)setBodyView:(UIView *)bodyView {
    if (_bodyView == bodyView) return;
    [_bodyView removeFromSuperview];
    _bodyView = bodyView;
    if (!bodyView) return;

    [self.contentView addSubview:bodyView];
    [bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)anchorContentBelowTopBar:(UIView *)topBar {
    [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topBar.mas_bottom);
        make.left.right.bottom.equalTo(self);
    }];
}

@end
