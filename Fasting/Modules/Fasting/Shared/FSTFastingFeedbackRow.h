//
//  FSTFastingFeedbackRow.h
//  Fasting
//
//  "Send feedback" 行（白圆角卡：📩 emoji + 文本 + 右箭头），点击触发 onTapped。
//  使用方：Active Fasting 页 (FSTActiveFastingRootView 底部)、Idle Ready 页 (FSTFastingIdleReadyView 底部)。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTFastingFeedbackRow : UIView

@property (nonatomic, copy, nullable) void (^onTapped)(void);

@end

NS_ASSUME_NONNULL_END
