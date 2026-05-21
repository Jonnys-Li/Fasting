//
//  UIButton+FSTNavCircle.h
//  Fasting
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 顶部导航按钮工厂：白色圆形按钮用于 water 等入口，裸图标按钮用于 share/back/remind。
/// diameter 推荐值 36（常规导航）或 40（强调入口，如 ActiveFasting 顶部 water 按钮）；
/// 设计稿之外的尺寸会破坏视觉节奏，请先与 Figma 对齐再用。
@interface UIButton (FSTNavCircle)

/// 用 SF Symbol 构建。tintColor 传 nil 时使用 fst_textPrimary。
/// 适用于"功能态强"的按钮 — 用 SF Symbol 可随系统字号 dynamicType 微调。
+ (instancetype)fst_navCircleButtonWithSystemName:(NSString *)symbolName
                                         diameter:(CGFloat)diameter
                                        tintColor:(nullable UIColor *)tintColor;

/// 用 Asset Catalog 中的图片构建（原始渲染，不做 tint）。
/// 适用于"品牌图标"或多色图标（如 water 滴蓝色） — 保留原图色彩。
+ (instancetype)fst_navCircleButtonWithImageNamed:(NSString *)imageName
                                         diameter:(CGFloat)diameter;

/// 用 Asset Catalog 中的图片构建裸图标按钮（原始渲染、无背景、无阴影）。
/// 用于贴边图标（如 share / back / remind） — 没有圆形背景，靠 hit area 而非视觉块面承载点击。
+ (instancetype)fst_navPlainButtonWithImageNamed:(NSString *)imageName
                                            size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
