//
//  FSTPlanChipPillView.h
//  Fasting
//
//  「准备断食 / Eating Time」页面里圆环下方的计划胶囊：
//  蜜桃 #F5E0D8 圆角胶囊 + 顶部居中向上的小三角凸点，
//  内容为计划名 + pencil 编辑图标，整体可点击触发 onTapped。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTPlanChipPillView : UIView

/// 展示文本（计划名，如 "14-10"）。
@property (nonatomic, copy, nullable) NSString *planName;

/// 整体点击回调。
@property (nonatomic, copy, nullable) void (^onTapped)(void);

@end

NS_ASSUME_NONNULL_END
