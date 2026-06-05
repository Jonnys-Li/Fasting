//
//  FSTFastingCardCell.h
//  Fasting
//
//  断食历史列表的容器 Cell：内部嵌一个 FSTFastingRecordCardView，
//  上下各 10pt 内距形成卡片之间的视觉间隔。card view 由 cell 内部持有，
//  外部只通过 -configureWithRecord: 推数据，不直接触达内嵌视图。
//

#import <UIKit/UIKit.h>

@class FSTFastingRecord;

NS_ASSUME_NONNULL_BEGIN

@interface FSTFastingCardCell : UITableViewCell

/// 用一条 record 配置内嵌卡片（转发给 FSTFastingRecordCardView）。
- (void)configureWithRecord:(nullable FSTFastingRecord *)record;

@end

NS_ASSUME_NONNULL_END
