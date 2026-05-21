//
//  UIButton+FSTStyle.h
//  Fasting
//
//  UIButton 样式扩展：项目中反复出现的胶囊按钮、图标按钮的工厂方法。
//  通过 Category 形式集中样式定义，避免在各 VC 里重复设置背景/字体/圆角。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (FSTStyle)

/// 实心绿色胶囊按钮：fst_primaryGreen 底色 + 白色加粗文字（如"保存"按钮）
/// @param title 按钮文字
+ (instancetype)fst_greenPillButtonWithTitle:(NSString *)title;

/// 白底绿字胶囊按钮：白色背景 + 绿色加粗文字（如"改变计划"按钮）
/// @param title 按钮文字
+ (instancetype)fst_outlineGreenPillButtonWithTitle:(NSString *)title;

/// 黄色胶囊按钮：0xF5C24A 底色 + 白色加粗文字（如食物日记底部"确认"按钮）
/// @param title 按钮文字
+ (instancetype)fst_yellowPillButtonWithTitle:(NSString *)title;

/// 圆形图标按钮：浅灰底色 + SF Symbol 图标
/// @param name SF Symbol 名字（如 "arrow.left"、"line.3.horizontal.decrease"）
/// @param size 按钮直径
+ (instancetype)fst_iconButtonWithSystemName:(NSString *)name size:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
