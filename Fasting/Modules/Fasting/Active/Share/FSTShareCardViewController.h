//
//  FSTShareCardViewController.h
//  Fasting
//
//  断食成果分享卡（FSTBaseModalViewController 居中卡片）：展示圆环截图 + 品牌行 + Save / Share。
//  以 initWithRingSnapshot: 传入 ActiveFasting 截下的圆环图；Save / Share 当前为 UI only。
//

#import "FSTBaseModalViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSTShareCardViewController : FSTBaseModalViewController

- (instancetype)initWithRingSnapshot:(UIImage *)snapshot;

@end

NS_ASSUME_NONNULL_END
