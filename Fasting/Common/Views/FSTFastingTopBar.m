//
//  FSTFastingTopBar.m
//  Fasting
//

#import "FSTFastingTopBar.h"
#import "FSTTheme.h"
#import <Masonry/Masonry.h>

#pragma mark - Layout constants

static const CGFloat kDefaultContentHeight = 56;
static const CGFloat kHorizontalInset      = 20;
static const CGFloat kButtonSpacing        = 12;

@interface FSTFastingTopBar ()
@property (nonatomic, strong) UIView *contentContainer;
@end

@implementation FSTFastingTopBar

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _contentHeight = kDefaultContentHeight;
        self.backgroundColor = [UIColor fst_pageBackground];
        [self setupSubviews];
        [self setupConstraints];
    }
    return self;
}

- (void)setupSubviews {
    self.contentContainer = [UIView new];
    [self addSubview:self.contentContainer];
}

- (void)setupConstraints {
    // contentContainer 需要 VC.view 的 safeAreaLayoutGuide 作锚，
    // 真正约束放在 -installInViewController: 内（拿得到 VC 时）。
}

- (void)setContentHeight:(CGFloat)contentHeight {
    _contentHeight = contentHeight > 0 ? contentHeight : kDefaultContentHeight;
}

- (void)installInViewController:(UIViewController *)viewController {
    NSParameterAssert(viewController);
    [viewController.view addSubview:self];

    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(viewController.view);
        make.bottom.equalTo(viewController.view.mas_safeAreaLayoutGuideTop).offset(self.contentHeight);
    }];

    [self.contentContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewController.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self);
    }];

    [self updateData];
}

- (void)updateData {
    for (UIView *sub in [self.contentContainer.subviews copy]) {
        [sub removeFromSuperview];
    }

    if (self.leftButton) {
        [self.contentContainer addSubview:self.leftButton];
        [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentContainer).offset(kHorizontalInset);
            make.centerY.equalTo(self.contentContainer);
        }];
    }

    UIView *previousRightButton = nil;
    for (UIButton *rightButton in self.rightButtons) {
        [self.contentContainer addSubview:rightButton];
        UIView *anchor = previousRightButton;
        [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            if (anchor) {
                make.right.equalTo(anchor.mas_left).offset(-kButtonSpacing);
            } else {
                make.right.equalTo(self.contentContainer).offset(-kHorizontalInset);
            }
            make.centerY.equalTo(self.contentContainer);
        }];
        previousRightButton = rightButton;
    }

    if (self.centerContent) {
        [self.contentContainer addSubview:self.centerContent];
        [self.centerContent mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentContainer);
        }];
    }
}

@end
