//
//  FSTWeightUnitToggleView.h
//  Fasting
//
//  kg/lb 单位切换胶囊视图：内部小白块滑动 + 字色互换 + 动画。
//

#import <UIKit/UIKit.h>
#import "FSTWeightUnit.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTWeightUnitToggleView : UIView

/// 当前单位
@property (nonatomic, assign) FSTWeightUnit unit;

/// 单位被用户切换时回调
@property (nonatomic, copy, nullable) void (^onUnitChanged)(FSTWeightUnit newUnit);

@end

NS_ASSUME_NONNULL_END
