//
//  FSTFastingStageCard.h
//  Fasting
//
//  阶段卡（独立可复用）：根据 FSTTipsFastingStage 切换背景色 / icon / 文案。
//  使用方：Active Fasting 页 (FSTFastingTipsSectionView 内嵌)、Idle Ready 页 (FSTFastingIdleReadyView 底部)。
//

#import <UIKit/UIKit.h>
#import "FSTFastingTipsSectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTFastingStageCard : UIView

/// 切换阶段卡的颜色 / 图标 / 文案。可多次调用。
- (void)configureForStage:(FSTTipsFastingStage)stage;

@end

NS_ASSUME_NONNULL_END
