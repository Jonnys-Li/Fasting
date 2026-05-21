//
//  FSTMealTasteCardView.h
//  Fasting
//
//  食物味道卡：3 个 emoji 按钮（糟糕 / 还可以 / 美味）。
//  - 触发场景：MealDetail 页 — 用户评分本餐口感。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealTasteCardView : UIView

/// 口味评分（与 FSTMealRecord.tasteLevel 同义）。
/// 取值：0 = 糟糕 🤢，1 = 还可以 😐，2 = 美味 😋。
/// 写入方：上游 VC 用 record.tasteLevel 推入初值；用户点 emoji 也会修改此值。
/// ⚠️ 当前没有 onChanged 回调 — VC 在保存时从本属性读取最新值并写回 record 草稿。
@property (nonatomic, assign) NSInteger tasteLevel;

@end

NS_ASSUME_NONNULL_END
