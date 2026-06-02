//
//  FSTFastingHistoryViewController.h
//  Fasting
//
//  断食历史列表页 — 倒序展示用户所有 FSTFastingRecord。
//  - 来源：Timeline 页点 "View all fasts" 类入口 push 进来。
//  - 输入：FSTRecordsDidChangeNotification + [sessionManager allRecords]。
//  - 输出：点行 push FSTAddRecordViewController（initWithRecord:）做编辑；左划删除调 deleteFastingRecord:。
//

#import "FSTBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTFastingHistoryViewController : FSTBaseViewController
@end

NS_ASSUME_NONNULL_END
