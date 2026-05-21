//
//  FSTPlanRecommendBoardView.h
//  Fasting
//
//  "更有效的周计划"推荐板块：标题 + 横向滚动彩色卡片。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FSTPlan;

@interface FSTPlanRecommendBoardView : UIView

/// 某张推荐卡片被点击时回调，参数为对应的 plan 实例。
@property (nonatomic, copy, nullable) void (^onCardTapped)(FSTPlan *plan);

@end

NS_ASSUME_NONNULL_END
