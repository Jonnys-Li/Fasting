//
//  FSTMealDiaryViewController.h
//  Fasting
//
//  食物日记列表页 — 按日期分组展示历史餐食记录。
//  - 来源：Timeline 页 / Plan 页的 "Log Meal" 入口 push 进入；或 TabBar 上的直接入口（如有）。
//  - 输入：FSTRecordsDidChangeNotification（餐食记录增删时刷新）+ [sessionManager allMealRecords]。
//  - 输出：点行 push FSTMealDetailViewController 编辑；点 "+" 新增（initWithMealRecord:nil）。
//

#import "FSTBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealDiaryViewController : FSTBaseViewController

@end

NS_ASSUME_NONNULL_END
