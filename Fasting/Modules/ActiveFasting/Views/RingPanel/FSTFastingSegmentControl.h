//
//  FSTFastingSegmentControl.h
//  Fasting
//
//  顶部 body/fork 装饰胶囊：保留两个图标的视觉效果，整体可点击。
//  点击触发 onTapped，由调用方决定行为（当前用作打开计划选择器入口）。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTFastingSegmentControl : UIView

/// 整体被点击时回调。
@property (nonatomic, copy, nullable) dispatch_block_t onTapped;

@end

NS_ASSUME_NONNULL_END
