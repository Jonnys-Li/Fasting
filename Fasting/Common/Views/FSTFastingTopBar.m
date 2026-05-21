//
//  FSTFastingTopBar.m
//  Fasting
//

#import "FSTFastingTopBar.h"
#import "UIColor+FST.h"
#import <Masonry/Masonry.h>

static const CGFloat kFSTFastingTopBarDefaultContentHeight = 56;
static const CGFloat kFSTFastingTopBarHorizontalInset      = 20;
static const CGFloat kFSTFastingTopBarButtonSpacing        = 12;

@interface FSTFastingTopBar ()
@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong, nullable) UIButton *leftButton;
@property (nonatomic, strong, nullable) NSArray<UIButton *> *rightButtons;
@property (nonatomic, strong, nullable) UIView *centerContent;
@property (nonatomic, assign) CGFloat contentHeight;
@end

@implementation FSTFastingTopBar

- (instancetype)initWithLeftButton:(nullable UIButton *)leftButton
                      rightButtons:(nullable NSArray<UIButton *> *)rightButtons
                     centerContent:(nullable UIView *)centerContent
                     contentHeight:(CGFloat)contentHeight {
    if ((self = [super initWithFrame:CGRectZero])) {
        _leftButton    = leftButton;
        _rightButtons  = [rightButtons copy];
        _centerContent = centerContent;
        _contentHeight = contentHeight > 0 ? contentHeight : kFSTFastingTopBarDefaultContentHeight;
        self.backgroundColor = [UIColor fst_pageBackground];
    }
    return self;
}

- (void)installInViewController:(UIViewController *)viewController {
    NSParameterAssert(viewController);
    [viewController.view addSubview:self];

    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(viewController.view);
        make.bottom.equalTo(viewController.view.mas_safeAreaLayoutGuideTop).offset(self.contentHeight);
    }];

    [self buildContentContainerInViewController:viewController];
}

#pragma mark - 布局

- (void)buildContentContainerInViewController:(UIViewController *)viewController {
    self.contentContainer = [UIView new];
    [self addSubview:self.contentContainer];

    [self.contentContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewController.view.mas_safeAreaLayoutGuideTop);
        make.left.right.bottom.equalTo(self);
    }];

    if (self.leftButton) {
        [self.contentContainer addSubview:self.leftButton];
        [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentContainer).offset(kFSTFastingTopBarHorizontalInset);
            make.centerY.equalTo(self.contentContainer);
        }];
    }

    UIView *previousRightButton = nil;
    for (UIButton *rightButton in self.rightButtons) {
        [self.contentContainer addSubview:rightButton];
        UIView *anchor = previousRightButton;
        [rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
            if (anchor) {
                make.right.equalTo(anchor.mas_left).offset(-kFSTFastingTopBarButtonSpacing);
            } else {
                make.right.equalTo(self.contentContainer).offset(-kFSTFastingTopBarHorizontalInset);
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
