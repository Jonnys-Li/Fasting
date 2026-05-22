//
//  UIImage+FSTHelpers.h
//  Fasting
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (FSTHelpers)

/// 返回 AlwaysOriginal 渲染模式的命名图片，避免 tintColor 覆盖源图色彩。
+ (nullable UIImage *)fst_originalImageNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
