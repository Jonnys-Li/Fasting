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

NS_ASSUME_NONNULL_BEGIN

@interface FSTTimelineModuleView : UIControl

/// Update card with formatted display data. Pass nil category to show empty state.
- (void)updateWithCategory:(nullable NSString *)category
                  dietType:(nullable NSString *)dietType
                tasteLevel:(NSInteger)tasteLevel
                  dateText:(nullable NSString *)dateText;

@property (nonatomic, copy, nullable) dispatch_block_t onChevronTapped;
@property (nonatomic, copy, nullable) dispatch_block_t onAddTapped;
@property (nonatomic, copy, nullable) dispatch_block_t onEntryTapped;

@end

NS_ASSUME_NONNULL_END
