//
//  UIButton+FST.h
//  Fasting
//
//  UIButton 样式扩展：胶囊按钮 + 图标按钮 + 导航圆形按钮的工厂方法。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (FST)

// MARK: - 胶囊按钮

/// 实心绿色胶囊按钮：fst_primaryGreen 底色 + 白色加粗文字
+ (instancetype)fst_greenPillButtonWithTitle:(NSString *)title;

/// 白底绿字胶囊按钮：白色背景 + 绿色加粗文字
+ (instancetype)fst_outlineGreenPillButtonWithTitle:(NSString *)title;

/// 黄色胶囊按钮：startButtonYellow 底色 + 白色加粗文字
+ (instancetype)fst_yellowPillButtonWithTitle:(NSString *)title;

// MARK: - 图标按钮

/// 圆形图标按钮：浅灰底色 + SF Symbol 图标
+ (instancetype)fst_iconButtonWithSystemName:(NSString *)name size:(CGFloat)size;

// MARK: - 导航圆形按钮

/// 用 SF Symbol 构建白色圆形导航按钮。tintColor 传 nil 时使用 fst_textPrimary。
+ (instancetype)fst_navCircleButtonWithSystemName:(NSString *)symbolName
                                         diameter:(CGFloat)diameter
                                        tintColor:(nullable UIColor *)tintColor;

/// 用 Asset Catalog 中的图片构建白色圆形导航按钮（原始渲染）。
+ (instancetype)fst_navCircleButtonWithImageNamed:(NSString *)imageName
                                         diameter:(CGFloat)diameter;

/// 用 Asset Catalog 中的图片构建裸图标按钮（无背景、无阴影）。
+ (instancetype)fst_navPlainButtonWithImageNamed:(NSString *)imageName
                                            size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
