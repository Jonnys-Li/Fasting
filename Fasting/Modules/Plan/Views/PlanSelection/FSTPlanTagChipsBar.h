//
//  FSTPlanTagChipsBar.h
//  Fasting
//
//  Choose Plan 标题下方的两行标签 chip 条。当前仅做视觉态切换，
//  不真正过滤计划（待 plan list 接入过滤数据源后再接入）。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTPlanTagChipsBar : UIView

/// chip 被点击时回调（identifier 即 chip 标题）。当前外部可忽略。
@property (nonatomic, copy, nullable) void (^onChipTapped)(NSString *identifier);

@end

NS_ASSUME_NONNULL_END
