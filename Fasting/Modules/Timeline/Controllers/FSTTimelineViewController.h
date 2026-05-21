//
//  FSTTimelineViewController.h
//  Fasting
//
//  时间线 Tab（FSTTabIndexTimeline）的主页 — 综合展示历史断食 + 餐食 + 体重的时间轴卡。
//  - 输入：FSTRecordsDidChangeNotification（任意 records 变化触发刷新）。
//  - 输出：点断食卡 push FSTFastingHistoryViewController 或具体 record 编辑；
//          点餐食卡 push FSTMealDetailViewController；
//          点 LogMeal 入口走 MealDetail 新建。
//

#import "FSTBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTTimelineViewController : FSTBaseViewController

@end

NS_ASSUME_NONNULL_END
