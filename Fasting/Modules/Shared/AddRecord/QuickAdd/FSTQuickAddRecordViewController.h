//
//  FSTQuickAddRecordViewController.h
//  Fasting
//
//  快速补录屏：只填 start / end 两个时间 + duration label，跳过完整 AddRecord 表单。
//  用于吃窗口态「Add new record」，保存走 FSTBuildFastingRecord + finishFastingWithRecord:。
//

#import "FSTBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTQuickAddRecordViewController : FSTBaseViewController

@end

NS_ASSUME_NONNULL_END
