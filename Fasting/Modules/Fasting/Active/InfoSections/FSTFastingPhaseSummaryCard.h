//
//  FSTFastingPhaseSummaryCard.h
//  Fasting
//
//  "血糖升高 / Lv.1 / ›" 横向阶段总结卡（fork 模式下显示在 headline 下）。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTFastingPhaseSummaryCard : UIControl

/// 默认态：血糖升高 Lv.1
- (void)configureForBloodGlucoseStage;

/// 100% 达成：Autophagy Starts! + 副标说明
- (void)configureForAutophagyState;

@end

NS_ASSUME_NONNULL_END
