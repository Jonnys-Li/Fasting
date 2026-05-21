//
//  FSTMealDiaryEntryRowView.h
//  Fasting
//
//  食物日记中的一条记录行：左侧时间轴圆点+连线，下方卡片含食物图标、
//  正餐/零食胶囊、饮食类型胶囊、口味表情。点击卡片或铅笔进入编辑详情。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FSTMealRecord;

@interface FSTMealDiaryEntryRowView : UIView

/// 用一条记录初始化。
- (instancetype)initWithRecord:(FSTMealRecord *)record NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// 卡片被点击（用 record 作为参数）
@property (nonatomic, copy, nullable) void (^onCardTapped)(FSTMealRecord *record);

/// 铅笔按钮被点击
@property (nonatomic, copy, nullable) void (^onEditTapped)(FSTMealRecord *record);

@end

NS_ASSUME_NONNULL_END
