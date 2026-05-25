//
//  UIView+FSTLayout.m
//  Fasting
//

#import "UIView+FSTLayout.h"
#import "UIColor+FST.h"

@implementation UIView (FSTLayout)

#pragma mark - 样式

- (void)fst_applyTintedBoxWithColor:(UIColor *)color alpha:(CGFloat)alpha radius:(CGFloat)radius {
    self.backgroundColor = [color colorWithAlphaComponent:alpha];
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

- (void)fst_applyMealCardStyle {
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 20;
    self.layer.borderWidth = 1.2;
    self.layer.borderColor = [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.22].CGColor;
}

+ (instancetype)fst_whiteCardWithRadius:(CGFloat)radius {
    return [self fst_containerWithBackground:[UIColor whiteColor] radius:radius];
}

+ (instancetype)fst_containerWithBackground:(UIColor *)bg radius:(CGFloat)radius {
    UIView *view = [self new];
    view.backgroundColor = bg;
    view.layer.cornerRadius = radius;
    return view;
}

#pragma mark - Masonry 速记

- (void)fst_pinEdgesToSuperview {
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.superview);
    }];
}

- (void)fst_pinEdgesToSuperviewWithInsets:(UIEdgeInsets)insets {
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.superview).insets(insets);
    }];
}

- (void)fst_pinSize:(CGSize)size {
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(size);
    }];
}

- (void)fst_pinHorizontalEdgesToSuperviewWithInset:(CGFloat)inset {
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.superview).offset(inset);
        make.right.equalTo(self.superview).offset(-inset);
    }];
}

- (void)fst_addSubviews:(NSArray<UIView *> *)subviews {
    for (UIView *view in subviews) [self addSubview:view];
}

@end
