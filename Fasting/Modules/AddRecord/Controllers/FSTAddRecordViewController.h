//
//  FSTAddRecordViewController.h
//  Fasting
//
//  保存断食记录的填写页 — 多张 InputCard（感受、备注、时间、体重）+ 顶部 Header。
//  - 两个 init 对应两种业务场景：
//    1) -initWithStartDate:endDate: — "新建"场景：用户在 Active Fasting 页点 END/COMPLETE 后 push 进来；
//       保存时调 [sessionManager finishFastingWithRecord:]，让历史记录 + 1。
//    2) -initWithRecord:           — "编辑"场景：用户在 FastingHistory 列表点已有记录的"编辑"后 push 进来；
//       保存时调 [[FSTRecordsRepository sharedRepository] updateFastingRecord:]，按 recordID 替换现有记录。
//  - 持有：FSTAddRecordRootView，里面是 4 张卡 + Header；本 VC 把卡的 onChanged 回调聚合写回到本地 record 草稿。
//

#import "FSTBaseViewController.h"
#import "FSTFastingRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTAddRecordViewController : FSTBaseViewController

/// 新建场景。基于刚结束的 startDate/endDate 构造一个空草稿；保存时调 finishFastingWithRecord:。
- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

/// 编辑场景。基于已有 record 构造草稿（recordID 保留）；保存时调 updateFastingRecord:。
- (instancetype)initWithRecord:(FSTFastingRecord *)record;

@end

NS_ASSUME_NONNULL_END
