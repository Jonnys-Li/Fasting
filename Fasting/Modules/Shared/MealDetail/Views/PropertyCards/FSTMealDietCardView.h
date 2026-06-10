//
//  FSTMealDietCardView.h
//  Fasting
//
//  饮食类型卡：5 行可选（生酮饮食 / 低碳饮食 / 混合式饮食 / 高碳饮食 / 我不确定）。
//  - 触发场景：MealDetail 页 — 用户选择本餐的饮食类型。
//  - 选中视觉：行右侧打勾或描边变色。
//

#import <UIKit/UIKit.h>
#import "FSTMealTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealDietCardView : UIView

/// 当前选中的饮食类型（与 FSTMealRecord.dietType 同义）。
/// 写入方：上游 VC 用 record.dietType 推入初值；用户点行也会修改此值。
/// ⚠️ 当前没有 onChanged 回调 — VC 在保存时从本属性读取最新值并写回 record 草稿。
@property (nonatomic, assign) FSTDietType dietType;

@end

NS_ASSUME_NONNULL_END
