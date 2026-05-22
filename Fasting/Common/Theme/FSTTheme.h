//
//  FSTTheme.h
//  Fasting
//
//  全 App 主题伞文件 — 集中 import UIColor / UIButton / UILabel / UIView / 基类等扩展，
//  并以 free function 形式暴露字体、间距、时间格式化工具。
//  使用约定：业务文件只 import "FSTTheme.h" 即可拿到全部主题相关 API，无需逐个 import。
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "UIColor+FST.h"
#import "UIButton+FSTStyle.h"
#import "UILabel+FSTStyle.h"
#import "UIView+FSTLayout.h"
#import "FSTBaseViewController.h"
#import "FSTBaseModalViewController.h"

NS_ASSUME_NONNULL_BEGIN

// MARK: - 字体辅助
// 统一字重命名，避免散布 [UIFont systemFontOfSize:weight:]。
// 调用方：所有 UILabel/UIButton 标题字体设置。
UIFont *FSTFontRegular(CGFloat size);    ///< Regular 字重，正文用。
UIFont *FSTFontMedium(CGFloat size);     ///< Medium 字重，副标题/列表项。
UIFont *FSTFontSemibold(CGFloat size);   ///< Semibold 字重，按钮/卡片标题。
UIFont *FSTFontBold(CGFloat size);       ///< Bold 字重，主标题/大数字。
UIFont *FSTFontAvenirBold(CGFloat size);     ///< AvenirNext-Bold，fallback Bold。
UIFont *FSTFontAvenirDemiBold(CGFloat size); ///< AvenirNext-DemiBold，fallback Semibold。

// MARK: - 间距常量
// 设计稿四档间距，业务侧不应再用裸数字。Masonry 约束、padding、margin 都直接引用。
extern const CGFloat FSTSpacingS;   ///< 8  — 紧凑（chip 内边距、密集列表）
extern const CGFloat FSTSpacingM;   ///< 12 — 标准（默认间距）
extern const CGFloat FSTSpacingL;   ///< 16 — 段落（卡片内边距、按钮高度）
extern const CGFloat FSTSpacingXL;  ///< 24 — 大段（区块之间、安全区边距）

// MARK: - 时间格式化
// App 内所有时间显示走这 5 个函数；保证全局一致并便于 localization。

/// "HH:MM:SS" 形如 "16:23:45"。用于圆环中央计时器、剩余时间。
/// 负数会被钳到 0，超 99 小时也能正确显示（不强制 2 位）。
NSString *FSTFormatHHMMSS(NSTimeInterval seconds);

/// "HH:mm" 形如 "18:30"。用于历史卡片的小时显示、Next fast 时间。
NSString *FSTFormatTimeOnly(NSDate *date);

/// 相对日期时间 "Today, 18:30" / "Yesterday, 09:00" / "Apr 30, 10:30"。
/// 用于活跃断食页的 Start / Ends 行，强调与"现在"的相对位置感。
NSString *FSTFormatRelativeDateTime(NSDate *date);

/// 记录详情专用 "Apr 30, 10:30 am" — 不含相对词。
/// 用于历史 / Timeline 列表的密集行（避免相对词在滚动时跳动）。
NSString *FSTFormatRecordDateLine(NSDate *date);

/// 仅相对日 "Today" / "Yesterday" / "Tomorrow" / "May 12"。
/// 用于日历类列表的分组标题（同一天的记录合并到一个 section 头部）。
NSString *FSTFormatRelativeDay(NSDate *date);

NS_ASSUME_NONNULL_END
