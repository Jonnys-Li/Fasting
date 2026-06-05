//
//  UILabel+FSTStyle.h
//  Fasting
//
//  UILabel 样式扩展：3 个语义预设（标题/副标题/正文）+ 1 个泛型工厂。
//  对齐 / 行数等展示配置不进工厂参数，由调用方在返回后用 property setter 设置（见 CLAUDE.md R3）。
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

/// 泛型工厂：任意 font + 任意 color，是唯一的通用入口。
/// 对齐 / 行数由调用方在返回后用 .textAlignment / .numberOfLines 自行设置（R3）。
+ (instancetype)fst_labelWithText:(nullable NSString *)text
                             font:(UIFont *)font
                            color:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
