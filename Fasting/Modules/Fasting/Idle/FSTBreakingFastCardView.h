//
//  FSTBreakingFastCardView.h
//  Fasting
//
//  Eating Time 页面里位于「Eating Time」标题下方、圆环上方的卡片：
//  白底 + 食物插画 + 「Breaking fast」标题 + 副文案 + 右侧 chevron。
//  整张卡可点击。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTBreakingFastCardView : UIView

/// 副文案（默认「上次进餐 · 点击编辑」）。
@property (nonatomic, copy, nullable) NSString *subtitleText;

/// 点击整张卡的回调。
@property (nonatomic, copy, nullable) void (^onTapped)(void);

@end

NS_ASSUME_NONNULL_END
