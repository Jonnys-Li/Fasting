//
//  FSTMealDiaryTopBarView.h
//  Fasting
//
//  食物日记顶部固定栏：返回按钮 + 日期切换胶囊（📅 + 日期 + ▾）+ 筛选按钮（带小红点）。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealDiaryTopBarView : UIView

/// 当前显示的日期（影响中央胶囊的"今天/昨天/月日"文字）
@property (nonatomic, strong) NSDate *selectedDate;

/// 返回按钮被点击
@property (nonatomic, copy, nullable) void (^onBackTapped)(void);

/// 日期胶囊被点击（外部弹出日期选择 sheet）
@property (nonatomic, copy, nullable) void (^onDateChipTapped)(void);

/// 筛选按钮被点击
@property (nonatomic, copy, nullable) void (^onFilterTapped)(void);

@end

NS_ASSUME_NONNULL_END
