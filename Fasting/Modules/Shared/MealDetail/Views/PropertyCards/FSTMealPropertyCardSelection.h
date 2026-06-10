//
//  FSTMealPropertyCardSelection.h
//  Fasting
//
//  MealDetail 三张属性卡（Diet / Slot / Taste）共用的「tag 选项选中态」样式。
//  数值此前在三卡间漂移（未选 alpha 0.48/0.45/0.45、边框 alpha 0.32/0.35/0.28、线宽两组），
//  审查确认属意外漂移而非刻意设计，统一收口于此；各卡 item 的形状/布局仍由各卡自管。
//

#import <UIKit/UIKit.h>
#import "FSTTheme.h"

NS_ASSUME_NONNULL_BEGIN

/// 把选项控件切到选中 / 未选中态：
///   选中   = 全亮 + primaryGreen 实边 1.8
///   未选中 = 半透明 0.45 + 32% 透明度细边 1.2
FOUNDATION_STATIC_INLINE void FSTApplyMealCardSelectionStyle(UIControl *control, BOOL selected) {
    control.alpha = selected ? 1.0 : 0.45;
    control.layer.borderColor = (selected ? [UIColor fst_primaryGreen]
                                          : [[UIColor fst_primaryGreen] colorWithAlphaComponent:0.32]).CGColor;
    control.layer.borderWidth = selected ? 1.8 : 1.2;
}

NS_ASSUME_NONNULL_END
