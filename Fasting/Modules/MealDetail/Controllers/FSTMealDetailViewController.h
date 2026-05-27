//
//  FSTMealDetailViewController.h
//  Fasting
//
//  食物日记的填写/编辑页 — 内容卡（照片+描述）+ 属性卡（餐次/饮食类型/口味/时间）。
//  - 两种调用方式：
//    1) initWithMealRecord:nil — "新建"场景：用户在 DailyPlan / MealDiary / TabBar 入口点 "Log Meal"；
//       保存调 [[FSTRecordsRepository sharedRepository] addOrUpdateMealRecord:] 插入新记录。
//    2) initWithMealRecord:record — "编辑"场景：用户在 MealDiary 点已有记录后 push 进来；
//       保存同样走 [repository addOrUpdateMealRecord:]（recordID 已有，按 ID 替换）。
//  - 图片：用户在 ContentCard 点拍照/选图 → [FSTMealImageService saveImage:] 落盘 → 路径写回 record.imagePath。
//

#import "FSTBaseViewController.h"
#import "FSTFastingRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealDetailViewController : FSTBaseViewController

/// 用现有的 record 初始化（编辑场景）；传 nil 表示新建（自动生成 UUID + 默认字段）。
/// 默认 returnsToTimelineTab=NO（保存后只 pop 一层，留在当前 tab）。
- (instancetype)initWithMealRecord:(nullable FSTMealRecord *)record;

/// returnsToTimelineTab=YES：保存后切到 Timeline tab + 双 nav pop 到 root。
/// 用于 Plan tab "Log Meal" 入口——把刚保存的 meal 立刻展示在 Timeline 上。
/// 其他入口（MealDiary 编辑、Timeline 自身新建/编辑）应传 NO 让保存后留在原位。
- (instancetype)initWithMealRecord:(nullable FSTMealRecord *)record
              returnsToTimelineTab:(BOOL)returnsToTimelineTab;

/// 当前编辑的 meal 记录（编辑态来自 init 入参，新建态为空 recordID 的占位 record）。
/// 仅供 state restoration 使用——据 recordID 是否非空判断是编辑/新建。
@property (nonatomic, strong, readonly) FSTMealRecord *mealRecord;

/// 保存后是否切回 Timeline tab。state restoration 需要原样还原这条标志。
@property (nonatomic, assign, readonly) BOOL returnsToTimelineTab;

@end

NS_ASSUME_NONNULL_END
