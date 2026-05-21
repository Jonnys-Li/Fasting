//
//  FSTFastingCardCell.h
//  Fasting
//
//  断食历史列表的容器 Cell：内部嵌一个 FSTFastingTimelineCardView，
//  上下各 10pt 内距形成卡片之间的视觉间隔。
//

#import <UIKit/UIKit.h>

@class FSTFastingTimelineCardView;

NS_ASSUME_NONNULL_BEGIN

@interface FSTFastingCardCell : UITableViewCell

/// 内嵌的时间轴卡片。VC 通过它调用 -configureWithRecord: 推数据。
@property (nonatomic, strong, readonly) FSTFastingTimelineCardView *cardView;

@end

NS_ASSUME_NONNULL_END
