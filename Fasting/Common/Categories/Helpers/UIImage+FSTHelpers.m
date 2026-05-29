//
//  UIImage+FSTHelpers.m
//  Fasting
//

#import "UIImage+FSTHelpers.h"

@implementation UIImage (FSTHelpers)

+ (nullable UIImage *)fst_originalImageNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

+ (nullable UIImage *)fst_templateImageNamed:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+ (nullable UIImage *)fst_ratingImageForLevel:(NSInteger)level {
    NSString *imageName = @"tl_rating_ok";
    if (level <= 0) {
        imageName = @"tl_rating_hard";
    } else if (level >= 2) {
        imageName = @"tl_rating_easy";
    }
    return [self fst_originalImageNamed:imageName];
}

@end
