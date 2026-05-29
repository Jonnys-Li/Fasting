//
//  FSTAddRecordBaseCardView.h
//  Fasting
//
//  AddRecord 4 张 InputCard 的共同基类：白底 + FSTRadiusXL 圆角。
//  子类（Feeling / Time / Weight / Note）只在自己的 init 里调 super init 然后 buildSubviews。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FSTAddRecordBaseCardView : UIView
@end

NS_ASSUME_NONNULL_END
