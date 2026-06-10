//
//  FSTMealSlotCardView.h
//  Fasting
//
//  "正餐 / 零食"二选一卡：2 个大方块。选中态描边变绿 + 加粗。
//  - 触发场景：MealDetail 页 — 用户分类本餐。
//

#import <UIKit/UIKit.h>
#import "FSTMealTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealSlotCardView : UIView

/// 当前选中的餐次类别（与 FSTMealRecord.mealCategory 同义）。
/// 写入方：上游 VC 用 record.mealCategory 推入初值；用户点方块也会修改此值。
/// ⚠️ 当前没有 onChanged 回调 — VC 在保存时从本属性读取最新值并写回 record 草稿。
@property (nonatomic, assign) FSTMealCategory mealCategory;

@end

NS_ASSUME_NONNULL_END
