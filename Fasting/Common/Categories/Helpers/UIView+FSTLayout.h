//
//  UIView+FSTLayout.h
//  Fasting
//
//  UIView 布局/样式扩展：把卡片、彩色高亮盒子等通用容器样式抽成方法。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (FSTLayout)

/// 彩色高亮盒子：设置带 alpha 的填充色与圆角（用于体重弹窗的绿色数字背景等）
/// @param color 基础色
/// @param alpha 透明度（0.0 - 1.0）
/// @param radius 圆角半径
- (void)fst_applyTintedBoxWithColor:(UIColor *)color alpha:(CGFloat)alpha radius:(CGFloat)radius;

/// 绿色描边白卡公共样式（MealDetail 模块卡片通用）
- (void)fst_applyMealCardStyle;

@end

NS_ASSUME_NONNULL_END
