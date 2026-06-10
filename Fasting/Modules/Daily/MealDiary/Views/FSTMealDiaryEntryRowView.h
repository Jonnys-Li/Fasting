//
//  FSTMealDiaryEntryRowView.h
//  Fasting
//
//  MealDiary 一行条目：左侧 timeline dot + 顶/底线，右侧 timeLabel + 卡片
//  （食物图标 + category chip + diet chip + feeling 图标）。
//
//  使用方式：[[FSTMealDiaryEntryRowView alloc] init]，set 各属性（category/dietType/tasteLevel/dateText
//  以及 hidesTopLine/hidesBottomLine），赋值即更新显示。
//

#import <UIKit/UIKit.h>
#import "FSTMealTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTMealDiaryEntryRowView : UIView

/// 餐次类别。
@property (nonatomic, assign) FSTMealCategory category;

/// 饮食类型。
@property (nonatomic, assign) FSTDietType dietType;

/// 0=Hard / 1=Ok / 2=Easy 的主观评分。
@property (nonatomic, assign) NSInteger tasteLevel;

/// 时间文案（一般用 FSTFormatRelativeDateTime 格式化）。
@property (nonatomic, copy, nullable) NSString *dateText;

@property (nonatomic, copy, nullable) void (^onCardTapped)(void);
@property (nonatomic, copy, nullable) void (^onEditTapped)(void);

@property (nonatomic, assign) BOOL hidesTopLine;
@property (nonatomic, assign) BOOL hidesBottomLine;

@end

NS_ASSUME_NONNULL_END
