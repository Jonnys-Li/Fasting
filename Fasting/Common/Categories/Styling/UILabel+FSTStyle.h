//
//  UILabel+FSTStyle.h
//  Fasting
//
//  UILabel 样式扩展：把项目中常用的标题/副标题/正文样式抽成工厂方法，
//  避免在各 VC 里重复 font/textColor/numberOfLines 等设置。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (FSTStyle)

/// 大标题：28pt Bold + fst_textPrimary（如页面顶部"断食"、"时间轴"）
+ (instancetype)fst_titleLabelWithText:(NSString *)text;

/// 中标题：22pt Bold + fst_textPrimary（如卡片大标题、弹窗标题"体重"）
+ (instancetype)fst_subtitleLabelWithText:(NSString *)text;

/// 正文文本：15pt Regular + fst_textSecondary（多行说明、次要信息）
+ (instancetype)fst_bodyLabelWithText:(NSString *)text;

/// 居中文本：指定 font/color + center alignment。
+ (instancetype)fst_centerLabelWithFont:(UIFont *)font color:(UIColor *)color;

/// 全参数 label（无对齐）。覆盖前 3 个偏特化方法触及不到的"任意 font + 任意 color"场景。
+ (instancetype)fst_labelWithText:(nullable NSString *)text
                             font:(UIFont *)font
                            color:(UIColor *)color;

/// 全参数 label + 文本对齐。
+ (instancetype)fst_labelWithText:(nullable NSString *)text
                             font:(UIFont *)font
                            color:(UIColor *)color
                         alignment:(NSTextAlignment)alignment;

/// 全参数 label + 对齐 + 行数。覆盖多行说明类 label 的样板。
+ (instancetype)fst_labelWithText:(nullable NSString *)text
                             font:(UIFont *)font
                            color:(UIColor *)color
                         alignment:(NSTextAlignment)alignment
                    numberOfLines:(NSInteger)numberOfLines;

@end

NS_ASSUME_NONNULL_END
