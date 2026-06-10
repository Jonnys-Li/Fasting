//
//  FSTTimelineModuleView.h
//  Fasting
//
//  Timeline 页的"食物日记"入口卡：
//  顶部 🍴 + "食物日记" + ? 徽标 + > 箭头；
//  中部时间轴圆点 + 时间 + 食物卡片（图标 / 标签 / 表情）；
//  底部 "+ 增加" 按钮。
//

#import <UIKit/UIKit.h>
#import "FSTMealTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTTimelineModuleView : UIControl

/// 用最近一条饮食记录的展示数据刷新卡片。无记录时调 -showEmptyMealState。
- (void)updateWithMealCategory:(FSTMealCategory)category
                      dietType:(FSTDietType)dietType
                    tasteLevel:(NSInteger)tasteLevel
                      dateText:(nullable NSString *)dateText;

/// 无饮食记录时显示空态（原以 nil category 表达，enum 后拆为独立方法）。
- (void)showEmptyMealState;

@property (nonatomic, copy, nullable) dispatch_block_t onChevronTapped;
@property (nonatomic, copy, nullable) dispatch_block_t onAddTapped;
@property (nonatomic, copy, nullable) dispatch_block_t onEntryTapped;

@end

NS_ASSUME_NONNULL_END
