//
//  UIImage+FSTHelpers.h
//  Fasting
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (FSTHelpers)

/// 返回 AlwaysOriginal 渲染模式的命名图片，避免 tintColor 覆盖源图色彩。
+ (nullable UIImage *)fst_originalImageNamed:(NSString *)name;

/// 返回 AlwaysTemplate 渲染模式的命名图片；与 tintColor 配合实现染色。
+ (nullable UIImage *)fst_templateImageNamed:(NSString *)name;

/// 评分等级（0=Hard / 1=Ok / 2=Easy，越界自动钳制）映射为评分图标（AlwaysOriginal）。
+ (nullable UIImage *)fst_ratingImageForLevel:(NSInteger)level;

@end

NS_ASSUME_NONNULL_END
