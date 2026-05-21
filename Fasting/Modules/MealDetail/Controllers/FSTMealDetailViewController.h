//
//  FSTMealDetailViewController.h
//  Fasting
//
//  食物日记的填写/编辑页 — 内容卡（照片+描述）+ 属性卡（餐次/饮食类型/口味/时间）。
//  - 两种调用方式：
//    1) initWithMealRecord:nil — "新建"场景：用户在 DailyPlan / MealDiary / TabBar 入口点 "Log Meal"；
//       保存调 [sessionManager addOrUpdateMealRecord:] 插入新记录。
//    2) initWithMealRecord:record — "编辑"场景：用户在 MealDiary 点已有记录后 push 进来；
//       保存同样走 addOrUpdateMealRecord（recordID 已有，按 ID 替换）。
//  - 图片：用户在 ContentCard 点拍照/选图 → [FSTMealImageService saveImage:] 落盘 → 路径写回 record.imagePath。
//

#import "FSTBaseViewController.h"
#import "FSTFastingRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealDetailViewController : FSTBaseViewController

/// 用现有的 record 初始化（编辑场景）；传 nil 表示新建（自动生成 UUID + 默认字段）。
- (instancetype)initWithMealRecord:(nullable FSTMealRecord *)record;

@end

NS_ASSUME_NONNULL_END
