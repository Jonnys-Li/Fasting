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

@class FSTMealRecord;

NS_ASSUME_NONNULL_BEGIN

@interface FSTTimelineModuleView : UIControl

/// 用最新一条记录刷新卡片内容；nil 时显示空态。
- (void)updateWithMealRecord:(nullable FSTMealRecord *)record;

/// 点击 ">" 箭头（跳转列表页）。
@property (nonatomic, copy, nullable) dispatch_block_t onChevronTapped;

/// 点击 "+ 增加"（新建记录）。
@property (nonatomic, copy, nullable) dispatch_block_t onAddTapped;

/// 点击食物卡片（查看/编辑记录）。
@property (nonatomic, copy, nullable) void (^onEntryTapped)(FSTMealRecord *record);

@end

NS_ASSUME_NONNULL_END
