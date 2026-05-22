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

@end
