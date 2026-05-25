//
//  UIView+FSTLayout.h
//  Fasting
//
//  UIView 布局/样式扩展：把卡片、彩色高亮盒子、Masonry 贴边等通用模板抽成方法。
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (FSTLayout)

#pragma mark - 样式

/// 彩色高亮盒子：填充色 + alpha + 圆角（体重弹窗、tip pill 等）。
- (void)fst_applyTintedBoxWithColor:(UIColor *)color alpha:(CGFloat)alpha radius:(CGFloat)radius;

/// 绿色描边白卡（MealDetail 模块通用）。
- (void)fst_applyMealCardStyle;

/// 白底圆角容器：覆盖项目里大量 `self.backgroundColor = white; self.layer.cornerRadius = X;` 模板。
+ (instancetype)fst_whiteCardWithRadius:(CGFloat)radius;

/// 任意背景色 + 圆角容器：fst_whiteCardWithRadius: 的泛化版。
+ (instancetype)fst_containerWithBackground:(UIColor *)bg radius:(CGFloat)radius;

#pragma mark - Masonry 速记

/// 贴满父视图，等价 `make.edges.equalTo(superview)`。
- (void)fst_pinEdgesToSuperview;

/// 贴父视图带 insets，等价 `make.edges.equalTo(superview).insets(insets)`。
- (void)fst_pinEdgesToSuperviewWithInsets:(UIEdgeInsets)insets;

/// 固定尺寸，等价 `make.size.mas_equalTo(size)`。
- (void)fst_pinSize:(CGSize)size;

/// 等宽贴 superview 水平边（左右 inset），不动 top/bottom。
- (void)fst_pinHorizontalEdgesToSuperviewWithInset:(CGFloat)inset;

/// 批量 addSubview。把 `[self addSubview:a]; [self addSubview:b]; ...` 收成一行。
- (void)fst_addSubviews:(NSArray<UIView *> *)subviews;

@end

NS_ASSUME_NONNULL_END
