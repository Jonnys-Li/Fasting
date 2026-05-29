//
//  UIView+FSTLayout.h
//  Fasting
//
//  UIView 布局/样式扩展：把卡片、彩色高亮盒子、圆点、分隔线、批量 addSubview 等通用模板抽成方法。
//  注意：Masonry 本身就是 DSL，不要再包一层贴边/固定尺寸的速记 —— 失去组合能力，可读性也不会提升。
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

/// 描边圆点：cornerRadius=size/2 + clipsToBounds + 可选 borderWidth/borderColor/bgColor。
/// 用于 Timeline / MealDiary / AddRecord 等小圆点节点。尺寸约束由调用方在 Masonry 中设定。
+ (instancetype)fst_circularDotWithSize:(CGFloat)size
                            borderColor:(nullable UIColor *)borderColor
                            borderWidth:(CGFloat)borderWidth
                                bgColor:(nullable UIColor *)bgColor;

/// 分隔线 UIView：仅设 backgroundColor。高度由调用方在 Masonry 约束里设定（1pt / 0.5pt 视场景）。
+ (instancetype)fst_separatorLineWithColor:(UIColor *)color;

#pragma mark - 批量添加

/// 批量 addSubview。把 `[self addSubview:a]; [self addSubview:b]; ...` 收成一行。
- (void)fst_addSubviews:(NSArray<UIView *> *)subviews;

@end

NS_ASSUME_NONNULL_END
