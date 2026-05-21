//
//  FSTAddRecordHeaderView.h
//  Fasting
//
//  添加/编辑记录页顶部的绿色 header：返回 + 垃圾桶按钮 + "总断食时间"标题 + 大数字。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTAddRecordHeaderView : UIView

/// 总断食时长（秒），用于显示"X 分钟"
@property (nonatomic, assign) NSTimeInterval totalSeconds;

/// 返回按钮被点击
@property (nonatomic, copy, nullable) void (^onBackTapped)(void);

/// 垃圾桶按钮被点击
@property (nonatomic, copy, nullable) void (^onTrashTapped)(void);

@end

NS_ASSUME_NONNULL_END
